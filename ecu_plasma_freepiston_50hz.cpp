/**
 * @file ecu_plasma_freepiston_50hz.cpp
 * @brief Real-Time ECU State Machine & 50 Hz Phase-Locked Controller
 *        for Opposed Free-Piston Plasma-HVAC Hybrid Reactor
 *
 * Target Hardware: Dual-Core ARM Cortex-M7 + FPGA Timer Co-Processor (10 ns resolution)
 * Cycle Frequency: 50.00 Hz (20,000 us period)
 */

#include <cstdint>
#include <cmath>

// --- Hardware Thresholds & Safety Limits (25,000-Hr Durability Envelope) ---
constexpr float MAX_N52H_MAGNET_TEMP_C     = 105.0f; // Hard cutoff below 120C Curie limit
constexpr float TARGET_RESERVOIR_TEMP_C   = 90.0f;  // Optimal preheat for cavitation
constexpr float MAX_SUPPLY_OZONE_PPM      = 0.010f; // ASHRAE/UL breathing zone limit
constexpr float MIN_AIR_BEARING_PRESS_KPA = 240.0f; // Protects 5-micron clearance
constexpr uint32_t CYCLE_PERIOD_US        = 20000;  // 50 Hz exact period

enum class SystemState : uint8_t {
    BOOT_SELF_TEST = 0,
    AIR_BEARING_SPINUP,
    PREHEAT_CAVITATION_PRIME,
    ACTIVE_50HZ_PLASMA_RUN,
    FAULT_SAFE_SHUTDOWN
};

enum class HvacFluidicMode : uint8_t {
    MODE_1_ADIABATIC_CONDENSER_COOLING = 1,
    MODE_2_SMOG_VOC_SCRUBBING          = 2,
    MODE_3_DESICCANT_NIGHT_PURGE       = 3
};

struct SensorTelemetry {
    float piston_pos_mm;          // LVDT / linear encoder position (0.0 to 40.0 mm TDC)
    float piston_vel_ms;          // Instantaneous velocity (m/s)
    float magnet_temp_c;          // N52H stator temperature
    float reservoir_temp_c;       // Water reservoir temperature
    float bearing_pressure_kpa;   // Dry air-bearing manifold pressure
    float supply_duct_o3_ppm;     // Downstream SCR catalyst ozone sensor
    float intake_rh_pct;          // Relative humidity entering cavitator
    float outdoor_temp_c;         // RTU ambient temperature
    float indoor_pm25_ugm3;       // Indoor particulate sensor
    float dc_bus_high_v;          // Linear alternator + PZT rectified bus (400V nom)
    float dc_bus_low_v;           // ECU + ZVS + Cavitator bus (24V / 4.2V rail)
};

struct ActuatorOutputs {
    bool air_bearing_solenoid;
    bool zvs_plasma_gate_enable;
    uint16_t zvs_pulse_width_ns;      // Nanosecond streamer control (50 - 250 ns)
    uint8_t cavitator_duty_pct;       // 15W - 30W ultrasonic/vortex drive
    uint8_t fluidic_splitter_pwm;     // Vortex amplifier control port bias (0-100%)
    uint8_t vgt_vane_position_pct;    // Variable Geometry Turbocharger backpressure
    bool condenser_mist_valve;        // Routes cold steam to HVAC condenser
    bool desiccant_loop_valve;        // Routes 90C water to desiccant wheel
    float linear_alt_load_ohms;       // Active impedance matching for 50 Hz resonance
};

class FreePistonPlasmaECU {
private:
    SystemState state_ = SystemState::BOOT_SELF_TEST;
    HvacFluidicMode hvac_mode_ = HvacFluidicMode::MODE_2_SMOG_VOC_SCRUBBING;
    uint32_t fault_code_ = 0;

    // Evaluate safety interlocks on every 100 us control tick
    bool checkSafetyInterlocks(const SensorTelemetry& t) {
        if (t.magnet_temp_c >= MAX_N52H_MAGNET_TEMP_C) {
            fault_code_ = 0x01; // Over-temp: N52H demagnetization risk
            return false;
        }
        if (t.supply_duct_o3_ppm > MAX_SUPPLY_OZONE_PPM) {
            fault_code_ = 0x02; // SCR breakthrough: Ozone above 0.01 ppm
            return false;
        }
        if (state_ >= SystemState::PREHEAT_CAVITATION_PRIME &&
            t.bearing_pressure_kpa < MIN_AIR_BEARING_PRESS_KPA) {
            fault_code_ = 0x03; // Air bearing pressure loss: 5 um seizure risk
            return false;
        }
        return true;
    }

    // Select optimal HVAC fluidic routing based on Zone 3B climate & IAQ telemetry
    void updateHvacMode(const SensorTelemetry& t) {
        if (t.indoor_pm25_ugm3 > 15.0f) {
            hvac_mode_ = HvacFluidicMode::MODE_2_SMOG_VOC_SCRUBBING;
        } else if (t.outdoor_temp_c > 29.0f && t.intake_rh_pct < 45.0f) {
            hvac_mode_ = HvacFluidicMode::MODE_1_ADIABATIC_CONDENSER_COOLING;
        } else {
            hvac_mode_ = HvacFluidicMode::MODE_3_DESICCANT_NIGHT_PURGE;
        }
    }

public:
    ActuatorOutputs stepControlLoop(const SensorTelemetry& t, uint32_t cycle_time_us) {
        ActuatorOutputs out{};

        if (!checkSafetyInterlocks(t)) {
            state_ = SystemState::FAULT_SAFE_SHUTDOWN;
        }

        switch (state_) {
            case SystemState::BOOT_SELF_TEST:
                out.air_bearing_solenoid = true;
                state_ = SystemState::AIR_BEARING_SPINUP;
                break;

            case SystemState::AIR_BEARING_SPINUP:
                out.air_bearing_solenoid = true;
                if (t.bearing_pressure_kpa >= MIN_AIR_BEARING_PRESS_KPA + 20.0f) {
                    state_ = SystemState::PREHEAT_CAVITATION_PRIME;
                }
                break;

            case SystemState::PREHEAT_CAVITATION_PRIME:
                out.air_bearing_solenoid = true;
                out.cavitator_duty_pct = 50; // 15W mist generation
                // Motor linear alternators briefly to initiate 50 Hz oscillation
                if (t.reservoir_temp_c >= 65.0f && t.piston_pos_mm > 35.0f) {
                    state_ = SystemState::ACTIVE_50HZ_PLASMA_RUN;
                }
                break;

            case SystemState::ACTIVE_50HZ_PLASMA_RUN:
                out.air_bearing_solenoid = true;
                updateHvacMode(t);

                // 1. Humidity-trimmed cavitation (15W base, up to 30W in Mode 1)
                if (hvac_mode_ == HvacFluidicMode::MODE_1_ADIABATIC_CONDENSER_COOLING) {
                    out.cavitator_duty_pct = 100; // Full 30W cold steam for condenser
                    out.condenser_mist_valve = true;
                    out.desiccant_loop_valve = false;
                } else if (hvac_mode_ == HvacFluidicMode::MODE_3_DESICCANT_NIGHT_PURGE) {
                    out.cavitator_duty_pct = 50;  // 15W optimal cracking humidity
                    out.condenser_mist_valve = false;
                    out.desiccant_loop_valve = true;
                } else {
                    out.cavitator_duty_pct = (t.intake_rh_pct < 75.0f) ? 65 : 40;
                    out.condenser_mist_valve = false;
                    out.desiccant_loop_valve = false;
                }

                // 2. Phase-Locked 33.6 kV Nanosecond Plasma Firing near TDC (36 - 39.5 mm)
                // Fires during final 15% of compression stroke for maximum radical density
                if (t.piston_pos_mm >= 36.0f && t.piston_vel_ms > 0.0f) {
                    out.zvs_plasma_gate_enable = true;
                    // Shorten pulse width as humidity rises to prevent thermal arc breakdown
                    out.zvs_pulse_width_ns = (t.intake_rh_pct > 80.0f) ? 80 : 140;
                } else {
                    out.zvs_plasma_gate_enable = false;
                    out.zvs_pulse_width_ns = 0;
                }

                // 3. Fluidic Vortex Amplifier & VGT Exhaust Loop Modulation
                // Regulates high-temp exhaust recirculation to hold reservoir at 90C
                float temp_err = TARGET_RESERVOIR_TEMP_C - t.reservoir_temp_c;
                out.fluidic_splitter_pwm = (temp_err > 0.0f) ? 75 : 30;
                out.vgt_vane_position_pct = 60;

                // 4. Linear Alternator Resonant Frequency Lock (50 Hz = 20,000 us)
                // Adjusts electrical damping load to maintain 40 mm stroke without TDC collision
                float stroke_err = 39.2f - t.piston_pos_mm;
                out.linear_alt_load_ohms = 12.0f + (stroke_err * 0.5f);
                break;

            case SystemState::FAULT_SAFE_SHUTDOWN:
                out.zvs_plasma_gate_enable = false;
                out.cavitator_duty_pct = 0;
                out.condenser_mist_valve = false;
                // Keep air bearings pressurized until pistons come to complete rest
                out.air_bearing_solenoid = (std::fabs(t.piston_vel_ms) > 0.05f);
                break;
        }

        return out;
    }
};
