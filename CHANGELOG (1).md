<!-- CHANGELOG.md -->
# CHANGELOG

## [2.2] — reconciliation pass

### Fixed
- **Feed and O₂ export were mutually incompatible.** 0.54 L/h cannot support 140 g/h O₂ export. Split into OP-1 (no export) and OP-2 (0.91 L/h feed). docs/01 §6.
- **Quench 3.0 mm → 1.8 mm, 0.08 → 0.25 g/s.** 0.08 g/s through 3 mm is 6.5 m/s, no quench. docs/10.
- **Bearing air moved to dedicated compressor B1.** Turbo delivers 1.5 bar, film needs 6. docs/10 §4.
- **Reservoir 2 L → 5 L.** 2 L is 11–19 h. docs/05, docs/10, docs/11.
- Net restated: **105 W (OP-1), 310 W (OP-2), band −45 to 250 W.** Supersedes 320–540 W in rev 2.1.
- Config 2 net **−25 W at base case** — negative. Requires f ≥ 0.28. docs/06 §8.

### Added
- README.md
- docs/00-scope.md
- docs/40-maintenance.md
- docs/32-FT-19-build.md (prior)
- docs/31-receive-fixtures.md (prior)
- LICENSE recommendation
- Water treatment: softener, float valve, overflow, low-level trip
- FM-26 to FM-30

### Changed
- docs/01 fully rewritten around water-as-fuel
- docs/20 adds scald, acid, refrigerant

### Superseded values
| Value | Was | Now |
|---|---|---|
| Net | 825 → 320–540 | 105 / 310 |
| O₂ export | 140 g/h at 0.54 L/h | 0 at 0.54; 140 needs 0.91 |
| Reservoir | 2 L | 5 L |
| Quench gap | 3.0 mm | 1.8 mm |

## [2.1] — numbers corrected
Condenser 52→25 °C, water 540→0–25 g/h net, O₂ 1500→2120 L/h at 20.7%, plasma 20→193 W, net 825→320–540 W, deep sea 1000 bar→50 m, DEF added.

## [2.0] — purifier reframe