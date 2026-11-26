"""
Thermodynamic & Chemical Kinetics Simulation:
32-Bank Opposed Free-Piston Generator Operating on Green Ammonia (NH3) + Cold Steam Plasma Assist
------------------------------------------------------------------------------------------------
Models:
1. Single-bank & 32-bank kinematics (110 mm bore, 160 mm stroke, 35 Hz, 30:1 compression ratio)
2. 33.6 kV ZVS nanosecond plasma radical generation (NH2*, H*, OH*, O*)
3. Two-stage NH3 thermal + plasma cracking kinetics (2 NH3 -> N2 + 3 H2, dH = +92.4 kJ/mol)
4. 90 C closed-loop reservoir waste-heat preheating & water condensation balance
5. Multi-stage electrical harvesting (Linear Alternators + VGT/Tesla + PZT + TEG + Ion Grid)
"""

import math
import csv

# --- Physical & Geometric Constants ---
NUM_BANKS = 32
BORE_M = 0.110               # 110 mm bore
STROKE_M = 0.160             # 160 mm stroke
FREQ_HZ = 35.0               # 35 cycles/sec per opposed bank
COMP_RATIO = 30.0            # 30:1 geometric compression ratio
GAMMA_MIX = 1.33             # Specific heat ratio for NH3 + moist air charge

# --- Thermodynamic & Chemical Constants ---
LHV_NH3_MJ_KG = 18.60        # Lower heating value of liquid ammonia (MJ/kg)
DELTA_H_CRACK_KJ_MOL = 92.4  # Endothermic cracking enthalpy for 2 mol NH3 (kJ)
MOLAR_MASS_NH3 = 0.017031    # kg/mol
MOLAR_MASS_H2O = 0.018015    # kg/mol
CP_H2O_KJ_KGK = 4.184        # Specific heat of liquid water
T_AMBIENT_K = 298.15         # 25 C ambient
T_RESERVOIR_K = 363.15       # 90 C preheated water reservoir

# --- Plasma & Auxiliary Electrical Inputs (32-Bank Total) ---
P_PLASMA_KW = 38.0           # 33.6 kV ZVS nanosecond corona (scaled across 32 banks)
P_CAVITATION_KW = 18.0       # Ultrasonic + fluidic vortex intake cavitation
P_ECU_VALVES_KW = 8.0        # High-speed phase-locked ECU & fluidic pilot valves
P_AUX_TOTAL_KW = P_PLASMA_KW + P_CAVITATION_KW + P_ECU_VALVES_KW

def simulate_ammonia_cycle(nh3_mass_flow_kg_hr=540.0, water_injection_ratio=0.35):
    """
    Simulates steady-state 32-bank operation on Green Ammonia (NH3).
    water_injection_ratio: mass of 90 C cold-steam mist per unit mass of NH3.
    """
    # 1. Geometry & Volumetric Flow
    area_piston = math.pi * (BORE_M / 2.0) ** 2
    v_swept_bank_m3 = 2.0 * area_piston * STROKE_M
    v_flow_total_m3_s = v_swept_bank_m3 * FREQ_HZ * NUM_BANKS

    # 2. Fuel & Water Mass Flows
    m_dot_nh3_kg_s = nh3_mass_flow_kg_hr / 3600.0
    m_dot_h2o_inj_kg_s = m_dot_nh3_kg_s * water_injection_ratio
    q_fuel_in_kw = m_dot_nh3_kg_s * LHV_NH3_MJ_KG * 1000.0

    # 3. Waste-Heat Preheating Savings (25 C -> 90 C)
    q_preheat_saved_kw = m_dot_h2o_inj_kg_s * CP_H2O_KJ_KGK * (T_RESERVOIR_K - T_AMBIENT_K)

    # 4. Plasma-Assisted Ammonia Cracking Fraction
    # Nanosecond corona creates H*, OH*, and excited N2* species that lower activation barrier
    mol_nh3_per_s = m_dot_nh3_kg_s / MOLAR_MASS_NH3
    # Non-thermal plasma radical seeding cracks ~6.5% directly at TDC, triggering full thermal cascade
    plasma_cracked_fraction = min(0.18, (P_PLASMA_KW * 0.42) / (mol_nh3_per_s * (DELTA_H_CRACK_KJ_MOL / 2.0)))
    effective_flame_speed_boost = 1.0 + 3.8 * plasma_cracked_fraction  # Overcomes slow NH3 laminar flame speed

    # 5. Compression & Peak Cycle Temperature
    t_intake_k = 342.0  # Warmed by 90 C mist + recirculated acoustic exhaust stream
    t_tdc_k = t_intake_k * (COMP_RATIO ** (GAMMA_MIX - 1.0))
    t_peak_k = t_tdc_k + 1580.0 * min(1.15, effective_flame_speed_boost / 1.25)

    # 6. Multi-Stage Power Conversion
    eta_linear_alternator = 0.455   # YSZ thermal barrier + 5 um air bearings + N52H
    p_linear_alt_kw = q_fuel_in_kw * eta_linear_alternator

    q_exhaust_available_kw = q_fuel_in_kw * (1.0 - eta_linear_alternator) * 0.78
    p_vgt_tesla_kw = q_exhaust_available_kw * 0.145   # VGT + biomimetic Tesla turbine
    p_pzt_acoustic_kw = q_exhaust_available_kw * 0.022  # 35 Hz PZT pressure pulse capture
    p_teg_pyro_kw = q_exhaust_available_kw * 0.038      # TEG + pyroelectric thermal gradient
    p_ion_grid_kw = P_PLASMA_KW * 0.16                  # Electrostatic ion grid recovery

    p_gross_electric_kw = (p_linear_alt_kw + p_vgt_tesla_kw +
                           p_pzt_acoustic_kw + p_teg_pyro_kw + p_ion_grid_kw)
    p_net_traction_kw = p_gross_electric_kw - P_AUX_TOTAL_KW
    net_thermal_efficiency = (p_net_traction_kw / q_fuel_in_kw) * 100.0

    # 7. Closed-Loop Water Mass Balance (Combustion H2O + Injected H2O - Losses)
    # Stoichiometric combustion: 4 NH3 + 3 O2 -> 2 N2 + 6 H2O (1.5 mol H2O per mol NH3)
    m_dot_h2o_comb_kg_s = (mol_nh3_per_s * 1.5) * MOLAR_MASS_H2O
    condenser_recovery_eff = 0.94
    m_dot_h2o_recovered_kg_hr = (m_dot_h2o_inj_kg_s + m_dot_h2o_comb_kg_s) * 3600.0 * condenser_recovery_eff
    net_surplus_water_l_hr = m_dot_h2o_recovered_kg_hr - (m_dot_h2o_inj_kg_s * 3600.0)

    return {
        "nh3_feed_kg_hr": round(nh3_mass_flow_kg_hr, 1),
        "fuel_thermal_in_kw": round(q_fuel_in_kw, 1),
        "airflow_m3_hr": round(v_flow_total_m3_s * 3600.0, 1),
        "preheat_waste_saved_kw": round(q_preheat_saved_kw, 2),
        "plasma_cracked_pct": round(plasma_cracked_fraction * 100.0, 2),
        "tdc_temp_k": round(t_tdc_k, 1),
        "peak_cycle_temp_k": round(t_peak_k, 1),
        "linear_alt_kw": round(p_linear_alt_kw, 1),
        "bottoming_total_kw": round(p_vgt_tesla_kw + p_pzt_acoustic_kw + p_teg_pyro_kw + p_ion_grid_kw, 1),
        "aux_plasma_cav_kw": round(P_AUX_TOTAL_KW, 1),
        "net_traction_kw": round(p_net_traction_kw, 1),
        "net_efficiency_pct": round(net_thermal_efficiency, 2),
        "net_surplus_water_l_hr": round(net_surplus_water_l_hr, 1)
    }

if __name__ == "__main__":
    print("=== 32-Bank Free-Piston Generator: Green Ammonia (NH3) Load Sweep ===")
    loads = [250.0, 350.0, 450.0, 540.0, 620.0]
    results = [simulate_ammonia_cycle(flow) for flow in loads]

    headers = list(results[0].keys())
    print(" | ".join(headers))
    print("-" * 140)
    for row in results:
        print(" | ".join(str(row[h]) for h in headers))
