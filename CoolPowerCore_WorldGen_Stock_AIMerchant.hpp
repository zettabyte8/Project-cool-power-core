#pragma once
#include <cstdint>
#include <cmath>
#include <array>
#include <algorithm>

namespace CoolPowerCore::HorizonsUnbound {

struct RealWorldStockTicker {
    char symbol[8];
    double realMarketPriceUSD;   // Mirrored via signed Pyth / Chainlink / Robinhood Chain feed
    double dailyChangePct;       // Live intraday delta (%)
    double dividendYieldPct;     // Annualized dividend / T-bill yield recycled to CPC NAV
    bool isCleanEnergyOrTech;    // Boosts in-game Sanctuary City & R&D bond multipliers
};

enum class MerchantArchetype : uint8_t {
    ARTISANAL_GUILD_BROKER = 0,  // Trades Sanctuary City timber, graphene, ceramics & textiles
    THERMAL_UTILITY_ARBITRAGER,  // Balances +337.9 We/core surplus power & 12.96 L/day pure water
    AERODROME_LP_MARKET_MAKER,   // Executes Base chain CPC/USDC & CPC/wstETH arbitrage loops
    ROBINHOOD_EQUITY_DEALER,     // Settles tokenized real-world stock & ETF trades in CPC-COIN
    FRONTIER_SALVAGE_QUARTERMASTER // Equips Mars plasma sabers, MK6 suits & Cerberus hounds
};

struct AIMerchantNPC {
    uint32_t npcId;
    MerchantArchetype archetype;
    int64_t sectorX;
    int64_t sectorZ;
    double cpcInventoryBalance;
    double localCurrencyReserve;
    double dailyTradeVolumeUSD;
    double spreadBps;            // 15-40 bps dynamic spread; 25 bps routed straight to CPC NAV
    uint32_t personalitySeed;    // Deterministic mild randomization for haggling & rare blueprints
};

struct ProceduralWorldGenConfig {
    uint64_t baseWorldSeed;
    float mildRandomnessFactor;  // Clamped [0.08f, 0.22f]: keeps thermodynamics real, worlds fun!
};

class SimulationEconomyAndWorldEngine {
public:
    static constexpr uint32_t MAX_MERCHANTS = 2048;
    static constexpr uint32_t MAX_STOCKS    = 64;

    // SplitMix64 fast deterministic PRNG (Doom-speed, zero heap allocation, cross-platform)
    static inline uint64_t splitMix64(uint64_t& state) noexcept {
        uint64_t z = (state += 0x9E3779B97F4A7C15ULL);
        z = (z ^ (z >> 30)) * 0xBF58476D1CE4E5B9ULL;
        z = (z ^ (z >> 27)) * 0x94D049BB133111EBULL;
        return z ^ (z >> 31);
    }

    static inline float nextUnitFloat(uint64_t& state) noexcept {
        return static_cast<float>(splitMix64(state) >> 40) * (1.0f / 16777216.0f);
    }

    /**
     * @brief Generates mild procedural variation (+/- 8% to 22%) for planetary terrain,
     *        weather anomalies, rare salvage caches, and NPC personality quirks while
     *        strictly preserving real-world Cool Power Core physics (382.93 Wth/core).
     */
    static inline void generateSectorModifiers(
        uint64_t baseSeed,
        int64_t sectorX,
        int64_t sectorZ,
        float randomnessScale,
        float& outTerrainRelief,
        float& outWeatherAnomaly,
        uint32_t& outRareBlueprintRoll
    ) noexcept {
        float clamped = std::clamp(randomnessScale, 0.05f, 0.25f);
        uint64_t s = baseSeed ^ (static_cast<uint64_t>(sectorX) * 0x9E3779B185EBCA87ULL)
                                ^ (static_cast<uint64_t>(sectorZ) * 0xC2B2AE3D27D4EB4FULL);
        float r1 = (nextUnitFloat(s) * 2.0f - 1.0f) * clamped;
        float r2 = (nextUnitFloat(s) * 2.0f - 1.0f) * clamped;
        outTerrainRelief  = 1.0f + r1; // e.g., 0.85x to 1.15x canyon/hill height
        outWeatherAnomaly = 1.0f + r2; // Mild storm/aurora variation driving real Delta-T play
        outRareBlueprintRoll = static_cast<uint32_t>(splitMix64(s) % 1000ULL);
    }

    /**
     * @brief Executes one 60Hz tick of autonomous AI Merchant NPC market-making.
     *        Every NPC trade routes 0.25% swap fee into global CPC-COIN NAV.
     */
    static inline double tickAIMerchantActivity(
        AIMerchantNPC& npc,
        const RealWorldStockTicker& linkedStock,
        double liveCpcNavUSD,
        uint64_t& rngState,
        double dtSeconds
    ) noexcept {
        float jitter = 0.85f + 0.30f * nextUnitFloat(rngState);
        double marketMomentum = 1.0 + (linkedStock.dailyChangePct * 0.01);
        double tradeNotionalUSD = (125.0 * jitter * marketMomentum) * dtSeconds;

        if (npc.localCurrencyReserve >= tradeNotionalUSD && liveCpcNavUSD > 0.0) {
            double cpcBought = tradeNotionalUSD / liveCpcNavUSD;
            npc.localCurrencyReserve -= tradeNotionalUSD;
            npc.cpcInventoryBalance  += cpcBought;
            npc.dailyTradeVolumeUSD  += tradeNotionalUSD;
            // 0.25% swap fee recycled directly into global CPC reserve basket
            return tradeNotionalUSD * 0.0025;
        }
        return 0.0;
    }
};

} // namespace CoolPowerCore::HorizonsUnbound
