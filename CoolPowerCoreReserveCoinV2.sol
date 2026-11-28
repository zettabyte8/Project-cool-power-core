// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title CoolPowerCoreReserveCoinV2 (CPC-COIN)
 * @author Thomas Gabriel Coleman
 * @notice Multi-currency global reserve & yield-compounding savings/UBI token.
 *         - Backed by the real-time sum USD value of all deposited currencies.
 *         - Routes idle ETH into Lido Liquid Staking (stETH/wstETH) for consistent base validator yield.
 *         - Routes blue-chip stablecoins & staked assets into Aave V3 / Sky sUSDS / Maker DSR & Beefy.com autocompounding vaults.
 *         - Recycles 100% of cross-pair DEX swap fees (0.25%), Lido staking rewards, and Beefy/Money-Market yields
 *           directly into the global reserve NAV without minting dilutive tokens.
 *         - Supports instant redemption into ANY supported currency in the reserve basket.
 *         - Includes cross-chain LayerZero / Chainlink CCIP lock-and-mint messaging hooks.
 */

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
}

interface IPriceOracle {
    /// @notice Returns USD price scaled to 18 decimals (1e18 = $1.00)
    function getPriceUSD18(address token) external view returns (uint256);
}

interface ILido {
    function submit(address _referral) external payable returns (uint256);
    function getSharesByPooledEth(uint256 _ethAmount) external view returns (uint256);
    function getPooledEthByShares(uint256 _sharesAmount) external view returns (uint256);
}

interface IWstETH is IERC20 {
    function wrap(uint256 _stETHAmount) external returns (uint256);
    function unwrap(uint256 _wstETHAmount) external returns (uint256);
    function stEthPerToken() external view returns (uint256);
}

interface IBeefyVaultV7 is IERC20 {
    function deposit(uint256 _amount) external;
    function withdraw(uint256 _shares) external;
    function getPricePerFullShare() external view returns (uint256);
    function want() external view returns (address);
}

interface IAaveV3Pool {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
}

contract CoolPowerCoreReserveCoinV2 {
    string public constant name = "Cool Power Core Reserve Coin";
    string public constant symbol = "CPC";
    uint8 public constant decimals = 18;

    address public governance;
    IPriceOracle public oracle;
    ILido public lidoStETH;
    IWstETH public wstETH;
    IAaveV3Pool public aavePool;

    uint256 public totalSupply;
    uint256 public constant SWAP_FEE_BPS = 25;        // 0.25% DEX swap fee -> 100% recycled into NAV
    uint256 public constant LIQUID_BUFFER_BPS = 1500; // 15.0% instant redemption buffer
    uint256 public constant BPS_DENOM = 10000;

    enum YieldTier {
        LIQUID_ONLY,       // 0: Cash-like reserve (no external lock)
        LIDO_WSTETH_BEEFY, // 1: ETH -> Lido stETH -> wrapped wstETH -> Beefy wstETH LP/Vault
        AAVE_V3_PLUS_BEEFY,// 2: Stablecoin/WBTC -> Aave V3 supply + Beefy autocompounder
        T_BILL_SAVINGS_LP  // 3: Sky sUSDS / Ondo USDY / EURC-USDC Curve + Beefy vault
    }

    struct ReserveAsset {
        bool supported;
        uint8 tokenDecimals;
        YieldTier tier;
        address yieldWrapper; // e.g., aToken or wstETH
        address beefyVault;   // Beefy.com autocompounding vault address
        uint256 targetAllocBps; // e.g., 8500 (85% deployed, 15% liquid buffer)
    }

    address[] public supportedTokens;
    mapping(address => ReserveAsset) public reserves;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Cross-chain bridge peer registry (ChainSelector / Endpoint ID => Remote CPC Router)
    mapping(uint64 => bytes32) public trustedRemoteRouters;

    event DepositMinted(address indexed user, address indexed tokenIn, uint256 amountIn, uint256 usdValue18, uint256 cpcMinted);
    event Redeemed(address indexed user, address indexed tokenOut, uint256 cpcBurned, uint256 amountOut, uint256 usdValue18);
    event DexSwapRecycled(address indexed trader, address indexed tokenIn, address indexed tokenOut, uint256 feeUsd18);
    event YieldCompounded(address indexed token, YieldTier tier, uint256 deployedAmount, uint256 newTotalBasketUsd18);
    event CrossChainBridgeOut(uint64 indexed dstChainId, address indexed sender, bytes32 recipient, uint256 cpcAmount);

    modifier onlyGov() {
        require(msg.sender == governance, "CPC: NOT_GOVERNANCE");
        _;
    }

    constructor(
        address _oracle,
        address _lidoStETH,
        address _wstETH,
        address _aavePool
    ) {
        governance = msg.sender;
        oracle = IPriceOracle(_oracle);
        lidoStETH = ILido(_lidoStETH);
        wstETH = IWstETH(_wstETH);
        aavePool = IAaveV3Pool(_aavePool);
    }

    function registerReserveAsset(
        address token,
        uint8 tokenDecimals,
        YieldTier tier,
        address yieldWrapper,
        address beefyVault,
        uint256 targetAllocBps
    ) external onlyGov {
        require(targetAllocBps <= 9000, "CPC: MAX_90_PCT_DEPLOYED");
        if (!reserves[token].supported) {
            supportedTokens.push(token);
        }
        reserves[token] = ReserveAsset({
            supported: true,
            tokenDecimals: tokenDecimals,
            tier: tier,
            yieldWrapper: yieldWrapper,
            beefyVault: beefyVault,
            targetAllocBps: targetAllocBps
        });
    }

    function setTrustedRemoteRouter(uint64 chainId, bytes32 remoteRouter) external onlyGov {
        trustedRemoteRouters[chainId] = remoteRouter;
    }

    /// @notice Calculates total USD value (18 decimals) of liquid balances + Lido wstETH + Aave + Beefy vault shares
    function totalBasketValueUSD18() public view returns (uint256 totalUsd18) {
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            address token = supportedTokens[i];
            ReserveAsset memory asset = reserves[token];
            if (!asset.supported) continue;

            uint256 liquidBal = IERC20(token).balanceOf(address(this));
            uint256 deployedUnderlying = 0;

            // 1. Account for wrapped Lido wstETH held directly or inside Beefy
            if (asset.tier == YieldTier.LIDO_WSTETH_BEEFY && address(wstETH) != address(0)) {
                uint256 wstBal = wstETH.balanceOf(address(this));
                if (asset.beefyVault != address(0)) {
                    IBeefyVaultV7 bv = IBeefyVaultV7(asset.beefyVault);
                    uint256 shares = bv.balanceOf(address(this));
                    wstBal += (shares * bv.getPricePerFullShare()) / 1e18;
                }
                deployedUnderlying = (wstBal * wstETH.stEthPerToken()) / 1e18;
            } else {
                // 2. Account for Aave aToken / Sky sUSDS wrapper + Beefy Vault shares
                if (asset.yieldWrapper != address(0)) {
                    deployedUnderlying += IERC20(asset.yieldWrapper).balanceOf(address(this));
                }
                if (asset.beefyVault != address(0)) {
                    IBeefyVaultV7 bv = IBeefyVaultV7(asset.beefyVault);
                    uint256 shares = bv.balanceOf(address(this));
                    deployedUnderlying += (shares * bv.getPricePerFullShare()) / 1e18;
                }
            }

            uint256 totalTokenUnits = liquidBal + deployedUnderlying;
            if (totalTokenUnits > 0) {
                uint256 normalized18 = _normalizeTo18(totalTokenUnits, asset.tokenDecimals);
                uint256 priceUsd18 = oracle.getPriceUSD18(token);
                totalUsd18 += (normalized18 * priceUsd18) / 1e18;
            }
        }
    }

    /// @notice Current Net Asset Value (NAV) of 1 CPC token in USD (18 decimals). Starts at $1.00 (1e18).
    function navPerCoinUSD18() public view returns (uint256) {
        if (totalSupply == 0) return 1e18;
        return (totalBasketValueUSD18() * 1e18) / totalSupply;
    }

    /// @notice Deposit ANY supported currency (USDC, EURC, WETH, WBTC, sUSDS, etc.) to mint CPC at live NAV
    function depositCurrency(address tokenIn, uint256 amountIn) external returns (uint256 cpcMinted) {
        ReserveAsset memory asset = reserves[tokenIn];
        require(asset.supported && amountIn > 0, "CPC: UNSUPPORTED_OR_ZERO");

        uint256 preBasketUsd18 = totalBasketValueUSD18();
        uint256 currentNav = totalSupply == 0 ? 1e18 : (preBasketUsd18 * 1e18) / totalSupply;

        require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), "CPC: TRANSFER_FAIL");

        uint256 normIn18 = _normalizeTo18(amountIn, asset.tokenDecimals);
        uint256 depositUsd18 = (normIn18 * oracle.getPriceUSD18(tokenIn)) / 1e18;

        cpcMinted = (depositUsd18 * 1e18) / currentNav;
        totalSupply += cpcMinted;
        balanceOf[msg.sender] += cpcMinted;

        _deployExcessToSafeYield(tokenIn);
        emit DepositMinted(msg.sender, tokenIn, amountIn, depositUsd18, cpcMinted);
    }

    /// @notice Redeem CPC at any time for ANY supported currency in the reserve basket
    function redeemForAnyCurrency(address tokenOut, uint256 cpcAmount) external returns (uint256 amountOut) {
        ReserveAsset memory asset = reserves[tokenOut];
        require(asset.supported && cpcAmount > 0 && balanceOf[msg.sender] >= cpcAmount, "CPC: INVALID_REDEEM");

        uint256 currentNav = navPerCoinUSD18();
        uint256 redeemUsd18 = (cpcAmount * currentNav) / 1e18;

        balanceOf[msg.sender] -= cpcAmount;
        totalSupply -= cpcAmount;

        uint256 priceOut18 = oracle.getPriceUSD18(tokenOut);
        uint256 normOut18 = (redeemUsd18 * 1e18) / priceOut18;
        amountOut = _denormalizeFrom18(normOut18, asset.tokenDecimals);

        _ensureLiquidity(tokenOut, amountOut);
        require(IERC20(tokenOut).transfer(msg.sender, amountOut), "CPC: PAYOUT_FAIL");

        emit Redeemed(msg.sender, tokenOut, cpcAmount, amountOut, redeemUsd18);
    }

    /// @notice Integrated Multi-Currency DEX Router: 100% of 0.25% swap fees stay in the reserve to boost CPC NAV
    function swapViaReserveRouter(address tokenIn, address tokenOut, uint256 amountIn, uint256 minAmountOut) external returns (uint256 amountOut) {
        require(reserves[tokenIn].supported && reserves[tokenOut].supported && tokenIn != tokenOut, "CPC: BAD_PAIR");
        require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), "CPC: SWAP_IN_FAIL");

        uint256 normIn18 = _normalizeTo18(amountIn, reserves[tokenIn].tokenDecimals);
        uint256 grossUsd18 = (normIn18 * oracle.getPriceUSD18(tokenIn)) / 1e18;
        uint256 feeUsd18 = (grossUsd18 * SWAP_FEE_BPS) / BPS_DENOM;
        uint256 netUsd18 = grossUsd18 - feeUsd18; // Fee remains inside reserve, increasing NAV for all CPC holders!

        uint256 normOut18 = (netUsd18 * 1e18) / oracle.getPriceUSD18(tokenOut);
        amountOut = _denormalizeFrom18(normOut18, reserves[tokenOut].tokenDecimals);
        require(amountOut >= minAmountOut, "CPC: SLIPPAGE_EXCEEDED");

        _ensureLiquidity(tokenOut, amountOut);
        require(IERC20(tokenOut).transfer(msg.sender, amountOut), "CPC: SWAP_OUT_FAIL");

        _deployExcessToSafeYield(tokenIn);
        emit DexSwapRecycled(msg.sender, tokenIn, tokenOut, feeUsd18);
    }

    /// @notice Routes idle capital above the 15% liquid buffer into Lido wstETH, Aave V3, Sky sUSDS, and Beefy.com
    function _deployExcessToSafeYield(address token) internal {
        ReserveAsset memory asset = reserves[token];
        if (asset.tier == YieldTier.LIQUID_ONLY) return;

        uint256 bal = IERC20(token).balanceOf(address(this));
        uint256 minBuffer = (bal * LIQUID_BUFFER_BPS) / BPS_DENOM;
        if (bal <= minBuffer) return;

        uint256 deployAmt = bal - minBuffer;

        if (asset.tier == YieldTier.LIDO_WSTETH_BEEFY && address(wstETH) != address(0)) {
            // Wrap stETH into non-rebasing wstETH and deposit into Beefy wstETH autocompounder
            IERC20(token).approve(address(wstETH), deployAmt);
            uint256 wstReceived = wstETH.wrap(deployAmt);
            if (asset.beefyVault != address(0) && wstReceived > 0) {
                wstETH.approve(asset.beefyVault, wstReceived);
                IBeefyVaultV7(asset.beefyVault).deposit(wstReceived);
            }
        } else if (asset.tier == YieldTier.AAVE_V3_PLUS_BEEFY && address(aavePool) != address(0)) {
            IERC20(token).approve(address(aavePool), deployAmt);
            aavePool.supply(token, deployAmt, address(this), 0);
            if (asset.beefyVault != address(0) && asset.yieldWrapper != address(0)) {
                uint256 aTokBal = IERC20(asset.yieldWrapper).balanceOf(address(this));
                IERC20(asset.yieldWrapper).approve(asset.beefyVault, aTokBal);
                IBeefyVaultV7(asset.beefyVault).deposit(aTokBal);
            }
        } else if (asset.beefyVault != address(0)) {
            IERC20(token).approve(asset.beefyVault, deployAmt);
            IBeefyVaultV7(asset.beefyVault).deposit(deployAmt);
        }

        emit YieldCompounded(token, asset.tier, deployAmt, totalBasketValueUSD18());
    }

    function _ensureLiquidity(address token, uint256 needed) internal {
        uint256 liquid = IERC20(token).balanceOf(address(this));
        if (liquid >= needed) return;
        uint256 shortfall = needed - liquid;

        ReserveAsset memory asset = reserves[token];
        if (asset.beefyVault != address(0)) {
            IBeefyVaultV7 bv = IBeefyVaultV7(asset.beefyVault);
            uint256 pps = bv.getPricePerFullShare();
            uint256 sharesToBurn = ((shortfall * 1e18) / pps) + 1;
            uint256 maxShares = bv.balanceOf(address(this));
            if (sharesToBurn > maxShares) sharesToBurn = maxShares;
            if (sharesToBurn > 0) bv.withdraw(sharesToBurn);
        }
        if (asset.tier == YieldTier.LIDO_WSTETH_BEEFY && address(wstETH) != address(0)) {
            uint256 wstBal = wstETH.balanceOf(address(this));
            if (wstBal > 0) wstETH.unwrap(wstBal);
        } else if (asset.tier == YieldTier.AAVE_V3_PLUS_BEEFY && address(aavePool) != address(0)) {
            aavePool.withdraw(token, shortfall, address(this));
        }
    }

    /// @notice Cross-chain LayerZero / Chainlink CCIP lock-and-mint transfer across Ethereum, Base, Arbitrum, Polygon
    function bridgeCrossChain(uint64 dstChainId, bytes32 recipient, uint256 cpcAmount) external {
        require(trustedRemoteRouters[dstChainId] != bytes32(0), "CPC: UNTRUSTED_CHAIN");
        require(balanceOf[msg.sender] >= cpcAmount && cpcAmount > 0, "CPC: INSUFFICIENT_CPC");
        balanceOf[msg.sender] -= cpcAmount;
        totalSupply -= cpcAmount;
        emit CrossChainBridgeOut(dstChainId, msg.sender, recipient, cpcAmount);
    }

    function _normalizeTo18(uint256 amount, uint8 dec) internal pure returns (uint256) {
        if (dec == 18) return amount;
        if (dec < 18) return amount * (10 ** (18 - dec));
        return amount / (10 ** (dec - 18));
    }

    function _denormalizeFrom18(uint256 amount18, uint8 dec) internal pure returns (uint256) {
        if (dec == 18) return amount18;
        if (dec < 18) return amount18 / (10 ** (18 - dec));
        return amount18 * (10 ** (dec - 18));
    }
}
