# Cool Power Core Black-Start & Cold-Start Transient Spin-Up Analysis

**Document ID:** CPC-START-002  
**Companion Data File:** `flywheel_blackstart_spinup_curve.csv`  
**Rotor Inertia ($I_{\text{total}}$):** $0.03344\text{ kg}\cdot\text{m}^2$  
**Starter Source:** $12\text{ V}$ LiFePO4 / Ultracapacitor Module ($336\text{ W}$ peak inverter-fed linear motoring)

---

## 1. Four-Phase Cold-Start Sequence (0.0 s to 5.0 s)

Because $5\,\mu\text{m}$ aerodynamic gas bearings require relative surface velocity ($>12\text{ Hz}$) to establish full hydrodynamic film stiffness, and $30:1$ compression requires high piston momentum to overcome peak cylinder pressure ($\sim 90\text{ bar}$), the ECU executes a **four-phase black-start trajectory**:

1. **Phase 1 — Decompressed Aerodynamic Lift-Off ($0.00\text{ s} \to 1.50\text{ s}$ | $0 \to 20\text{ Hz}$):**
   * **Action:** Fluidic vortex bypass valves hold the exhaust/intake ports open (decompression mode) while auxiliary micro-piezo aerostatic bleed air floats the $5\,\mu\text{m}$ bearings during the first $0.25\text{ s}$ ($<3\text{ Hz}$).
   * **Dynamics:** The linear alternator operates in **bidirectional motoring mode** at $28\text{ A}$ ($12\text{ V}$ source $\rightarrow 336\text{ W}$ peak), accelerating the counter-rotating rhombic flywheel at $\sim 58\text{ rad/s}^2$ with minimal compression drag.
2. **Phase 2 — Full $30:1$ Compression Ramp ($1.50\text{ s} \to 2.85\text{ s}$ | $20 \to 35\text{ Hz}$):**
   * **Action:** At $20\text{ Hz}$ ($1,200\text{ RPM}$), flywheel kinetic energy reaches **$263.8\text{ J}$** ($17.8\times$ the single-cycle compression work of $14.85\text{ J}$). The ECU snaps the fluidic compression valves shut, engaging full $30:1$ adiabatic compression ($T_{\text{TDC}} \approx 860^\circ\text{C}$).
   * **Dynamics:** Stored flywheel momentum effortlessly carries the pistons through TDC without stalling or speed drop.
3. **Phase 3 — Plasma Light-Off & Bootstrap Crossover ($2.85\text{ s} \to 4.35\text{ s}$ | $35 \to 49.8\text{ Hz}$):**
   * **Action:** At $35\text{ Hz}$ ($2,100\text{ RPM}$), the ECU energizes the $15\text{ W}$ intake cavitator and $20\text{ W}$ ZVS $33.6\text{ kV}$ nanosecond plasma pulser ($43.4\text{ W}$ total parasitic draw).
   * **Dynamics:** Radicalized cold steam and ambient hydrocarbons ignite isochorically during the $1.45\text{ ms}$ TDC dwell window. By **$3.35\text{ s}$ ($41.8\text{ Hz}$)**, gross electrical generation crosses **$185\text{ W}$**, turning **net bus power positive** while simultaneously driving the flywheel to synchronous speed.
4. **Phase 4 — $50\text{ Hz}$ Synchronous Lock-In ($t \ge 4.45\text{ s}$ | $50.0\text{ Hz}$ / $3,000\text{ RPM}$):**
   * **Action:** Starter assist cuts to **$0.0\text{ W}$**. The ECU switches the linear alternator to regenerative load-clamping mode, holding frequency at $50.00 \pm 0.11\text{ Hz}$ ($1,650.2\text{ J}$ stored rotational energy).

---

## 2. Energy & Battery Sizing Summary

| Cold-Start Metric | Value | Engineering Implication |
| :--- | :--- | :--- |
| **Time to $20\text{ Hz}$ (Compression Engage)** | $1.50\text{ s}$ | Full hydrodynamic air-bearing film established |
| **Time to $35\text{ Hz}$ (Plasma Light-Off)** | $2.85\text{ s}$ | $808.6\text{ J}$ kinetic energy stored; zero TDC stall risk |
| **Time to Net-Positive Power Crossover** | $3.35\text{ s}$ | System becomes self-sustaining on internal bus |
| **Time to $50.0\text{ Hz}$ Synchronous Lock** | $4.45\text{ s}$ | Full rated steady-state output achieved |
| **Total Cumulative $12\text{ V}$ Starter Energy** | **$1,248.5\text{ J}$ ($0.347\text{ Wh}$)** | Equivalent to **$0.104\text{ Ah}$** at $12\text{ V}$ |
| **Minimum Cold-Start Storage Requirement** | **$2.5\text{ kJ}$ Ultracapacitor** or **$1\text{ Ah}$ LiFePO4** | Enables $>30$ consecutive black-starts without external grid power |

---

## 3. Cold-Reservoir ($\mathbf{20^\circ\text{C} \to 90^\circ\text{C}}$) Thermal Warm-Up Note
During a true cold start from $20^\circ\text{C}$ ambient water temperature, the cavitator initially draws $28.5\text{ W}$ (vs. $15.0\text{ W}$ at $90^\circ\text{C}$) until exhaust heat warms the $0.54\text{ L}$ thermal reservoir. With $0.54\text{ kg}$ of water ($c_p = 4,184\text{ J/kg}\cdot\text{K}$) receiving $\sim 380\text{ W}$ of recovered exhaust/block heat, the reservoir reaches the **$90^\circ\text{C}$ optimal cracking setpoint in $6.9\text{ minutes}$** ($415\text{ s}$), during which the system already operates at a net electrical surplus.
