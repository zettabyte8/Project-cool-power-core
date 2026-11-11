<!-- docs/32-g1-water-rig.md -->
# 32 — G1 Water Rig Build

Measures dissociation fraction. Decides whether the project is a generator or a purifier. **Build before anything else.**

## 1. Method

Steady-state balance: $H = (C + V - F)/18$, then $f = 18H/F$.
F feed, C condensate, V vapour. V from a metered 3% slipstream by total condensation.
Cross-check: H₂ by sensor on a dried sample. Both within 20% or the run is void.

## 2. Cost

| Item | $ |
|---|---|
| Balance 5 kg × 0.01 g × 2 | 180 |
| Needle valve + rotameter (slipstream) | 60 |
| Borosilicate cold trap −40 °C | 45 |
| Silica gel | 12 |
| Heated sample line 150 °C + controller | 95 |
| Electrochemical H₂ sensor, 0–4% | 90 |
| Thermal air mass meter | 85 |
| Logger, 1 Hz, SD | 60 |
| Misc tubing, fittings, stands | 50 |
| **Total** | **677** |

Floor with scrounged balances: **$450**. A lab TCD instead of the cheap sensor adds ~$1,100 and is worth it only after a first pass.

## 3. Rig

Balances on a separate slab, not the rig frame — vibration ruins them.

1. Feed balance → reservoir → 3 bar pump → cavitator → arc → chamber
2. Condensate balance under the condenser
3. Slipstream tap at turbine outlet → heated line → cold trap on a live balance → silica backup → H₂ sensor
4. Air mass meter upstream of the orifice

## 4. Uncertainty

δf/f = 2.5% at 3% slipstream and 0.01 g live balances. The trap dominates. At 1% slipstream the error triples and f = 0.15 becomes indistinguishable from 0.20 — **do not use a 1% slipstream.**

## 5. Calibration

Inject H₂ from a mass flow controller at the rate equivalent to f = 0.20. Both methods must return 0.20 ± 5%. Miss and the campaign does not start.

## 6. Procedure

Calibrate → 90 °C, 3 bar, σ 0.2 → arc 193 W, corona 100 ppm → 30 min to steady state → 4 h → compute both ways.

## 7. Verdict

| Result | Action |
|---|---|
| Both within 20%, f ≥ 0.15 | Proceed |
| Agree, f < 0.12 | Purifier only |
| Disagree > 20% | Leak or wet sample — redo |

## 8. Traps

Wet sample kills the sensor. H₂ recombines in cold line. Flashback — sinter arrestor mandatory. Balance drift from vibration. Slipstream ratio drifts with backpressure — verify hourly.