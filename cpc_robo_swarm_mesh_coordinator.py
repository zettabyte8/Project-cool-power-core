#!/usr/bin/env python3
"""
Cool Power Core (uCPC-ROBO) Autonomous Swarm Mesh & Energy-Sharing Broker
Simulates multi-unit UWB acoustic shield phalanx synchronization, peer-to-peer
48V graphene supercapacitor + 90C water auctions, and terraforming grid coverage.
"""

import math
import time
from dataclasses import dataclass, field
from typing import List, Tuple, Optional


@dataclass
class RoboAgent:
    unit_id: str
    morphology: str  # "hound", "feline", "dragon"
    x: float
    y: float
    v_scap: float = 48.0          # 36.0V (empty) to 52.0V (full 180Wh bank)
    water_l: float = 1.6          # 0.2L to 2.0L in 90C reservoir
    role: str = "PATROL"          # PATROL, HEAVY_HAUL, TERRAFORM, SHIELD_WALL, DOCKING
    shield_deployed: bool = False

    @property
    def soc(self) -> float:
        return max(0.0, min(1.0, (self.v_scap - 36.0) / 16.0))

    @property
    def water_frac(self) -> float:
        return max(0.0, min(1.0, self.water_l / 2.0))


class SwarmMeshCoordinator:
    def __init__(self, agents: List[RoboAgent]):
        self.agents = agents
        self.sim_time_s = 0.0

    def step_physics(self, dt_s: float = 10.0):
        self.sim_time_s += dt_s
        for a in self.agents:
            if a.role == "TERRAFORM":
                # High plasma auger + N2 fixation draw: net -0.018 V/s, -0.00012 L/s
                a.v_scap = max(36.2, a.v_scap - 0.018 * dt_s)
                a.water_l = max(0.25, a.water_l - 0.00012 * dt_s)
            elif a.role == "HEAVY_HAUL":
                a.v_scap = max(36.5, a.v_scap - 0.010 * dt_s)
                a.water_l = min(2.0, a.water_l + 0.00004 * dt_s)
            elif a.role == "PATROL":
                # Net +155We surplus charges supercapacitor and accumulates water
                a.v_scap = min(52.0, a.v_scap + 0.012 * dt_s)
                a.water_l = min(2.0, a.water_l + 0.00006 * dt_s)

    def run_energy_water_auction(self) -> Optional[Tuple[str, str, float, float]]:
        donors = [a for a in self.agents if a.soc > 0.78 and a.role == "PATROL"]
        seekers = [a for a in self.agents if a.soc < 0.35 or a.water_frac < 0.25]
        if not donors or not seekers:
            return None

        donor = max(donors, key=lambda x: x.soc)
        seeker = min(seekers, key=lambda x: x.soc)

        # Peer-to-peer magnetic umbilical transfer (48V 1.2kW bus + 90C water)
        dv = min(4.5, (donor.v_scap - seeker.v_scap) * 0.45)
        dw = min(0.45, max(0.0, (donor.water_l - seeker.water_l) * 0.40))
        donor.v_scap -= dv
        seeker.v_scap += dv
        donor.water_l -= dw
        seeker.water_l += dw
        return (donor.unit_id, seeker.unit_id, round(dv, 2), round(dw, 3))

    def trigger_phalanx_shield_wall(self, threat_bearing_deg: float, squad_center: Tuple[float, float]):
        rad = math.radians(threat_bearing_deg)
        cx, cy = squad_center
        # Place units 2.2m forward of squad along threat bearing with 1.15m lateral spacing
        fwd_x, fwd_y = cx + 2.2 * math.cos(rad), cy + 2.2 * math.sin(rad)
        perp_x, perp_y = -math.sin(rad), math.cos(rad)

        n = len(self.agents)
        for idx, a in enumerate(self.agents):
            offset = (idx - (n - 1) / 2.0) * 1.15
            a.x = round(fwd_x + offset * perp_x, 2)
            a.y = round(fwd_y + offset * perp_y, 2)
            a.role = "SHIELD_WALL"
            a.shield_deployed = True


if __name__ == "__main__":
    squad = [
        RoboAgent("CPC-HOUND-01", "hound", 0.0, 0.0, v_scap=41.0, water_l=0.9, role="TERRAFORM"),
        RoboAgent("CPC-HOUND-02", "hound", 4.0, 2.0, v_scap=44.5, water_l=1.2, role="HEAVY_HAUL"),
        RoboAgent("CPC-FELINE-03", "feline", -3.0, 5.0, v_scap=50.5, water_l=1.8, role="PATROL"),
        RoboAgent("CPC-DRAGON-04", "dragon", 1.0, -4.0, v_scap=51.8, water_l=1.95, role="PATROL"),
    ]
    mesh = SwarmMeshCoordinator(squad)

    print("=== SIMULATING 450s SWARM TERRAFORMING & ENERGY AUCTION ===")
    for _ in range(45):
        mesh.step_physics(dt_s=10.0)
        tx = mesh.run_energy_water_auction()
        if tx:
            print(f"[t={mesh.sim_time_s:4.0f}s] P2P DOCK TRANSFER: {tx[0]} -> {tx[1]} | +{tx[2]}V | +{tx[3]}L (90C H2O)")

    print("
=== UWB GUNSHOT TRIANGULATION: DEPLOYING INTERLOCKING PHALANX ===")
    mesh.trigger_phalanx_shield_wall(threat_bearing_deg=45.0, squad_center=(10.0, 10.0))
    for a in squad:
        print(f"  {a.unit_id} ({a.morphology:6s}) -> pos=({a.x:5.2f}, {a.y:5.2f}) | shield={a.shield_deployed} | V_scap={a.v_scap:.2f}V")
