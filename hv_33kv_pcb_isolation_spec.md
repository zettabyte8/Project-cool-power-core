# High-Voltage PCB & Dielectric Isolation Specification (33.6 kV Nanosecond ZVS Stage)

## 1. Electrical Architecture Overview
* **Primary Driver:** 4.2 V DC input, 20 W nominal, Zero-Voltage Switching (ZVS) push-pull oscillator driving a 1000:1 MnZn Ferrite U-Core transformer (~4.2 kV AC pulsed secondary at 45–65 kHz carrier, gated at 50 Hz piston TDC).
* **Voltage Multiplier:** 8-stage Cockcroft-Walton (CW) diode-capacitor ladder stepping 4.2 kV peak to **33.6 kV DC/pulsed corona potential**.
* **Pulse Shaping:** Nanosecond magnetic compression / spark-gap sharpening network delivering <50 ns rise-time streamer pulses into the intake plasma reactor while preventing thermal arc transition.

---

## 2. Creepage, Clearance & Dielectric Isolation Rules (IPC-2221B / IEC 60664-1)
Operating at **33.6 kV** inside a high-humidity HVAC environment (Pollution Degree 3) requires strict physical and material segregation:

| Isolation Zone | Voltage Differential | Minimum Air Clearance | Minimum Surface Creepage | Required Dielectric Barrier |
| :--- | :--- | :--- | :--- | :--- |
| **Low-Voltage ECU / 4.2 V Bus to Transformer Secondary** | 4.2 kV RMS | ≥ 12.0 mm | ≥ 25.0 mm (with milled slots) | Triple-insulated wire (TIW) + 3.0 mm FR-4/PTFE bobbin barrier |
| **CW Multiplier Stage-to-Stage Nodes** | 4.2 kV / stage | ≥ 8.5 mm | ≥ 16.0 mm | 2.0 mm routed isolation slots between adjacent capacitor pads |
| **33.6 kV Output Node to Grounded Chassis / HVAC Frame** | 33.6 kV Peak | ≥ 65.0 mm (unpotted) / ≥ 18.0 mm (potted) | ≥ 110.0 mm | Full encapsulation in two-part **high-dielectric silicone elastomer** (≥ 20 kV/mm) |

---

## 3. PCB Layout & Corona Suppression Guidelines
1. **Eliminate Sharp Copper Corners:** All traces carrying >1 kV must use smooth teardrop fillets and rounded turns (minimum bend radius ≥ 3.0 mm). Sharp 90° edges concentrate electric field gradients and trigger premature corona discharge on the PCB surface.
2. **No Internal Ground Planes Under HV Multiplier:** Strip all internal and bottom copper planes beneath the 1000x ferrite secondary and the entire 8-stage Cockcroft-Walton ladder. Maintain a minimum **40 mm keep-out zone** from any grounded pour.
3. **Anti-Tracking Milled Slots:** Route **2.5 mm wide air/potting slots** through the PCB substrate between consecutive Cockcroft-Walton multiplier stages and around the high-voltage output terminal to interrupt surface moisture films.
4. **High-Voltage Component Selection:**
   * **CW Capacitors:** Use N4700 or C0G high-voltage ceramic disc capacitors rated ≥ 10 kV DC per stage (do not use X7R/Y5V dielectrics due to severe capacitance loss under DC bias and piezoelectric microphonics).
   * **CW Diodes:** Use ultra-fast recovery high-voltage avalanche diodes ($t_{rr} < 35\text{ ns}$, $V_{RRM} \ge 12\text{ kV}$ per stage) to prevent reverse-recovery heating during nanosecond pulse discharge.
5. **Vacuum Degassing & Encapsulation:** After ultrasonic cleaning with isopropyl alcohol and baking at 85°C for 4 hours to remove absorbed moisture, pot the entire high-voltage multiplier assembly under vacuum (<5 mbar) using UL 94 V-0 thermally conductive silicone potting compound to eliminate air voids that cause internal partial discharge.

---

## 4. EMI / RFI Shielding & ECU Protection
* **Faraday Cage Enclosure:** House the ZVS driver, MnZn U-Core transformer, and potted CW multiplier inside a seamless, grounded **2.0 mm aluminum/mu-metal enclosure** connected to earth ground via a low-inductance braided copper strap.
* **Optical / Galvanic Gate Isolation:** Isolate the 50 Hz TDC trigger signal from the microcontroller to the ZVS MOSFET gates using **high-CMTI (>100 kV/µs) digital isolators** and isolated DC-DC gate drivers to prevent nanosecond plasma transients from resetting the ECU.
