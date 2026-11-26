#!/usr/bin/env python3
"""
24-Hour Commercial RTU + 50 Hz Free-Piston Plasma Reactor Co-Simulation
Anchored to ASHRAE Climate Zone 3B (Inland Southern California / Corona, CA Summer Design Day)
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def run_simulation():
    hours = np.arange(0, 24, 1)
    # Typical Inland Southern California (Zone 3B) Summer Design Day Ambient Temp (C) & RH (%)
    t_amb_c = np.array([
        19.5, 18.8, 18.2, 17.8, 17.5, 18.0, 20.5, 24.0,
        28.2, 32.0, 35.1, 37.5, 39.2, 40.5, 41.0, 40.2,
        38.5, 35.8, 32.2, 28.5, 25.5, 23.2, 21.5, 20.3
    ])
    rh_amb = np.array([
        68, 71, 74, 76, 77, 75, 65, 52,
        40, 32, 26, 22, 19, 17, 16, 18,
        21, 26, 33, 42, 50, 56, 61, 65
    ])

    # Baseline 25-Ton Commercial RTU Cooling Load (kW thermal)
    q_load_kw = np.array([
        18.0, 16.5, 15.5, 15.0, 15.0, 17.5, 28.0, 42.0,
        56.0, 68.0, 76.0, 82.0, 86.0, 88.0, 88.0, 85.0,
        78.0, 66.0, 52.0, 40.0, 32.0, 26.0, 22.0, 19.5
    ])

    # Baseline RTU COP degradation with high outdoor ambient temperature
    cop_base = np.clip(3.6 - 0.045 * (t_amb_c - 25.0), 2.1, 4.0)
    p_elec_base_kw = q_load_kw / cop_base

    # Integrated System Dynamics:
    # 1. IAQ Scrubbing reduces required conditioned Outside Air (OA) ventilation load by ~18% during occupied hours (07:00 - 19:00)
    occupied_mask = (hours >= 7) & (hours <= 19)
    q_load_integrated_kw = np.where(occupied_mask, q_load_kw * 0.84, q_load_kw * 0.96)

    # 2. Adiabatic Cold-Steam Pre-Cooling of Condenser Air when T_amb > 28 C and RH < 45%
    adiabatic_active = (t_amb_c > 28.0) & (rh_amb < 45.0)
    wet_bulb_depression = (t_amb_c - 15.0) * (1.0 - rh_amb / 100.0) * 0.55
    t_cond_in_c = np.where(adiabatic_active, t_amb_c - wet_bulb_depression, t_amb_c)

    cop_integrated = np.clip(3.6 - 0.045 * (t_cond_in_c - 25.0), 2.3, 4.1)

    # Net Reactor Electrical Parasitic Draw (45 W input - 19 W recovered = 26 W = 0.026 kW)
    p_reactor_net_kw = 0.026
    p_elec_integrated_kw = (q_load_integrated_kw / cop_integrated) + p_reactor_net_kw

    # Thermodynamic Single-Cycle 50 Hz P-V Integration (39.27 cc swept, 30:1 CR)
    theta = np.linspace(0, 2 * np.pi, 500)
    v_bdc = 39.27e-6  # m^3
    cr = 30.0
    v_tdc = v_bdc / cr
    vol_m3 = v_tdc + 0.5 * (v_bdc - v_tdc) * (1 - np.cos(theta))

    # Polytropic compression (n=1.32) + nanosecond radical exothermic kick at TDC
    p0 = 101325.0  # Pa
    p_comp = p0 * (v_bdc / vol_m3) ** 1.32
    # Radical recombination heat release near TDC (pi +/- 0.15 rad)
    heat_boost = 1.0 + 0.14 * np.exp(-((theta - np.pi) / 0.12) ** 2) * (theta >= np.pi)
    p_cycle_bar = (p_comp * heat_boost) / 1e5

    df = pd.DataFrame({
        'Hour': hours,
        'Ambient_Temp_C': t_amb_c,
        'Ambient_RH_pct': rh_amb,
        'Baseline_Cooling_Load_kW': np.round(q_load_kw, 2),
        'Integrated_Cooling_Load_kW': np.round(q_load_integrated_kw, 2),
        'Baseline_COP': np.round(cop_base, 2),
        'Integrated_COP': np.round(cop_integrated, 2),
        'Baseline_Elec_kW': np.round(p_elec_base_kw, 2),
        'Integrated_Elec_kW': np.round(p_elec_integrated_kw, 2),
        'Hourly_Savings_kWh': np.round(p_elec_base_kw - p_elec_integrated_kw, 2)
    })

    df.to_csv('simulation_24hr_results.csv', index=False)
    total_base_kwh = df['Baseline_Elec_kW'].sum()
    total_int_kwh = df['Integrated_Elec_kW'].sum()
    savings_pct = ((total_base_kwh - total_int_kwh) / total_base_kwh) * 100.0
    print(f"24-Hr Baseline HVAC Energy: {total_base_kwh:.2f} kWh")
    print(f"24-Hr Integrated HVAC Energy: {total_int_kwh:.2f} kWh")
    print(f"Total Daily Energy Reduction: {total_base_kwh - total_int_kwh:.2f} kWh ({savings_pct:.1f}%)")

if __name__ == '__main__':
    run_simulation()
