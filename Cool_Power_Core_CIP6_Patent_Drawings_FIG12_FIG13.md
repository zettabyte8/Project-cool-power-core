# USPTO Formal Line Drawings & Reference Numeral Guide (`FIG. 12` & `FIG. 13`)
**Docket No.:** `CPC-PAT-2026-006-CIP` (Continuation-in-Part of `CPC-PAT-2026-001`)  
**Title:** *Handheld Magnetically Confined Planetary Plasma Lance Powered by Closed-Loop Cold-Sink Cavitation (`CPC-SABER-MARS`)*  
**Inventor:** Thomas Gabriel Coleman (Corona, California, USA)  
**Filing Standard:** 37 CFR § 1.84 Formal Black-and-White Line Art (Sheets 6/7 & 7/7 of Consolidated Master Portfolio)

---

## Sheet 6/7 — `FIG. 12`: Cross-Sectional Elevation of `CPC-SABER-MARS` Emitter & Closed-Loop Hilt Assembly

`FIG. 12` illustrates the longitudinal cross-section of the `2.48 kg` handheld Martian plasma lance (`1200`), showing the coaxial vapor-recovery emitter head, hybrid Halbach + Bitter magnetic mirror nozzle (`0.65 T` throat / `0.67 T` distal pinch), `90°C` CVD-graphene hydrodynamic vortex cavitator, `33.6 kV` ZVS plasma exciter, and `-60°C` Martian cryo-fin thermoelectric cogenerator (`+142.0 We`).

| Numeral | Component Name | Technical Description & Function |
| :--- | :--- | :--- |
| **1200** | Handheld Planetary Plasma Lance Assembly | Hermetically sealed `2.48 kg` (`0.93 kg` Mars weight) Ti-6Al-4V hilt & emitter |
| **1202** | Ti-6Al-4V Outer Pressure Housing | Aerospace-grade structural shell rated for `610 Pa` CO₂ dust & `-120°C` thermal shock |
| **1204** | Replaceable `180 mL` Ice/Water Cartridge | Sealed quick-disconnect feedstock reservoir (`>75 hr` continuous endurance) |
| **1206** | `90°C` Preheated Thermal Reservoir | Jacketed fluid chamber preheated by Bitter-coil and plasma waste heat (`382.9 Wth`) |
| **1208** | CVD-Graphene Fluidic Vortex Cavitator | Zero-moving-part cavitation stage generating nanobubble vapor micro-droplets |
| **1210** | `33.6 kV` ZVS Nanosecond Plasma Exciter | High-frequency pulsed ionization stage dissociating vapor into `H⁺ / O⁺ / CO` plasma |
| **1212** | `Sm₂Co₁₇` Halbach Permanent Magnet Array | Radiation-hardened 8-segment dipole ring providing `0.42 T` passive base confinement |
| **1214** | `CuCrZr` / CVD-Diamond Bitter Coil | Active water-cooled electromagnet adding `+0.23 T` (`0.65 T` peak throat flux) |
| **1216** | Distal Magnetic Mirror Pinch Coil | Shaping solenoid generating a `0.67 T` pinch boundary at `z = 92.0 cm` |
| **1218** | Confined `4,200 K` Toroidal Plasma Blade | Low-beta (`β = 0.18`) `0.92 m` plasma column (`>94%` convective loss reduction in `610 Pa`) |
| **1220** | Coaxial Annular Vapor Aspiration Shroud | Electrostatic/vacuum peripheral duct recovering `98.4%` of condensed water vapor |
| **1222** | External Ti-6Al-4V Cryo-Fin Heat Sink | Deployable radiator fins rejecting heat to `-60°C` Martian ambient (`ΔT = 150 K`) |
| **1224** | `Bi₂Te₃` / `PMN-PT` Thermoelectric Stack | Solid-state cogeneration collar outputting `+142.0 We` continuous recharge power |

---

## Sheet 7/7 — `FIG. 13`: Dual-Bus Power Architecture & `<1.2 ms` Capacitive EVA Deadman Quench Circuit

`FIG. 13` illustrates the electrical power-conditioning, supercapacitor pulse bus (`3.5 kW` peak / `2.4 kW` continuous), and fail-safe `<1.2 ms` capacitive EVA-glove deadman magnetic quench protection schematic (`1300`).

| Numeral | Component Name | Technical Description & Function |
| :--- | :--- | :--- |
| **1300** | Dual-Bus Power & Quench Control Schematic | Fail-safe electrical & telemetry block diagram for `CPC-SABER-MARS` |
| **1302** | `+142.0 We` `µCPC` Thermoelectric Bus | Continuous DC generation output from `Bi₂Te₃` / `PMN-PT` cryo-fin bridge (`1224`) |
| **1304** | Lockstep Radiation-Hardened SOI MPPT ECU | Dual-core Silicon-on-Insulator power tracker & safety supervisor (`10 kHz` loop) |
| **1306** | `140 Wh` Graphene-CNT Supercapacitor Bank | High-rate solid-state pulse buffer (`59 min` full self-recharge; `3.5 kW` peak discharge) |
| **1308** | Bidirectional `48 V` High-Current DC Bus | Primary power rail feeding the `33.6 kV` ZVS plasma driver and Bitter coil inverter |
| **1310** | Dual-Redundant Capacitive EVA Grip Sensors | Through-glove dielectric proximity sensors embedded in the Ti-6Al-4V hilt grip |
| **1312** | `<1.2 ms` Solid-State GaN Quench Switch | Sub-millisecond optical-isolated gate driver triggered upon grip release or `>4 g` drop |
| **1314** | Snubber & Crowbar Energy Dump Resistor | Dissipates Bitter-coil inductive energy (`L·I²/2`) in `<0.8 ms` to collapse magnetic bottle |
| **1316** | `610 Pa` Rapid Plasma Dispersion Plume | Instantaneous non-thermal expansion of `4,200 K` plasma into `610 Pa` ambient upon quench |
| **1318** | Suit UWB / Telemetry Status Transceiver | Wireless health, cartridge level, and blade-state HUD link to astronaut EVA helmet |
