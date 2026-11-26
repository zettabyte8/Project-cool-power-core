# SCALED OUTPUT MAP v2 — PLACEHOLDER

Status: PROVISIONAL, modelled, none measured. Supersedes v1 of this file.
Basis corrected to 180 L/min core and 185/240 W parasitic.

---

## 1. BASIS

| Parameter | Value | Source |
|---|---|---|
| Core flow | 180 L/min | v12; consistent with 32 mm/65 Hz |
| Parasitic, air only | 185 W | v27 STATE 1B |
| Parasitic, with water | 240 W | v12 REMEDIATE 180–240 W |
| Fixed controller | 5 W | not scaled |
| Aux harvest | 19 W | audit v2, 4.2% of 450 W |
| Net efficiency | 36.8% | v12, v22, v27 |
| Fuel | CH4-eq, 800 kJ/mol | v12 basis |

Net efficiency is the biggest unverified number. See §4.

## 2. BREAK-EVEN

| Target | Concentration | Repo source |
|---|---|---|
| Air-only net zero | ~5,400 ppm | between v27 3,700 and this model |
| With water net zero | ~7,200 ppm | derived |
| +420 W export | 15,000 ppm (1.5%) | v12 |
| Thermal ceiling | 45,000 ppm (4.5%) | v12 |

Dropped: 140 ppm (Slayer v3, 42 W parasitic) and 600 ppm (CSV,
44.5 W parasitic). Both omit bearing, blower, cavitator and desiccant.

## 3. NET OUTPUT BY TIER

Water mode, W. Negative = mains draw.

| ppm | 0.5x | 1.0x | 2.5x | 10x |
|---|---|---|---|---|
| 25 urban | −118 | −231 | −571 | −2,267 |
| 500 | −108 | −211 | −519 | −2,062 |
| 3,700 | −59 | −112 | −274 | −1,079 |
| 15,000 | +115 | +235 | +594 | +2,390 |
| 45,000 | +575 | +1,156 | +2,896 | +11,600 |

Air only, W:

| ppm | 0.5x | 1.0x | 2.5x | 10x |
|---|---|---|---|---|
| 25 urban | −88 | −170 | −418 | −1,657 |
| 500 | −80 | −156 | −382 | −1,512 |
| 3,700 | −31 | −57 | −136 | −529 |
| 15,000 | +142 | +290 | +731 | +2,940 |
| 45,000 | +603 | +1,211 | +3,034 | +12,150 |

## 4. EFFICIENCY SENSITIVITY

Air-only break-even, 1.0x:

| Net efficiency | Break-even |
|---|---|
| 25.4% (Slayer file) | 7,830 ppm |
| 30% (defensible) | 6,630 ppm |
| 36.8% (v12, v27) | 5,407 ppm |

A 45% efficiency spread moves break-even 45%. This is the number to
measure at G1, ahead of the aux harvest.

## 5. SCALE-INVARIANCE

Break-even is flat across the twentyfold range; the fixed 5 W is the only
deviation and it only bites at 0.5x. Scaling buys throughput, not reach.
The 10x is justified by 1,800 L/min cleaned and 12 kW export at 45,000 ppm.

## 6. UPGRADE VERDICTS

**Slayer PLL GaN-ZVS** — IN as optional configuration. Audit v2: 250 ns
gives 0.90e17 radicals/J against 2.65e17 at 10 ns, i.e. 66% worse per
joule, O3 21.5 -> 61.6 ppm, quench bed 120 -> 372 cm3, +$38.88 media.
Audit recommends 10 ns, which the Slayer cannot produce.

**Flywheel** — OUT until it names a job the 1.0 kWh LiFePO4 pack and the
500 F bus do not cover. At v27's 15–20,000 h life a bearing is parity, not
a halving. Remaining objections: rim-release containment at ~315 m/s,
vacuum envelope and pump, gyroscopic load in vehicle and airship tiers,
overspeed on field loss.

## 7. FAULT REGISTER

| # | Fault | Status |
|---|---|---|
| F1 | No fuel identified | CLOSED — CH4-eq is the fuel |
| F2 | Four break-even figures | CLOSED — 5,400 / 7,200 / 15,000 |
| F3 | Core flow 30/118/180/251 | CLOSED — 180 |
| F4 | ECLSS not self-powered | OPEN — v31, v32 |
| F5 | Hydride mass 7x understated | OPEN |
| F6 | 25.4% vs 36.8% efficiency | OPEN — G1 |
| F7 | Aux 34 W unmodelled | CLOSED — 19 W derived |
| F8 | 2,380 W dissociation vs 20 W plasma | CLOSED — 0.1% split |
| F9 | Water quoted without RH | OPEN |
| F10 | SCR present in audit, absent in v27 | OPEN |
| F11 | v30.1 branches from v12.1 | OPEN — read late |
| F12 | LICENSE / NOTICE / CLA | NOTICE + CLA drafted, not pushed |

## 8. WHAT THIS MEANS

Engine off on clean air. 180–240 W mains or PV. Water and air only.
Engine on above ~5,400 ppm air-only or ~7,200 with water. Export above
15,000 ppm.

Advertise the REMEDIATE draw, not a plus figure. A plus figure invites the
"so it powers itself" reading that v12 spent a whole section killing.

## 9. REMAINING

v13–v16 (cold start, PCM, recuperator, resonance) are the highest-value
unread files — the 88% recuperator underpins every number here. Then
v17–v20, v11, v23–v26, v28–v33, v30.1 last.