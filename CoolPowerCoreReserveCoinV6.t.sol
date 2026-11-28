// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "./CoolPowerCoreReserveCoinV6.sol";

contract MockERC20 is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _n, string memory _s, uint8 _d) {
        name = _n; symbol = _s; decimals = _d;
    }

    function mint(address to, uint256 amt) external {
        balanceOf[to] += amt;
        totalSupply += amt;
        emit Transfer(address(0), to, amt);
    }

    function approve(address spender, uint256 amt) external returns (bool) {
        allowance[msg.sender][spender] = amt;
        emit Approval(msg.sender, spender, amt);
        return true;
    }

    function transfer(address to, uint256 amt) external returns (bool) {
        require(balanceOf[msg.sender] >= amt, "BAL");
        balanceOf[msg.sender] -= amt;
        balanceOf[to] += amt;
        emit Transfer(msg.sender, to, amt);
        return true;
    }

    function transferFrom(address from, address to, uint256 amt) external returns (bool) {
        require(balanceOf[from] >= amt, "BAL");
        if (allowance[from][msg.sender] != type(uint256).max) {
            require(allowance[from][msg.sender] >= amt, "ALLOW");
            allowance[from][msg.sender] -= amt;
        }
        balanceOf[from] -= amt;
        balanceOf[to] += amt;
        emit Transfer(from, to, amt);
        return true;
    }
}

contract CoolPowerCoreReserveCoinV6Test is Test {
    CoolPowerCoreReserveCoinV6 public cpc;
    MockERC20 public usdc;
    MockERC20 public wstETH;

    address public constant GNOSIS_SAFE = 0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37;
    address public constant INVENTOR    = 0x1419734ee0d1e213f4496d6bf088cc3b480ccedf;

    address public alice = address(0xA11CE);
    address public bob   = address(0xB0B);

    function setUp() public {
        usdc = new MockERC20("USD Coin", "USDC", 6);
        wstETH = new MockERC20("Wrapped stETH", "wstETH", 18);

        vm.prank(GNOSIS_SAFE);
        cpc = new CoolPowerCoreReserveCoinV6(GNOSIS_SAFE, INVENTOR, address(usdc));

        vm.startPrank(GNOSIS_SAFE);
        cpc.registerAsset(address(usdc), 6, 1e18);
        cpc.registerAsset(address(wstETH), 18, 3200e18);
        vm.stopPrank();

        usdc.mint(alice, 1_000_000e6);
        usdc.mint(bob, 1_000_000e6);
        usdc.mint(GNOSIS_SAFE, 1_000_000e6);
        wstETH.mint(bob, 100e18);
    }

    function testInitialNAVIsOneDollar() public view {
        assertEq(cpc.navUSD18(), 1e18, "Initial NAV must be $1.00");
    }

    function testMultiCurrencyDepositAndInstantRedemption() public {
        vm.startPrank(alice);
        usdc.approve(address(cpc), 10_000e6);
        uint256 mintedAlice = cpc.deposit(address(usdc), 10_000e6, 0);
        assertEq(mintedAlice, 10_000e18);
        vm.stopPrank();

        vm.startPrank(bob);
        wstETH.approve(address(cpc), 1e18); // $3,200
        uint256 mintedBob = cpc.deposit(address(wstETH), 1e18, 0);
        assertEq(mintedBob, 3_200e18);
        vm.stopPrank();

        assertEq(cpc.totalBasketValueUSD18(), 13_200e18);

        // Alice redeems 1,000 CPC instantly for USDC
        vm.prank(alice);
        uint256 usdcOut = cpc.redeem(1_000e18, address(usdc), 0);
        assertEq(usdcOut, 1_000e6);
        assertEq(cpc.navUSD18(), 1e18, "NAV invariant after par redemption");
    }

    function testETFDebtFreeMagnifiedDividendFairness() public {
        // Alice deposits $10,000 (75% share), Bob deposits $3,333.33... -> use clean $10k and $30k (25% / 75%)
        vm.startPrank(alice);
        usdc.approve(address(cpc), 10_000e6);
        cpc.deposit(address(usdc), 10_000e6, 0);
        vm.stopPrank();

        vm.startPrank(bob);
        usdc.approve(address(cpc), 30_000e6);
        cpc.deposit(address(usdc), 30_000e6, 0);
        vm.stopPrank();

        // Gnosis Safe distributes $4,000 ETF dividend in Compounding Mode (default = true)
        vm.startPrank(GNOSIS_SAFE);
        usdc.approve(address(cpc), 4_000e6);
        cpc.distributeETFDividend(address(usdc), 4_000e6);
        vm.stopPrank();

        // NAV jumps by +10% ($44,000 / 40,000 CPC = $1.10) with zero token dilution
        assertEq(cpc.navUSD18(), 1.1e18);

        // Switch Alice and Bob to Direct Claim Mode and distribute another $4,000
        vm.prank(alice);
        cpc.setAutoCompoundDividends(false);
        vm.prank(bob);
        cpc.setAutoCompoundDividends(false);

        vm.startPrank(GNOSIS_SAFE);
        usdc.approve(address(cpc), 4_000e6);
        cpc.distributeETFDividend(address(usdc), 4_000e6);
        vm.stopPrank();

        // Alice holds 25% -> $1,000 USDC claimable; Bob holds 75% -> $3,000 USDC claimable
        assertApproxEqAbs(cpc.withdrawableDividendOf(alice), 1_000e6, 2);
        assertApproxEqAbs(cpc.withdrawableDividendOf(bob), 3_000e6, 2);

        vm.prank(alice);
        uint256 claimedAlice = cpc.claimETFDividend();
        assertApproxEqAbs(claimedAlice, 1_000e6, 2);
        assertEq(cpc.withdrawableDividendOf(alice), 0);
    }

    function testDirectInventorPatronagePassThrough() public {
        uint256 beforeBal = usdc.balanceOf(INVENTOR);
        vm.startPrank(alice);
        usdc.approve(address(cpc), 500e6);
        cpc.donateToInventorERC20(address(usdc), 500e6, "For Thomas Coleman - Cool Power Core R&D");
        vm.stopPrank();

        assertEq(usdc.balanceOf(INVENTOR) - beforeBal, 500e6);
        assertEq(cpc.patronageUSD18(alice), 500e18);
    }
}
