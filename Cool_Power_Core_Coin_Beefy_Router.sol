// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// ============================================================================
// COOL POWER CORE CRYPTO COIN (CPC-COIN) - MULTI-CURRENCY VAULT, DEX ROUTER
// & BEEFY.COM AUTOCOMPOUNDING STRATEGY CONTRACT
// Architect: Thomas Gabriel Coleman (Corona, CA)
// ============================================================================

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}

interface IPriceOracle {
    // Returns 18-decimal USD price for any supported reserve asset
    function getAssetPriceUSD18(address token) external view returns (uint256);
}

interface IBeefyVault {
    function deposit(uint256 _amount) external;
    function withdraw(uint256 _shares) external;
    function getPricePerFullShare() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract CPCCoinReserveAndRouter {
    string public constant name = "Cool Power Core Reserve Coin";
    string public constant symbol = "CPC";
    uint8  public constant decimals = 18;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public governance;
    IPriceOracle public oracle;

    struct ReserveAsset {
        bool    supported;
        address beefyVault;      // Corresponding Beefy.com autocompounding vault
        uint256 liquidBuffer;    // 20% instant redemption buffer in contract
        uint256 beefyShares;     // 80% deployed into Beefy autocompounder
    }

    address[] public assetList;
    mapping(address => ReserveAsset) public reserves;

    uint256 public constant SWAP_FEE_BPS = 25;        // 0.25% swap fee recycled 100% into NAV
    uint256 public constant BUFFER_TARGET_BPS = 2000; // 20.00% instant redemption liquidity
    uint256 private locked = 1;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event DepositMinted(address indexed user, address indexed token, uint256 amountIn, uint256 cpcMinted, uint256 nav18);
    event Redeemed(address indexed user, address indexed tokenOut, uint256 cpcBurned, uint256 amountOut, uint256 nav18);
    event CrossPairSwap(address indexed trader, address indexed tokenIn, address indexed tokenOut, uint256 feeRecycledUSD18);
    event BeefyRebalanced(address indexed token, uint256 deployedToBeefy, uint256 totalReserveUSD18);

    modifier nonReentrant() {
        require(locked == 1, "REENTRANCY");
        locked = 2;
        _;
        locked = 1;
    }

    modifier onlyGov() {
        require(msg.sender == governance, "ONLY_GOV");
        _;
    }

    constructor(address _oracle) {
        governance = msg.sender;
        oracle = IPriceOracle(_oracle);
    }

    function addReserveAsset(address token, address beefyVault) external onlyGov {
        require(!reserves[token].supported, "ALREADY_SUPPORTED");
        reserves[token] = ReserveAsset({
            supported: true,
            beefyVault: beefyVault,
            liquidBuffer: 0,
            beefyShares: 0
        });
        assetList.push(token);
        if (beefyVault != address(0)) {
            IERC20(token).approve(beefyVault, type(uint256).max);
        }
    }

    // Computes total USD value (18 decimals) across ALL deposited currencies + Beefy compounded yield
    function totalBasketValueUSD18() public view returns (uint256 totalUSD18) {
        uint256 len = assetList.length;
        for (uint256 i = 0; i < len; i++) {
            address token = assetList[i];
            ReserveAsset memory r = reserves[token];
            uint256 underlyingAmount = r.liquidBuffer;
            if (r.beefyVault != address(0) && r.beefyShares > 0) {
                uint256 ppfs = IBeefyVault(r.beefyVault).getPricePerFullShare();
                underlyingAmount += (r.beefyShares * ppfs) / 1e18;
            }
            uint8 dec = IERC20(token).decimals();
            uint256 norm18 = underlyingAmount * (10 ** (18 - dec));
            uint256 priceUSD18 = oracle.getAssetPriceUSD18(token);
            totalUSD18 += (norm18 * priceUSD18) / 1e18;
        }
    }

    // Net Asset Value (NAV) of 1.0 CPC in 18-decimal USD (ratchets upward as fees & Beefy yield accrue)
    function getCPCNavUSD18() public view returns (uint256) {
        if (totalSupply == 0) return 1e18; // Initial $1.0000 par value
        return (totalBasketValueUSD18() * 1e18) / totalSupply;
    }

    // Deposit ANY supported currency to mint CPC at current multi-currency basket NAV
    function depositAnyCurrency(address tokenIn, uint256 amountIn) external nonReentrant returns (uint256 cpcMinted) {
        ReserveAsset storage r = reserves[tokenIn];
        require(r.supported && amountIn > 0, "INVALID_DEPOSIT");

        uint256 navBefore = getCPCNavUSD18();
        require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), "TRANSFER_FAIL");
        r.liquidBuffer += amountIn;

        uint8 dec = IERC20(tokenIn).decimals();
        uint256 norm18 = amountIn * (10 ** (18 - dec));
        uint256 depositUSD18 = (norm18 * oracle.getAssetPriceUSD18(tokenIn)) / 1e18;

        cpcMinted = (depositUSD18 * 1e18) / navBefore;
        _mint(msg.sender, cpcMinted);
        _rebalanceToBeefy(tokenIn);

        emit DepositMinted(msg.sender, tokenIn, amountIn, cpcMinted, getCPCNavUSD18());
    }

    // Redeem CPC at ANY time for ANY underlying currency in the global basket
    function redeemForAnyCurrency(address tokenOut, uint256 cpcAmount) external nonReentrant returns (uint256 amountOut) {
        ReserveAsset storage r = reserves[tokenOut];
        require(r.supported && cpcAmount > 0 && balanceOf[msg.sender] >= cpcAmount, "INVALID_REDEEM");

        uint256 nav = getCPCNavUSD18();
        uint256 redeemUSD18 = (cpcAmount * nav) / 1e18;
        uint256 priceOut = oracle.getAssetPriceUSD18(tokenOut);

        uint8 dec = IERC20(tokenOut).decimals();
        uint256 norm18Out = (redeemUSD18 * 1e18) / priceOut;
        amountOut = norm18Out / (10 ** (18 - dec));

        _burn(msg.sender, cpcAmount);

        // Pull from Beefy vault if withdrawal exceeds 20% instant buffer
        if (amountOut > r.liquidBuffer && r.beefyVault != address(0)) {
            uint256 deficit = amountOut - r.liquidBuffer;
            uint256 ppfs = IBeefyVault(r.beefyVault).getPricePerFullShare();
            uint256 sharesNeeded = (deficit * 1e18) / ppfs + 1;
            if (sharesNeeded > r.beefyShares) sharesNeeded = r.beefyShares;
            uint256 balBefore = IERC20(tokenOut).balanceOf(address(this));
            IBeefyVault(r.beefyVault).withdraw(sharesNeeded);
            r.beefyShares -= sharesNeeded;
            r.liquidBuffer += (IERC20(tokenOut).balanceOf(address(this)) - balBefore);
        }

        require(r.liquidBuffer >= amountOut, "INSUFFICIENT_ASSET_LIQUIDITY");
        r.liquidBuffer -= amountOut;
        require(IERC20(tokenOut).transfer(msg.sender, amountOut), "PAYOUT_FAIL");

        emit Redeemed(msg.sender, tokenOut, cpcAmount, amountOut, getCPCNavUSD18());
    }

    // Internal DEX Pair Router: 100% of 0.25% swap fee remains in pool, boosting CPC NAV for all holders
    function swapReservePair(address tokenIn, address tokenOut, uint256 amountIn, uint256 minAmountOut)
        external nonReentrant returns (uint256 amountOut)
    {
        require(reserves[tokenIn].supported && reserves[tokenOut].supported && tokenIn != tokenOut, "BAD_PAIR");
        require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), "IN_FAIL");
        reserves[tokenIn].liquidBuffer += amountIn;

        uint256 feeAmount = (amountIn * SWAP_FEE_BPS) / 10000;
        uint256 netIn = amountIn - feeAmount;

        uint8 decIn = IERC20(tokenIn).decimals();
        uint8 decOut = IERC20(tokenOut).decimals();
        uint256 netUSD18 = ((netIn * (10 ** (18 - decIn))) * oracle.getAssetPriceUSD18(tokenIn)) / 1e18;
        uint256 feeUSD18 = ((feeAmount * (10 ** (18 - decIn))) * oracle.getAssetPriceUSD18(tokenIn)) / 1e18;

        amountOut = ((netUSD18 * 1e18) / oracle.getAssetPriceUSD18(tokenOut)) / (10 ** (18 - decOut));
        require(amountOut >= minAmountOut && reserves[tokenOut].liquidBuffer >= amountOut, "SLIPPAGE_OR_LIQ");

        reserves[tokenOut].liquidBuffer -= amountOut;
        require(IERC20(tokenOut).transfer(msg.sender, amountOut), "OUT_FAIL");
        _rebalanceToBeefy(tokenIn);

        emit CrossPairSwap(msg.sender, tokenIn, tokenOut, feeUSD18);
    }

    // Routes 80% of excess reserve liquidity into Beefy.com autocompounding vaults
    function _rebalanceToBeefy(address token) internal {
        ReserveAsset storage r = reserves[token];
        if (r.beefyVault == address(0)) return;
        uint256 ppfs = IBeefyVault(r.beefyVault).getPricePerFullShare();
        uint256 totalAsset = r.liquidBuffer + ((r.beefyShares * ppfs) / 1e18);
        uint256 targetBuffer = (totalAsset * BUFFER_TARGET_BPS) / 10000;

        if (r.liquidBuffer > targetBuffer + 1e6) {
            uint256 toDeploy = r.liquidBuffer - targetBuffer;
            uint256 sharesBefore = IBeefyVault(r.beefyVault).balanceOf(address(this));
            IBeefyVault(r.beefyVault).deposit(toDeploy);
            uint256 sharesGained = IBeefyVault(r.beefyVault).balanceOf(address(this)) - sharesBefore;
            r.liquidBuffer -= toDeploy;
            r.beefyShares += sharesGained;
            emit BeefyRebalanced(token, toDeploy, totalBasketValueUSD18());
        }
    }

    function _mint(address to, uint256 amt) internal {
        totalSupply += amt;
        balanceOf[to] += amt;
        emit Transfer(address(0), to, amt);
    }

    function _burn(address from, uint256 amt) internal {
        balanceOf[from] -= amt;
        totalSupply -= amt;
        emit Transfer(from, address(0), amt);
    }
}
