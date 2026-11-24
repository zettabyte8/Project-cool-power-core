# Smog/VOC Chemical Energy Recovery & α-MnO₂ Quench Housing Schematic Specifications

## 1. Executive Summary
This engineering addendum quantifies the **recoverable chemical enthalpy** from urban smog, volatile organic compounds (VOCs), carbon monoxide ($	ext{CO}$), $	ext{NO}_x$, $	ext{SO}_2$, and particulate matter ($	ext{PM}_{2.5}$) across five atmospheric concentration profiles, paired with full mechanical and fluidic schematic specifications for the **$lpha	ext{-MnO}_2$ ozone ($	ext{O}_3$) quench housing**.

---

## 2. Pollutant Chemical Enthalpy & Power Recovery Model

### 2.1 Boundary Conditions & Molar Flow Basis
* **Volumetric Intake Rate ($Q_{	ext{in}}$):** $117.8	ext{ L/min}$ ($0.001963	ext{ m}^3	ext{/s}$) at $50	ext{ Hz}$ opposed-piston cycle ($39.27	ext{ cm}^3$ swept volume).
* **Intake Manifold State:** $90^\circ	ext{C}$ ($363.15	ext{ K}$), $101.325	ext{ kPa}$ ($1	ext{ atm}$), $80\%	ext{ RH}$.
* **Total Molar Gas Flow ($\dot{n}_{	ext{total}}$):**
  $$\dot{n}_{	ext{total}} = rac{P \cdot Q_{	ext{in}}}{R \cdot T_{	ext{in}}} = rac{101325 	imes 0.0019633}{8.3145 	imes 363.15} = 0.0659	ext{ mol/s}$$
* **Oxidation / Destruction Efficiency ($\eta_{	ext{ox}}$):** $92\%$ (combined nanosecond corona radicalization + $30:1$ compression).
* **Thermoelectric + Linear Alternator Conversion Efficiency ($\eta_{	ext{conv}}$):** $28\%$ of released chemical enthalpy converted to electrical bus power.

### 2.2 Reaction Enthalpies ($\Delta H^\circ$)
1. **VOCs (modeled as Toluene, $	ext{C}_7	ext{H}_8 + 9	ext{O}_2 ightarrow 7	ext{CO}_2 + 4	ext{H}_2	ext{O}$):** $\Delta H = -3,910	ext{ kJ/mol}$
2. **Carbon Monoxide ($	ext{CO} + rac{1}{2}	ext{O}_2 ightarrow 	ext{CO}_2$):** $\Delta H = -283.0	ext{ kJ/mol}$
3. **Particulate Soot ($	ext{C}_{(s)} + 	ext{O}_2 ightarrow 	ext{CO}_2$):** $\Delta H = -393.5	ext{ kJ/mol}$ ($12.011	ext{ g/mol}$)
4. **Sulfur Dioxide ($	ext{SO}_2 + rac{1}{2}	ext{O}_2 + 	ext{H}_2	ext{O} ightarrow 	ext{H}_2	ext{SO}_4$):** $\Delta H = -99.0	ext{ kJ/mol}$
5. **Nitrogen Oxides ($	ext{NO} + 	ext{O}_3 ightarrow 	ext{NO}_2 + 	ext{O}_2$):** $\Delta H = -57.0	ext{ kJ/mol}$

### 2.3 Scenario Results Summary (See `smog_voc_energy_recovery_model.csv`)

| Atmospheric Profile | $	ext{NO}_x$ (ppm) | VOC (ppm) | $	ext{CO}$ (ppm) | $	ext{PM}_{2.5}$ ($\mu	ext{g/m}^3$) | Total Chemical Heat (W) | Recovered Electric (W) | Net Balance vs. 44.5 W Parasitic (W) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Clean Ambient Baseline** | 0.05 | 0.05 | 0.5 | 12 | 0.02 W | 0.01 W | **-44.49 W** |
| **Moderate Urban Smog (LA / IE)** | 15.0 | 25.0 | 50.0 | 85 | 6.89 W | 1.93 W | **-42.57 W** |
| **Heavy Traffic / Tunnel Exhaust** | 85.0 | 120.0 | 350.0 | 450 | 34.85 W | 9.76 W | **-34.74 W** |
| **Industrial Flue / Dense VOC** | 250.0 | 500.0 | 1,200.0 | 2,500 | 140.25 W | 39.27 W | **-5.23 W** |
| **Concentrated Hydrocarbon Vapor** | 400.0 | 1,500.0 | 3,000.0 | 5,000 | 408.73 W | 114.44 W | **+69.94 W** |

> **Key Physical Finding:** At typical urban smog levels ($15	ext{–}85	ext{ ppm NO}_x$, $25	ext{–}120	ext{ ppm VOC}$), pollutant oxidation contributes **$1.9	ext{ W}$ to $9.8	ext{ W}$** of electrical recovery—acting as a **pollution-scrubbing parasitic offset** rather than a self-sustaining fuel source. Self-sustaining net positive electrical generation ($>44.5	ext{ W}$) solely from airborne chemical enthalpy requires **$\ge 570	ext{ ppm}$ toluene-equivalent VOC loading** (or equivalent industrial syngas/hydrocarbon vapor feed), unless supplemented by an external thermal gradient ($\Delta T$) across the TEG/pyroelectric stack.

---

## 3. $lpha	ext{-MnO}_2$ Ozone Quench Housing Schematic Specifications

### 3.1 Process Design Basis
* **Target Outlet Concentration:** $\le 0.05	ext{ ppmv}$ (OSHA/NIOSH continuous exposure limit).
* **Quench Inlet Temperature & Flow:** $65^\circ	ext{C}$ ($338.15	ext{ K}$) downstream of condenser/TEG; volumetric flow $Q_{	ext{quench}} = 109.7	ext{ L/min}$ ($0.001828	ext{ m}^3	ext{/s}$).
* **Substrate Architecture:** Extruded cordierite honeycomb monolith ($400	ext{ CPSI}$, wall thickness $0.15	ext{ mm}$, open frontal area $	ext{OFA} = 0.76$, hydraulic channel diameter $d_h = 1.12	ext{ mm}$) washcoated with **cryptomelane-type $lpha	ext{-MnO}_2$ nanorods** at $120	ext{ g/L}$ loading.
* **Humidity Derating:** Because exhaust enters near saturation ($75\%	ext{–}85\%	ext{ RH}$), competitive $	ext{H}_2	ext{O}$ physisorption on $	ext{Mn}^{3+}/	ext{Mn}^{4+}$ oxygen vacancies reduces the effective mass-transfer rate constant ($k_v = 28.5	ext{ s}^{-1}$ dry) by a factor of $2.15	imes$ (pulsed) to $2.65	imes$ (continuous boost).

### 3.2 Dimensional & Fluidic Comparison Table

| Parameter | Configuration A: Pulsed Baseline ($21.6	ext{ ppm O}_3$) | Configuration B: Continuous Boost ($61.6	ext{ ppm O}_3$) |
| :--- | :---: | :---: |
| **Required NTU ($\ln(C_{	ext{in}}/C_{	ext{out}})$)** | $6.07$ | $7.12$ |
| **Effective Bed Volume ($V_{	ext{bed}}$)** | $837	ext{ cm}^3$ ($0.84	ext{ L}$) | $1,210	ext{ cm}^3$ ($1.21	ext{ L}$) |
| **Active $lpha	ext{-MnO}_2$ Catalyst Mass** | $100.4	ext{ g}$ | $145.2	ext{ g}$ |
| **Monolith Core Diameter ($D_{	ext{core}}$)** | $8.11	ext{ cm}$ ($81.1	ext{ mm}$) | $9.17	ext{ cm}$ ($91.7	ext{ mm}$) |
| **Monolith Core Length ($L_{	ext{core}}$)** | $16.22	ext{ cm}$ ($162.2	ext{ mm}$) | $18.34	ext{ cm}$ ($183.4	ext{ mm}$) |
| **Superficial Face Velocity ($u_s$)** | $0.354	ext{ m/s}$ | $0.277	ext{ m/s}$ |
| **Channel Velocity ($u_{	ext{ch}}$)** | $0.466	ext{ m/s}$ | $0.364	ext{ m/s}$ |
| **Core Pressure Drop ($\Delta P$)** | $39.2	ext{ Pa}$ ($0.39	ext{ mbar}$) | $34.6	ext{ Pa}$ ($0.35	ext{ mbar}$) |
| **Space Velocity (GHSV)** | $7,864	ext{ hr}^{-1}$ | $5,440	ext{ hr}^{-1}$ |

### 3.3 Mechanical & Material Schematic Layout

```text
  [From Condenser / Ion Grid: 65°C, 80% RH, 21.6–61.6 ppm O3]
                             │
                             ▼
            ┌─────────────────────────────────┐
            │  1. INLET DIFFUSER CONE (15°)   │  <-- 316L SS, PTFE-lined,
            │     + Perforated Baffle Plate   │      42% open area diffuser
            └────────────────┬────────────────┘
                             │
            ┌────────────────▼────────────────┐
            │  2. UPSTREAM GUARD & HEATER     │  <-- 12W PTC trim ring (keeps
            │     Hydrophobic PTFE Mesh       │      wall >70°C to prevent
            └────────────────┬────────────────┘      liquid film condensation)
                             │
            ┌────────────────▼────────────────┐
            │  3. α-MnO2 MONOLITH CANISTER    │  <-- 316L SS Shell (ID: 85–96 mm)
            │     400 CPSI Cordierite Core    │      Intumescent vermiculite mat
            │     (L = 162–183 mm)            │      (3.0 mm radial compression)
            └────────────────┬────────────────┘
                             │
            ┌────────────────▼────────────────┐
            │  4. OUTLET PLENUM & SENSOR PORT │  <-- Electrochemical O3 sensor
            │     (Target: <= 0.05 ppmv O3)   │      (0–1 ppm range, +/-5 ppb)
            └────────────────┬────────────────┘
                             │
                             ▼
            [To Clean Air / O2-Enriched Exhaust Outlet]
```

### 3.4 Fabrication & Integration Notes
1. **Condensation Prevention:** Liquid water droplets block $lpha	ext{-MnO}_2$ micropores immediately. A $12	ext{ W}$ positive-temperature-coefficient (PTC) heater band wrapped around the inlet diffuser maintains wall temperature $5^\circ	ext{C}$ above the local dew point ($>70^\circ	ext{C}$).
2. **Mounting & Vibration Isolation:** Because the housing sits downstream of a $50	ext{ Hz}$ opposed-piston oscillator, the cordierite monolith must be wrapped in a $3.0	ext{ mm}$ intumescent ceramic fiber mat inside a $1.5	ext{ mm}$ thick **316L stainless steel** shell with V-band flanges for rapid cartridge replacement.
3. **Pressure Drop Budget:** At $<40	ext{ Pa}$ across the monolith, the quench stage imposes less than $0.04\%$ backpressure penalty on the free-piston exhaust stroke and Tesla micro-turbine.
