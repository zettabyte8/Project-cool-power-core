# SCALED OUTPUT MAP — PLACEHOLDER

Status: PROVISIONAL. Companion to REV 6.0 MASTER (placeholder).
All figures modelled, none measured. Superseded when FT-19 runs and when
the aux-harvest derivation lands.

Designer: Thomas G. Coleman

---

## 0. PURPOSE AND STATUS

This file maps outputs, efficiency and break-even across the four scale
tiers so the scaling behaviour is visible in one place. It exists because
the question "does a bigger unit work on weaker vapour?" has a
counter-intuitive answer, and that answer governs which tiers are worth
building.

Nothing here is measured. Treat every net figure as provisional.

## 1. ASSUMPTIONS

| Parameter | Value | Basis |
|---|---|---|
| Aux harvest at 1.0x | 16 W | TEG 7, Tesla turbine 5, pyroelectric 2, PZT 2 — unmeasured |
| Fixed controller load | 5 W per unit | Not scaled |
| Water-mode parasitic at 1.0x | 250 W | Includes 95 W heat-pumped desiccant regen |
| Net conversion | 25.4% | 88% oxidation x 34% indicated x 85% alternator |
| Stroke / bore | 1.25 | Constant across tiers |
| Frequency | 65 Hz | Constant across tiers |
| Compression ratio | 15–26:1 | 26:1 top mandatory for HCCI on steam |
| Fuel basis | Toluene, 92 g/mol, 42 MJ/kg | Blend shifts break-even <10% |
| Steam cap | 40% mass | Above this, misfire rate climbs |

All net figures are **water mode** — the honest configuration, since water
is the second priority and is never traded away silently.

## 2. SCALED OUTPUTS

| | 0.5x micro | 1.0x base | 2.5x mobile | 10x industrial |
|---|---|---|---|---|
| Bore x stroke | 25.4 x 31.8 mm | 32 x 40 mm | 43.4 x 54.3 mm | 69 x 86.3 mm |
| Swept volume | 32.2 cm³ | 64.4 cm³ | 161 cm³ | 644 cm³ |
| Core flow | 125 L/min | 251 L/min | 628 L/min | 2,510 L/min |
| Air cleaned | 29.1 m³/h | 58.3 m³/h | 145.7 m³/h | 582.7 m³/h |
| Water @60% RH | 5.4 L/day | 10.8 L/day | 27 L/day | 108 L/day |
| Parasitic (water mode) | 36.3 W | 255 W | 630 W | 2,505 W |
| Aux harvest | 2 W | 16 W | 40 W | 160 W |
| **Break-even VOC** | **2,046 ppm** | **2,004 ppm** | **1,979 ppm** | **1,966 ppm** |
| Fuel at break-even | 20.8 g/h | 97 g/h | 241 g/h | 963 g/h |
| Net @ 25 ppm (urban) | −33.9 W | −236 W | −582 W | −2,315 W |
| Net @ 500 ppm | −26.8 W | −179 W | −441 W | −1,748 W |
| Net @ 2,000 ppm | −4.4 W | −0.4 W | +6.5 W | +41 W |
| Net @ 5,000 ppm | +40.3 W | +357.5 W | +901 W | +3,620 W |

## 3. EFFICIENCY, BOTH DRIVERS

| | Baseline MnZn + 8-stage CW | PLL GaN-ZVS | Gain |
|---|---|---|---|
| Lean oxidation | 52% | 88% | 1.69x |
| Radical yield at 20 W | 1.0 | 2.85 | 2.85x |
| Net conversion | 12.4% | 25.4% | 2.05x |
| Break-even at 1.0x | ~2,400 ppm | ~2,004 ppm | 1.2x |

The 2.85x radical figure is a modelling assumption resting on 52% -> 88%
oxidation. It is the largest unverified number in the file.

## 4. FINDING: BREAK-EVEN IS SCALE-INVARIANT

Break-even sits within 4% of 2,000 ppm across a twentyfold volume range.
Fuel and parasitic scale together, so a bigger machine buys throughput, not
reach. The micro tier is marginally worst only because of the fixed 5 W of
controller, which is why it is the least worth building.

**Consequence:** the 10x industrial unit is justified by 583 m³/h of
cleaned air and 3.6 kW of export at 5,000 ppm — not by running on weaker
vapour than the base unit.

## 5. SENSITIVITY, 1.0x

| Configuration | Break-even |
|---|---|
| Water mode, aux 16 W (baseline) | 2,004 ppm |
| Water mode, aux 32 W | 1,870 ppm |
| Water mode, aux 0 W | 2,138 ppm |
| Air only, aux 16 W | 956 ppm |
| Air only, aux 0 W | 1,090 ppm |

**The dominant lever is water mode, not aux.** Dropping water halves
break-even; aux to zero moves it 7%. This corrects an earlier overstatement
that break-even "doubles" without aux — at the corrected parasitic level
aux is only 6% of load and has little leverage.

## 6. FUEL CALIBRATION

| Source | Yield | Runs base unit? |
|---|---|---|
| Cigarette, candle | 1–5 g/h | No |
| Gas cooking | 10–20 g/h | No |
| Open wood fire | 50–200 g/h | Yes, with margin |
| Solvent / paint vent | 100 g/h + | Yes |
| Refinery plume | kg/h | Yes, exports |

"Cook and smoke as fuel" is true for a fire and false for a cigarette.
That distinction belongs in the README.

## 7. THERMAL CEILING

At 6,500 ppm the 10x unit passes 31 kW thermal through 583 m³/h. EGR via
the vortex amplifier and the argon aerogel magnet barrier become the
limiting hardware. Do not sell the 10x past ~5,000 ppm without a liner and
magnet upgrade.

## 8. OPEN

- Aux derivation: TEG, turbine, pyroelectric, PZT measured separately
- FT-19 full-flow water and power balance at 25 °C / 60% RH
- G1 dissociation fraction vs steam fraction with misfire rate
- Ozone outlet at full flow, both drivers
- Verify 88% oxidation is achievable at 40% steam and 26:1

## 9. CHANGELOG

v1 — Initial map. Four tiers. Scale-invariance identified. Water mode
declared the dominant sensitivity. Aux overstatement corrected.