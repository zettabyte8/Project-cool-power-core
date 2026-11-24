# REV 6.0 — MASTER REDESIGN (PLACEHOLDER)

Status: PLACEHOLDER. Supersedes rev 1.4–5.x and reconciles v9–v33.
Two figures remain unmeasured: FT-19 (dissociation fraction) and the
aux-harvest derivation. Everything else here is derived and checkable.

Designer: Thomas G. Coleman

---

## 1. WHAT THIS MACHINE IS

A smoke-eating air purifier with water harvesting. Mains-powered in clean
air. Self-sustaining in smoke or solvent vapour. Industrial variant exports
power openly; consumer variants mask the surplus behind lights, fans and
sound and do not advertise it.

Priority order, fixed: clean air > water > quiet > life support > cost >
electricity. Electricity is last deliberately.

## 2. THE ONE NUMBER THAT GOVERNS EVERYTHING

Fuel is airborne hydrocarbon. At 25% net conversion, the parasitic load
divides by 0.25 to give the fuel required:

$$P_{fuel} = \frac{P_{parasitic} - P_{aux}}{0.25}$$

| Mode | Parasitic | Aux | Fuel needed | VOC at 251 L/min |
|---|---|---|---|---|
| Air only | 130 W | 16 W | 456 W | ~956 ppmv (~46 g/h) |
| Air + water | 255 W | 16 W | 956 W | ~2,004 ppmv (~97 g/h) |

Ambient urban air at 25 ppmv supplies ~12 W. Urban is roughly 40x short.
That is the truth of the machine and every claim below follows from it.

| Environment | VOC ppmv | Chemical in | Net electric (air only) |
|---|---|---|---|
| Clean ambient | 0.05 | 0.02 W | −129 W |
| Urban | 25 | 11.9 W | −111 W |
| Tunnel | 120 | 57 W | −100 W |
| Break-even | 956 | 456 W | 0 W |
| Solvent vent | 2,000 | 954 W | 0 W (with water) |
| Refinery plume | 5,000 | 2,385 W | +240 W |
| Thermal ceiling | 6,500 | 3,100 W | +330 W |

## 3. CORRECTIONS APPLIED

| Fault | Resolution |
|---|---|
| No primary fuel identified | VOC/CO/PM declared the fuel; break-even published as ppmv and g/h |
| 34 W aux harvest unmodelled | Cut to 16 W pending derivation: TEG on condenser 7 W, Tesla turbine 5 W, pyroelectric 2 W, PZT 2 W |
| Break-even 140 vs 600 ppmv in sibling files | Single figure adopted: 956 ppmv air-only, 2,004 with water |
| 2,379.7 W dissociation shown beside a 20 W plasma | Stated: 0.84% split, steam is working fluid, VOC is fuel |
| Geometry regressed to 25 mm / 50 Hz / 30:1 | Rebuilt on 32 mm / 65 Hz |
| HCCI impossible at 22.5:1 with steam | CR band raised to 15–26:1; steam capped at 40% mass |
| 42 W parasitic omitted desiccant regen | 95 W heat-pumped regen added to parasitic |
| N52H 120 °C called Curie | Corrected: 120 °C max operating, Curie ~340 °C; N52SH on the hot side |
| "28.4%" unsupported | Replaced with the break-even table above |
| Water quoted flat | Always quoted with RH: 10.8 L/day at 60% RH, 5.4 at 40%, 3.2 at 30% |
| "Slayer exciter" misdescribed | Driver is a PLL GaN half-bridge ZVS at 1.85–2.01 MHz |

## 4. CORE

- Two opposed pistons, 32 mm bore x 40 mm stroke, 64.4 cm³ total
- 65 Hz, 251 L/min core flow, 0.1457 mol/s at 90 °C / 1.05 bar
- CR 15:1 to 26:1 dynamic; 26:1 top is mandatory for HCCI on steam
- Steam capped at 40% mass fraction; above that, misfire rate climbs
- Bearing: aerostatic 5 µm film, dedicated scroll compressor, 65 W, 30 s accumulator
- Pistons Si3N4 with DLC, oil-free; Inconel 625 hot side
- Bounce chambers He/Ar, quarter-wave phase lock, 180° opposition

Fuel basis used throughout: toluene, 92 g/mol, 42 MJ/kg, 3.276 MJ/mol.
Blend from other aromatics shifts break-even by under 10%.

## 5. PLASMA AND CRACKING

Stage 4A — PLL GaN half-bridge ZVS, alumina bobbin 32 x 90 mm,
500 turns 34 AWG on L2 (2.41 mH), 3 turns 14 AWG Litz on L1 (0.42 µH,
k 0.18). Dry resonance 2.01 MHz, compressed 1.85 MHz, tracked by PLL on
measured secondary phase error. 1 kW peak, 400 µs burst at TDC, 2% duty,
20 W average, 33.6–42 kV. Alumina because dielectric loss at MHz is real.

Stage 4B — recuperative SiC / graphene-nickel monolith, 480–650 °C.
Exhaust-fed when burning; **resistance-trimmed at 25 W when it is not.**
This is the change that makes low-VOC operation honest: without fuel there
is no exhaust heat, so the cracker cannot be free.

Ozone quench is now primary duty, not polish. Continuous discharge at
2.85x radical yield raises O3 hard. alpha-MnO2 bed sized for full flow,
outlet alarm at 0.05 ppm. If the bed grows, the Slayer saving shrinks.

## 6. WATER

MOF-303 wheel, 720 L/min sorption loop, 43.2 m³/h, face velocity 0.17 m/s.
Regeneration by heat pump at COP 3, 95 W. Harvested, never fed.
Net production only, no external water source.
Output at 60% RH: 10.8 L/day. Quote the curve, never the point.

## 7. THEATRE

Runs on a surplus rail only, fed after core, never from it. Scales with
surplus rather than switching. Advertised floor is structurally protected.

1. Single keyed harness connector, no tools
2. Theatre airflow separate from cooling airflow
3. Controller tolerates theatre-absent: no alarm, no derate
4. Export terminals real, labelled "service", fused
5. Pulling the plug is harmless and obvious
6. Surplus must be continuous, not spiky

No firmware change needed to unlock. Pulling the plug is a supported state
and is a tested configuration in the gate plan.

## 8. TIERS

| Subsystem | Standalone | Household | Vehicle | Life support | Industrial |
|---|---|---|---|---|---|
| Ion grid | M | M | M | M | M |
| Core + cracker | M | M | M | M | M |
| Water loop | O | M | O | M | M |
| Theatre | M | M | M | O | O |
| CO2 scrub | — | — | — | M | — |
| O2 trim | — | — | — | M | — |
| Export | O | O | O | O | M |

M = mandatory, O = optional, — = absent.

## 9. GATES

- **G1** — dissociation fraction vs steam fraction, with misfire rate
  logged. Pass: f >= 0.28 at <=40% steam.
- **FT-19** — full-flow water and power balance at 25 °C / 60% RH
- **Aux derivation** — TEG, turbine, pyroelectric, PZT measured separately
  at the design point before the 16 W figure is quoted anywhere
- **Slayer three-way** — PLL GaN vs matched ZVS vs pulsed, radicals per
  joule, same electrode, same gas, same humidity
- **Ozone** — outlet O3 at full flow, both drivers
- **Theatre-absent** — 24 h run with the harness pulled, no fault

## 10. SAFETY

33.6–42 kV RF, 900 °C hot side, H2, O3, 6 bar bearing air, 90 °C water,
sulphuric condensate. DBD barrier is the current limit on the plasma path;
the bare corona grid needs a ballast. Ferrite or can around the driver —
an unshielded MHz source will upset the pyroelectric and TEG sensing.

## 11. BOM BAND

$1,400–1,700 at 100k. The $108 figure is not achievable with a MOF rotor,
Ti4O7 anode, PMN-PT, PZT-8 and skutterudite in the list.

## 12. OPEN

- Aux harvest derivation (gates the break-even table)
- v30.1 branches from v12.1, seventeen versions back — verify no
  reintroduced faults
- LICENSE and NOTICE still absent
- Repo hygiene: duplicate CHANGELOG, superseded DEF doc, thirty root
  screenshots
- v34/v35 not in repo

## 13. CHANGELOG

6.0 — Full redesign on v-series geometry. Fuel identified and quantified.
Break-even published. Aux harvest cut to a defensible 16 W. Cracker made
resistance-trimmed. Ozone quench promoted. Theatre rail specified.