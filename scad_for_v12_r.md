// ============================================================================
// COOL POWER CORE V12 (1.0x BASE SCALE) - PARAMETRIC 3D CAD ASSEMBLY
// Designer: Thomas G. Coleman | Reconciled Physics & Thermal-Barrier Edition
// Units: Millimeters (mm)
// ============================================================================

$fn = 72; // Smooth cylindrical resolution

// --- 1. MASTER DIMENSIONAL PARAMETERS ---
chassis_L = 340;
chassis_W = 210;
chassis_H = 240;

bore_D = 32.0;               // Silicon Nitride cylinder bore
liner_OD = 46.0;             // Si3N4 ceramic liner outer diameter
cylinder_L = 130.0;          // Central combustion & bounce cylinder length
piston_L = 28.0;             // Opposed free-piston length
piston_offset = 14.0;        // Mid-stroke piston spacing from center

aerogel_thick = 15.0;        // Krypton aerogel thermal barrier (600C -> <120C)
stator_ID = liner_OD + (aerogel_thick * 2); // 76.0 mm
stator_OD = 104.0;           // N52SH Halbach linear alternator stator OD
stator_L = 36.0;             // Each alternator sleeve length
cooling_jacket_OD = 114.0;   // Liquid/air cooling sleeve keeping magnets <=120C

// --- 2. VISIBILITY TOGGLES (Set to false for cutaway inspection) ---
show_outer_enclosure = true;
cutaway_view = true;         // Slices top half open to inspect internal stages

// --- 3. COLOR PALETTE ---
c_ceramic   = [0.22, 0.24, 0.28, 1.0]; // Silicon Nitride (Si3N4)
c_aerogel   = [0.85, 0.92, 0.98, 0.85];// Krypton-Silica Aerogel barrier
c_magnet    = [0.75, 0.78, 0.82, 1.0]; // N52SH Halbach Alternator
c_cooling   = [0.15, 0.55, 0.85, 0.9]; // Stator Liquid Cooling Jacket
c_copper    = [0.82, 0.45, 0.22, 1.0]; // Heat Exchanger / Condenser
c_plasma    = [0.55, 0.25, 0.85, 0.85];// NTP Dielectric Chamber
c_chassis   = [0.35, 0.38, 0.42, 0.22];// Translucent Housing

// ============================================================================
// MAIN ASSEMBLY
// ============================================================================
difference() {
    union() {
        core_axis_assembly();
        upper_intake_and_plasma_train();
        lower_condenser_and_mof_loop();
        if (show_outer_enclosure) outer_enclosure();
    }
    
    // Cutaway section box for internal engineering inspection
    if (cutaway_view) {
        translate([-200, 0, -200])
            cube([400, 200, 400]);
    }
}

// ============================================================================
// MODULE 1: FREE-OPPOSED PISTON CORE + THERMAL BARRIER + N52SH ALTERNATORS
// ============================================================================
module core_axis_assembly() {
    translate([0, 0, 15]) rotate([0, 90, 0]) {
        
        // A. Silicon Nitride (Si3N4) Cylinder Liner (600°C Zone)
        color(c_ceramic)
        difference() {
            cylinder(h = cylinder_L, d = liner_OD, center = true);
            cylinder(h = cylinder_L + 2, d = bore_D, center = true);
            // Central exhaust & intake port windows
            rotate([90, 0, 0]) cylinder(h = liner_OD + 4, d = 10, center = true);
        }

        // B. Dual Opposed Free Pistons (DLC-Coated Si3N4)
        for (dir = [-1, 1]) {
            translate([0, 0, dir * (piston_offset + piston_L/2)])
            color([0.12, 0.12, 0.14])
            difference() {
                cylinder(h = piston_L, d = bore_D - 0.1, center = true);
                // 15-degree toroidal crown bowl
                translate([0, 0, -dir * (piston_L/2 - 2)])
                    cylinder(h = 4.2, d1 = bore_D * 0.7, d2 = bore_D * 0.3, center = true);
            }
            
            // Pneumatic Bounce-Chamber End Caps + PZT-8 Piezo Rings
            translate([0, 0, dir * (cylinder_L/2 + 8)])
            color(c_copper)
            cylinder(h = 16, d = liner_OD + 6, center = true);
        }

        // C. 15mm Krypton-Silica Aerogel Thermal Isolation Sleeve
        color(c_aerogel)
        difference() {
            cylinder(h = cylinder_L - 8, d = stator_ID, center = true);
            cylinder(h = cylinder_L, d = liner_OD, center = true);
        }

        // D. Dual N52SH Halbach Linear Alternator Stators & Liquid Cooling Jackets
        for (dir = [-1, 1]) {
            translate([0, 0, dir * (piston_offset + piston_L/2)]) {
                // N52SH Magnet & Copper Coil Stator (Maintained <= 120°C)
                color(c_magnet)
                difference() {
                    cylinder(h = stator_L, d = stator_OD, center = true);
                    cylinder(h = stator_L + 2, d = stator_ID, center = true);
                }
                
                // Active Liquid/Air Stator Cooling Jacket
                color(c_cooling)
                difference() {
                    cylinder(h = stator_L + 4, d = cooling_jacket_OD, center = true);
                    cylinder(h = stator_L + 6, d = stator_OD, center = true);
                }
            }
        }
    }
}

// ============================================================================
// MODULE 2: INTAKE VENTURI, 90°C RESERVOIR, CAVITATION, NTP & STAGE 4B CRACKER
// ============================================================================
module upper_intake_and_plasma_train() {
    // Intake Ion Grid + Venturi Mixer (Left Upper)
    translate([-115, 0, 82]) rotate([0, 90, 0]) {
        color([0.3, 0.3, 0.35])
        cylinder(h = 28, d = 44, center = true); // Ion Capture Grid Housing
        
        // 21-deg Converging / 7-deg Diverging Venturi
        translate([0, 0, 26]) color(c_copper)
        cylinder(h = 24, d1 = 36, d2 = 12, center = true);
        translate([0, 0, 48]) color(c_copper)
        cylinder(h = 20, d1 = 12, d2 = 28, center = true);
    }

    // 90°C Heated Water Reservoir (Top Rear)
    translate([-45, -48, 82])
    color(c_cooling)
    cube([68, 42, 46], center = true);

    // Non-Thermal Plasma (NTP) Swirl Chamber (Top Center)
    translate([10, 0, 82]) rotate([0, 90, 0])
    color(c_plasma)
    difference() {
        cylinder(h = 90, d = 34, center = true);
        cylinder(h = 92, d = 26, center = true);
    }

    // Stage 4B Thermal-Catalytic Cracker Monolith (Top Right, 480-650°C)
    translate([95, 0, 82]) rotate([0, 90, 0])
    color(c_ceramic)
    difference() {
        cylinder(h = 65, d = 42, center = true);
        cylinder(h = 67, d = 30, center = true);
    }
}

// ============================================================================
// MODULE 3: SECONDARY MOF-303 SORPTION WHEEL & FLUOROGRAPHENE CONDENSER
// ============================================================================
module lower_condenser_and_mof_loop() {
    // MOF-303 / Graphene Rotary Sorption Wheel (720 L/min Secondary Loop)
    translate([-85, 0, -68]) rotate([0, 90, 0])
    color([0.2, 0.65, 0.45])
    difference() {
        cylinder(h = 34, d = 96, center = true);
        cylinder(h = 36, d = 18, center = true);
    }

    // Fluorographene Condenser & Potable Water Sump (14-deg Drain Pitch)
    translate([35, 0, -72]) rotate([0, 14, 0])
    color(c_copper)
    cube([140, 110, 52], center = true);

    // Ti4O7 Electrochemical Water Polishing Cell & UV-C Chamber
    translate([130, 0, -78])
    color(c_cooling)
    cylinder(h = 56, d = 36, center = true);
}

// ============================================================================
// MODULE 4: OUTER ENCLOSURE (340 x 210 x 240 mm)
// ============================================================================
module outer_enclosure() {
    color(c_chassis)
    difference() {
        cube([chassis_L, chassis_W, chassis_H], center = true);
        cube([chassis_L - 8, chassis_W - 8, chassis_H - 8], center = true);
    }
}
