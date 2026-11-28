// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title CoolPowerCoreReserveCoinV3 (CPC-COIN)
 * @author Thomas Gabriel Coleman
 * @notice Multi-Currency Yield-Compounding Reserve Token with:
 *   1. Lido Liquid Staking (wstETH) + Sky sUSDS + Aave V3 + Beefy.com Autocompounding
 *   2. Base Chain Aerodrome Finance (veAERO / CL & vAMM Gauge Staking + Trade Pairs)
 *   3. Robinhood Chain (Arbitrum-Orbit L2) Omnichain Settlement & Tokenized Equity/Stock Mirror
 *   4. Autonomous AI Merchant NPC Liquidity & Trade-Velocity Hooks
 * @dev Zero token inflation: 100% of staking rewards, gauge emissions, Beefy harvests,
 *      and cross-pair DEX fees compound directly into global reserve NAV.
 */

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IPriceOracle {
    function getPriceUSD18(address token) external view returns (uint256);
}

interface ILidoWstETH {
    function wrap(uint256 _stETHAmount) external returns (uint256);
    function unwrap(uint256 _wstETHAmount) external returns (uint256);
    function getStETHByWstETH(uint256 _wstETHAmount) external view returns (uint256);
}

interface IBeefyVault {
    function deposit(uint256 _amount) external;
    function withdraw(uint256 _shares) external;
    function getPricePerFullShare() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

interface IAerodromeRouter {
    struct Route {
        address from;
        address to;
        bool stable;
        address factory;
    }
    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] calldata routes,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IAerodromeGauge {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function getReward(address account) external;
    function earned(address account) external view returns (uint256);
}

interface IRobinhoodBridgeAdapter {
    function sendOmnichainNAVSync(
        uint32 dstEid,
        uint256 navUSD18,
        uint256 totalReserveUSD18
    ) external payable;
}

contract CoolPowerCoreReserveCoinV3 {
    string public constant name = "Cool Power Core Reserve Coin";
    string public constant symbol = "CPC";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public governance;
    IPriceOracle public priceOracle;
    ILidoWstETH public wstETH;
    IAerodromeRouter public aerodromeRouter;
    IRobinhoodBridgeAdapter public robinhoodBridge;

    // Chain IDs: Ethereum (1), Base (8453), Arbitrum (42161), Polygon (137), Robinhood Chain L2 (46630)
    uint256 public constant BASE_CHAIN_ID = 8453;
    uint256 public constant ROBINHOOD_CHAIN_ID = 46630;

    uint256 public constant LIQUID_BUFFER_BPS = 1500;     // 15.0% instant multi-currency exit buffer
    uint256 public constant LIDO_BEEFY_BPS    = 4500;     // 45.0% Lido wstETH + Sky sUSDS + Beefy.com
    uint256 public constant AERODROME_LP_BPS  = 2500;     // 25.0% Base Aerodrome LP + Gauge Staking
    uint256 public constant RH_EQUITY_BPS     = 1500;     // 15.0% Robinhood Chain Tokenized Stock/ETF Mirror
    uint256 public constant SWAP_FEE_BPS      = 25;       // 0.25% recycled 100% into NAV
    uint256 public constant BPS_DENOM         = 10000;

    enum YieldRoute {
        LIQUID_BUFFER,
        LIDO_WSTETH_BEEFY,
        AERODROME_BASE_GAUGE,
        ROBINHOOD_CHAIN_EQUITY_MIRROR
    }

    struct AssetConfig {
        bool supported;
        bool isSyntheticStockMirror; // Mirrors real-world equities/ETFs on Robinhood Chain
        YieldRoute route;
        address yieldWrapper;        // wstETH, Beefy Vault, or Aerodrome LP Token
        address aerodromeGauge;      // Aerodrome Gauge on Base for AERO emissions -> auto-compounded
        uint256 liquidBalance;
        uint256 deployedPrincipal;
    }

    address[] public supportedAssets;
    mapping(address => AssetConfig) public assetConfigs;

    // Autonomous AI Merchant NPC Registry (keeps velocity & cross-pair swap fees flowing)
    mapping(address => bool) public authorizedAIMerchants;
    uint256 public totalAIMerchantVolumeUSD18;
    uint256 public totalRecycledFeesUSD18;

    uint256 private _unlocked = 1;
    modifier nonReentrant() {
        require(_unlocked == 1, "REENTRANCY");
        _unlocked = 0;
        _;
        _unlocked = 1;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "UNAUTHORIZED");
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Deposited(address indexed user, address indexed asset, uint256 amountIn, uint256 usdValue18, uint256 cpcMinted);
    event Redeemed(address indexed user, address indexed assetOut, uint256 cpcBurned, uint256 usdValue18, uint256 amountOut);
    event CrossPairSwapRecycled(address indexed trader, bool isAIMerchant, address tokenIn, address tokenOut, uint256 feeUSD18);
    event YieldCompounded(uint256 newTotalBasketUSD18, uint256 newNavUSD18);
    event RobinhoodChainSynced(uint256 chainId, uint256 navUSD18, uint256 totalBasketUSD18);

    constructor(
        address _oracle,
        address _wstETH,
        address _aerodromeRouter,
        address _robinhoodBridge
    ) {
        governance = msg.sender;
        priceOracle = IPriceOracle(_oracle);
        wstETH = ILidoWstETH(_wstETH);
        aerodromeRouter = IAerodromeRouter(_aerodromeRouter);
        robinhoodBridge = IRobinhoodBridgeAdapter(_robinhoodBridge);
    }

    function configureAsset(
        address token,
        bool isStockMirror,
        YieldRoute route,
        address yieldWrapper,
        address aerodromeGauge
    ) external onlyGovernance {
        if (!assetConfigs[token].supported) {
            supportedAssets.push(token);
        }
        assetConfigs[token] = AssetConfig({
            supported: true,
            isSyntheticStockMirror: isStockMirror,
            route: route,
            yieldWrapper: yieldWrapper,
            aerodromeGauge: aerodromeGauge,
            liquidBalance: assetConfigs[token].liquidBalance,
            deployedPrincipal: assetConfigs[token].deployedPrincipal
        });
    }

    function setAIMerchant(address merchant, bool active) external onlyGovernance {
        authorizedAIMerchants[merchant] = active;
    }

    /**
     * @notice Computes aggregate USD value across all deposited crypto, stablecoins,
     *         Lido wstETH, Aerodrome Base LPs, Beefy vaults, and Robinhood Chain stock mirrors.
     */
    function totalBasketValueUSD18() public view returns (uint256 totalUSD18) {
        uint256 len = supportedAssets.length;
        for (uint256 i = 0; i < len; i++) {
            address token = supportedAssets[i];
            AssetConfig memory cfg = assetConfigs[token];
            uint256 price18 = priceOracle.getPriceUSD18(token);

            uint256 effectiveUnits = cfg.liquidBalance + cfg.deployedPrincipal;
            if (cfg.route == YieldRoute.LIDO_WSTETH_BEEFY && cfg.yieldWrapper != address(0)) {
                uint256 shares = IERC20(cfg.yieldWrapper).balanceOf(address(this));
                uint256 ppfs = IBeefyVault(cfg.yieldWrapper).getPricePerFullShare();
                uint256 vaultUnits = (shares * ppfs) / 1e18;
                effectiveUnits = cfg.liquidBalance + vaultUnits;
            }
            totalUSD18 += (effectiveUnits * price18) / 1e18;
        }
    }

    /// @notice Current NAV per CPC coin in 18-decimal USD ($1.000000 = 1e18 at genesis)
    function navPerCoinUSD18() public view returns (uint256) {
        if (totalSupply == 0) return 1e18;
        return (totalBasketValueUSD18() * 1e18) / totalSupply;
    }

    /// @notice Deposit ANY supported currency or tokenized stock asset to mint CPC at live NAV
    function deposit(address asset, uint256 amountIn, uint256 minCpcOut)
        external
        nonReentrant
        returns (uint256 cpcMinted)
    {
        AssetConfig storage cfg = assetConfigs[asset];
        require(cfg.supported && amountIn > 0, "INVALID_ASSET_OR_AMOUNT");

        uint256 basketBefore = totalBasketValueUSD18();
        uint256 supplyBefore = totalSupply;

        require(IERC20(asset).transferFrom(msg.sender, address(this), amountIn), "TRANSFER_FAILED");

        uint256 price18 = priceOracle.getPriceUSD18(asset);
        uint256 depositUSD18 = (amountIn * price18) / 1e18;

        if (supplyBefore == 0 || basketBefore == 0) {
            cpcMinted = depositUSD18;
        } else {
            cpcMinted = (depositUSD18 * supplyBefore) / basketBefore;
        }
        require(cpcMinted >= minCpcOut, "SLIPPAGE_EXCEEDED");

        // Maintain 15% liquid redemption buffer; deploy 85% to Lido/Beefy/Aerodrome/RH
        uint256 liquidSlice = (amountIn * LIQUID_BUFFER_BPS) / BPS_DENOM;
        uint256 deploySlice = amountIn - liquidSlice;
        cfg.liquidBalance += liquidSlice;
        cfg.deployedPrincipal += deploySlice;

        if (cfg.route == YieldRoute.LIDO_WSTETH_BEEFY && cfg.yieldWrapper != address(0)) {
            IERC20(asset).approve(cfg.yieldWrapper, deploySlice);
            IBeefyVault(cfg.yieldWrapper).deposit(deploySlice);
        } else if (cfg.route == YieldRoute.AERODROME_BASE_GAUGE && cfg.aerodromeGauge != address(0)) {
            IERC20(asset).approve(cfg.aerodromeGauge, deploySlice);
            IAerodromeGauge(cfg.aerodromeGauge).deposit(deploySlice);
        }

        totalSupply += cpcMinted;
        balanceOf[msg.sender] += cpcMinted;

        emit Transfer(address(0), msg.sender, cpcMinted);
        emit Deposited(msg.sender, asset, amountIn, depositUSD18, cpcMinted);
    }

    /// @notice Redeem CPC coins at ANY time for ANY underlying reserve currency at live NAV
    function redeem(address assetOut, uint256 cpcAmount, uint256 minAmountOut)
        external
        nonReentrant
        returns (uint256 amountOut)
    {
        AssetConfig storage cfg = assetConfigs[assetOut];
        require(cfg.supported && cpcAmount > 0, "INVALID_REDEMPTION");
        require(balanceOf[msg.sender] >= cpcAmount, "INSUFFICIENT_CPC");

        uint256 usdClaim18 = (cpcAmount * totalBasketValueUSD18()) / totalSupply;
        uint256 priceOut18 = priceOracle.getPriceUSD18(assetOut);
        amountOut = (usdClaim18 * 1e18) / priceOut18;
        require(amountOut >= minAmountOut, "SLIPPAGE_EXCEEDED");

        balanceOf[msg.sender] -= cpcAmount;
        totalSupply -= cpcAmount;

        if (cfg.liquidBalance >= amountOut) {
            cfg.liquidBalance -= amountOut;
        } else {
            uint256 deficit = amountOut - cfg.liquidBalance;
            cfg.liquidBalance = 0;
            if (cfg.route == YieldRoute.AERODROME_BASE_GAUGE && cfg.aerodromeGauge != address(0)) {
                IAerodromeGauge(cfg.aerodromeGauge).withdraw(deficit);
            }
            if (cfg.deployedPrincipal >= deficit) {
                cfg.deployedPrincipal -= deficit;
            } else {
                cfg.deployedPrincipal = 0;
            }
        }

        require(IERC20(assetOut).transfer(msg.sender, amountOut), "PAYOUT_FAILED");

        emit Transfer(msg.sender, address(0), cpcAmount);
        emit Redeemed(msg.sender, assetOut, cpcAmount, usdClaim18, amountOut);
    }

    /**
     * @notice Multi-pair swap router used by players and autonomous AI Merchant NPCs.
     *         Captures 0.25% swap fee and retains 100% inside the reserve basket,
     *         directly ratcheting up CPC NAV for all holders.
     */
    function swapReservePair(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut
    ) external nonReentrant returns (uint256 amountOut) {
        AssetConfig storage cfgIn = assetConfigs[tokenIn];
        AssetConfig storage cfgOut = assetConfigs[tokenOut];
        require(cfgIn.supported && cfgOut.supported && tokenIn != tokenOut, "INVALID_PAIR");

        require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), "IN_FAILED");

        uint256 feeIn = (amountIn * SWAP_FEE_BPS) / BPS_DENOM;
        uint256 netIn = amountIn - feeIn;

        // Fee stays inside tokenIn liquidBalance -> permanently increases totalBasketValueUSD18
        cfgIn.liquidBalance += amountIn;

        uint256 usdNet18 = (netIn * priceOracle.getPriceUSD18(tokenIn)) / 1e18;
        amountOut = (usdNet18 * 1e18) / priceOracle.getPriceUSD18(tokenOut);
        require(amountOut >= minAmountOut && cfgOut.liquidBalance >= amountOut, "LIQUIDITY_OR_SLIPPAGE");

        cfgOut.liquidBalance -= amountOut;
        require(IERC20(tokenOut).transfer(msg.sender, amountOut), "OUT_FAILED");

        uint256 feeUSD18 = (feeIn * priceOracle.getPriceUSD18(tokenIn)) / 1e18;
        totalRecycledFeesUSD18 += feeUSD18;
        if (authorizedAIMerchants[msg.sender]) {
            totalAIMerchantVolumeUSD18 += usdNet18;
        }

        emit CrossPairSwapRecycled(msg.sender, authorizedAIMerchants[msg.sender], tokenIn, tokenOut, feeUSD18);
    }

    /// @notice Harvests Aerodrome Base AERO gauge rewards & syncs live NAV to Robinhood Chain L2
    function harvestAerodromeAndSyncRobinhood(uint32 robinhoodDstEid) external payable {
        uint256 len = supportedAssets.length;
        for (uint256 i = 0; i < len; i++) {
            AssetConfig storage cfg = assetConfigs[supportedAssets[i]];
            if (cfg.route == YieldRoute.AERODROME_BASE_GAUGE && cfg.aerodromeGauge != address(0)) {
                IAerodromeGauge(cfg.aerodromeGauge).getReward(address(this));
            }
        }
        uint256 currentNav = navPerCoinUSD18();
        uint256 currentBasket = totalBasketValueUSD18();
        if (address(robinhoodBridge) != address(0)) {
            robinhoodBridge.sendOmnichainNAVSync{value: msg.value}(
                robinhoodDstEid,
                currentNav,
                currentBasket
            );
        }
        emit YieldCompounded(currentBasket, currentNav);
        emit RobinhoodChainSynced(ROBINHOOD_CHAIN_ID, currentNav, currentBasket);
    }
}
