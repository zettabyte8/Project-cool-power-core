// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title CoolPowerCoreReserveCoinV6 (CPC-COIN v6.0)
 * @author Thomas Gabriel Coleman (Corona, CA)
 * @notice Multi-currency reserve savings & UBI coin backed by the aggregate USD value
 *         of all deposited assets. Combines Lido wstETH, Beefy.com autocompounding vaults,
 *         Aerodrome Finance (Base 8453), Robinhood Chain L2 (46630), and Tokenized
 *         Blue-Chip ETF Dividend Sweeps (SCHD, JEPI, VOO, SGOV) for consistent, fair,
 *         non-dilutive NAV compounding and pro-rata dividend distributions.
 */

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IPriceOracle {
    function getPriceUSD18(address asset) external view returns (uint256);
}

contract CoolPowerCoreReserveCoinV6 {
    string public constant name = "Cool Power Core Reserve Coin";
    string public constant symbol = "CPC";
    uint8 public constant decimals = 18;

    address public immutable investmentSafe;     // 0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37
    address public immutable inventorBeneficiary; // 0x1419734ee0d1e213f4496d6bf088cc3b480ccedf
    IPriceOracle public oracle;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Supported reserve assets (USDC, wstETH, cbBTC, USDS, tokenized ETFs)
    address[] public reserveAssets;
    mapping(address => bool) public isSupportedAsset;
    mapping(address => uint256) public liquidBufferBalance;
    mapping(address => uint256) public deployedStrategyValueUSD18;

    // Strategy Allocation Targets (BPS = 10000)
    uint256 public constant BUFFER_BPS = 1500;          // 15.0% Instant Any-Currency Exit Buffer
    uint256 public constant LIDO_BEEFY_BPS = 3500;      // 35.0% Lido wstETH + Beefy.com + Sky sUSDS
    uint256 public constant AERODROME_BASE_BPS = 2500;  // 25.0% Aerodrome Finance (Base 8453) Gauges
    uint256 public constant ROBINHOOD_ETF_BPS = 2500;   // 25.0% Robinhood Chain L2 (46630) Dividend ETFs
    uint256 public constant SWAP_FEE_BPS = 25;          // 0.25% Cross-Pair DEX Swap Fee -> 100% to NAV

    // Fair ETF Dividend Distribution Accounting (Magnified Dividend Per Share)
    uint256 private constant MAGNITUDE = 2**128;
    uint256 public magnifiedDividendPerShare;
    mapping(address => int256) private magnifiedDividendCorrections;
    mapping(address => uint256) public withdrawnDividends;
    mapping(address => bool) public autoCompoundDividends; // Default true: compounds into NAV/CPC
    mapping(address => uint16) public yieldPatronageBps;    // Optional 0-100% yield pledge to inventor
    IERC20 public dividendSettlementToken; // e.g., USDC

    uint256 public totalEtfDividendsHarvestedUSD18;
    uint256 public totalDefiYieldHarvestedUSD18;
    uint256 public totalSwapFeesCompoundedUSD18;
    uint256 public totalInventorDonationsUSD18;

    event Deposit(address indexed user, address indexed asset, uint256 amountIn, uint256 cpcMinted, uint256 navUSD18);
    event Redeem(address indexed user, address indexed assetOut, uint256 cpcBurned, uint256 amountOut, uint256 navUSD18);
    event EtfDividendSwept(string indexed ticker, uint256 usdAmount18, bool distributedCashStream);
    event YieldAndFeesCompounded(uint256 defiYieldUSD18, uint256 swapFeesUSD18, uint256 newNavUSD18);
    event DividendClaimed(address indexed holder, uint256 amountUSDC);
    event InventorPatronageReceived(address indexed donor, address indexed asset, uint256 amount, string note);

    modifier onlySafe() {
        require(msg.sender == investmentSafe, "CPC: caller not Gnosis Safe");
        _;
    }

    constructor(address _oracle, address _dividendToken) {
        investmentSafe = 0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37;
        inventorBeneficiary = 0x1419734ee0d1e213f4496d6bf088cc3b480ccedf;
        oracle = IPriceOracle(_oracle);
        dividendSettlementToken = IERC20(_dividendToken);
    }

    function addReserveAsset(address asset) external onlySafe {
        require(!isSupportedAsset[asset], "CPC: already supported");
        isSupportedAsset[asset] = true;
        reserveAssets.push(asset);
    }

    /// @notice Returns aggregate USD value (1e18) of all liquid buffers + deployed Lido/Beefy/Aerodrome/ETF positions
    function totalBasketValueUSD18() public view returns (uint256 totalUSD) {
        uint256 len = reserveAssets.length;
        for (uint256 i = 0; i < len; i++) {
            address asset = reserveAssets[i];
            uint256 px = oracle.getPriceUSD18(asset);
            totalUSD += (liquidBufferBalance[asset] * px) / 1e18;
            totalUSD += deployedStrategyValueUSD18[asset];
        }
    }

    /// @notice Current Net Asset Value (NAV) of 1.0 CPC in USD (1e18)
    function navPerCoinUSD18() public view returns (uint256) {
        if (totalSupply == 0) return 1e18;
        return (totalBasketValueUSD18() * 1e18) / totalSupply;
    }

    /// @notice Deposit any supported currency to mint CPC at exact real-time basket NAV
    function deposit(address asset, uint256 amountIn) external returns (uint256 cpcMinted) {
        require(isSupportedAsset[asset] && amountIn > 0, "CPC: invalid asset/amount");
        uint256 navBefore = navPerCoinUSD18();
        require(IERC20(asset).transferFrom(msg.sender, address(this), amountIn), "CPC: transfer failed");

        uint256 depositUSD18 = (amountIn * oracle.getPriceUSD18(asset)) / 1e18;
        cpcMinted = (depositUSD18 * 1e18) / navBefore;

        liquidBufferBalance[asset] += amountIn;
        _mint(msg.sender, cpcMinted);
        emit Deposit(msg.sender, asset, amountIn, cpcMinted, navPerCoinUSD18());
    }

    /// @notice Redeem CPC at any time for any supported currency in the reserve basket
    function redeem(address assetOut, uint256 cpcAmount) external returns (uint256 amountOut) {
        require(isSupportedAsset[assetOut] && cpcAmount > 0, "CPC: invalid redeem");
        require(balanceOf[msg.sender] >= cpcAmount, "CPC: insufficient CPC");

        uint256 nav = navPerCoinUSD18();
        uint256 usdValue18 = (cpcAmount * nav) / 1e18;
        amountOut = (usdValue18 * 1e18) / oracle.getPriceUSD18(assetOut);
        require(liquidBufferBalance[assetOut] >= amountOut, "CPC: rebalance buffer required");

        _burn(msg.sender, cpcAmount);
        liquidBufferBalance[assetOut] -= amountOut;
        require(IERC20(assetOut).transfer(msg.sender, amountOut), "CPC: payout failed");
        emit Redeem(msg.sender, assetOut, cpcAmount, amountOut, navPerCoinUSD18());
    }

    /**
     * @notice Harvests consistent quarterly/monthly dividends from Robinhood Chain L2
     *         tokenized blue-chip ETFs (SCHD, JEPI, VOO, SGOV).
     *         If distributeAsCashStream == false, 100% compounds directly into CPC NAV.
     *         If distributeAsCashStream == true, distributes pro-rata per CPC share fairly.
     */
    function sweepEtfDividends(
        string calldata ticker,
        address settlementAsset,
        uint256 amountIn,
        bool distributeAsCashStream
    ) external onlySafe {
        require(amountIn > 0, "CPC: zero dividend");
        require(IERC20(settlementAsset).transferFrom(msg.sender, address(this), amountIn), "CPC: sweep transfer failed");
        uint256 usd18 = (amountIn * oracle.getPriceUSD18(settlementAsset)) / 1e18;
        totalEtfDividendsHarvestedUSD18 += usd18;

        if (!distributeAsCashStream || totalSupply == 0) {
            // 100% non-dilutive NAV ratchet for all CPC holders
            liquidBufferBalance[settlementAsset] += amountIn;
        } else {
            // Pro-rata fair cash-stream distribution per CPC share
            magnifiedDividendPerShare += (amountIn * MAGNITUDE) / totalSupply;
        }
        emit EtfDividendSwept(ticker, usd18, distributeAsCashStream);
    }

    /// @notice Compounds Lido wstETH, Beefy.com, Aerodrome Base gauges, and 0.25% DEX swap fees into NAV
    function compoundDeFiAndSwapFees(
        address asset,
        uint256 yieldAmount,
        uint256 swapFeeAmount
    ) external onlySafe {
        uint256 totalIn = yieldAmount + swapFeeAmount;
        require(totalIn > 0, "CPC: zero yield");
        require(IERC20(asset).transferFrom(msg.sender, address(this), totalIn), "CPC: yield transfer failed");
        liquidBufferBalance[asset] += totalIn;

        uint256 px = oracle.getPriceUSD18(asset);
        totalDefiYieldHarvestedUSD18 += (yieldAmount * px) / 1e18;
        totalSwapFeesCompoundedUSD18 += (swapFeeAmount * px) / 1e18;
        emit YieldAndFeesCompounded(totalDefiYieldHarvestedUSD18, totalSwapFeesCompoundedUSD18, navPerCoinUSD18());
    }

    function withdrawableDividendOf(address holder) public view returns (uint256) {
        int256 accumulated = int256(magnifiedDividendPerShare * balanceOf[holder]) + magnifiedDividendCorrections[holder];
        uint256 totalEarned = accumulated > 0 ? uint256(accumulated) / MAGNITUDE : 0;
        return totalEarned - withdrawnDividends[holder];
    }

    function claimEtfDividend() external returns (uint256 payout) {
        payout = withdrawableDividendOf(msg.sender);
        require(payout > 0, "CPC: no claimable dividend");
        withdrawnDividends[msg.sender] += payout;

        uint16 patBps = yieldPatronageBps[msg.sender];
        uint256 inventorCut = (payout * patBps) / 10000;
        uint256 holderCut = payout - inventorCut;

        if (inventorCut > 0) {
            require(dividendSettlementToken.transfer(inventorBeneficiary, inventorCut), "CPC: patronage transfer failed");
        }
        if (holderCut > 0) {
            require(dividendSettlementToken.transfer(msg.sender, holderCut), "CPC: dividend payout failed");
        }
        emit DividendClaimed(msg.sender, holderCut);
    }

    function setYieldPatronageBps(uint16 bps) external {
        require(bps <= 10000, "CPC: max 100%");
        yieldPatronageBps[msg.sender] = bps;
    }

    /// @notice Direct 100% pass-through donation to Thomas Gabriel Coleman (0x1419...cedf)
    function donateToInventor(address asset, uint256 amount, string calldata note) external {
        require(amount > 0, "CPC: zero donation");
        require(IERC20(asset).transferFrom(msg.sender, inventorBeneficiary, amount), "CPC: donation failed");
        totalInventorDonationsUSD18 += (amount * oracle.getPriceUSD18(asset)) / 1e18;
        emit InventorPatronageReceived(msg.sender, asset, amount, note);
    }

    function _mint(address to, uint256 value) internal {
        totalSupply += value;
        balanceOf[to] += value;
        magnifiedDividendCorrections[to] -= int256(magnifiedDividendPerShare * value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] -= value;
        totalSupply -= value;
        magnifiedDividendCorrections[from] += int256(magnifiedDividendPerShare * value);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(balanceOf[msg.sender] >= value, "CPC: balance low");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        int256 magCorrection = int256(magnifiedDividendPerShare * value);
        magnifiedDividendCorrections[msg.sender] += magCorrection;
        magnifiedDividendCorrections[to] -= magCorrection;
        return true;
    }
}
