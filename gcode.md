(PROJECT: COOL POWER CORE - ISOLATION ROUTING)
(DESIGNER: THOMAS G COLEMAN)
(TOOL: 0.8MM DIAMOND-KNIT DOWN-CUT ROUTER BIT)
(WORK COORDINATES: G54 - PCB TOP SURFACE CENTER X0 Y0 Z0)

G90 G21 G17 G40 G80  (Absolute positioning, mm, XY plane selection, cancel cycles)
M03 S24000           (Spindle start clockwise at 24k RPM, allow 3s to reach speed)
G04 P3000            (Dwell for 3 seconds)

(APPROACH AND AIR CLEARANCE SECTOR)
G00 X-2.25 Y-15.0 Z5.0  (Rapid move to slot boundary start position, clear 5mm above work)
G01 Z0.20 F120          (Controlled plunge to air boundary layer)

(INCREMENTAL ROUTING STEP DOWN LOOP - 6 PASSES AT 0.25MM STEP DOWN)
G91                  (Switch to Incremental Mode for the nested pass sequence)

(PASS 1)
G01 Z-0.45 F120      (Plunge 0.25mm into material from +0.20mm starting clearance)
G01 X4.50 F480       (Cut width of slot)
G01 Y30.0            (Cut length of slot)
G01 X-4.50           (Return width profile)
G01 Y-30.0           (Return length profile closing boundary loop)

(PASS 2)
G01 Z-0.25 F120      (Step down to -0.50mm deep relative to stock surface)
G01 X4.50 F480
G01 Y30.0
G01 X-4.50
G01 Y-30.0

(PASS 3)
G01 Z-0.25 F120      (Step down to -0.75mm deep)
G01 X4.50 F480
G01 Y30.0
G01 X-4.50
G01 Y-30.0

(PASS 4)
G01 Z-0.25 F120      (Step down to -1.00mm deep)
G01 X4.50 F480
G01 Y30.0
G01 X-4.50
G01 Y-30.0

(PASS 5)
G01 Z-0.25 F120      (Step down to -1.25mm deep)
G01 X4.50 F480
G01 Y30.0
G01 X-4.50
G01 Y-30.0

(PASS 6 - COMPLETE BREAKTHROUGH OVER-CUT)
G01 Z-0.35 F120      (Step down to -1.60mm deep to ensure full puncture of 1.52mm base)
G01 X4.50 F480
G01 Y30.0
G01 X-4.50
G01 Y-30.0

(RETRACTION AND CLOSURE MATRIX)
G90                  (Revert to Absolute Positioning)
G01 Z5.0 F600        (Rapid retract out of cut zone to safe 5mm clearance height)
G00 X0 Y0            (Return machine tool home to origin axes)
M05                  (Spindle stop command)
M30                  (Program end and rewind)
