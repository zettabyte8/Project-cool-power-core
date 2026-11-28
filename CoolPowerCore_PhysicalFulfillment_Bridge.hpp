#pragma once
#include <cstdint>
#include <cstring>
#include <array>

namespace cpc::fulfillment {

enum class FulfillmentMode : uint8_t {
    IN_GAME_DIGITAL_ONLY = 0,
    PHYSICAL_SHIPPING_WHEN_AVAILABLE = 1
};

enum class OrderLifecycle : uint8_t {
    QUEUED_PRE_MANUFACTURING = 0,
    MANUFACTURING_BATCH_OPEN = 1,
    IN_TRANSIT_CARRIER = 2,
    DELIVERED = 3,
    REFUNDED_ESCROW = 4
};

struct alignas(64) HardwareCatalogItem {
    uint16_t skuId;
    char skuCode[24];
    char displayName[64];
    double priceCPC;
    double thermalRatingWth;
    double netElectricWe;
    double pureWaterLDay;
    uint8_t manufacturingReady; // 0 = Queued for Batch 1 Production, 1 = Ready to Ship
    uint32_t globalQueueCount;
};

struct alignas(64) PhysicalShippingOrder {
    uint64_t orderId;
    uint16_t skuId;
    uint16_t quantity;
    double escrowedCPC;
    FulfillmentMode mode;
    OrderLifecycle status;
    char recipientName[48];
    char shippingAddress[96];
    char regionCode[16];      // e.g., "US-CA", "US-ALL", "EU", "APAC"
    char shippingHashHex[65]; // Privacy-preserving SHA-256 commitment
    char trackingNumber[32];
};

class RealWorldFulfillmentBridge {
public:
    static constexpr size_t MAX_SKUS = 8;
    static constexpr size_t MAX_ORDERS = 64;

    std::array<HardwareCatalogItem, MAX_SKUS> catalog{};
    std::array<PhysicalShippingOrder, MAX_ORDERS> orders{};
    size_t orderCount = 0;

    void initDefaultCatalog() noexcept {
        catalog[0] = {0, "CPC-RES-1", "Home Zero-Septic Module (342 We + 12.96 L/d)", 1850.0, 382.93, 342.4, 12.96, 0, 1420};
        catalog[1] = {1, "CPC-NEURO-HAT", "Air-Gapped Zero-RF Neural Brain Hat", 890.0, 0.0, 0.0, 0.0, 0, 3180};
        catalog[2] = {2, "CPC-IND-10", "Industrial 10-Core Microgrid Skid (3.42 kWe)", 16500.0, 3829.3, 3424.0, 129.6, 0, 412};
        catalog[3] = {3, "CPC-SUIT-MK6", "Valkyrie-Neuro Briefcase Flight Exosuit", 24000.0, 765.86, 615.0, 18.4, 0, 295};
        catalog[4] = {4, "CPC-CERBERUS-HD", "Cerberus-HDX Tri-Headed Robotic Mount", 32000.0, 765.86, 626.0, 17.5, 0, 188};
        catalog[5] = {5, "CPC-RIFLE-ATMOS", "Vortex-Condenser Plasma/CO2 Industrial Cutter", 4200.0, 382.93, 318.4, 8.2, 0, 640};
    }

    bool placePhysicalOrder(uint16_t skuId, uint16_t qty, const char* name, const char* addr,
                            const char* region, const char* hashHex, double& playerCPCBalance) noexcept {
        if (skuId >= 6 || qty == 0 || orderCount >= MAX_ORDERS) return false;
        double totalCost = catalog[skuId].priceCPC * static_cast<double>(qty);
        if (playerCPCBalance < totalCost) return false;

        playerCPCBalance -= totalCost;
        catalog[skuId].globalQueueCount += qty;

        PhysicalShippingOrder& o = orders[orderCount];
        o.orderId = 10000 + orderCount + 1;
        o.skuId = skuId;
        o.quantity = qty;
        o.escrowedCPC = totalCost;
        o.mode = FulfillmentMode::PHYSICAL_SHIPPING_WHEN_AVAILABLE;
        o.status = catalog[skuId].manufacturingReady ? OrderLifecycle::MANUFACTURING_BATCH_OPEN
                                                     : OrderLifecycle::QUEUED_PRE_MANUFACTURING;
        std::strncpy(o.recipientName, name, sizeof(o.recipientName) - 1);
        std::strncpy(o.shippingAddress, addr, sizeof(o.shippingAddress) - 1);
        std::strncpy(o.regionCode, region, sizeof(o.regionCode) - 1);
        std::strncpy(o.shippingHashHex, hashHex, sizeof(o.shippingHashHex) - 1);
        std::strncpy(o.trackingNumber, "PENDING-BATCH-1", sizeof(o.trackingNumber) - 1);
        orderCount++;
        return true;
    }
};

} // namespace cpc::fulfillment
