# Cool Power Core (CPC-RAD-HV) — NRC & IAEA Nuclear Safety Licensing & Compliance Checklist
**Document ID:** `CPC-REG-2026-004` | **Inventor / Architect:** Thomas G. Coleman | **System Variant:** `CPC-RAD-HV` (1,000-Core Skid & Single-Core Module)

---

## 1. Regulatory Scope & Licensing Pathway Overview
Deployment of the **Cool Power Core Radiation-Harvesting Variant (`CPC-RAD-HV`)** at nuclear remediation sites (such as Fukushima Daiichi, Hanford, Sellafield, or commercial decommissioning facilities) triggers dual-jurisdiction oversight covering **radioactive effluent/waste processing**, **high-voltage plasma equipment**, and **sealed/unsealed byproduct material containment**.

* **United States Jurisdiction (U.S. NRC / DOE):**
  * **10 CFR Part 20:** Standards for Protection Against Radiation (ALARA, effluent concentration limits, occupational dose limits).
  * **10 CFR Part 30 / Part 70:** Rules of General Applicability to Domestic Licensing of Byproduct Material & Special Nuclear Material (SNM criticality safety).
  * **10 CFR Part 50 Appendix B / ASME NQA-1:** Quality Assurance Criteria for Nuclear Power Plants and Fuel Reprocessing Plants.
  * **10 CFR Part 71 / 49 CFR 173:** Packaging and Transportation of Radioactive Material (for vitrified solid cake canisters).
* **International & Japanese Jurisdiction (IAEA / NRA):**
  * **IAEA GSR Part 3:** Radiation Protection and Safety of Radiation Sources (International Basic Safety Standards).
  * **IAEA GSR Part 5:** Predisposal Management of Radioactive Waste.
  * **IAEA SSR-6:** Regulations for the Safe Transport of Radioactive Material.
  * **Japan NRA Ordinance (Act on the Regulation of Nuclear Source Material, Nuclear Fuel Material and Reactors):** Specific Technical Standards for Specified Nuclear Facilities (Fukushima Daiichi ALPS/water-treatment compliance).

---

## 2. Master Regulatory & Safety Compliance Matrix

| Item ID | Regulatory Standard | Domain / Hazard | `CPC-RAD-HV` Engineering Control & Acceptance Criterion | Verification Method |
| :--- | :--- | :--- | :--- | :--- |
| **REG-01** | **10 CFR 20.1201 / IAEA GSR Part 3** | Occupational External Gamma Dose | 28 mm graded **W-B₄C** sump shield attenuates 99.4% of ¹³⁷Cs (662 keV) and ⁶⁰Co (1.17/1.33 MeV) photons; exterior contact dose **≤ 15 µSv/hr** at 100% sump loading. | Monte Carlo MCNP6 shielding model + calibrated Geiger-Müller / ion-chamber survey. |
| **REG-02** | **10 CFR 20.1302 / App. B Table 2** | Liquid Effluent Release Limits | Closed-loop distillation + V₂O₅/TiO₂ SCR yields distillate with **< 0.1 Bq/L** non-tritiated β/γ activity (Decontamination Factor **> 10⁵**). | HPGe gamma spectroscopy & Liquid Scintillation Counting (LSC) per batch. |
| **REG-03** | **10 CFR 20.1302 / NRA Tritium Std** | Tritiated Water (HTO) Control | Counter-current 33.6 kV plasma kinetic isotope enrichment concentrates HTO into bottoms loop; overhead vapor discharge **< 1,500 Bq/L** (WHO/NRA discharge threshold). | Dual-channel LSC tritium assay + inline quadrupole mass spectrometer. |
| **REG-04** | **10 CFR 70.24 / ANSI/ANS-8.1** | Nuclear Criticality Safety (NCS) | Sump internal diameter restricted to **Ø134 mm** (favorable geometry) with **5 wt% ¹⁰B-enriched B₄C** neutron absorber matrix; \(k_{	ext{eff}} < 0.85\) under full moderation/reflection. | MCNP6 criticality validation + physical geometric interlock inspection. |
| **REG-05** | **ASME BPVC Sec. VIII Div. 1 / Sec. III** | Pressure Boundary & Hydrogen Deflagration | **Ti-6Al-4V** sump & **8YSZ** liner rated to **4.5 MPa** MAWP; internal hydrogen inventory kept **< 1.8 vol%** (well below 4.0% LFL) via continuous catalytic recombination. | Hydrostatic proof test at 1.5× MAWP + helium mass-spectrometer leak test (`< 10⁻⁸ std cm³/s`). |
| **REG-06** | **IEEE Std 323 / IEC 60780** | Equipment Environmental & Radiation Qualification | **Sm₂Co₁₇** alternator magnets, **SOI** 15 W ECU, and **CVD-diamond** passivated 4H-SiC tiles qualified to **1.0 × 10⁸ Gy (10 Grad)** cumulative Total Ionizing Dose (TID). | Co-60 gamma-cell accelerated irradiation test + post-dose functional characterization. |
| **REG-07** | **OSHA 1910.1000 / ACGIH TLV** | Ozone (O₃) & NOₓ Off-Gas Containment | Dual-stage catalytic **V₂O₅/TiO₂ + MnO₂** destruct unit reduces exhaust ozone from 1,200 ppm internal to **< 0.05 ppm** at skid boundary (below 0.1 ppm 8-hr TWA). | Chemiluminescent NOₓ and UV-photometric O₃ continuous emissions monitors (CEMS). |
| **REG-08** | **NFPA 70 (NEC) / IEC 61010-1** | High-Voltage (33.6 kV) & Fiber-Optic Isolation | Potted 8-stage Cockcroft-Walton multiplier enclosed in grounded Faraday cage with **65 mm PTFE creepage**, dual-redundant lid interlocks, and active crowbar discharge (< 50 ms). | Hipot dielectric withstand test at 50 kV DC + interlock trip latency verification. |
| **REG-09** | **IAEA GSR Part 5 / 10 CFR 61.56** | Solid Waste Form Stability (Class A/B/C) | Vitrified borosilicate-phosphate concentrate cake discharged via pneumatic slide gate into **Type A / IP-2 shielded canisters**; compressive strength **> 3.45 MPa**, zero free liquids. | ANS 16.1 leachability index testing (`LI > 8.0`) + zero-free-liquid verification. |
| **REG-10** | **ASME NQA-1 / ISO 9001** | Software & Real-Time ECU Safety Interlocks | CPLD hardware watchdog executes sub-10 µs hard shutdown on loss of 5 µm air-bearing pressure, sump over-pressure, or N52H/Sm₂Co₁₇ over-temperature (> 110°C). | Hardware-in-the-loop (HIL) fault-injection test suite & software V&V audit. |

---

## 3. Pre-Deployment Site Licensing & Commissioning Sign-Off Protocol
1. **Safety Analysis Report (SAR) Submittal:** Submit site-specific MCNP6 dose-rate, criticality (\(k_{	ext{eff}}\)), and hydrogen deflagration bounding analyses to the site Nuclear Safety Review Board.
2. **Cold Commissioning (Non-Radioactive Surrogate):** Execute 250-hour continuous endurance run using stable **¹³³Cs / ⁸⁸Sr / ⁵⁹Co** non-radioactive chemical surrogates to verify **> 10⁵ decontamination factor** and **+320.7 W** baseline net power prior to introducing hot leachate.
3. **Hot Commissioning & Radiological Hold-Point:** Introduce diluted site water at 10% design activity (`10⁴ Bq/L`), verify CEMS off-gas (`< 0.05 ppm O₃`), confirm LSC distillate purity (`< 0.1 Bq/L`), and obtain Radiation Protection Officer (RPO) release for 100% continuous operation.
