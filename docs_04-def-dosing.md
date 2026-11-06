<!-- docs/04-def-dosing.md -->
# 04 — DEF Dosing Loop

Without reductant the SCR does nothing. This machine generates 100–300 ppm NOx and is a net NOx source; the dosing loop is a functional requirement, not emissions garnish.

## 1. Chemistry (A)

DEF = 32.5 wt% urea in deionised water, density 1.09 g/mL.

$$(\text{NH}_2)_2\text{CO} \rightarrow 2\text{NH}_3 + \text{CO}_2$$

60.06 g urea → 34.06 g NH₃ = **0.567 g NH₃/g urea** → **0.184 g NH₃/g DEF**

Standard + fast SCR, 1 mol NH₃ per mol NOx. Target ANR 1.05.

## 2. Dose rate (A)

At 150 ppm NOx and 116.9 mmol/s exhaust: 1.754×10⁻⁵ mol/s NOx

$$\dot m_{NH_3} = 1.05 \times 1.754\times10^{-5} \times 17.03 = 3.14\times10^{-4}\ \text{g/s} = 1.13\ \text{g/h}$$
$$\dot V_{DEF} = \frac{1.13}{0.184 \times 1.09} = \mathbf{5.6\ mL/h}$$

| NOx | DEF rate | 2 L tank |
|---|---|---|
| 50 ppm | 1.9 mL/h | 1070 h |
| 150 ppm | 5.6 mL/h | 364 h |
| 300 ppm | 11.2 mL/h | 182 h |

## 3. Metering

5.6 mL/h = 1.56 µL/s. Standard urea injectors are 100× oversized, so **meter by duty cycle, not by pump speed.**

- Pump: diaphragm, 0.1 mL/min fixed, PWM at 93% nominal
- Turndown by pulse width; minimum credible pulse 2 ms
- Injection point: 150 mm upstream of the SCR face, 15° into flow
- Atomising air: 0.02 g/s tapped from the compressor discharge

**ANR must hold 0.95–1.15.** Below 0.8 NOx slips; above 1.2 NH₃ slips and 5 ppm is smellable in a room.

## 4. Control

**Open-loop primary, sensor trim secondary.** A NOx sensor is $150 and 800 ms slow — too slow to be the primary on a 50 Hz machine.

| Input | Use |
|---|---|
| Arc power | Primary NOx proxy |
| Load / cycle rate | Primary NOx proxy |
| Boost pressure | Flow compensation |
| Outlet NOx sensor | Trim only, 0.2 Hz, ±15% authority |

$$\text{duty} = k \cdot P_{arc} \cdot f_{cycle} \cdot \frac{1}{\dot m_{exh}} \cdot \frac{T_{SCR}}{350} \cdot (1 + \text{trim})$$

Map `k` at commissioning against measured NOx at three loads. Store in EEPROM.

## 5. Thermal management

Urea crystallises above 60 °C at the injector tip and deposits above 200 °C.

- Injector body shielded from the turbine radiant path
- Coolant jacket from the reservoir return
- **Purge on every shutdown:** 3 s air purge after DEF off
- **Thaw on cold start:** 60 W tank heater, 45 s, blocked below 5 °C
- Freeze point −11 °C. Tank is HDPE, allows 10% expansion

## 6. Interlocks

| Condition | Action |
|---|---|
| SCR < 200 °C | DEF inhibited (no conversion, deposits) |
| SCR > 450 °C | DEF inhibited (NH₃ oxidises) |
| Tank level < 5% | Derate to 50%, then 25%, then stop |
| Purge air loss | Latch FAULT |
| NH₃ slip > 5 ppm, 60 s | Reduce ANR 10%, re-trim |

## 7. SCR sizing (B)

Space velocity 40,000/h at 10.1 m³/h → **253 mL catalyst.** Plus 20% ammonia slip catalyst (Cu-zeolite) = **300 mL total block**, 400 cpsi, 50 cm² face, 60 mm length.

Do not undersize. At 300 ppm with a marginal block, conversion falls to 60% and the machine is a net NOx source by 2×.

## 8. Failure modes

| Mode | Symptom | Remedy |
|---|---|---|
| Crystal clog | Rising NOx, low flow | Hot water flush, purge check |
| Overdose | NH₃ smell | Trim down, check sensor |
| Underdose | NOx breakthrough | Check pump, map |
| Catalyst poisoned | Falling DE at normal temp | Replace block |
| Thaw failure | No dose cold | Heater check |

## 9. Consumables note

DEF is a **consumable at 5.6 mL/h.** 2 L lasts 15 days at full duty. The appliance is not fuel-free; it is fuel-free *and* needs a DEF jug. Say so on the box.