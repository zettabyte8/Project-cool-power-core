#pragma once
#include <cstdint>
#include <cstring>
#include <array>

// ============================================================================
// Cool Power Core (TM): Horizons Unbound - V4 Engine & Inventor Patronage Module
// Author: Thomas Gabriel Coleman (Corona, CA, USA)
// Target: Cross-Platform 60 FPS (16.666 ms) Zero-Allocation Deterministic Kernel
// ============================================================================

namespace cpc_engine_v4 {

enum class PatronTier : uint8_t {
    NONE               = 0,
    SPARK_SUPPORTER    = 1, // >= $10 USD equivalent
    CORE_BUILDER       = 2, // >= $100 USD equivalent
    SANCTUARY_FOUNDER  = 3, // >= $1,000 USD equivalent
    FRONTIER_ARCHITECT = 4  // >= $10,000 USD equivalent
};

enum class DonationRail : uint8_t {
    ONCHAIN_CPC_COIN     = 0, // Zero-fee CPC-COIN transfer on Base / Ethereum / Arbitrum
    ONCHAIN_BASE_USDC    = 1, // Base Chain (8453) USDC / ETH / Aerodrome LP tip
    ONCHAIN_ROBINHOOD_L2 = 2, // Robinhood Chain (46630) tokenized stock/cash tip
    YIELD_STREAM_PLEDGE  = 3, // Optional % of CPC-COIN Staking/Beefy/Lido yield
    FIAT_CARD_APPLE_PAY  = 4, // GitHub Sponsors / Stripe / Ko-fi / OpenCollective
    ACH_WIRE_GRANT       = 5  // Institutional R&D / Sanctuary City Seed Grant
};

struct alignas(64) InventorPatronageState {
    uint64_t player_entity_id;
    uint64_t lifetime_donated_cents;
    uint32_t founder_monument_plaque_id; // Inscribed in Sanctuary City Central Agora
    uint16_t yield_pledge_bps;           // 0 to 10000 bps (optional yield split)
    PatronTier current_tier;
    bool unlocked_golden_core_skin;      // Cosmetic only - never pay-to-win
    bool unlocked_founder_wing_emblem;   // Cosmetic emblem for CPC-SUIT-MK6 & Cerberus
    char custom_plaque_inscription[32];  // Engraved on in-game Inventor Plaza Wall
};

// Evaluates Patron Tier & unlocks non-pay-to-win commemorative cosmetics
inline void UpdatePatronTier(InventorPatronageState& state) noexcept {
    if (state.lifetime_donated_cents >= 1000000ULL) {
        state.current_tier = PatronTier::FRONTIER_ARCHITECT;
        state.unlocked_golden_core_skin = true;
        state.unlocked_founder_wing_emblem = true;
    } else if (state.lifetime_donated_cents >= 100000ULL) {
        state.current_tier = PatronTier::SANCTUARY_FOUNDER;
        state.unlocked_golden_core_skin = true;
        state.unlocked_founder_wing_emblem = true;
    } else if (state.lifetime_donated_cents >= 10000ULL) {
        state.current_tier = PatronTier::CORE_BUILDER;
        state.unlocked_golden_core_skin = true;
        state.unlocked_founder_wing_emblem = false;
    } else if (state.lifetime_donated_cents >= 1000ULL) {
        state.current_tier = PatronTier::SPARK_SUPPORTER;
        state.unlocked_golden_core_skin = false;
        state.unlocked_founder_wing_emblem = false;
    } else {
        state.current_tier = PatronTier::NONE;
    }
}

// Processes a verified on-chain or fiat donation callback in < 0.002 ms (O(1), zero heap alloc)
inline void OnVerifiedInventorDonation(
    InventorPatronageState& state,
    uint64_t amount_cents,
    const char* inscription_utf8
) noexcept {
    state.lifetime_donated_cents += amount_cents;
    UpdatePatronTier(state);
    if (inscription_utf8 != nullptr && inscription_utf8[0] != '\0') {
        std::strncpy(state.custom_plaque_inscription, inscription_utf8, 31);
        state.custom_plaque_inscription[31] = '\0';
    }
}

} // namespace cpc_engine_v4
