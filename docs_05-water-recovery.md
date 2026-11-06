<!-- docs/05-water-recovery.md -->
# 05 — Water Recovery

**Supersedes rev 2.0, which specified 52 °C condensing. At 52 °C nothing condenses.**

## 1. Why 52 °C fails (A)

Exhaust humidity ratio: 540 g/h water in 3.11 g/s air = **0.048 kg/kg**
Saturation at 52 °C: $\frac{0.622 \times 13.6}{101-13.6} = 0.097$ kg/kg

0.048 < 0.097. Unsaturated. **Zero condensate.**

Actual dewpoint of a 0.048 kg/kg stream is **39.5 °C.**

## 2. Recovery vs condenser temperature (A)

| Cond. temp | Water left in gas | Recovery | Makeup needed |
|---|---|---|---|
| 39.5 °C | 540 g/h | 0% | 540 g/h |
| 35 °C | 411 g/h | 24% | 411 g/h |
| 30 °C | 307 g/h | 43% | 307 g/h |
| 25 °C | 225 g/h | 58% | 225 g/h |
| 20 °C | 165 g/h | 69% | 165 g/h |
| 15 °C | 120 g/h | 78% | 120 g/h |
| 9.5 °C | 83 g/h | 85% | 83 g/h |

## 3. Two configurations

**Config 1 — ambient condenser, 25 °C.** No chiller. 58% recovery, 225 g/h makeup. Air at 60% RH supplies 78 g/h. **Net −147 g/h = 3.5 L/day consumed.** Cheap and simple. Water tank is a consumable.

**Config 2 — chilled condenser, 10 °C.** 130 W chiller. 85% recovery, 83 g/h makeup, 78 g/h from air. **Net −5 g/h, effectively neutral above 62% RH.** Costs 130 W net output.

## 4. Recommendation

**Ship Config 1. Offer Config 2 as a variant.** Config 1 at 320–540 W and 3.5 L/day is a better product than Config 2 at 190–410 W and humidity-dependent. A break room has a water line.

## 5. Air-side supply (A)

$$\dot m_{air\ water} = \dot V_{air} \times 12\ \text{g/m}^3 \times \frac{RH}{100} = 127 \times \frac{RH}{100}\ \text{g/h}$$

| RH | Supply |
|---|---|
| 40% | 51 g/h |
| 60% | 76 g/h |
| 80% | 102 g/h |
| 95% | 121 g/h |

## 6. Honest product claim

"Produces drinking water" is **false** for Config 1 — it consumes 3.5 L/day. Correct claim:

> **"Dehumidifies 0.5 L/day and needs a 3.5 L/day water top-up."**

For Config 2 at >62% RH: "water-neutral."