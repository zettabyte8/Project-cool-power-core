/* ============================================================================
 * FILE: cpc_exo_ext_ii_controller.c
 * PLATFORM: Dual ARM Cortex-M7 @ 480 MHz (Lockstep Safety Architecture)
 * SYSTEM: Cool Power Core (CPC-EXO-EXT-II) 10-Axis Powered Exoskeleton & ECLSS
 * INVENTOR: Thomas Gabriel Coleman
 * ============================================================================ */

#include <stdint.h>
#include <stdbool.h>
#include <math.h>

#define NUM_JOINTS          10
#define DT_FOC_S            0.0001f   /* 10 kHz Field-Oriented Control */
#define DT_ADMITTANCE_S     0.0010f   /* 1 kHz Human-Intent Admittance */
#define DT_THERMAL_S        0.0100f   /* 100 Hz Dual-uCPC & ECLSS Loop */

#define V_BUS_NOMINAL       48.0f
#define V_SCAP_MIN_PTO      36.0f
#define V_SCAP_CRIT_SHED    32.0f
#define T_RESERVOIR_TARGET  90.0f
#define T_MAGNET_LIMIT      95.0f     /* N52H Thermal Safety Ceiling */

typedef enum {
    EXO_STATE_BOOT_DIAG = 0,
    EXO_STATE_WARMUP_90C,
    EXO_STATE_ASSIST_NOMINAL,
    EXO_STATE_PTO_BURST,
    EXO_STATE_CBRN_SEALED_MAX,
    EXO_STATE_REGEN_DESCENT,
    EXO_STATE_SAFE_LIMP
} ExoState_t;

typedef struct {
    float q_rad;            /* Joint angle (rad) */
    float dq_rad_s;         /* Joint velocity (rad/s) */
    float tau_human_nm;     /* 6-axis F/T cuff interaction torque (Nm) */
    float tau_cmd_nm;       /* Output QDD motor torque command (Nm) */
    float tau_limit_nm;     /* Mechanical & thermal torque ceiling (Nm) */
    float temp_winding_c;   /* Stator winding NTC temperature (C) */
    float k_assist;         /* Payload & intent gain [0.0 .. 1.0] */
    float b_damp;           /* Virtual viscous damping (Nm*s/rad) */
    bool  fault;
} JointChannel_t;

typedef struct {
    float v_bus_48v;
    float v_scap_bank;
    float p_ucpc_gen_w;
    float p_regen_w;
    float t_lcg_return_c;
    float t_reservoir_c;
    float t_magnet_rotor_c;
    float o2_pp_kpa;
    float co2_ppm;
    bool  pto_trigger_req;
    bool  cbrn_alarm;
} SystemTelemetry_t;

static ExoState_t g_state = EXO_STATE_BOOT_DIAG;
static JointChannel_t g_joints[NUM_JOINTS];
static SystemTelemetry_t g_telem;

/* Gravity & payload compensation torque lookup (simplified link model) */
static float compute_gravity_comp(uint8_t idx, float q_rad, float payload_kg) {
    const float g = 9.80665f;
    switch (idx) {
        case 0: case 1: /* Hip Flexion/Extension (J1, J2) */
            return (18.5f + 0.42f * payload_kg) * g * 0.22f * sinf(q_rad);
        case 2: case 3: /* Knee Flexion/Extension (J3, J4) */
            return (12.0f + 0.35f * payload_kg) * g * 0.24f * sinf(q_rad);
        case 4: case 5: /* Lumbar Pitch/Roll (J5, J6) */
            return (24.0f + 0.55f * payload_kg) * g * 0.28f * sinf(q_rad);
        case 6: case 7: /* Shoulder Flexion (J7, J8) */
            return (4.5f + 0.25f * payload_kg) * g * 0.30f * sinf(q_rad);
        case 8: case 9: /* Elbow Flexion (J9, J10) */
            return (2.8f + 0.25f * payload_kg) * g * 0.26f * sinf(q_rad);
        default:
            return 0.0f;
    }
}

/* 1 kHz Admittance & Regenerative Braking Torque Law */
void exo_control_step_1khz(float est_payload_kg) {
    /* Hardware & Thermal Supervisor Interlocks */
    if (g_telem.t_magnet_rotor_c > T_MAGNET_LIMIT || g_telem.v_bus_48v < 28.0f) {
        g_state = EXO_STATE_SAFE_LIMP;
    }

    float power_scale = 1.0f;
    if (g_telem.v_scap_bank < V_SCAP_CRIT_SHED) {
        power_scale = 0.45f; /* Load-shed heavy assist to protect ECLSS */
    }

    for (uint8_t i = 0; i < NUM_JOINTS; i++) {
        JointChannel_t *j = &g_joints[i];
        if (g_state == EXO_STATE_SAFE_LIMP || j->fault || j->temp_winding_c > 125.0f) {
            /* Passive viscous safety damping via phase-shorting */
            j->tau_cmd_nm = -1.8f * j->dq_rad_s;
            continue;
        }

        float tau_g = compute_gravity_comp(i, j->q_rad, est_payload_kg);
        float tau_intent = j->k_assist * power_scale * j->tau_human_nm;
        float tau_total = tau_g + tau_intent - (j->b_damp * j->dq_rad_s);

        /* Regenerative braking boost during eccentric load lowering */
        if ((tau_total * j->dq_rad_s) < -5.0f) {
            g_state = EXO_STATE_REGEN_DESCENT;
        }

        if (tau_total > j->tau_limit_nm)  tau_total = j->tau_limit_nm;
        if (tau_total < -j->tau_limit_nm) tau_total = -j->tau_limit_nm;
        j->tau_cmd_nm = tau_total;
    }
}

/* 100 Hz Dual-uCPC Thermal, ECLSS & PTO Bus Supervisor */
void ucpc_eclss_supervisor_100hz(bool *pto_elec_enable, bool *pto_fluid_enable, float *lcg_valve_duty) {
    /* Route LCG metabolic waste heat to hold cavitation reservoir at 90C */
    float err_t = T_RESERVOIR_TARGET - g_telem.t_reservoir_c;
    float duty = 0.50f + 0.08f * err_t;
    if (duty > 1.0f) duty = 1.0f;
    if (duty < 0.0f) duty = 0.0f;
    *lcg_valve_duty = duty;

    /* Gate 650 W PTO burst only when supercapacitor reserve > 36 V & ECLSS O2 nominal */
    if (g_telem.pto_trigger_req && g_telem.v_scap_bank >= V_SCAP_MIN_PTO && g_telem.o2_pp_kpa >= 19.5f) {
        g_state = EXO_STATE_PTO_BURST;
        *pto_elec_enable = true;
        *pto_fluid_enable = true;
    } else {
        *pto_elec_enable = false;
        *pto_fluid_enable = false;
        if (g_telem.cbrn_alarm) {
            g_state = EXO_STATE_CBRN_SEALED_MAX;
        } else if (g_state == EXO_STATE_PTO_BURST) {
            g_state = EXO_STATE_ASSIST_NOMINAL;
        }
    }
}
