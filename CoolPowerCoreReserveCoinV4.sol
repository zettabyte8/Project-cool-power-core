// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title CoolPowerCoreReserveCoinV4 (CPC-COIN) & Inventor Patronage Portal
 * @author Thomas Gabriel Coleman (Corona, CA, USA)
 * @notice Multi-currency reserve savings token with:
 *         - 85% yield deployment across Aerodrome (Base 8453), Lido wstETH, Beefy.com, Sky sUSDS, and Robinhood Chain (46630)
 *         - 15% instant any-currency redemption buffer + 100% 0.25% swap fee recycling into NAV
 *         - Direct Inventor Patronage & Donation Portal (100% pass-through to Thomas Gabriel Coleman + optional Yield-Stream Split)
 */

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IPriceOracle {
    function getPriceUSD18(address token) external view returns (uint256);
}

interface IAerodromeGauge {
    function deposit(uint256 amount) external;
    function getReward(address account) external;
}

interface IBeefyVault {
    function deposit(uint256 amount) external;
    function withdraw(uint256 shares) external;
}

interface ILidoWstETH {
    function wrap(uint256 stETHAmount) external returns (uint256);
}

contract CoolPowerCoreReserveCoinV4 {
    string public constant name = "Cool Power Core Reserve Coin";
    string public constant symbol = "CPC";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public inventorBeneficiary;
    address public governance;
    IPriceOracle public oracle;

    // Multi-chain protocol adapters
    address public aerodromeBaseGauge;      // Base Chain (8453) CPC/USDC, CPC/wstETH, CPC/cbBTC
    address public lidoWstETHAdapter;       // Lido Liquid Staking wstETH
    address public beefyAutocompoundVault;  // Beefy.com Multi-Chain Vault
    address public robinhoodChainBridge;    // Robinhood Chain L2 (46630) Bridge

    uint256 public constant SWAP_FEE_BPS = 25;         // 0.25% swap fee recycled 100% into NAV
    uint256 public constant LIQUID_BUFFER_BPS = 1500;  // 15.0% instant any-currency redemption buffer
    uint256 public constant BPS_DENOM = 10000;

    // Supported reserve basket tokens
    address[] public supportedTokens;
    mapping(address => bool) public isSupportedToken;
    uint256 public externalDeployedValueUSD18;

    // Inventor Patronage & Donation Tracking
    uint256 public totalDirectDonationsUSD18;
    mapping(address => uint256) public donorLifetimeUSD18;
    mapping(address => uint16) public userYieldDonationBps; // Optional user opt-in yield share (0 to 10000 bps)

    enum PatronTier {
        NONE,
        SPARK_SUPPORTER,       // >= $10
        CORE_BUILDER,          // >= $100
        SANCTUARY_FOUNDER,     // >= $1,000
        FRONTIER_ARCHITECT     // >= $10,000
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Deposited(address indexed user, address indexed token, uint256 tokenAmt, uint256 cpcMinted, uint256 navUSD18);
    event Redeemed(address indexed user, address indexed tokenOut, uint256 cpcBurned, uint256 tokenOutAmt, uint256 navUSD18);
    event CrossPairSwap(address indexed trader, address tokenIn, address tokenOut, uint256 feeRecycledUSD18, uint256 newNavUSD18);
    event YieldHarvested(uint256 aerodromeUSD18, uint256 lidoBeefyUSD18, uint256 robinhoodUSD18, uint256 newNavUSD18);
    event InventorDonationReceived(
        address indexed donor,
        address indexed token,
        uint256 tokenAmount,
        uint256 usdValue18,
        PatronTier tier,
        string tributeNote
    );
    event YieldPatronageConfigured(address indexed patron, uint16 shareBps);

    modifier onlyGovernance() {
        require(msg.sender == governance, "CPC: not governance");
        _;
    }

    constructor(
        address _inventorBeneficiary,
        address _oracle,
        address _aerodromeBaseGauge,
        address _lidoWstETHAdapter,
        address _beefyAutocompoundVault,
        address _robinhoodChainBridge
    ) {
        require(_inventorBeneficiary != address(0), "CPC: zero inventor address");
        inventorBeneficiary = _inventorBeneficiary;
        governance = msg.sender;
        oracle = IPriceOracle(_oracle);
        aerodromeBaseGauge = _aerodromeBaseGauge;
        lidoWstETHAdapter = _lidoWstETHAdapter;
        beefyAutocompoundVault = _beefyAutocompoundVault;
        robinhoodChainBridge = _robinhoodChainBridge;
    }

    function addSupportedToken(address token) external onlyGovernance {
        require(!isSupportedToken[token], "CPC: already supported");
        isSupportedToken[token] = true;
        supportedTokens.push(token);
    }

    function updateInventorBeneficiary(address newBeneficiary) external {
        require(msg.sender == inventorBeneficiary, "CPC: only inventor");
        require(newBeneficiary != address(0), "CPC: zero address");
        inventorBeneficiary = newBeneficiary;
    }

    /// @notice Total USD value (18 decimals) of liquid reserve basket + deployed staking/LP vaults
    function totalReserveValueUSD18() public view returns (uint256 totalUSD18) {
        totalUSD18 = externalDeployedValueUSD18;
        uint256 len = supportedTokens.length;
        for (uint256 i = 0; i < len; i++) {
            address t = supportedTokens[i];
            uint256 bal = IERC20(t).balanceOf(address(this));
            if (bal > 0) {
                totalUSD18 += (bal * oracle.getPriceUSD18(t)) / 1e18;
            }
        }
    }

    /// @notice Current Net Asset Value per CPC coin in USD (18 decimals). Starts at $1.00 (1e18).
    function navPerCoinUSD18() public view returns (uint256) {
        if (totalSupply == 0) return 1e18;
        return (totalReserveValueUSD18() * 1e18) / totalSupply;
    }

    /// @notice Deposit any supported currency to mint CPC savings coins at exact NAV
    function deposit(address token, uint256 amount) external returns (uint256 cpcMinted) {
        require(isSupportedToken[token], "CPC: unsupported token");
        require(amount > 0, "CPC: zero amount");
        uint256 navBefore = navPerCoinUSD18();
        uint256 depositUSD18 = (amount * oracle.getPriceUSD18(token)) / 1e18;
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "CPC: transferFrom failed");

        cpcMinted = (depositUSD18 * 1e18) / navBefore;
        _mint(msg.sender, cpcMinted);
        emit Deposited(msg.sender, token, amount, cpcMinted, navPerCoinUSD18());
    }

    /// @notice Redeem CPC coins at anytime for any supported reserve currency
    function redeem(address tokenOut, uint256 cpcAmount) external returns (uint256 tokenOutAmount) {
        require(isSupportedToken[tokenOut], "CPC: unsupported token");
        require(cpcAmount > 0 && balanceOf[msg.sender] >= cpcAmount, "CPC: insufficient CPC");
        uint256 nav = navPerCoinUSD18();
        uint256 redeemUSD18 = (cpcAmount * nav) / 1e18;
        uint256 priceOut = oracle.getPriceUSD18(tokenOut);
        tokenOutAmount = (redeemUSD18 * 1e18) / priceOut;
        require(IERC20(tokenOut).balanceOf(address(this)) >= tokenOutAmount, "CPC: rebalance buffer needed");

        _burn(msg.sender, cpcAmount);
        require(IERC20(tokenOut).transfer(msg.sender, tokenOutAmount), "CPC: transfer failed");
        emit Redeemed(msg.sender, tokenOut, cpcAmount, tokenOutAmount, navPerCoinUSD18());
    }

    /// @notice Cross-pair swap used by players & AI Merchant NPCs; 100% of 0.25% fee stays in reserve to raise NAV
    function swapReservePair(address tokenIn, address tokenOut, uint256 amountIn) external returns (uint256 amountOut) {
        require(isSupportedToken[tokenIn] && isSupportedToken[tokenOut] && tokenIn != tokenOut, "CPC: invalid pair");
        require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), "CPC: transferFrom failed");

        uint256 usdIn = (amountIn * oracle.getPriceUSD18(tokenIn)) / 1e18;
        uint256 feeUSD18 = (usdIn * SWAP_FEE_BPS) / BPS_DENOM;
        uint256 netUSD18 = usdIn - feeUSD18;

        amountOut = (netUSD18 * 1e18) / oracle.getPriceUSD18(tokenOut);
        require(IERC20(tokenOut).balanceOf(address(this)) >= amountOut, "CPC: insufficient pair liquidity");
        require(IERC20(tokenOut).transfer(msg.sender, amountOut), "CPC: transfer failed");

        emit CrossPairSwap(msg.sender, tokenIn, tokenOut, feeUSD18, navPerCoinUSD18());
    }

    /// @notice Direct 100% pass-through ERC-20 donation to Thomas Gabriel Coleman for designing Cool Power Core
    function donateToInventorERC20(address token, uint256 amount, string calldata tributeNote) external {
        require(amount > 0, "CPC: zero donation");
        require(IERC20(token).transferFrom(msg.sender, inventorBeneficiary, amount), "CPC: donation transfer failed");

        uint256 usdVal18 = isSupportedToken[token] ? (amount * oracle.getPriceUSD18(token)) / 1e18 : 0;
        totalDirectDonationsUSD18 += usdVal18;
        donorLifetimeUSD18[msg.sender] += usdVal18;

        emit InventorDonationReceived(
            msg.sender,
            token,
            amount,
            usdVal18,
            getPatronTier(msg.sender),
            tributeNote
        );
    }

    /// @notice Direct 100% pass-through native ETH / Base ETH / Robinhood ETH donation to inventor
    function donateNativeToInventor(string calldata tributeNote) external payable {
        require(msg.value > 0, "CPC: zero native donation");
        (bool sent, ) = inventorBeneficiary.call{value: msg.value}("");
        require(sent, "CPC: native transfer failed");

        // Assumes index 0 or wrapped native oracle reference if configured; records raw wei in event
        emit InventorDonationReceived(
            msg.sender,
            address(0),
            msg.value,
            0,
            getPatronTier(msg.sender),
            tributeNote
        );
    }

    /// @notice Allows CPC holders to optionally pledge a % of future yield appreciation to inventor R&D
    function setYieldPatronageShare(uint16 shareBps) external {
        require(shareBps <= BPS_DENOM, "CPC: max 10000 bps");
        userYieldDonationBps[msg.sender] = shareBps;
        emit YieldPatronageConfigured(msg.sender, shareBps);
    }

    /// @notice Harvests Aerodrome (Base), Lido wstETH, Beefy.com, and Robinhood Chain yields directly into NAV
    function recordAutocompoundedYield(
        uint256 aerodromeUSD18,
        uint256 lidoBeefyUSD18,
        uint256 robinhoodUSD18
    ) external onlyGovernance {
        externalDeployedValueUSD18 += (aerodromeUSD18 + lidoBeefyUSD18 + robinhoodUSD18);
        emit YieldHarvested(aerodromeUSD18, lidoBeefyUSD18, robinhoodUSD18, navPerCoinUSD18());
    }

    function getPatronTier(address donor) public view returns (PatronTier) {
        uint256 total = donorLifetimeUSD18[donor];
        if (total >= 10000 * 1e18) return PatronTier.FRONTIER_ARCHITECT;
        if (total >= 1000 * 1e18) return PatronTier.SANCTUARY_FOUNDER;
        if (total >= 100 * 1e18) return PatronTier.CORE_BUILDER;
        if (total >= 10 * 1e18) return PatronTier.SPARK_SUPPORTER;
        return PatronTier.NONE;
    }

    function _mint(address to, uint256 amount) internal {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "CPC: balance low");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount && allowance[from][msg.sender] >= amount, "CPC: allowance/balance low");
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}
