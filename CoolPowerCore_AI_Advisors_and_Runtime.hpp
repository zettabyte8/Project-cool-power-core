#pragma once
// CoolPowerCore_AI_Advisors_and_Runtime.hpp
// Cross-Platform 60 FPS Engine Integration for Gemini AI (google.com), Venice.ai & Game Master AI
// Invented by Thomas Gabriel Coleman (Corona, CA)

#include <cstdint>
#include <array>
#include <string_view>

namespace cpc::ai {

enum class AdvisorPersona : uint8_t {
    GEMINI_GOOGLE = 0, // Lead Systems, Thermodynamics & Hardware Engineering Mentor
    VENICE_AI     = 1, // Sovereign DeFi, Aerodrome/Lido/Robinhood Yield & Zero-RF Security Architect
    GAME_MASTER   = 2  // Sanctuary City Lore, 2,048 AI Merchants & Procedural Quest Director
};

enum class DeviceTier : uint8_t {
    TIER0_MOBILE_ANDROID = 0,
    TIER1_CONSOLE_TV     = 1,
    TIER2_DESKTOP_HAPTIC = 2,
    TIER3_BRAIN_HAT_SUIT = 3
};

struct alignas(64) AdvisorContextSnapshot {
    AdvisorPersona activePersona;
    DeviceTier     deviceTier;
    uint32_t       activeCpcNodes;
    double         netElectricWatts;
    double         pureWaterLitersPerDay;
    double         playerCpcBalance;
    double         cpcReserveNavUsd;
    uint32_t       activeNpcMerchants;
};

struct AdvisorResponsePacket {
    AdvisorPersona   persona;
    std::string_view displayName;
    std::string_view domainSpecialty;
    bool             requiresExternalBridge; // False when using deterministic on-device knowledge core
};

constexpr std::array<AdvisorResponsePacket, 3> kAdvisorRegistry = {{
    { AdvisorPersona::GEMINI_GOOGLE, "Gemini AI (google.com)", "Cool Power Core Thermodynamics, Flight Suits & Sanctuary Cities", false },
    { AdvisorPersona::VENICE_AI,     "Venice.ai",              "CPC-COIN Multi-Chain Yield, Privacy & Air-Gapped Brain-Hat Security", false },
    { AdvisorPersona::GAME_MASTER,   "Game Master AI",         "Procedural Quests, 2,048 AI Merchant NPCs & Frontier Lore", false }
}};

inline AdvisorContextSnapshot BuildLiveSnapshot(
    AdvisorPersona persona,
    DeviceTier tier,
    uint32_t nodes,
    double cpcBalance,
    double navUsd
) noexcept {
    constexpr double kNetWattsPerCore = 342.40;
    constexpr double kWaterLitersPerCore = 12.96;
    return AdvisorContextSnapshot{
        persona,
        tier,
        nodes,
        static_cast<double>(nodes) * kNetWattsPerCore,
        static_cast<double>(nodes) * kWaterLitersPerCore,
        cpcBalance,
        navUsd,
        2048u
    };
}

} // namespace cpc::ai
