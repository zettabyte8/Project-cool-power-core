#pragma once
// CoolPowerCore_Quest_Negotiation_Engine.hpp
// Zero-Heap-Allocation 60 FPS C++20 Module for NPC Quests, Undercut Bidding & Interplanetary Transit
// Author: Thomas Gabriel Coleman | Cool Power Core(TM): Horizons Unbound (v6.5)

#include <cstdint>
#include <cmath>
#include <array>

namespace cpc::quests {

enum class QuestCategory : uint8_t {
    INTERPLANETARY_PASSENGER = 0,
    CARGO_BIDDING_WAR        = 1,
    SUBSEA_MAGLEV_TRANSIT    = 2,
    SANCTUARY_CORE_BUILD     = 3
};

enum class BidStrategy : uint8_t {
    AGGRESSIVE_UNDERCUT_22PCT = 0, // 0.78x rival quote, 96% base win rate
    BALANCED_VALUE_12PCT      = 1, // 0.88x rival quote, 82% base win rate
    PREMIUM_EXPRESS_4PCT      = 2  // 0.96x rival quote, 58% base win rate
};

struct alignas(64) NpcContract {
    uint64_t contract_id;
    QuestCategory category;
    uint8_t  origin_world_id;
    uint8_t  dest_world_id;
    uint8_t  hardware_tier_req;
    float    rival_npc_quote_cpc;     // Chemical/legacy operator bid in CPC-COIN
    float    base_cpc_energy_cost;    // Low marginal cost via 382.93 Wth/core heat recovery
    float    distance_au_or_km;
    float    transit_duration_sec;
    uint32_t reputation_reward;
    bool     active;
    bool     completed;
};

struct PlayerQuestLedger {
    double   cpc_coin_balance;
    double   cpc_nav_usd;
    uint32_t active_cpc_cores;
    uint32_t reputation_score;
    uint8_t  hardware_tier;           // 0=Android, 1=Console, 2=Desktop+SemiHaptics, 3=FullSuit+BrainHat
    uint32_t contracts_won;
    double   cumulative_cpc_earned;
};

inline float ComputeRigHeatRecoveryDiscount(uint8_t hardware_tier) noexcept {
    constexpr std::array<float, 4> kDiscounts = { 0.00f, 0.12f, 0.25f, 0.40f };
    return (hardware_tier < 4) ? kDiscounts[hardware_tier] : 0.40f;
}

inline float ComputeNetTransitCost(const NpcContract& c, uint8_t hardware_tier) noexcept {
    const float discount = ComputeRigHeatRecoveryDiscount(hardware_tier);
    return c.base_cpc_energy_cost * (1.0f - discount);
}

struct BidEvaluationResult {
    bool  accepted;
    float player_bid_cpc;
    float net_transit_cost_cpc;
    float projected_net_profit_cpc;
    float effective_win_probability;
};

inline BidEvaluationResult EvaluateNpcNegotiation(
    const NpcContract& contract,
    const PlayerQuestLedger& player,
    BidStrategy strategy,
    uint64_t deterministic_rng_sample
) noexcept {
    float mult = 0.88f;
    float base_prob = 0.82f;
    if (strategy == BidStrategy::AGGRESSIVE_UNDERCUT_22PCT) { mult = 0.78f; base_prob = 0.96f; }
    else if (strategy == BidStrategy::PREMIUM_EXPRESS_4PCT)   { mult = 0.96f; base_prob = 0.58f; }

    const float bid = contract.rival_npc_quote_cpc * mult;
    const float net_cost = ComputeNetTransitCost(contract, player.hardware_tier);

    // Reputation adds up to +12% trust bonus during NPC haggling
    const float rep_bonus = std::fmin(0.12f, static_cast<float>(player.reputation_score) * 0.00025f);
    const float win_prob = std::fmin(0.99f, base_prob + rep_bonus);

    if (player.cpc_coin_balance < static_cast<double>(net_cost)) {
        return { false, bid, net_cost, bid - net_cost, win_prob };
    }

    const float roll = static_cast<float>(deterministic_rng_sample & 0xFFFFULL) / 65535.0f;
    const bool won = (roll <= win_prob);
    return { won, bid, net_cost, bid - net_cost, win_prob };
}

} // namespace cpc::quests
