/**
 * Coupling to fit on the 28BYJ-48 Stepper motor shaft.
 **/

$fn=100;

couplingOD = 10;    // The outer diameter required for the coupling
couplingH = 8;     // The coupling height
topHoleD = 0;       // If a hole in the coupling top is needed, set the
                    // diameter here. NOTE: This works best if this diameter is
                    // less than the shaft flat bit width or else bridging is
                    // needed when printing - just try it and see what works
                    // best.

// --- Motor shaft measurements -------
shaftD = 4.95;  // Shaft diameter
shaftH = 8.4;   // Shaft height
shaftFlatH = 6.1; // Height of flat bit from top
shaftFlatW = 2.95; // Width of flat area

// The shaft bit
module Shaft() {

    // Some clearance to allow a good fit
    c = 0.6;

    // First the flat bit for the top
    intersection() {
        cylinder(h=shaftH, d=shaftD+c);
        translate([-(shaftFlatW+c)/2, -(shaftD+c)/2, 0])
            cube([shaftFlatW+c, shaftD+c, shaftH]);
    }
    cylinder(d=shaftD+c, h=shaftH-shaftFlatH);
}

module Coupling() {

    // The full coupling, minus the shaft
    difference() {
        cylinder(d=couplingOD, h=couplingH);
        // Hole in the top?
        if (topHoleD>0) {
            translate([0, 0, shaftH-0.06])
            cylinder(h=couplingH, d=topHoleD);
        }
        // Drop it 0.05mm so it cuts through the coupling bottom
        translate([0, 0, -0.05])
            Shaft();
    }
}

// Turn it upside down for better printing.
translate([0, 0, couplingH])
    rotate([180, 0, 0])
        Coupling();
