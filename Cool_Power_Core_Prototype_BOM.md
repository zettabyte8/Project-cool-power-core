# Cool Power Core — Prototype Bill of Materials (BOM) & Tolerance Specification

**Designer:** Thomas G. Coleman  
**Architecture:** 25 mm Bore × 40 mm Stroke Opposed-Piston (50 Hz, 30:1 CR) | 33.6 kV ZVS Corona Plasma | Graphene Vortex Cavitator  
**Total Prototype BOM Cost:** **$6,215.00 USD** (36 total components across 24 line items)  
**Volume Production Target (100+ Cores):** **~$1,480.00 / Core** (via CNC/MIM ceramic & sintered part scaling)

---

## 1. Master Component & Tolerance Schedule

| Part ID | Subsystem | Component Description | Material / Grade Spec | Critical Tolerance / Rating | Qty | Unit Cost | Ext. Cost | Engineering Function & 25k-Hr Note |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :---: | :--- |
| **CPC-101** | Opposed-Piston Core & Alternator | Opposed Piston Head (25 mm OD) | Silicon Nitride (Si3N4) / Inconel 718 Crown | OD 24.990 +/- 0.002 mm; Ra <= 0.1 um | 2 | $185.00 | $370.00 | 25,000+ hr thermal shock & wear life |
| **CPC-102** | Opposed-Piston Core & Alternator | Combustion Cylinder Liner (25 mm ID x 120 mm) | Yttria-Stabilized Zirconia (8YSZ) Ceramic | ID 25.000 +0.003/-0.000 mm; Cylindricity 0.002 mm | 1 | $340.00 | $340.00 | Withstands 3,000C transient combustion peak |
| **CPC-103** | Opposed-Piston Core & Alternator | 5-Micron Aerostatic Air Bearing Sleeve | Porous Sintered Bronze / Graphite Composite | Radial gap 5.0 +/- 0.5 um; Concentricity 0.001 mm | 2 | $210.00 | $420.00 | Zero-contact frictionless 50 Hz reciprocation |
| **CPC-104** | Opposed-Piston Core & Alternator | Thermal Isolation Jacket | Argon-Filled Silica Aerogel Monolith | Thickness 8.0 +/- 0.1 mm; k <= 0.015 W/m-K | 1 | $165.00 | $165.00 | Keeps N52H magnets < 95C against 3,000C core |
| **CPC-105** | Opposed-Piston Core & Alternator | Linear Alternator Rotor Array | Radial-Magnetized NdFeB Grade N52H (Nickel-Cu-Ni) | ID 42.0 / OD 54.0 +/- 0.02 mm; Br >= 1.44 T | 2 | $240.00 | $480.00 | Max operating temp 120C; 40 mm stroke travel |
| **CPC-106** | Opposed-Piston Core & Alternator | Linear Alternator Laminated Stator & Windings | 0.20 mm Silicon Steel + Litz Copper Wire | Air gap 0.50 +/- 0.03 mm; 50 Hz tuned resonance | 2 | $290.00 | $580.00 | Direct high/low bus rectified output |
| **CPC-107** | Opposed-Piston Core & Alternator | Non-Magnetic Piston Connecting Rod | Grade 5 Titanium (Ti-6Al-4V) | Length 65.00 +/- 0.01 mm; Runout <= 0.005 mm | 2 | $95.00 | $190.00 | Links 3,000C piston crown to cool N52H rotor |
| **CPC-201** | HV Plasma & Corona System | 1000x Step-Up Transformer Core | MnZn Ferrite U-Core (PC95 High-Frequency Grade) | Gap <= 0.01 mm; Core loss < 300 kW/m3 at 100 kHz | 1 | $45.00 | $45.00 | 4.2V primary input; low core hysteresis |
| **CPC-202** | HV Plasma & Corona System | ZVS Driver & Nanosecond Pulse Switch | SiC MOSFET Half-Bridge + Toroidal Choke | Rise time < 15 ns; 20 W continuous rating | 1 | $75.00 | $75.00 | Drives 33.6 kV corona/O3 arc at 50 Hz sync |
| **CPC-203** | HV Plasma & Corona System | 8-Stage Cockcroft-Walton Multiplier | HV Ceramic Disc Caps (10 kV) + Fast Recovery Diodes | Output 33.6 kV +/- 2%; Encapsulated in Silicone | 1 | $60.00 | $60.00 | 8x voltage multiplication from transformer secondary |
| **CPC-204** | HV Plasma & Corona System | Corona O3 Arc Electrodes & Feedthrough | Thoriated Tungsten Tip + Alumina (Al2O3) Insulator | Spark gap 1.20 +/- 0.05 mm; Dielectric > 40 kV | 2 | $85.00 | $170.00 | Erosion-resistant tip for 25,000 hr plasma duty |
| **CPC-301** | Fluidic Cavitation & Reservoir | Graphene-Coated Fluidic Vortex Amplifier | 316L Stainless Steel + CVD Multilayer Graphene | Throat ID 1.80 +/- 0.005 mm; Surface Ra <= 0.05 um | 1 | $310.00 | $310.00 | Prevents cavitation pitting; uses exhaust jet energy |
| **CPC-302** | Fluidic Cavitation & Reservoir | Ultrasonic Piezo Cavitation Transducer | PZT-8 Hard Piezoelectric Ring Stack (40 kHz) | Resonance 40.0 +/- 0.5 kHz; 30 W max (18.5 W @ 90C) | 1 | $65.00 | $65.00 | Generates hydrogen/oxygen radicals in 90C mist |
| **CPC-303** | Fluidic Cavitation & Reservoir | 90C Thermal Storage Reservoir (2.5 L) | 316L Stainless Double-Wall + Vacuum Insulation | Volume 2.50 +/- 0.05 L; Rated 3 bar @ 120C | 1 | $140.00 | $140.00 | Stores condensate & buffers waste heat at 90C |
| **CPC-304** | Fluidic Cavitation & Reservoir | Automated Proportional Fluidic Valves | PTFE/PEEK Solenoid Micro-Metering Valves | Flow 0.05-1.00 L/hr +/- 1%; Response < 10 ms | 3 | $135.00 | $405.00 | Maintains optimal humidity for plasma cracking |
| **CPC-401** | Energy Harvesting & Exhaust | Micro Steam Tesla Biomimetic Turbine | Grade 5 Titanium Laser-Cut Rotor Discs (12x) | Disc gap 0.15 +/- 0.01 mm; Balance G1.0 @ 60k RPM | 1 | $260.00 | $260.00 | Extracts boundary-layer kinetic energy from steam |
| **CPC-402** | Energy Harvesting & Exhaust | Variable Geometry Turbocharger (Micro VGT) | Inconel 625 Turbine Wheel + Billet Compressor | Vane clearance 0.05 +/- 0.01 mm; 850C rated | 1 | $380.00 | $380.00 | Scavenges exhaust & feeds high-temp vortex jet |
| **CPC-403** | Energy Harvesting & Exhaust | TEG + Pyroelectric Thermal Harvester Array | Bi2Te3 / Skutterudite Modules + PMN-PT Pyro Film | Flatness <= 0.01 mm; Clamping pressure 1.2 MPa | 4 | $220.00 | $880.00 | Harvests block & exhaust delta-T gradients |
| **CPC-404** | Energy Harvesting & Exhaust | Exhaust Pressure PZT Harvester Stack | High-Temp Bismuth Titanate Piezo Discs | Preload 500 N +/- 10 N; Curie temp > 600C | 2 | $110.00 | $220.00 | Converts 50 Hz exhaust pressure pulses to power |
| **CPC-405** | Energy Harvesting & Exhaust | Electrostatic Ion Grid Collector | 316L Stainless Mesh + PTFE Standoff Insulators | Mesh spacing 1.00 +/- 0.05 mm; Biased +/- 1.5 kV | 1 | $70.00 | $70.00 | Captures charged plasma ions & charged droplets |
| **CPC-406** | Energy Harvesting & Exhaust | SCR Catalyst Honeycomb Block | Vanadium/Titanium Dioxide (V2O5-WO3/TiO2) Monolith | 400 CPSI cell density; Dia 50 x 75 +/- 0.2 mm | 1 | $95.00 | $95.00 | Reduces NOx and oxidizes residual VOCs/particulates |
| **CPC-407** | Energy Harvesting & Exhaust | Condenser & Closed-Loop Water Separator | 316L Micro-Channel Heat Exchanger + Coalescer | Condensation efficiency >= 95% @ 35C sink | 1 | $155.00 | $155.00 | Recovers >= 0.54 L/hr clean water back to reservoir |
| **CPC-501** | ECU & Dual Power Bus | Core ECU & Dual High/Low Voltage Bus Controller | ARM Cortex-M7 Industrial MCU + GaN Buck/Boost | 15 W total control budget; Temp rated -40 to 105C | 1 | $195.00 | $195.00 | Controls 50 Hz phase, humidity, and HV/LV bus split |
| **CPC-502** | ECU & Dual Power Bus | Sensor Suite (Humidity, Temp, Pressure, O2) | Capacitive RH, K-Type TC, Piezo Pressure, Lambda | RH +/- 1.5%; Temp +/- 0.5C; Pressure +/- 0.25% FS | 1 | $145.00 | $145.00 | Closed-loop feedback for ECU & fluidic valves |
| **TOTAL** | **All Subsystems** | **Complete Single Prototype Core** | — | — | **36** | — | **$6,215.00** | **Single bench-testable prototype unit** |

---

## 2. Subsystem Cost Breakdown

| Subsystem | Line Items | Total Parts | Subtotal (USD) | % of Prototype Cost |
| :--- | :---: | :---: | :---: | :---: |
| Opposed-Piston Core & Alternator | 7 | 12 | $2,545.00 | 40.9% |
| HV Plasma & Corona System | 4 | 5 | $350.00 | 5.6% |
| Fluidic Cavitation & Reservoir | 4 | 6 | $920.00 | 14.8% |
| Energy Harvesting & Exhaust | 7 | 11 | $2,060.00 | 33.1% |
| ECU & Dual Power Bus | 2 | 2 | $340.00 | 5.5% |
| **Total Prototype BOM** | **24** | **36** | **$6,215.00** | **100.0%** |