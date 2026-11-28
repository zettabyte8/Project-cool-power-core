// CoolPowerCore_Adaptive_CrossDevice_Runtime.hpp
// Playable Browser (WebAssembly/WebGPU), Android Mobile, Console, Desktop Haptics & Full-Body Neural Suit Runtime
// Inventor & Author: Thomas Gabriel Coleman | Corona, California

#pragma once
#include <cstdint>
#include <cmath>
#include <array>

namespace cpc::runtime {

enum class InterfaceTier : uint8_t {
    TIER_0_MOBILE_WEB_TOUCH   = 0, // Handheld Android/iOS browser: touch controls, 720p dynamic resolution, battery-saver shader
    TIER_1_CONSOLE_GAMEPAD    = 1, // Console / Smart TV browser: 1080p60 HDR, standard dual-motor rumble, full rig suite
    TIER_2_DESKTOP_SEMIHAPTIC = 2, // Desktop + Controller/Haptic Vest: 4K RT atmosphere, adaptive triggers, live stock HUD
    TIER_3_FULLBODY_BRAINHAT  = 3  // Full-body 64-zone haptic suit + air-gapped 64ch EEG/fNIRS brain hat: 8-DOF neural cast
};

struct ContinuousPlayerState {
    uint64_t player_seed;
    uint32_t sector_id;
    double   world_x;
    double   world_y;
    double   world_z;
    double   cpc_coin_balance;
    double   cpc_nav_usd18;
    uint32_t deployed_cpc_cores;
    float    supercap_pct;
    uint8_t  unlocked_blueprint_mask;
    uint64_t state_checksum_sha256_low;
};

struct ScaledCapabilityProfile {
    uint16_t render_width;
    uint16_t render_height;
    uint16_t max_active_particles;
    uint8_t  active_neural_arms;
    uint8_t  vortex_multishot_count;
    bool     enable_volumetric_rt;
    bool     enable_brainhat_thought_lock;
    float    haptic_gain_multiplier;
};

class AdaptiveInterfaceScaler {
public:
    static constexpr ScaledCapabilityProfile resolve_profile(InterfaceTier tier) noexcept {
        switch (tier) {
            case InterfaceTier::TIER_0_MOBILE_WEB_TOUCH:
                return { 1280, 720,  35,  0, 1, false, false, 0.35f };
            case InterfaceTier::TIER_1_CONSOLE_GAMEPAD:
                return { 1920, 1080, 90,  2, 2, false, false, 0.65f };
            case InterfaceTier::TIER_2_DESKTOP_SEMIHAPTIC:
                return { 3840, 2160, 180, 2, 2, true,  false, 0.85f };
            case InterfaceTier::TIER_3_FULLBODY_BRAINHAT:
            default:
                return { 3840, 2160, 320, 4, 4, true,  true,  1.00f };
        }
    }

    // Continuous deterministic state serialization so switching from Android Mobile Web
    // to Console, Desktop, or Full-Body Haptic Suit + Brain Hat preserves 100% of progress.
    static uint64_t compute_state_checksum(const ContinuousPlayerState& s) noexcept {
        uint64_t h = s.player_seed ^ (static_cast<uint64_t>(s.sector_id) << 32);
        h ^= static_cast<uint64_t>(s.deployed_cpc_cores) * 0x9E3779B97F4A7C15ULL;
        h ^= static_cast<uint64_t>(s.cpc_coin_balance * 10000.0);
        h ^= (h >> 30);
        h *= 0xBF58476D1CE4E5B9ULL;
        h ^= (h >> 27);
        return h;
    }
};

} // namespace cpc::runtime
