// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/CoolPowerCoreReserveCoinV6.sol";
import "../src/CoolPowerCoreHardwareFulfillment.sol";

contract MockERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _n, string memory _s, uint8 _d) {
        name = _n;
        symbol = _s;
        decimals = _d;
    }

    function mint(address to, uint256 amt) external {
        balanceOf[to] += amt;
    }

    function approve(address spender, uint256 amt) external returns (bool) {
        allowance[msg.sender][spender] = amt;
        return true;
    }

    function transfer(address to, uint256 amt) external returns (bool) {
        require(balanceOf[msg.sender] >= amt, "bal");
        balanceOf[msg.sender] -= amt;
        balanceOf[to] += amt;
        return true;
    }

    function transferFrom(address from, address to, uint256 amt) external returns (bool) {
        require(balanceOf[from] >= amt, "bal");
        require(allowance[from][msg.sender] >= amt, "allow");
        allowance[from][msg.sender] -= amt;
        balanceOf[from] -= amt;
        balanceOf[to] += amt;
        return true;
    }
}

contract CoolPowerCoreHardwareFulfillmentTest is Test {
    CoolPowerCoreReserveCoinV6 public cpc;
    CoolPowerCoreHardwareFulfillment public fulfillment;
    MockERC20 public usdc;

    address public constant GNOSIS_SAFE = 0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37;
    address public constant INVENTOR_PATRONAGE = 0x1419734ee0d1e213f4496d6bf088cc3b480ccedf;
    address public buyer = address(0xBEEF);

    function setUp() public {
        usdc = new MockERC20("USD Coin", "USDC", 6);
        cpc = new CoolPowerCoreReserveCoinV6(GNOSIS_SAFE, INVENTOR_PATRONAGE);
        fulfillment = new CoolPowerCoreHardwareFulfillment(address(cpc), GNOSIS_SAFE);

        vm.startPrank(GNOSIS_SAFE);
        cpc.registerReserveAsset(address(usdc), 6, 1e18, 2500); // $1.00 par
        fulfillment.registerSKU(1, "CPC-RES-1", 1250e18, 100);
        fulfillment.registerSKU(2, "CPC-NEURO-HAT", 650e18, 250);
        vm.stopPrank();

        // Fund buyer with USDC and mint CPC-COIN at 1.0000 par
        usdc.mint(buyer, 10_000e6);
        vm.startPrank(buyer);
        usdc.approve(address(cpc), 10_000e6);
        cpc.depositAndMint(address(usdc), 5_000e6, 0);
        vm.stopPrank();
    }

    function testPreOrderEscrowAndInstantRefundBeforeLock() public {
        uint256 startBal = cpc.balanceOf(buyer);
        bytes32 shipHash = keccak256("Thomas Coleman | Corona, CA 92879 | Encrypted");

        vm.startPrank(buyer);
        cpc.approve(address(fulfillment), 1250e18);
        uint256 orderId = fulfillment.placePreOrder(1, 1, shipHash);
        assertEq(cpc.balanceOf(buyer), startBal - 1250e18);
        assertEq(cpc.balanceOf(address(fulfillment)), 1250e18);

        // Cancel before manufacturing opens -> 100% instant escrow refund
        fulfillment.cancelPreOrder(orderId);
        assertEq(cpc.balanceOf(buyer), startBal);
        assertEq(cpc.balanceOf(address(fulfillment)), 0);
        vm.stopPrank();
    }

    function testManufacturingLockBatchSettlementAndTracking() public {
        bytes32 shipHash = keccak256("Buyer Shipping Commitment Hash");

        vm.startPrank(buyer);
        cpc.approve(address(fulfillment), 1900e18);
        uint256 order1 = fulfillment.placePreOrder(1, 1, shipHash);
        uint256 order2 = fulfillment.placePreOrder(2, 1, shipHash);
        vm.stopPrank();

        // Gnosis Safe enables Batch-1 manufacturing
        vm.startPrank(GNOSIS_SAFE);
        fulfillment.setManufacturingAvailable(1, true);
        fulfillment.setManufacturingAvailable(2, true);
        fulfillment.lockAndSettleOrder(order1);
        fulfillment.lockAndSettleOrder(order2);
        assertEq(cpc.balanceOf(GNOSIS_SAFE), 1900e18);

        // Attach carrier tracking once shipped
        fulfillment.markShipped(order1, "FEDEX-CPC-92879-0001");
        vm.stopPrank();

        (, , , , , , CoolPowerCoreHardwareFulfillment.OrderStatus status, string memory tracking) = fulfillment.orders(order1);
        assertEq(uint256(status), uint256(CoolPowerCoreHardwareFulfillment.OrderStatus.SHIPPED));
        assertEq(tracking, "FEDEX-CPC-92879-0001");
    }
}
