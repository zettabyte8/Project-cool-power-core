<!-- docs/32b-blank-run.md -->
# 32b — Blank Run Protocol

Must run before any measurement. Establishes the leak rate so a leak is not read as dissociation.

## 1. Purpose

With no arc, f = 0. Any H computed is leak. Subtract it from every subsequent run.

## 2. Procedure

1. Full flow, 0.54 L/h, 90 °C, 3 bar, σ 0.2 — identical to a live run.
2. **Arc off. Corona off.**
3. Run 4 h exactly.
4. Weigh as normal.

## 3. Compute

$$H_{leak} = \frac{C + V - F}{18}$$

A positive $H_{leak}$ means water is escaping unmeasured.

## 4. Acceptance

| Leak as water over 4 h | Verdict |
|---|---|
| < 20 g | Good, correct and continue |
| 20–40 g | Acceptable, correct and note it |
| > 40 g | **Stop.** Find the leak. It is 10% of a real signal |

Reference: a real signal at f = 0.20 is ~433 g over 4 h. A 40 g leak is 9%.

## 5. Correction

$$f_{true} = \frac{18(H_{measured} - H_{leak})}{F}$$

## 6. Where leaks hide

Condenser outlet to sump · slipstream tap thread · jar lid · pump diaphragm · reservoir lid. Soapy water on every joint at 3 bar before the blank.

## 7. Frequency

Blank before every campaign, and again if any joint is disturbed. **Two blanks bracketing a run is better than one** — if they differ by more than 5 g, the rig moved and the run is void.