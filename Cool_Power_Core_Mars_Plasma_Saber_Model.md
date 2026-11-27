# Cool Power Core™ Handheld Magneto-Confined Plasma Lightsaber (`CPC-SABER-MARS`)
**Inventor:** Thomas Gabriel Coleman | **Location:** Corona, CA | **Document ID:** `CPC-SPEC-MARS-SABER-01`

---

## 1. Executive Physics & Martian Environmental Advantage
While Hollywood depictions of a "lightsaber" violate classical optics (photons do not stop at a fixed length in free space), a **magnetically confined, closed-loop plasma lance (`CPC-SABER-MARS`)** is physically achievable—and works **significantly better on Mars than on Earth**:

1. **610 Pa Low-Convection Advantage:** Earth's dense `101.3 kPa` atmosphere rapidly strips heat from an open plasma arc via convective cooling, requiring tens of kilowatts to sustain a 1-meter blade. Mars's tenuous **`610 Pa` (`0.006 atm`) \(	ext{CO}_2\) atmosphere** reduces convective heat loss by **>94%**, allowing a **`2.4 kW`** plasma core to sustain a **`0.92 m`**, **`4,200 K`** cutting blade.
2. **`-60°C` Martian Cold-Sink Carnot Boost:** The miniaturized **`uCPC-MARS`** generator inside the hilt rejects heat through external Ti-6Al-4V cryo-fins into the **`-60°C` (`213 K`)** Martian air, boosting thermoelectric/pyroelectric Carnot efficiency by **+38%** to generate **`+142.0 We` continuous self-recharging power** from a `180 mL` water cartridge and compressed Martian \(	ext{CO}_2\).
3. **Closed Toroidal Magnetic Bottle (`0.65 T`):** A `Sm₂Co₁₇` Halbach array paired with a pulsed `CuCrZr` Bitter coil projects an elongated magnetic cusp that forces dissociated \(	ext{CO} / 	ext{O}^+ / 	ext{H}^+\) plasma to execute a U-turn at **`0.92 m`** and return to the hilt collector ring—preventing plasma escape, eliminating lethal stray radiation, and recovering ionized gas.

---

## 2. Hilt Architecture & Mass Budget (`2.48 kg` Total)
| Part ID | Subsystem | Materials | Mass (kg) | Specification |
| :--- | :--- | :--- | :---: | :--- |
| `SABER-01` | Miniaturized `uCPC-MARS` Core | Ti-6Al-4V / 8YSZ / Graphene | 0.92 | `+142.0 We` continuous (`90°C` cav. + `33.6 kV` ZVS) |
| `SABER-02` | Micro-Scroll Mars \(	ext{CO}_2\) Intake | Anodized Al-Li / PTFE | 0.24 | Compresses `610 Pa` ambient \(	ext{CO}_2\) to `1.8 bar` |
| `SABER-03` | Replaceable Ice / Water Micro-Cartridge | PEEK / 316L Stainless | 0.28 | `180 mL` water feed (`6.5 hr` continuous recharge) |
| `SABER-04` | Graphene-CNT Hybrid Supercapacitor | Graphene Aerogel / Ionic Liq. | 0.42 | `140 Wh` energy buffer, `3.5 kW` peak discharge |
| `SABER-05` | `Sm₂Co₁₇` Halbach + Bitter Magnetic Nozzle | `Sm₂Co₁₇` / CuCrZr / BN | 0.34 | `0.65 T` closed-loop toroidal magnetic pinch |
| `SABER-06` | Hilt Shell, Cryo-Fins & EVA Deadman Grip | Ti-6Al-4V / Carbon-PEEK | 0.28 | `320 mm L × 44 mm Ø`, dust-sealed EVA switch |
| **TOTAL** | **Complete `CPC-SABER-MARS` Assembly** | **Flight-Qualified** | **2.48** | **`0.93 kg` effective weight in Mars `0.38 g`** |

---

## 3. Martian Duty-Cycle & Operational Modes
| Operational Mode | Plasma Arc (W) | `uCPC` Recharge (W) | Coil/Avionics (W) | Net Battery Delta (W) | Max Burst | Martian EVA Role |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **Holstered Recharge** | 0 | +142.0 | 0 | **+142.0** | Continuous | Full supercap recharge in `59 min` |
| **Ice & Regolith Probe** | 650 | +142.0 | 220 | **-728.0** | 11.5 min | Subsurface permafrost core boring |
| **EVA Structural Weld** | 1,450 | +142.0 | 380 | **-1,688.0** | 5.0 min | Habitat Ti-6Al-4V & regolith seam fusion |
| **Basalt / Metal Cut** | 2,400 | +142.0 | 520 | **-2,778.0** | 3.0 min | Slicing dense Martian basalt & wreckage |
| **Emergency Rescue** | 2,850 | +142.0 | 610 | **-3,318.0** | 2.5 min | Airlock breach / rover extraction |

---

## 4. Safety Interlocks & Governing Patent Coverage
* **Dual-Stage EVA Deadman Grip:** Capacitive + mechanical pressure interlock collapses the `0.65 T` field in **`<1.2 milliseconds`** if dropped, instantly quenching the `4,200 K` plasma into harmless low-density \(	ext{CO}_2/	ext{H}_2	ext{O}\) vapor.
* **Electrostatic Dust Shield (`33.6 kV`):** Repels abrasive Martian iron-oxide dust from the magnetic nozzle aperture.
* **Patent Alignment:** Covered under **Thomas Gabriel Coleman's** core thermodynamic/plasma architecture (`CPC-PAT-2026-001`) and planetary ISRU/EVA extensions (`CPC-PAT-2026-003-CIP`).
