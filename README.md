<!-- README.md -->
# Project Cool Power Core

**Automated closed-loop atmospheric remediation engine.** Destroys airborne VOCs, CO, O₃ and PM by plasma-thermal oxidation, condenses water out of the airstream, and returns a net electrical surplus.

Designed by Thomas G. Coleman.

## Status

Design phase, pre-prototype. **All power figures are modelled, none measured.** The single number that decides whether this is a generator or a purifier is dissociation fraction `f`, and it is unmeasured — gate G1.

## Headline

| | OP-1 | OP-2 |
|---|---|---|
| Net electric | 105 W | 310 W |
| Water draw | 3.6 L/day | 7.4 L/day |
| VOC destruction | ≥90% | ≥85% |
| Air throughput | 5.4 m³/h | 10.6 m³/h |

Band across all sensitivities: **−45 to 250 W.** Below f = 0.12 the machine is a purifier only.

## It is not fuel-free

Water is the fuel. It is consumed at 3.6–7.4 L/day. DEF is a second consumable at 5.6 mL/h. The machine needs a water feed line, a drain, and a DEF jug.

## Layout

```
/docs     design, calculations, test plan, maintenance
/cad      (empty — pending)
/rust     (empty)
/firmware (empty)
/gcode    machining
/rfq      vendor packs
```

## Read in this order

1. `docs/00-scope.md` — what it is and is not
2. `docs/01-calc-sheet.md` — every number and its derivation
3. `docs/06-uncertainty.md` — what kills it
4. `docs/10-architecture.md` — flow order, normative
5. `docs/30-test-plan.md` — gates
6. `docs/50-failure-modes.md` — how it fails

## Safety

33.6 kV DC, 900 °C surfaces, hydrogen, ozone, 6 bar air, 90 °C water, sulphuric condensate. Read `docs/20-safety.md` before energising anything.

## Licence

CERN-OHL-S v2. Patent rights reserved by the designer.