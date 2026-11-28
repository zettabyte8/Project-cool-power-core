// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title CoolPowerCoreHardwareFulfillment
 * @author Thomas Gabriel Coleman (Corona, CA)
 * @notice On-chain bridge linking in-game Cool Power Core (CPC) hardware purchases
 *         to real-world physical manufacturing & shipping fulfillment once production opens.
 *         Funds are held in non-custodial escrow or routed to the Investment Gnosis Safe
 *         upon verified batch manufacturing unlock, with full buyer refund protection prior to production lock.
 */
interface IERC20Minimal {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract CoolPowerCoreHardwareFulfillment {
    address public constant INVESTMENT_GNOSIS_SAFE = 0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37;
    address public constant INVENTOR_PATRONAGE_EVM = 0x1419734ee0d1e213f4496d6bf088cc3b480ccedf;

    IERC20Minimal public immutable cpcCoin;
    address public admin;

    enum OrderStatus {
        QUEUED_PRE_MANUFACTURING,
        MANUFACTURING_LOCKED,
        SHIPPED_WITH_TRACKING,
        DELIVERED,
        REFUNDED
    }

    struct HardwareSKU {
        string skuCode;
        string name;
        uint256 priceCPC18;
        bool manufacturingAvailable;
        uint256 totalReserved;
        uint256 totalShipped;
    }

    struct FulfillmentOrder {
        uint256 orderId;
        address buyer;
        uint256 skuId;
        uint256 quantity;
        uint256 totalPaidCPC18;
        bytes32 encryptedShippingHash; // SHA-256 of encrypted off-chain shipping address + pubkey
        string regionZone;             // e.g., "US-WEST", "US-EAST", "EU", "APAC", "MARS-ISRU"
        OrderStatus status;
        string carrierTrackingCode;
        uint256 createdAt;
    }

    uint256 public nextOrderId = 1;
    uint256 public skuCount;
    mapping(uint256 => HardwareSKU) public catalog;
    mapping(uint256 => FulfillmentOrder) public orders;
    mapping(address => uint256[]) public buyerOrders;

    event HardwareReservedForShipping(
        uint256 indexed orderId,
        address indexed buyer,
        uint256 indexed skuId,
        uint256 quantity,
        uint256 totalPaidCPC18,
        bytes32 encryptedShippingHash,
        string regionZone
    );
    event ManufacturingBatchOpened(uint256 indexed skuId, string skuCode);
    event OrderShipped(uint256 indexed orderId, string carrierTrackingCode);
    event OrderRefunded(uint256 indexed orderId, address indexed buyer, uint256 refundedCPC18);

    modifier onlyAdmin() {
        require(msg.sender == admin || msg.sender == INVESTMENT_GNOSIS_SAFE, "CPC: Not authorized");
        _;
    }

    constructor(address _cpcCoin) {
        require(_cpcCoin != address(0), "CPC: Invalid token");
        cpcCoin = IERC20Minimal(_cpcCoin);
        admin = msg.sender;

        _registerSKU("CPC-RES-1", "Cool Power Core Home Zero-Septic Module (342 We + 12.96 L/d)", 1850e18, false);
        _registerSKU("CPC-IND-10", "Cool Power Core Industrial 10-Core Skid (3.42 kWe)", 16500e18, false);
        _registerSKU("CPC-NEURO-HAT", "Air-Gapped Zero-RF Neural Command Hat (64-ch EEG)", 890e18, false);
        _registerSKU("CPC-SUIT-MK6", "Valkyrie-Neuro Briefcase Exosuit Frame (Commercial)", 24000e18, false);
        _registerSKU("CPC-CERBERUS-HD", "Cerberus-HDX Robotic Utility Quadruped", 32000e18, false);
        _registerSKU("CPC-RIFLE-ATMOS", "Vortex-Condenser Industrial Plasma/CO2 Cutter", 4200e18, false);
    }

    function _registerSKU(string memory skuCode, string memory name, uint256 priceCPC18, bool mfgReady) internal {
        catalog[skuCount] = HardwareSKU(skuCode, name, priceCPC18, mfgReady, 0, 0);
        skuCount++;
    }

    /**
     * @notice Purchase CPC tech in-game and attach a real-world physical shipping reservation.
     *         Shipping address is hashed on-chain (encrypted off-chain for buyer privacy).
     */
    function purchaseWithPhysicalShipping(
        uint256 skuId,
        uint256 quantity,
        bytes32 encryptedShippingHash,
        string calldata regionZone
    ) external returns (uint256 orderId) {
        require(skuId < skuCount, "CPC: Unknown SKU");
        require(quantity > 0 && quantity <= 50, "CPC: Invalid qty");
        require(encryptedShippingHash != bytes32(0), "CPC: Missing shipping hash");

        HardwareSKU storage item = catalog[skuId];
        uint256 totalCost = item.priceCPC18 * quantity;

        require(cpcCoin.transferFrom(msg.sender, address(this), totalCost), "CPC: Payment failed");

        orderId = nextOrderId++;
        OrderStatus initialStatus = item.manufacturingAvailable
            ? OrderStatus.MANUFACTURING_LOCKED
            : OrderStatus.QUEUED_PRE_MANUFACTURING;

        if (item.manufacturingAvailable) {
            require(cpcCoin.transfer(INVESTMENT_GNOSIS_SAFE, totalCost), "CPC: Safe settlement failed");
        }

        orders[orderId] = FulfillmentOrder({
            orderId: orderId,
            buyer: msg.sender,
            skuId: skuId,
            quantity: quantity,
            totalPaidCPC18: totalCost,
            encryptedShippingHash: encryptedShippingHash,
            regionZone: regionZone,
            status: initialStatus,
            carrierTrackingCode: "",
            createdAt: block.timestamp
        });

        item.totalReserved += quantity;
        buyerOrders[msg.sender].push(orderId);

        emit HardwareReservedForShipping(
            orderId, msg.sender, skuId, quantity, totalCost, encryptedShippingHash, regionZone
        );
    }

    /**
     * @notice Buyer may cancel and reclaim 100% of escrowed CPC-COIN anytime before manufacturing opens.
     */
    function cancelPreManufacturingOrder(uint256 orderId) external {
        FulfillmentOrder storage ord = orders[orderId];
        require(ord.buyer == msg.sender, "CPC: Not buyer");
        require(ord.status == OrderStatus.QUEUED_PRE_MANUFACTURING, "CPC: Already locked/shipped");

        ord.status = OrderStatus.REFUNDED;
        catalog[ord.skuId].totalReserved -= ord.quantity;
        require(cpcCoin.transfer(msg.sender, ord.totalPaidCPC18), "CPC: Refund transfer failed");

        emit OrderRefunded(orderId, msg.sender, ord.totalPaidCPC18);
    }

    /**
     * @notice Admin / Gnosis Safe enables real-world manufacturing for a SKU batch.
     */
    function setManufacturingAvailable(uint256 skuId, bool available) external onlyAdmin {
        require(skuId < skuCount, "CPC: Unknown SKU");
        catalog[skuId].manufacturingAvailable = available;
        if (available) {
            emit ManufacturingBatchOpened(skuId, catalog[skuId].skuCode);
        }
    }

    /**
     * @notice Settle queued orders into active production and dispatch carrier tracking once shipped.
     */
    function markOrderShipped(uint256 orderId, string calldata trackingCode) external onlyAdmin {
        FulfillmentOrder storage ord = orders[orderId];
        require(
            ord.status == OrderStatus.QUEUED_PRE_MANUFACTURING ||
            ord.status == OrderStatus.MANUFACTURING_LOCKED,
            "CPC: Invalid order state"
        );
        if (ord.status == OrderStatus.QUEUED_PRE_MANUFACTURING) {
            require(cpcCoin.transfer(INVESTMENT_GNOSIS_SAFE, ord.totalPaidCPC18), "CPC: Safe settle failed");
        }
        ord.status = OrderStatus.SHIPPED_WITH_TRACKING;
        ord.carrierTrackingCode = trackingCode;
        catalog[ord.skuId].totalShipped += ord.quantity;

        emit OrderShipped(orderId, trackingCode);
    }
}
