<!-- docs/01-calc-sheet.md -->
# 01 — Calculation Sheet

Every headline number, its derivation, and a confidence rating. **Nothing in the pitch deck may appear unless it appears here first.**

Confidence: **A** = first-principles, checkable. **B** = standard correlation, ±30%. **C** = judgement, ±60%. **D** = assumption needing measurement.

## 1. Geometry (A)

| Quantity | Formula | Value |
|---|---|---|
| Piston area | $\pi (12.5)^2$ | 490.87 mm² |
| Swept / cylinder | $A \times 40$ | 19.635 cm³ |
| Total swept | $\times 2$ | 39.270 cm³ |
| Clearance volume | $39.270 / 29$ | 1.3541 cm³ |
| TDC gap | $V_c / A$ | 2.759 mm |
| Swept rate @50 Hz | $39.270 \times 50$ | 1.9635 L/s |
| Mean piston speed | $2 \times 0.040 \times 50$ | 4.00 m/s |
| Ambient-equiv. throughput @PR 1.5 | $1.9635 \times 1.5 \times 3.6$ | 10.6 m³/h |

## 2. Mass flows (B)

Charge density at BDC, 1.5 bar, 330 K: $1.5\times10^5/(287\times330) = 1.584$ kg/m³

$$\dot m_{air} = 1.9635\times10^{-3} \times 1.584 = 3.11\ \text{g/s}$$

$$\dot m_{water} = 0.54\ \text{L/h} = 0.150\ \text{g/s} = 8.333\ \text{mmol/s}$$

Exhaust total molar flow: 116.9 mmol/s (air 107.3 − O₂ consumed 1.25 + steam 8.333 + combustion water 2.5).

## 3. Energy (A)

| Quantity | Formula | Value |
|---|---|---|
| Full dissociation ΔH | $8.333\times10^{-3} \times 286{,}000$ | 2383 W |
| At f = 0.30 | $\times 0.30$ | 715 W |
| H₂ produced | $2.5\ \text{mmol/s} \times 242{,}000$ | 605 W |
| Electrical share @3000 °C (ΔG/ΔH = 27%) | $715 \times 0.27$ | 193 W |

**Why 27%:** at 3273 K the Gibbs term is ~65 kJ/mol against 245 kJ/mol total. The remainder is heat, recovered from exhaust. This is the entire justification for high-temperature cracking and it only holds above 2500 K.

## 4. Parasitics (B) — full

| Item | Config 1 (ambient condenser) | Config 2 (chilled) |
|---|---|---|
| Plasma arc | 193 | 193 |
| Bearing air compressor | 95 | 95 |
| Corona | 20 | 20 |
| Cavitator | 15 | 15 |
| Condenser fan | 10 | 10 |
| ECU + sensors | 8 | 8 |
| Water pump | 2 | 2 |
| DEF pump | 1 | 1 |
| Injector driver | 1 | 1 |
| DEF tank heater (avg) | 3 | 3 |
| **Chiller** | — | **130** |
| Turbo recovery | −25 | −25 |
| **Total** | **193 W** | **323 W** |

## 5. Gross and net (C)

IMEP 3.5–5.0 bar over 1.9635×10⁻³ m³/s = 687–982 W indicated. ×0.85 mechanical ×0.88 alternator = **514–735 W gross.**

| | Config 1 | Config 2 |
|---|---|---|
| Gross | 514–735 | 514–735 |
| Parasitic | 193 | 323 |
| **Net** | **320–540 W** | **190–410 W** |

Top of both bands requires 85% regenerator effectiveness. Median is ~430 and ~300.

## 6. Oxygen (A)

O₂ in 10.6 m³/h of air: $10.6 \times 0.2095 = 2.22$ m³/h = **2220 L/h**
Consumed in combustion: 1.25 mmol/s = 100 L/h
Exhaust O₂: 2120 L/h at ~20.7% in 10.2 m³/h of gas

**Claim: "1,380 L/h O₂-enriched exhaust."** With a 90%-capable membrane, ~350 L/h at 90%, costing 40 W and 25 L/h of sweep air.

## 7. NOx (C)

Zeldovich at 3000 °C, 150 ppm mean, 10–30 ppm post-SCR. 2.9 g/h as NO₂. See file 04.

## 8. Heat rejection (B)

Config 1: condenser 400 W + machine 300 W = **700 W.** At 10 K approach and 25 °C ambient, 1.4 m² radiator.
Config 2: condenser at 10 °C rejects 400 W to a chiller that dumps 530 W, plus 300 W machine = **830 W**, 1.7 m².

## 9. What is NOT in this sheet

Turbomachinery efficiency curves, regenerator effectiveness curve, bearing film stiffness, YSZ thermal shock life, atomisation Sauter diameter, quench rate measurement. All **D** — measure before quoting.