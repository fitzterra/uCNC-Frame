/**
 * X Bridges
 **/

//-----------------------------------
// Draw/print Control

// Set to true to draw for printing - motor and bearing will not be drawn
print = false;

// What to draw? One of:
// "bs" for bearing side bridge
// "ms" for motor side bridge
// "all" to draw both bridges
draw = "all";
//------------------------------------

// Version number for X Bridges
_version = "v0.10";

include <Configuration.scad>;
use <ToolsLib.scad>;
use <StepMotor_28BYJ-48.scad>;

/**
 * Module to extend the XBridge module for the bearing side X Bridge.
 *
 * Parameters are the same as for the XBridge module. Additional parameters
 * are define below.
 *
 * @param b_id: Bearing inner diameter
 * @param b_od: Bearing outer diameter
 * @param b_t: Bearing thickness
 **/
module XBridgeBearingSide(h, w, f, t, rd, rcd, md, dwd, b_id, b_od, b_t) {
    // The support rib in the XBridge is 2/5ths wider than the rod diameter
    // and 3 times the plate thickness
    rOd = rd+rd*2/5;


    // The base bridge and a cut out for the bearing box
    difference() {
        XBridge(h, w, f, t, rd, rcd, md, dwd);
        translate([w/2, h-(rd*7/5)/2-rcd/2, b_od/2+t*2])
            // Cut out bearing space
            cube([rOd+1, b_t+0.4, b_od], center=true);
    }
    
    // Placement of the bearing box
    translate([w/2, h-(rd*7/5)/2-rcd/2, b_od/2+t]) {
        // The bearing box.
        difference() {
            union() {
                // Outer box including 0.2 mm clearance above/below bearing
                cube([b_od, b_t+t*3+0.4, b_od/2+t*3], center=true);
                translate([0, 0, t*3])
                    rotate([-90, 0, 0])
                    cylinder(h=b_t+t*3+0.4, d=b_od, center=true);
            }
            // Cut out bearing space
            translate([0, 0, (b_od/2+t*3)/2])
                cube([b_od+1, b_t+0.4, b_od+t*3+1], center=true);
            // Open up the wire slit again. The bridge base defines the width
            // of the slit as dwdC which 1.2 * dwd, and the breadth as 1.4xrOd
            cube([rOd*1.4, dwd*1.2, b_od+t*3], center=true);

            // mounting holes
            translate([0, 0, t*3])
            rotate([-90, 0, 0])
                cylinder(d=b_id, h=b_t+t*3+1, center=true);
        }
        // The bearing sample if not printing
        if (print == false) {
            translate([0, 0, t*3])
            rotate([-90, 0, 0])
                color("Silver")
                    Bearing(b_id, b_od, b_t);
        }
    }
        
    // The version number
    translate([t+2, t+2, t])
        Version(h=0.5, s=3, v=_version);

}

/**
 * Module to extend the XBridge module for the motor side X Bridge.
 **/
module XBridgeMotorSide(h, w, f, t, rd, rcd, md, dwd) {
    // The support rib in the XBridge is 2/5ths wider than the rod diameter
    // and 3 times the plate thickness
    rOd = rd+rd*2/5;

    // The base bridge and a cut out for the bearing box
    difference() {
        XBridge(h, w, f, t, rd, rcd, md, dwd);
    }
    
    // Placement of the wmotor mount box
    translate([0, XB_h-(XB_rd*7/5)/2-XB_rcd/2-t-SHH/2, t]) {
        // The motor mount plate.
        difference() {
            // Mount plate
            cube([w, t, (MBD+MTW)/2+t*5]);
            // The body cutout
            translate([w/2, 0, MBD/2+t*4])
                rotate([-90, 0, 0])
                    cylinder(h=t*3, d=MBD+0.2, center=true);
            // The mount holes
            for (x=[w/2-MHCC/2, w/2+MHCC/2]) {
                translate([x, 0, MBD/2+t*4])
                    rotate([-90, 0, 0])
                        cylinder(h=t*3, d=4, center=true);
            }
        }
        // Support gussets
        for (x=[0, w-t]) {
            hull() {
                translate([x, 0, MBD/2+MTW/2+t*5-1])
                    cube([t, t, 1]);
                translate([x, -h/3, 0])
                    cube([t, h/3, 1]);
            }
        }
        // The motor sample if not printing
        if (print == false) {
            translate([XB_w/2, -MBH/2+MTH+t, MBD/2+t*4])
                rotate([0, 90, -90])
                    StepMotor28BYJ();
        }
    }
        
    // The version number
    translate([t+2, t+2, t])
        Version(h=0.5, s=3, v=_version);

}

// What to draw?
if (draw=="all" || draw=="bs") {
    translate([-XB_w-2, 0, 0])
    XBridgeBearingSide(XB_h, XB_w, XB_f, XB_t, XB_rd, XB_rcd, XB_md, XB_dwd,
                       B_id, B_od, B_t);
}
if (draw=="all" || draw=="ms") {
    translate([2, 0, 0])
    XBridgeMotorSide(XB_h, XB_w, XB_f, XB_t, XB_rd, XB_rcd, XB_md, XB_dwd,
                     B_id, B_od, B_t);
}
