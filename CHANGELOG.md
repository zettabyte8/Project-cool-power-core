<!-- CHANGELOG.md -->
# CHANGELOG

## [2.1] — numbers corrected

### Fixed
- **Condensing temperature 52 °C → 25 °C (Config 1) / 10 °C (Config 2).** 52 °C was above dewpoint; no condensation occurred. Full derivation in docs/05.
- **Water output: 540 g/h → 0–25 g/h net.** 0.54 L/h was the fuel rate, double-counted as product.
- **Oxygen: 1500 L/h "medical grade" → 2120 L/h at 20.7% enriched** (350 L/h at 90% with a membrane).
- **Plasma 20 W → 193 W.** 20 W cannot crack 8.33 mmol/s at any temperature.
- **Net 825 W → 320–540 W (C1) / 190–410 W (C2).** 65 W parasitic list omitted the bearing compressor, real arc, pumps and fan.
- **Deep sea 1000 bar → 50 m equalised.** 1000 bar × 30:1 = 30 kbar peak; diesel peak is 200 bar.
- **SCR had no reductant.** Added docs/04.

### Added
- docs/01 calculation sheet
- docs/04 DEF dosing
- docs/05 water recovery
- docs/06 uncertainty

### Removed
- "zero-input" (DEF is a consumable)
- "megawatt-scale" for ion thrusters
- "3000 °C chamber" → "3000 °C arc core"

-  ## [2.2] — Reduce Electric Waste

-  ### Added
-  Touch Screen Monitor for control and monitoring of the system
-  Lights and fans as needed to reduce Electric byproduct close to Zero so as not to disrupt the global energy economy

yyalnergy energyconomy 
