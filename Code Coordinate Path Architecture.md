(PROJECT: COOL POWER CORE - MICRO-CHANNEL HEAT EXCHANGER)
(DESIGNER: THOMAS G COLEMAN)
(TOOL: 0.5MM 2-FLUTE COATED MICRO END MILL)
(WORK COORDINATES: G54 - COPPER BLOCK TOP FACE FRONT-LEFT CORNER X0 Y0 Z0)

G90 G21 G17 G40 G80  (Absolute, mm, XY plane selection, cancel cycles)
M03 S35000           (Start spindle at 35,000 RPM)
G04 P3000            (Dwell 3 seconds for spindle stabilization)
M07                  (Activate high-pressure mist coolant)

(APPROACH TO HOME RETRACT PLANE)
G00 X0.25 Y0 Z5.0    (Center tool on Channel 1 profile, clear 5mm above stock)

(-------------------------------------------------------)
(CHANNEL 1 ROUTING - LINEAR PATH BETWEEN Y0 AND Y11.5)
(-------------------------------------------------------)
G00 X0.25 Y0 Z0.20   (Move to initial approach clearance)
M98 P1000 L20        (Call Subprogram 1000 to execute 20 passes to Z-2.0)
G00 Z5.0             (Retract tool to safe clearance height)

(-------------------------------------------------------)
(CHANNEL 2 ROUTING - STEP-OVER X +1.0MM)
(-------------------------------------------------------)
G00 X1.25 Y0
G00 Z0.20
M98 P1000 L20
G00 Z5.0

(-------------------------------------------------------)
(CHANNEL 3 ROUTING - STEP-OVER X +1.0MM)
(-------------------------------------------------------)
G00 X2.25 Y0
G00 Z0.20
M98 P1000 L20
G00 Z5.0

(-------------------------------------------------------)
(CHANNEL 4 ROUTING - STEP-OVER X +1.0MM)
(-------------------------------------------------------)
G00 X3.25 Y0
G00 Z0.20
M98 P1000 L20
G00 Z5.0

(-------------------------------------------------------)
(CHANNEL 5 ROUTING - STEP-OVER X +1.0MM)
(-------------------------------------------------------)
G00 X4.25 Y0
G00 Z0.20
M98 P1000 L20
G00 Z5.0

(-------------------------------------------------------)
(CHANNEL 6 ROUTING - STEP-OVER X +1.0MM)
(-------------------------------------------------------)
G00 X5.25 Y0
G00 Z0.20
M98 P1000 L20
G00 Z5.0

(-------------------------------------------------------)
(CHANNEL 7 ROUTING - STEP-OVER X +1.0MM)
(-------------------------------------------------------)
G00 X6.25 Y0
G00 Z0.20
M98 P1000 L20
G00 Z5.0

(-------------------------------------------------------)
(CHANNEL 8 ROUTING - STEP-OVER X +1.0MM)
(-------------------------------------------------------)
G00 X7.25 Y0
G00 Z0.20
M98 P1000 L20
G00 Z5.0

(-------------------------------------------------------)
(CHANNEL 9 ROUTING - STEP-OVER X +1.0MM)
(-------------------------------------------------------)
G00 X8.25 Y0
G00 Z0.20
M98 P1000 L20
G00 Z5.0

(-------------------------------------------------------)
(CHANNEL 10 ROUTING - STEP-OVER X +1.0MM)
(-------------------------------------------------------)
G00 X9.25 Y0
G00 Z0.20
M98 P1000 L20
G00 Z5.0

(SYSTEM TEARDOWN AND SHUTDOWN MATRIX)
G90
G00 Z10.0            (Retract tool to safe clearance height)
M09                  (Coolant off)
M05                  (Spindle stop)
G00 X0 Y0            (Return to machine origin)
M30                  (End of program)

(-------------------------------------------------------)
(SUBPROGRAM O1000 - INCREMENTAL DESTRUCTIVE DOWN-CUT)
(-------------------------------------------------------)
O1000
G91                  (Switch to incremental mode for localized step-down)
G01 Z-0.10 F45       (Feed down exactly 0.10mm into copper stock)
G90                  (Revert to absolute mode for precise channel tracks)
G01 Y11.5 F210       (Cut straight forward to channel terminus)
G00 Z0.20            (Air clearance rapid lifting)
G00 Y0               (Rapid travel back to channel start point)
M99                  (Return from subprogram to primary loop stack)
