# REV 6.1 MASTER — PLACEHOLDER

Supersedes rev 6.0. All figures modelled. FT-19 and G1 unrun.

## 1. DECISIONS MADE IN THIS REVISION

| # | Decision |
|---|---|
| D1 | Engine-bypass is the DEFAULT household mode: 19 W, 0.38 L/h |
| D2 | Engine runs only above ~2,000 ppm toluene or when export is wanted |
| D3 | Break-even published as 2,000 ppm toluene; 3,700 ppm CH4-eq is the pessimistic bound |
| D4 | Service life 15,000–20,000 h. 45,000 h retired |
| D5 | Mechanical flywheel dropped. The 1.4 kg SiC foam is the flywheel |
| D6 | Energy ledger declared NORMALISED, plasma = 100 units. Not per pulse |
| D7 | NTP 85 W continuous-capable, burst to 3 W at 2.5% duty in clean air |
| D8 | Aux harvest fixed at 19 W, sourced from the low recuperator TEG tier |
| D9 | Plasma wall jacket with a hard 95 °C dielectric limit |
| D10 | Advertised figure is the 19 W draw, never a net-export figure |

## 2. WHY D6 MATTERS

v14, v15 and v16 all failed to reconcile joules with watts because the
ledger is a ratio, not a per-cycle count. Rebuilt on v15's convention
(only recovered work plus pre-heat credit count as credit):

| | Deficit, normalised |
|---|---|
| v14 | 83.5 |
| v15 | 61.2 |
| v16 rebuilt | ~21 |

v16's published 45.8 double-counted rows 2, 3 and 4. The rebuild is not
a gain claim — it is the same physics, counted once.

## 3. MODES

| Mode | Engine | Draw | Water | Air |
|---|---|---|---|---|
| Sentry | off | 0.32 W | 0 | sample only |
| **Bypass (default)** | **off** | **19 W** | **0.38 L/h** | full |
| Engine, clean | 22 Hz | ~203 W | 0.45 L/h | full |
| Engine, 2,000 ppm | 28 Hz | 0 | 0.54 L/h | full |
| Export | 65 Hz | +338 W | 0.72 L/h | full |

## 4. NET OUTPUT, toluene, W

| ppm | 0.5x | 1.0x | 2.5x | 10x |
|---|---|---|---|---|
| 25 urban | −104 | −203 | −501 | −1,989 |
| 500 | −80 | −155 | −379 | −1,502 |
| 2,000 break-even | −3 | −1 | +6 | +37 |
| 5,300 | +166 | +338 | +852 | +3,423 |
| 12,200 ceiling | +520 | +1,046 | +2,622 | +10,502 |
| **Bypass, W** | **−14.5** | **−24** | **−52.5** | **−195** |
| **Bypass water, L/day** | **4.6** | **9.1** | **23** | **91** |

## 5. CORE

32 mm bore, 64 mm total stroke, 65 Hz, 180 L/min core, 51.5 cm³ swept.
CR 14.5–22:1. Steam capped 40% mass. He/Ar 70/30 bounce, 2.2–6.8 bar.
Si3N4 DLC pistons. Bearing film 5 µm, 65 W dedicated compressor.

Low CR is plasma-dependent and therefore clean-air-only. CR top stays 22
until G1 shows HCCI at 26 on 40% steam.

## 6. THERMAL

Plasma wall jacket to the 90 °C reservoir, dielectric held < 95 °C.
Dual-tier recuperator, 88% high tier, Bi2Te3 TEG on the 145→55 °C low
tier producing the 19 W. SiC foam 1.4 kg at Stage 4B as the inter-cycle
thermal flywheel. iEGR Helmholtz ram +0.12–0.18 bar. 15 mm krypton
aerogel, N52SH held ≤120 °C.

## 7. WATER

MOF-303 wheel, 720 L/min, regenerated 65–80 °C by reservoir heat.
Harvested only, never fed. Always quoted with RH: 9.1 L/day at 60%,
4.6 at 40%, 2.7 at 30%.

## 8. THEATRE

Surplus rail only, six rules as rev 6.0. Separate airflow. Single keyed
connector. No firmware. Export terminals labelled "service". Pulling the
plug is a tested configuration.

## 9. TIERS

Standalone: air, bypass, theatre. Household: + water, + engine.
Vehicle: + altitude. Life support: + CO2, O2, Sabatier. Industrial:
advertised export, no theatre.

## 10. FAULTS

| # | Fault | Status |
|---|---|---|
| F1 | No fuel identified | CLOSED |
| F2 | Four break-even figures | CLOSED — 2,000 toluene |
| F3 | Core flow 30/118/180/251 | CLOSED — 180 |
| F4 | ECLSS not self-powered | OPEN — v31, v32 |
| F5 | Hydride mass 7x understated | OPEN — needs ~9 kg per 120 g H2 |
| F6 | 25.4% vs 30% vs 36.8% efficiency | OPEN — G1, 30% adopted provisionally |
| F7 | Aux unmodelled | CLOSED — 19 W, TEG tier |
| F8 | Dissociation vs plasma budget | CLOSED — 0.1% split |
| F9 | Water without RH | CLOSED — curve published |
| F10 | SCR present/absent | OPEN |
| F11 | v30.1 branches from v12.1 | OPEN |
| F12 | Ledger dimensional error | CLOSED — normalised, D6 |
| F13 | TPV 15–25 W optimistic | OPEN — derate to 3–8 W |
| F14 | 45,000 h vs 15–20,000 h | CLOSED — 15–20,000 |

## 11. GATES

G1 dissociation vs steam with misfire log. FT-19 water and power at
60% RH. Aux measured at the TEG tier. Ozone at full flow both drivers.
Theatre-absent 24 h. Efficiency at G1 is the swing number: 25.4% moves
break-even to 2,700 ppm, 36.8% to 1,700.

## 12. REMAINING

v13 PCM, v17–v20 altitude, v31–v33 ECLSS, v21, v23–v26, v28–v29,
v30.1 last. LICENSE text still absent. CLA and NOTICE drafted, not pushed.