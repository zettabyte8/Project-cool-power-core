#pragma once
#include <cstdint>
#include <cmath>
#include <array>
#include <string_view>

namespace CoolPowerCore::EngineV5 {

// ============================================================================
// INVENTOR TREASURY & PATRONAGE CONSTANTS (THOMAS GABRIEL COLEMAN)
// ============================================================================
inline constexpr std::string_view kInvestmentGnosisSafe = "0xB386f10EAd67f6cDd7Ee8662c8749354E8B48b37";
inline constexpr std::string_view kDonateEvmAddress     = "0x1419734ee0d1e213f4496d6bf088cc3b480ccedf";
inline constexpr std::string_view kDonateBtcCakePay     = "howeyecrypto@cake.cash";
inline constexpr std::string_view kDonateSolAddress     = "2eRUANUAcvyWw1fyHnBSS53g4pWURXcE4se1WRW6H3Nr";

// Locked 60 FPS Deterministic Simulation Constants
inline constexpr double   kFixedDeltaTimeSec   = 1.0 / 60.0; // 16.6667 ms
inline constexpr double   kCoreEnthalpyOffsetW = 382.93;     // Authentic CPC thermal core
inline constexpr uint32_t kMaxAiMerchants      = 2048;
inline constexpr uint32_t kMaxStockTickers     = 32;

// ============================================================================
// DETERMINISTIC SPLITMIX64 WITH MILD BOUNDED RANDOMIZATION (+/-8% TO +/-22%)
// ============================================================================
struct SplitMix64 {
    uint64_t state;
    constexpr explicit SplitMix64(uint64_t seed) noexcept : state(seed) {}

    constexpr uint64_t next_u64() noexcept {
        uint64_t z = (state += 0x9e3779b97f4a7c15ULL);
        z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ULL;
        z = (z ^ (z >> 27)) * 0x94d049bb133111ebULL;
        return z ^ (z >> 31);
    }

    constexpr double next_unit() noexcept {
        return static_cast<double>(next_u64() >> 11) * (1.0 / 9007199254740992.0);
    }

    constexpr double mild_variance(double pct_bound) noexcept {
        // Returns multiplier in [1.0 - pct_bound, 1.0 + pct_bound]
        return 1.0 + ((next_unit() * 2.0) - 1.0) * pct_bound;
    }
};

// ============================================================================
// REAL-WORLD STOCK MARKET & MULTI-CHAIN CPC-COIN RESERVE MIRROR
// ============================================================================
struct MarketTicker {
    char     symbol[8];
    double   realWorldPriceUSD;
    double   dailyChangePct;
    bool     isRobinhoodChainTokenized;
};

struct CpcReserveState {
    double totalBasketUSD;
    double totalCpcSupply;
    double navUSD;
    double dailyDexVolumeUSD;
    double aerodromeBaseApr;   // Base Chain ID 8453
    double lidoBeefyApr;       // Lido wstETH + Beefy.com + Sky sUSDS
    double robinhoodL2Apr;     // Robinhood Chain L2 ID 46630
    double totalDonatedUSD;

    constexpr void step_60hz_compounding() noexcept {
        if (totalCpcSupply <= 0.0) return;
        // Weighted net yield floor ~7.84% APR + 0.25% AI Merchant swap fee recycling
        constexpr double kWeightedApr = 0.0784;
        constexpr double kSecondsPerYear = 31536000.0;
        const double yieldTick = totalBasketUSD * (kWeightedApr / kSecondsPerYear) * kFixedDeltaTimeSec;
        const double feeTick   = (dailyDexVolumeUSD / 86400.0) * 0.0025 * kFixedDeltaTimeSec;
        totalBasketUSD += (yieldTick + feeTick);
        navUSD = totalBasketUSD / totalCpcSupply;
    }
};

// ============================================================================
// AUTONOMOUS AI MERCHANT NPC CLASS (2,048 ACTIVE AGENTS)
// ============================================================================
enum class MerchantGuild : uint8_t {
    ThermalWaterArbitrager = 0,
    AerodromeBaseMaker     = 1,
    RobinhoodEquityDealer  = 2,
    ArtisanalCraftBroker   = 3,
    FrontierGearQuartermaster = 4
};

struct alignas(32) AiMerchantNpc {
    uint32_t      id;
    MerchantGuild guild;
    float         haggleQuirkFactor; // Mild +/-12% personality pricing spread
    double        cpcInventory;
    double        stableBalanceUSD;
    double        cumulativeSwapVolumeUSD;

    constexpr void tick_trade(SplitMix64& rng, CpcReserveState& reserve) noexcept {
        if ((rng.next_u64() & 0x3FFULL) == 0) { // ~3.5 trades/min per merchant
            const double tradeUSD = (45.0 + rng.next_unit() * 420.0) * haggleQuirkFactor;
            cumulativeSwapVolumeUSD += tradeUSD;
            reserve.dailyDexVolumeUSD += tradeUSD;
        }
    }
};

// ============================================================================
// SANCTUARY CITY PATRONAGE KIOSK & NON-PAY-TO-WIN TIERS
// ============================================================================
enum class PatronTier : uint8_t {
    Explorer          = 0, // Free full educational & world access
    SparkSupporter    = 1, // $10+   Wall of Gratitude inscription
    CoreBuilder       = 2, // $100+  Commemorative Gold/Graphene CPC skin
    SanctuaryFounder  = 3, // $1,000+ Custom Agora Statue & Guild Banner
    FrontierArchitect = 4  // $10,000+ Naming rights on orbital/ridge research outpost
};

constexpr PatronTier evaluate_patron_tier(double donatedUSD) noexcept {
    if (donatedUSD >= 10000.0) return PatronTier::FrontierArchitect;
    if (donatedUSD >= 1000.0)  return PatronTier::SanctuaryFounder;
    if (donatedUSD >= 100.0)   return PatronTier::CoreBuilder;
    if (donatedUSD >= 10.0)    return PatronTier::SparkSupporter;
    return PatronTier::Explorer;
}

} // namespace CoolPowerCore::EngineV5
