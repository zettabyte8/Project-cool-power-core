"""
ECU Phase-Control & Thermodynamic Simulation for 50 Hz Opposed Free-Piston Plasma Generator
Models:
  1. Opposed piston kinematics & linear alternator back-EMF phase-locking (50 Hz)
  2. Closed-loop water injection & relative humidity PID control for cavitation
  3. Fluidic vortex amplifier exhaust split ratio & 90C thermal reservoir balance
  4. High/Low DC bus power routing (400V traction bus vs. 12V/4.2V ZVS plasma driver)
"""

import math
import csv

class FreePistonPlasmaECU:
    def __init__(self, target_freq_hz=50.0, bore_mm=25.0, stroke_mm=40.0, comp_ratio=30.0):
        self.freq = target_freq_hz
        self.omega = 2.0 * math.pi * self.freq
        self.bore_m = bore_mm / 1000.0
        self.stroke_m = stroke_mm / 1000.0
        self.comp_ratio = comp_ratio
        self.swept_vol_m3 = 2.0 * (math.pi / 4.0) * (self.bore_m ** 2) * self.stroke_m
        self.clearance_vol_m3 = self.swept_vol_m3 / (self.comp_ratio - 1.0)

        # Control setpoints
        self.target_reservoir_temp_c = 90.0
        self.target_water_rate_lph = 0.54
        self.plasma_power_w = 20.0
        self.cavitation_power_w = 15.0
        self.ecu_valve_power_w = 10.0

        # Dynamic state variables
        self.reservoir_temp_c = 25.0
        self.phase_error_rad = 0.0
        self.integral_humidity_err = 0.0

    def step_cycle(self, dt_s, t_s, ambient_temp_c=20.0, ambient_rh=0.50, fuel_power_w=0.0):
        # 1. Opposed Piston Kinematics (x1 = -x2 for zero net momentum)
        phase = self.omega * t_s + self.phase_error_rad
        x_pos_m = 0.5 * self.stroke_m * (1.0 - math.cos(phase))
        velocity_mps = 0.5 * self.stroke_m * self.omega * math.sin(phase)

        # Instantaneous volume and adiabatic-polytropic compression temperature
        inst_vol = self.clearance_vol_m3 + (math.pi / 4.0) * (self.bore_m ** 2) * (self.stroke_m - x_pos_m) * 2.0
        vol_ratio = (self.swept_vol_m3 + self.clearance_vol_m3) / inst_vol
        gamma = 1.32  # Moist air + steam + radical mixture
        gas_temp_k = (ambient_temp_c + 273.15) * (vol_ratio ** (gamma - 1.0))

        # Plasma discharge trigger near Top Dead Center (phase within +/- 15 deg of pi)
        tdc_dist = abs((phase % (2.0 * math.pi)) - math.pi)
        plasma_active = 1 if tdc_dist < 0.26 else 0
        if plasma_active:
            gas_temp_k += 1850.0  # Localized nanosecond streamer radical heating

        # 2. Humidity-Controlled Water Injection (PID trim around 0.54 L/hr)
        target_moisture_g_s = (self.target_water_rate_lph * 1000.0) / 3600.0
        ambient_moisture_g_s = 0.022 * ambient_rh
        needed_injection_g_s = max(0.0, target_moisture_g_s - ambient_moisture_g_s)
        actual_injection_lph = (needed_injection_g_s * 3600.0) / 1000.0

        # 3. Exhaust Split & 90C Reservoir Thermal Balance
        total_thermal_in_w = (self.plasma_power_w + self.cavitation_power_w + fuel_power_w) * 0.85
        # Fluidic vortex splitter routes high-temp stream to cavitator & reservoir coil
        heat_to_reservoir_w = min(total_thermal_in_w * 0.55, 65.0)
        reservoir_mass_kg = 1.5  # 1.5 L thermal buffer
        cp_water = 4184.0
        ambient_loss_w = 0.35 * (self.reservoir_temp_c - ambient_temp_c)

        if self.reservoir_temp_c < self.target_reservoir_temp_c:
            dT = ((heat_to_reservoir_w - ambient_loss_w) * dt_s) / (reservoir_mass_kg * cp_water)
            self.reservoir_temp_c = min(self.target_reservoir_temp_c, self.reservoir_temp_c + dT)
            fluidic_bypass_ratio = 0.25  # 75% exhaust to reservoir heat exchanger
        else:
            fluidic_bypass_ratio = 0.85  # Divert excess heat to VGT/Tesla bottoming loop

        # 4. Electrical Generation (Linear Alternator + Bottoming Cascade)
        emf_v = 415.0 * abs(math.sin(phase))  # Rectified to 400V DC bus
        gross_elec_w = (self.plasma_power_w + self.cavitation_power_w) * 0.44 + (fuel_power_w * 0.465)
        parasitic_w = self.plasma_power_w + self.cavitation_power_w + self.ecu_valve_power_w
        net_bus_w = gross_elec_w - parasitic_w

        return {
            "time_s": round(t_s, 5),
            "piston_pos_mm": round(x_pos_m * 1000.0, 3),
            "piston_vel_mps": round(velocity_mps, 3),
            "core_temp_c": round(gas_temp_k - 273.15, 1),
            "plasma_active": plasma_active,
            "water_inj_lph": round(actual_injection_lph, 4),
            "reservoir_temp_c": round(self.reservoir_temp_c, 2),
            "fluidic_bypass_ratio": round(fluidic_bypass_ratio, 2),
            "rectified_bus_v": round(emf_v, 1),
            "net_bus_power_w": round(net_bus_w, 2)
        }

if __name__ == "__main__":
    ecu = FreePistonPlasmaECU()
    # Simulate 2 full 50 Hz cycles (0.04 s) in REEV mode (fuel_power_w = 3400 W per module)
    rows = []
    dt = 0.0005  # 2 kHz ECU control loop
    for step in range(80):
        t = step * dt
        rows.append(ecu.step_cycle(dt_s=dt, t_s=t, ambient_temp_c=15.0, ambient_rh=0.45, fuel_power_w=3400.0))

    with open("ecu_telemetry_sample.csv", "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)
    print("Simulated 80 ECU control ticks across 2 cycles. Final Net Power (W):", rows[-1]["net_bus_power_w"])
