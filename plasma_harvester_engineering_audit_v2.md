# Plasma-Assisted Thermo-Chemical Harvester: Engineering Audit & Setpoint Optimization (v2)

## 1. Executive Summary & Audit Scope
This audit document accompanies the parametric simulation dataset (`plasma_harvester_parametric_model.csv`) and evaluates the closed-loop plasma-cavitation opposed free-piston harvester across **45 operating setpoint combinations** spanning:
* **Plasma Pulse Width:** $10\text{ ns}$ to $250\text{ ns}$ (at $33.6\text{ kV}$ peak, $20\text{ W}$ average input)
* **Electrode Gap Distance:** $1.5\text{ mm}$, $2.5\text{ mm}$, and $4.0\text{ mm}$ ($E$-fields from $84.0\text{ kV/cm}$ to $224.0\text{ kV/cm}$)
* **Exhaust Bypass Ratio:** $0.25$, $0.45$, and $0.65$ (fraction of exhaust thermal stream routed to the $90^\circ\text{C}$ reservoir and Venturi cavitator)

---

## 2. Modelled Parasitic Power Derivation (~43.4 W to 49.0 W)
All parasitic power figures are **modelled** from first-principles fluid mechanics and pulsed-power circuit budgets rather than wall-plug measurements:

1. **ZVS + 8-Stage Cockcroft-Walton Plasma Driver ($P_{\text{plasma}}$):**
   * Fixed at **$20.0\text{ W}$** average input ($4.2\text{ V}$ DC bus stepped up $8000\times$ to $33.6\text{ kV}$).
   * Pulse repetition frequency scales inversely with pulse width ($10\text{ ns}$ to $250\text{ ns}$) to hold average discharge power constant.
2. **Acoustic/Fluidic Cavitator ($P_{\text{cav}}$):**
   * **Cold Baseline ($25^\circ\text{C}$):** $30.0\text{ W}$ nominal drive power required to overcome surface tension ($\sigma = 72.0\text{ mN/m}$) and dynamic viscosity ($\mu = 0.89\text{ mPa}\cdot\text{s}$).
   * **Preheated State ($90^\circ\text{C}$):** Surface tension drops to $60.8\text{ mN/m}$ ($-15.6\%$) and viscosity drops to $0.315\text{ mPa}\cdot\text{s}$ ($-64.6\%$), while saturation vapor pressure rises from $3.17\text{ kPa}$ to $70.1\text{ kPa}$. This lowers the cavitation inception threshold by **$22.0\%$**, reducing cavitator draw to **$23.4\text{ W}$** (or **$29.0\text{ W}$** in the conservative $15\text{ W} + 15\text{ W}$ dual-stage split configuration, yielding **$49.0\text{ W}$** total parasitic load).

---

## 3. Thermal Energy Source Verification (Exhaust-Heated vs. Resistance-Heated)
The water cracking and preheating stages are **100% exhaust-heated and non-thermally plasma-assisted**, with zero resistive heating elements:
* **Sensible Preheating ($25^\circ\text{C} \to 90^\circ\text{C}$ at $0.54\text{ L/hr}$):**
  $$\dot{Q}_{\text{sens}} = \dot{m} c_p \Delta T = (0.00015\text{ kg/s})(4184\text{ J/kg}\cdot\text{K})(65\text{ K}) = 40.8\text{ W}$$
* **Exhaust Bypass Threshold:** With $\sim 450\text{ W}$ of available exhaust enthalpy, an **Exhaust Bypass Ratio $\ge 0.10$** satisfies sensible preheating, while **Bypass Ratio $= 0.45$** ($202.5\text{ W}$ recovered) supplies both the $40.8\text{ W}$ reservoir maintenance and partial latent vaporization enthalpy ($339.0\text{ W}$ required for full phase change) ahead of the $30:1$ compression stroke.

---

## 4. Baseline Drivers & Reference States

| Metric / Efficiency Claim | Modelled Value | Baseline Driver | Reference State |
| :--- | :--- | :--- | :--- |
| **Cavitation Power Reduction** | **$-22.0\%$** ($30.0\text{ W} \to 23.4\text{ W}$) | Liquid water at $25^\circ\text{C}$, $101.3\text{ kPa}$ | Preheated water at $90^\circ\text{C}$, $80\%$ intake RH |
| **Linear Alternator Efficiency** | **$85.0\%$** mechanical-to-electrical | Ideal lossless electromechanical transducer | Radial N52H array at $50\text{ Hz}$, $40\text{ mm}$ stroke, $<100^\circ\text{C}$ magnet temp |
| **TEG + Pyroelectric Recovery** | **$4.2\%$** thermal conversion | Carnot limit ($\eta_C = 1 - T_c/T_h \approx 56\%$) | $\Delta T = 380\text{ K}$ across YSZ-insulated exhaust block |
| **Adiabatic Compression Temp** | **$860^\circ\text{C}$** bulk ($3000^\circ\text{C}$ streamer) | Uncompressed intake at $90^\circ\text{C}$, $1\text{ bar}$ | $30:1$ volumetric compression ratio, $\gamma = 1.35$ |
| **SCR $\text{NO}_x$ Conversion** | **$>92\%$** reduction | Untreated post-plasma exhaust gas | Vanadium/$\text{TiO}_2$ honeycomb at $300^\circ\text{C}$–$380^\circ\text{C}$ |

---

## 5. Ozone ($\text{O}_3$) Output & $\alpha\text{-MnO}_2$ Quench Bed Sizing
Operating at **$2.5\text{ mm}$ gap ($134.4\text{ kV/cm}$)** and **$80\%$ RH at $90^\circ\text{C}$** across $117.8\text{ L/min}$ ($1.963 \times 10^{-3}\text{ m}^3/\text{s}$) total gas flow:

| Operating Mode | Pulse Width | Radical Yield ($\text{radicals/J}$) | Pre-Quench $\text{O}_3$ | Required NTU ($\le 0.05\text{ ppm}$) | $\alpha\text{-MnO}_2$ Bed Volume | Catalyst Media Cost |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Optimal Nanosecond Pulsed** | $10\text{ ns}$ | $2.65 \times 10^{17}$ | $21.5\text{ ppm}$ | $6.06$ | $119.8\text{ cm}^3$ | $\$18.47$ |
| **Moderate Pulsed** | $50\text{ ns}$ | $2.21 \times 10^{17}$ | $23.8\text{ ppm}$ | $6.17$ | $122.0\text{ cm}^3$ | $\$18.81$ |
| **Quasi-Continuous Boost ($+185\%$ flux)** | $250\text{ ns}$ | $0.90 \times 10^{17}$ | $61.6\text{ ppm}$ | $7.12$ | $372.0\text{ cm}^3$ ($3.1\times$) | $\$57.35$ ($+\$38.88$) |

### Key Takeaway on Quench Economics
* Pushing the discharge toward continuous or long-pulse operation ($250\text{ ns}$) increases gas thermalization, raising pre-quench $\text{O}_3$ from **$21.5\text{ ppm}$ to $61.6\text{ ppm}$** while cutting per-joule radical efficiency by **$66\%$**.
* To hold outlet ozone below the **$0.05\text{ ppm}$** occupational/ambient threshold, the $\alpha\text{-MnO}_2$ catalytic quench bed must scale from **$120\text{ cm}^3$ to $372\text{ cm}^3$** (accounting for higher space-velocity mass-transfer resistance), adding **$+\$38.88$** in catalyst media cost and negating the BOM savings of a simplified continuous driver.
* **Recommended Setpoint:** Maintain **$10\text{ ns}$ pulse width**, **$2.5\text{ mm}$ electrode gap**, and **$0.45$ exhaust bypass ratio**, yielding **$2.65 \times 10^{17}\text{ radicals/J}$**, **$43.4\text{ W}$** parasitic draw, and **$151.6\text{ W}$** net electrical output.
