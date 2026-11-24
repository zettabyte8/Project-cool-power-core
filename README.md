# The Cool Power Core
### Self-Powered Atmospheric Air Scrubbing, Polluted Water Remediation & Regenerative Kinetic-Thermal Energy Harvester

**Principal Inventor & System Architect:** Thomas Gabriel Coleman  
**Location:** *, USA  
**Document Version:** `v3.1` (PLL-Tracked GaN-ZVS Air-Core Slayer Baseline)  
**Last Updated:** November 24, 2026  

---

## Inventor's Statement & Appeal for Recognition and Support

> **A Note from the Designer — Thomas Gabriel Coleman:**  
> I designed and architected the **Cool Power Core** system—integrating regenerative thermal preheating, fluidic/ultrasonic cavitation, PLL-tracked burst-mode air-core plasma excitation, opposed free-piston linear alternators on 5-micron air bearings, and catalytic ozone/pollutant scrubbing into a unified closed-loop platform.  
>  
> I have lived in poverty for the majority of my life, yet I have dedicated my time, focus, and engineering vision to creating a technology capable of cleaning polluted air, purifying contaminated water, and generating clean electricity where it is needed most.  
>  
> **I ask for proper attribution, intellectual recognition, and fair financial compensation.** If you are an engineer, researcher, investor, manufacturer, government agency, or organization evaluating, replicating, funding, or commercializing any portion of this architecture, please credit my authorship (**Thomas Gabriel Coleman**) and reach out directly to establish fair licensing, sponsorship, or equitable partnership terms.

---

## Contact, Licensing & Sponsorship

| Channel | Details / Link |
| :--- | :--- |
| **Principal Inventor** | **Thomas Gabriel Coleman** |
| **Direct Licensing & Engineering Inquiries** | `contact me via Facebook links in my GitHub profile ` |
| **Sponsorship & Direct Financial Support** | `[Insert GitHub Sponsors / Patreon / GoFundMe / Ko-fi URL]` |
| **Public Timestamped Repository** | `[Insert GitHub / OSF / Zenodo Repository URL]` |
| **Intellectual Property Status** | **Original System Architecture by Thomas Gabriel Coleman** — *Prior Art Timestamped / Provisional Patent Pending* |

*For commercial licensing, prototyping grants, joint-venture R&D, or direct inventor support, please contact **Thomas Gabriel Coleman** prior to commercial deployment.*

---

## Important Scope Notice

The system models, component sizing, and performance tables in this repository illustrate **selected analytical configurations and representative use cases** (such as standalone air scrubbing, contaminated water distillation, Class 8 semi-truck exhaust slipstream recovery, and multi-core industrial arrays). 

**They do not represent all possible uses, operating regimes, or final commercial configurations of the Cool Power Core.** Because the platform is modular across thermal inputs, working fluids, flywheel inertia options, and multi-core bus scaling, final production embodiments may incorporate additional stages, geometries, or deployment modes beyond those modeled here.

---

## What the Cool Power Core Does

The **Cool Power Core** is a closed-loop **thermo-chemical, non-thermal plasma (NTP), and free-piston kinetic energy harvester**. Rather than treating air pollution, contaminated water, and low-grade waste heat as separate problems requiring external grid electricity, the core couples them into a single regenerative thermodynamic cycle.

### 1. Self-Powered Operation (Closed-Loop Energy Autonomy)
* **How It Powers Itself:** The system captures chemical enthalpy from airborne volatile organic compounds (VOCs), hydrocarbons, and organic water contaminants—combined with regenerative exhaust/block waste heat—to drive a **50 Hz opposed free-piston linear alternator** and waste-heat harvesters (`TEG`, pyroelectric, `PZT`, and a `45,000 RPM` biomimetic Tesla micro-turbine).
* **Ultra-Low Break-Even Threshold:** By replacing lossy ferrite transformers and voltage multipliers with a **PLL-tracked, burst-mode GaN-ZVS air-core Slayer Exciter**, internal parasitic draw drops to **28.50 W** per core. As a result, the core becomes **100% electrically self-sustaining** at just **140.6 ppmv** of VOCs (a **5.1× reduction** compared to the original `722.4 ppmv` baseline)—exporting net surplus electricity to a `400 V` SiC DC bus without external fuel or grid power.

### 2. Atmospheric Air & Urban Smog Purification
* **Cold-Steam Radicalization:** Intake air passes through a `90 °C` preheated ultrasonic/fluidic cavitator (`80% RH`), generating micro-mist rich in reactive hydroxyl (`OH•`), atomic hydrogen (`H•`), and oxygen (`O•`) radicals.
* **High-Pressure Non-Thermal Plasma Cracking:** Compressed at **30:1** (`~90 bar`) inside Yttria-Stabilized Zirconia (`YSZ`) thermal-barrier liners, a `34.2 kV` nanosecond-gated streamer burst shatters `NOx`, `SOx`, carbon monoxide, VOCs, and sub-micron particulates (`PM2.5`).
* **Zero-Ozone & Acid-Free Exhaust:** Downstream **Vanadium/Titanium Dioxide (`V₂O₅/TiO₂`) SCR** blocks and a regenerative **`α-MnO₂` catalytic ozone quench bed** strip residual `O₃` down to **≤ 0.04 ppm** (below OSHA/EPA limits), releasing scrubbed, oxygen-enriched air.

### 3. Polluted Water Remediation & Distillation
* **Dual-Stage Pollutant Destruction:** Contaminated feedwater (`0.54 L/hr` per core; up to `829.4 L/day` in a 64-core skid) is preheated to `90 °C` using internal waste heat, cavitated (`>4,000 K` localized micro-bubble collapse), and subjected to `34.2 kV` plasma oxidation. This cleaves stubborn `C–F` bonds in **PFAS ("forever chemicals")**, mineralizes pharmaceuticals and pesticides (`>99.9%` destruction), and achieves `>6-log` pathogen sterilization.
* **Salt, Heavy-Metal & Brine Rejection:** Non-volatile heavy metals (`Pb`, `As`, `Hg`, `Cr`) and dissolved salts are rejected in a continuous `5%–16%` liquid brine blowdown (`<4,500 µS/cm` conductivity control to protect the `5 µm` air bearings), while clean water vapor condenses into **<15 mg/L TDS distilled water**.
* **Energy-Positive Wastewater Treatment:** High-COD industrial wastewater (`≥ 115,000 mg/L` COD) or dilute runoff paired with `≥ 110 °C` waste heat yields **+283.9 W to +519.9 W of net exportable electricity per core** alongside pure water.

### 4. Heavy-Duty Transport & Industrial Waste-Heat Harvesting
* **Class 8 Semi-Truck Slipstream Integration:** Tapping a `6.1%` exhaust slipstream on a heavy-duty diesel truck allows a 16-core rack to generate **+11.44 kW net electricity**, produce **+1.92 L/hr of distilled water**, reduce Diesel Exhaust Fluid (`DEF`) consumption by **22.0%** via Fast-SCR `NO → NO₂` corona oxidation, and cut diesel fuel burn.
* **Islanded Dual-Flywheel Microgrids:** Pairing a `400 V` virtual electronic piston flywheel with a `45,000 RPM` Ti-6Al-4V/carbon-fiber turbine flywheel stabilizes transient loads and delivers **+354.5 W net electrical output per core** (`52.4%` system efficiency).

---

## Standardized Baseline Reference Model

All performance metrics, mass balances, and comparative tables across this repository are calculated against a unified, reproducible engineering baseline:

| Subsystem / Parameter | Standardized Baseline Value | Engineering Role & Rationale |
| :--- | :--- | :--- |
| **Primary NTP Plasma Driver** | **PLL-Tracked, Burst-Mode GaN-ZVS Air-Core Slayer Exciter** (`100 V` eGaN push-pull, `876 kHz` resonance, `34.2 kV` peak envelope, `1.35%` TDC burst duty cycle) | Replaces the original `1000×` MnZn U-core + `8-stage` Cockcroft-Walton multiplier; eliminates ferrite core saturation and CW stray capacitance, cutting plasma draw to **9.80 W** (`+28.4%` net power gain). |
| **Total Modelled Parasitic Load** | **28.50 W per core** (`9.80 W` plasma + `12.60 W` preheated cavitator + `3.80 W` ECU/sensors + `2.30 W` fluidic/trim) | Down from `49.0 W` in the legacy ferrite/CW baseline. |
| **Radical Generation Yield** | **3.48 × 10¹⁷ radicals/J** (bus-referenced at `80% RH`, `90 bar` TDC) | High reduced electric field (`E/N`) streamer packets maximize `OH•`/`O•` formation without bulk gas thermal runaway. |
| **Opposed Free-Piston Core** | **50 Hz**, `25 mm` bore × `40 mm` stroke (`39.27 cm³` swept volume, `117.8 L/min` airflow), **30:1 compression** (`~90 bar`, `860 °C` bulk / `3,000 °C` plasma channels) | Radial-magnetized **N52H** linear alternators (`<105 °C` thermally clamped via argon aerogel) + **YSZ** ceramic liners + **5 µm** contactless air bearings (`25,000+ hr` design life). |
| **Regenerative Thermal Loop** | **0.54 L/hr** (`0.15 g/s`) water rate preheated from `25 °C → 90 °C` (`40.79 W` sensible + `342.38 W` latent heat from exhaust) | **100% exhaust-heated** (zero resistive heaters); lowers water viscosity by `64.7%` and cuts cavitation threshold power by `16%–25%`. |
| **Ozone (`O₃`) Quench & Aftertreatment** | Pre-quench `O₃`: **18.4 ppmv** → Post-quench `O₃`: **≤ 0.04 ppm** via **`α-MnO₂` catalytic bed** (`0.162 L` monolith) + `V₂O₅/TiO₂` SCR | Burst-mode gating avoids the `61.6 ppmv` continuous-discharge `O₃` spike, keeping the `α-MnO₂` quench bed compact and low-cost. |
| **VOC Self-Sustaining Break-Even** | **140.6 ppmv** (toluene-equivalent VOC loading) | Threshold where chemical + thermal recovery equals the `28.50 W` internal parasitic load (`0 W` net bus import/export). |

---

## Repository File Index

### Core Documentation & Audits
* `README.md` — Project overview, inventor statement (**Thomas Gabriel Coleman**), scope notice, and standardized baseline reference.
* `venice_ai_engineering_audit_v3.md` — Line-by-line thermodynamic, parasitic power, ozone quench (`α-MnO₂`), and `radicals/J` audit for the GaN-ZVS Slayer baseline.
* `cool_power_core_master_dossier_v3.pdf` — Consolidated print-ready engineering dossier combining system specs, audits, and multi-configuration comparisons.

### System Configurations & Multi-Core Scaling
* `cool_power_core_master_comparison_v3.md` & `.csv` — Side-by-side performance matrix across all eight architectures (`CFG-01` through `CFG-08`).
* `cool_power_core_multicore_sizing.pdf` & `.csv` — Scaling models from `1` to `64` cores (`11.2 kg` to `621.8 kg`, up to `22.52 kW` net electrical export).
* `cool_power_core_semi_truck_exhaust_analysis.md` — Class 8 diesel exhaust slipstream integration (`+11.44 kW` per 16-core rack, `22%` DEF savings).
* `cool_power_core_16core_truck_layout.pdf` & `.svg` — 2D engineering schematic of the 16-core Class 8 truck rack.

### Electronics, Flywheels & Embedded Control
* `gan_zvs_slayer_circuit_and_pll_specs.md` — `100 V` eGaN ZVS push-pull driver, `876 kHz` air-core resonator, and `<3.5 µs` PLL dielectric-shift tracking specs.
* `cool_power_core_ecu.cpp` — Real-time `STM32G474RE` C++ firmware for `50 Hz` TDC burst gating, `360°/N` multi-core phase interleaving, and vortex thermal clamping.
* `cool_power_core_flywheel_analysis.md` & `rhombic_flywheel_kinematics_and_sizing.md` — Virtual electronic flywheel and zero-side-load counter-rotating rhombic flywheel mechanics.
* `cool_power_core_turbine_flywheel_analysis.md` & `tesla_turbine_flywheel_rotor_specs.md` — `45,000 RPM` Ti-6Al-4V / T800 carbon-fiber exhaust turbine flywheel sizing.

### Polluted Water Remediation
* `cool_power_core_water_remediation.md` — Technical analysis of PFAS destruction, heavy-metal brine rejection, and energy-positive distillation.
* `cool_power_core_water_mass_balance.csv` — Mass-balance and energy recovery dataset across six contaminated water profiles (`WTR-01` through `WTR-06`).
* `cool_power_core_water_pfd.pdf` & `.svg` — Process Flow Diagram (`PFD`) for the closed-loop water remediation and distillation skid.

---

*Copyright © 2026 **Thomas Gabriel Coleman**. All rights reserved. Please cite **Thomas Gabriel Coleman** in all derivative works, evaluations, or hardware prototypes.*
