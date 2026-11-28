// CoolPowerCore_Corporate_Staffing_Engine.hpp
// Cross-Platform C++20 Zero-Allocation Corporate Org-Chart & Autonomous NPC Payroll Engine
// Founder & Executive Chairman (Tier-0 Sovereign Authority above CEO): Thomas Gabriel Coleman

#pragma once
#include <cstdint>
#include <array>
#include <string_view>

namespace cpc::corporate {

enum class AuthorityRank : uint8_t {
    EXECUTIVE_CHAIRMAN_FOUNDER = 0, // Thomas Gabriel Coleman (Above CEO; Veto & Strategy Authority)
    CHIEF_EXECUTIVE_OFFICER    = 1, // Reports directly to Executive Chairman
    C_SUITE_EXECUTIVE          = 2, // CTO, CFO, COO, CLO, CMO, Chief Safety Officer
    VP_DIVISION_DIRECTOR       = 3, // Foundry, Sanctuary Cities, Subsea/Orbital, AI & Web3
    LEAD_ENGINEER_ARCHITECT    = 4, // Thermodynamics, Plasma, Robotics, Smart Contracts
    OPERATIONS_ARTISAN_STAFF   = 5  // Guild Instructors, QA Technicians, Logistics Dispatchers
};

enum class SeatHolderType : uint8_t {
    AI_NPC_AGENT   = 0, // Autonomous AI NPC staffing the role & spending earned CPC wages
    HUMAN_EMPLOYEE = 1  // Real-world human hire (automatically supersedes AI NPC upon onboarding)
};

struct CorporateRoleSeat {
    uint16_t       seat_id;
    AuthorityRank  rank;
    SeatHolderType holder_type;
    uint32_t       employee_entity_id;
    double         hourly_wage_cpc;       // Paid in CPC-COIN from operational treasury
    double         accrued_wallet_cpc;    // Spendable balance used by AI NPC or Human
    double         spent_in_economy_cpc;  // Amount AI NPC spent on goods, stocks, or housing
    uint8_t        efficiency_bps;        // 10000 = 100.00%
};

class CoolPowerCoreOrgEngine {
public:
    static constexpr uint16_t TOTAL_CORPORATE_SEATS = 64;
    static constexpr double   NPC_CONSUMPTION_RATIO = 0.72; // AI NPCs spend 72% of wages back into CPC economy

    void initialize_org_chart() noexcept {
        // Seat 0: Executive Chairman & Founder (Above CEO)
        seats_[0] = {0, AuthorityRank::EXECUTIVE_CHAIRMAN_FOUNDER, SeatHolderType::HUMAN_EMPLOYEE, 1, 0.0, 0.0, 0.0, 10000};
        // Seat 1: Chief Executive Officer (AI-CEO-01 until filled by human)
        seats_[1] = {1, AuthorityRank::CHIEF_EXECUTIVE_OFFICER, SeatHolderType::AI_NPC_AGENT, 1001, 18.50, 420.0, 0.0, 9850};
        // Remaining 62 seats populated across C-Suite, VPs, Engineers, and Sanctuary Operations
        for (uint16_t i = 2; i < TOTAL_CORPORATE_SEATS; ++i) {
            AuthorityRank r = (i < 8)  ? AuthorityRank::C_SUITE_EXECUTIVE :
                              (i < 18) ? AuthorityRank::VP_DIVISION_DIRECTOR :
                              (i < 40) ? AuthorityRank::LEAD_ENGINEER_ARCHITECT :
                                         AuthorityRank::OPERATIONS_ARTISAN_STAFF;
            double wage = (r == AuthorityRank::C_SUITE_EXECUTIVE)      ? 14.00 :
                          (r == AuthorityRank::VP_DIVISION_DIRECTOR)   ? 10.50 :
                          (r == AuthorityRank::LEAD_ENGINEER_ARCHITECT)? 7.50  : 4.25;
            seats_[i] = {i, r, SeatHolderType::AI_NPC_AGENT, static_cast<uint32_t>(1000 + i), wage, 85.0, 0.0, 9600};
        }
    }

    // Accrues hourly/tick wages and triggers autonomous AI NPC spending into the CPC economy
    double process_payroll_tick(double elapsed_hours) noexcept {
        double total_npc_economic_spend = 0.0;
        for (auto& seat : seats_) {
            if (seat.rank == AuthorityRank::EXECUTIVE_CHAIRMAN_FOUNDER) continue;
            double earned = seat.hourly_wage_cpc * elapsed_hours;
            seat.accrued_wallet_cpc += earned;
            if (seat.holder_type == SeatHolderType::AI_NPC_AGENT && seat.accrued_wallet_cpc >= 25.0) {
                double spend = seat.accrued_wallet_cpc * NPC_CONSUMPTION_RATIO;
                seat.accrued_wallet_cpc   -= spend;
                seat.spent_in_economy_cpc += spend;
                total_npc_economic_spend  += spend; // Recycles via 0.25% swap fee into CPC-COIN NAV
            }
        }
        return total_npc_economic_spend;
    }

    // Executive Chairman (Thomas Gabriel Coleman) or HR assigns a real human to replace an AI NPC seat
    bool fill_seat_with_human(uint16_t seat_id, uint32_t human_user_id) noexcept {
        if (seat_id == 0 || seat_id >= TOTAL_CORPORATE_SEATS) return false;
        seats_[seat_id].holder_type        = SeatHolderType::HUMAN_EMPLOYEE;
        seats_[seat_id].employee_entity_id = human_user_id;
        seats_[seat_id].accrued_wallet_cpc = 0.0; // Fresh payroll ledger for incoming human
        seats_[seat_id].efficiency_bps     = 10000;
        return true;
    }

    // Revert seat to autonomous AI NPC if human steps down
    bool revert_seat_to_ai_npc(uint16_t seat_id) noexcept {
        if (seat_id == 0 || seat_id >= TOTAL_CORPORATE_SEATS) return false;
        seats_[seat_id].holder_type        = SeatHolderType::AI_NPC_AGENT;
        seats_[seat_id].employee_entity_id = static_cast<uint32_t>(1000 + seat_id);
        return true;
    }

private:
    std::array<CorporateRoleSeat, TOTAL_CORPORATE_SEATS> seats_{};
};

} // namespace cpc::corporate
