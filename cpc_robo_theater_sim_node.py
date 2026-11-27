#!/usr/bin/env python3
"""
Cool Power Core (uCPC-ROBO) Multi-Frontier Theater Simulation Node
Compatible with ROS 2 Humble / Gazebo Harmonic / NVIDIA Isaac Sim
Inventor: Thomas Gabriel Coleman
"""
import math
from dataclasses import dataclass

@dataclass
class RobotState:
    mode: str = "RECON"          # RECON, MULE, COVER, COMPANION, TERRAFORM
    morphology: str = "HOUND"    # HOUND, FELINE, DRAGON
    gravity_g: float = 1.0       # 1.0 Earth, 0.38 Mars, 0.165 Moon
    ambient_humidity: float = 0.45
    reservoir_temp_c: float = 90.0
    supercap_wh: float = 320.0
    max_supercap_wh: float = 320.0
    skin_temp_c: float = 38.5
    shield_deployed: bool = False
    water_stored_l: float = 2.0
    o2_generated_g: float = 0.0

class CoolPowerRoboTheaterSim:
    def __init__(self):
        self.state = RobotState()
        self.mode_profiles = {
            "RECON":     {"waste_heat_w": 95.0,  "gross_we": 198.5, "load_we": 38.0,  "o2_rate": 75.0},
            "MULE":      {"waste_heat_w": 210.0, "gross_we": 224.0, "load_we": 118.0, "o2_rate": 95.0},
            "COVER":     {"waste_heat_w": 165.0, "gross_we": 208.0, "load_we": 95.0,  "o2_rate": 85.0},
            "COMPANION": {"waste_heat_w": 110.0, "gross_we": 196.0, "load_we": 42.0,  "o2_rate": 80.0},
            "TERRAFORM": {"waste_heat_w": 310.0, "gross_we": 238.0, "load_we": 152.0, "o2_rate": 180.0},
        }

    def step(self, dt_sec: float, acoustic_threat_db: float = 40.0, crew_stress_index: float = 0.2):
        # Autonomous mode switching for tactical cover or companion care
        if acoustic_threat_db > 115.0:
            self.state.mode = "COVER"
            self.state.shield_deployed = True
        elif crew_stress_index > 0.75 and self.state.mode not in ("COVER", "TERRAFORM"):
            self.state.mode = "COMPANION"
            self.state.shield_deployed = False

        prof = self.mode_profiles[self.state.mode]
        parasitic_we = 11.2 + 18.0 + 24.0  # Cavitation + 33.6kV Plasma + Sensors/ECU
        net_bus_we = prof["gross_we"] - parasitic_we - prof["load_we"]

        # Update 320 Wh graphene supercapacitor bank
        delta_wh = (net_bus_we * dt_sec) / 3600.0
        self.state.supercap_wh = max(0.0, min(self.state.max_supercap_wh, self.state.supercap_wh + delta_wh))

        # Closed-loop water & O2 generation
        self.state.water_stored_l += (0.22 * dt_sec) / 3600.0
        self.state.o2_generated_g += (prof["o2_rate"] * dt_sec) / 3600.0

        return {
            "mode": self.state.mode,
            "morphology": self.state.morphology,
            "shield_deployed": self.state.shield_deployed,
            "net_bus_we": round(net_bus_we, 2),
            "supercap_soc_pct": round((self.state.supercap_wh / self.state.max_supercap_wh) * 100.0, 1),
            "water_l": round(self.state.water_stored_l, 3),
            "o2_g": round(self.state.o2_generated_g, 2),
        }

if __name__ == "__main__":
    sim = CoolPowerRoboTheaterSim()
    print("Patrol:", sim.step(3600.0, acoustic_threat_db=45.0))
    print("Shootout Alert:", sim.step(60.0, acoustic_threat_db=132.0))
    sim.state.mode = "TERRAFORM"
    sim.state.gravity_g = 0.38
    print("Mars Terraform:", sim.step(3600.0, acoustic_threat_db=30.0))
