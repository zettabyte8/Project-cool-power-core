// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title CoolPowerCoreReserveCoinV5 (CPC-COIN)
 * @author Thomas Gabriel Coleman (Corona, CA)
 * @notice Multi-currency reserve savings coin backed by global deposits, compounded via
 *         Lido (wstETH), Beefy.com, Aerodrome (Base 8453), and Robinhood Chain (46630),
 *         with integrated 100% direct inventor patronage routing.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract CoolPowerCoreReserveCoinV5 {
    string public constant name = "Cool Power Core Reserve Coin";
    string public constant symbol = "CPC";
    uint8 public constant decimals = 18;

    // Treasury & Inventor Addresses (Thomas Gabriel Coleman)
    address public constant INVESTMENT_GNOSIS_SAFE = 0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37;
    address public constant INVENTOR_DONATE_EVM    = 0x1419734eE0D1e213f4496D6bf088cc3B480Ccedf;
    string  public constant DONATE_BTC_CAKE_PAY    = "howeyecrypto@cake.cash";
    string  public constant DONATE_SOL_ADDRESS     = "2eRUANUAcvyWw1fyHnBSS53g4pWURXcE4se1WRW6H3Nr";

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Reserve & Yield Accounting (1e18 USD precision)
    uint256 public totalReserveUSD18;
    uint256 public swapFeeBps = 25; // 0.25% recycled strictly to NAV

    // Yield Allocation Targets (Basis Points = 10,000)
    uint256 public constant BUFFER_LIQUID_BPS   = 1500; // 15% instant any-currency redemption buffer
    uint256 public constant AERODROME_BASE_BPS  = 2500; // 25% Aerodrome Finance Base (8453) gauges
    uint256 public constant LIDO_BEEFY_BPS      = 4500; // 45% Lido wstETH + Beefy.com + Sky sUSDS
    uint256 public constant ROBINHOOD_L2_BPS    = 1500; // 15% Robinhood Chain L2 (46630) RWA & liquidity

    // Supported Reserve Currencies
    mapping(address => bool) public isSupportedCurrency;
    mapping(address => uint256) public oraclePriceUSD18;

    // Patronage Tracking
    mapping(address => uint256) public cumulativeDonatedUSD18;
    mapping(address => uint16)  public yieldPatronageBps; // Opt-in 0 to 10000 bps of yield appreciation
    mapping(address => uint256) public userLastEntryNav18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event ReserveDeposited(address indexed user, address indexed token, uint256 amount, uint256 usdValue18, uint256 cpcMinted);
    event ReserveRedeemed(address indexed user, address indexed outToken, uint256 cpcBurned, uint256 outAmount);
    event YieldAndFeesCompounded(uint256 addedUSD18, uint256 newNav18);
    event DirectInventorDonation(address indexed patron, address indexed token, uint256 amount, uint256 usdValue18, string note);
    event NativeInventorDonation(address indexed patron, uint256 weiAmount, string note);
    event YieldPatronageUpdated(address indexed patron, uint16 bps);

    modifier onlySafe() {
        require(msg.sender == INVESTMENT_GNOSIS_SAFE, "Caller not Investment Gnosis Safe");
        _;
    }

    constructor() {
        // Initialize NAV at $1.00 (1e18)
    }

    function currentNavUSD18() public view returns (uint256) {
        if (totalSupply == 0 || totalReserveUSD18 == 0) return 1e18;
        return (totalReserveUSD18 * 1e18) / totalSupply;
    }

    function configureCurrency(address token, bool supported, uint256 priceUSD18) external onlySafe {
        isSupportedCurrency[token] = supported;
        oraclePriceUSD18[token] = priceUSD18;
    }

    function updateOraclePrice(address token, uint256 priceUSD18) external onlySafe {
        require(isSupportedCurrency[token], "Unsupported token");
        oraclePriceUSD18[token] = priceUSD18;
    }

    /**
     * @notice Deposit any supported currency into the global reserve basket in exchange for CPC-COIN.
     */
    function depositCurrency(address token, uint256 amount) external returns (uint256 cpcMinted) {
        require(isSupportedCurrency[token], "Currency not supported");
        require(amount > 0, "Zero deposit");

        uint256 nav = currentNavUSD18();
        uint256 usdVal18 = (amount * oraclePriceUSD18[token]) / 1e18;
        cpcMinted = (usdVal18 * 1e18) / nav;

        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");

        totalReserveUSD18 += usdVal18;
        totalSupply += cpcMinted;
        balanceOf[msg.sender] += cpcMinted;
        if (userLastEntryNav18[msg.sender] == 0) {
            userLastEntryNav18[msg.sender] = nav;
        }

        emit Transfer(address(0), msg.sender, cpcMinted);
        emit ReserveDeposited(msg.sender, token, amount, usdVal18, cpcMinted);
    }

    /**
     * @notice Redeem CPC-COIN at any time for any available currency in the global reserve basket.
     */
    function redeemCurrency(uint256 cpcAmount, address outToken) external returns (uint256 outAmount) {
        require(isSupportedCurrency[outToken], "Output currency unsupported");
        require(balanceOf[msg.sender] >= cpcAmount && cpcAmount > 0, "Insufficient CPC");

        uint256 nav = currentNavUSD18();
        uint256 grossUsd18 = (cpcAmount * nav) / 1e18;

        // Route opt-in yield appreciation share to Inventor Donate EVM if configured
        uint16 patBps = yieldPatronageBps[msg.sender];
        uint256 entryNav = userLastEntryNav18[msg.sender];
        if (patBps > 0 && nav > entryNav && entryNav > 0) {
            uint256 gainUsd18 = (cpcAmount * (nav - entryNav)) / 1e18;
            uint256 patronUsd18 = (gainUsd18 * patBps) / 10000;
            if (patronUsd18 > 0 && patronUsd18 < grossUsd18) {
                grossUsd18 -= patronUsd18;
                uint256 patronTokens = (patronUsd18 * 1e18) / oraclePriceUSD18[outToken];
                cumulativeDonatedUSD18[msg.sender] += patronUsd18;
                IERC20(outToken).transfer(INVENTOR_DONATE_EVM, patronTokens);
                emit DirectInventorDonation(msg.sender, outToken, patronTokens, patronUsd18, "Opt-In Yield Patronage");
            }
        }

        uint256 feeUsd18 = (grossUsd18 * swapFeeBps) / 10000;
        uint256 netUsd18 = grossUsd18 - feeUsd18;
        outAmount = (netUsd18 * 1e18) / oraclePriceUSD18[outToken];

        require(IERC20(outToken).balanceOf(address(this)) >= outAmount, "Rebalance buffer");

        balanceOf[msg.sender] -= cpcAmount;
        totalSupply -= cpcAmount;
        // Retain swap fee in totalReserveUSD18 so remaining holders' NAV rises
        totalReserveUSD18 -= netUsd18;

        require(IERC20(outToken).transfer(msg.sender, outAmount), "Payout failed");
        emit Transfer(msg.sender, address(0), cpcAmount);
        emit ReserveRedeemed(msg.sender, outToken, cpcAmount, outAmount);
    }

    /**
     * @notice Harvesters (Lido wstETH, Beefy vaults, Aerodrome Base gauges, Robinhood L2)
     *         recycle compounded yield and swap fees directly into global reserve value.
     */
    function harvestAndCompoundYield(uint256 yieldUsd18) external onlySafe {
        require(yieldUsd18 > 0, "Zero yield");
        totalReserveUSD18 += yieldUsd18;
        emit YieldAndFeesCompounded(yieldUsd18, currentNavUSD18());
    }

    /**
     * @notice Route excess reserve capital to the Investment Gnosis Safe for multi-chain
     *         deployment (Aerodrome Base 25%, Lido+Beefy 45%, Robinhood Chain 15%).
     */
    function deployToYieldStrategy(address token, uint256 amount) external onlySafe {
        require(IERC20(token).transfer(INVESTMENT_GNOSIS_SAFE, amount), "Strategy transfer failed");
    }

    /**
     * @notice 100% Direct ERC-20 Donation to Thomas Gabriel Coleman's EVM address.
     */
    function donateToInventorERC20(address token, uint256 amount, string calldata note) external {
        require(amount > 0, "Zero donation");
        require(IERC20(token).transferFrom(msg.sender, INVENTOR_DONATE_EVM, amount), "Donation transfer failed");
        uint256 usdVal18 = oraclePriceUSD18[token] > 0
            ? (amount * oraclePriceUSD18[token]) / 1e18
            : amount;
        cumulativeDonatedUSD18[msg.sender] += usdVal18;
        emit DirectInventorDonation(msg.sender, token, amount, usdVal18, note);
    }

    /**
     * @notice 100% Direct Native ETH/Base/Robinhood Chain Donation to Thomas Gabriel Coleman.
     */
    function donateNativeToInventor(string calldata note) external payable {
        require(msg.value > 0, "Zero native donation");
        (bool ok, ) = INVENTOR_DONATE_EVM.call{value: msg.value}("");
        require(ok, "Native transfer failed");
        emit NativeInventorDonation(msg.sender, msg.value, note);
    }

    receive() external payable {
        (bool ok, ) = INVENTOR_DONATE_EVM.call{value: msg.value}("");
        require(ok, "Native transfer failed");
        emit NativeInventorDonation(msg.sender, msg.value, "Direct Native Transfer");
    }

    function setYieldPatronageShare(uint16 bps) external {
        require(bps <= 10000, "Max 100%");
        yieldPatronageBps[msg.sender] = bps;
        emit YieldPatronageUpdated(msg.sender, bps);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        allowance[from][msg.sender] -= value;
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }
}
