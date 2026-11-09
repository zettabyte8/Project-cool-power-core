<!-- docs/00-scope.md -->
# 00 — Scope

## What this is

A sealed-space air purifier. Point-of-breathing or small cabin, 1–10 m³. It oxidises VOCs, CO, O₃ and soot at 900–3000 °C, reduces NOx on a catalyst, condenses water, and exports a modest electrical surplus.

## What this is not

- **Not a room purifier.** 10.6 m³/h is 1/30th of a HEPA unit. It compensates by destroying rather than trapping, and by being the only unit that also dehumidifies and generates. It does not compensate enough for a living room.
- **Not fuel-free.** Water is the fuel at 3.6–7.4 L/day.
- **Not free energy.** It is a heat engine burning water. 1.4 L/kWh at OP-1, 1.0 at OP-2 — against 0.3 L/kWh for diesel.
- **Not medical oxygen.** Exhaust is 20.7% O₂ enriched, not 99.5%. Medical grade needs a membrane and dryers not yet specified.
- **Not submersible to 1000 m.** Pressure equalisation works to ~50 m. Below that, a hull or variable CR.

## Operating envelope

| Parameter | Min | Max |
|---|---|---|
| Ambient | −5 °C | 45 °C |
| RH | 15% | 99% |
| Altitude | 0 | 2000 m (derate) |
| Duty | intermittent | continuous |

Below 40% RH the machine draws over 4 L/day. Below 15% it is water-negative by 300 g/h and needs a 10 L reservoir.

## Success criteria

| Gate | Criterion |
|---|---|
| G1 | f ≥ 0.15 by two methods within 20% |
| G3 | VOC DE ≥ 90% at M1 |
| G4 | Regenerator ≥ 0.75 |
| G6 | 1000 h, DE holds within 5% |

**Kill:** f < 0.12 at G1 converts the project to purifier-only. That is a decision, not a failure.

## Out of scope for rev 2

- Config 2 chiller (specified, not built — needs f ≥ 0.28)
- Oxygen membrane
- Deep sea beyond 50 m
- Space configuration
- Vehicle integration