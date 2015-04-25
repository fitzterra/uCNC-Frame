/**
 *
 * Bearing side X bridge.
 **/

//-----------------------------------
// Draw/print Control

// Set to true to draw for printing - motor and bearing will not be drawn
print = true;

// What to draw? One of:
// "bs" for bearing side bridge
// "ms" for motor side bridge
// "all" to draw both bridges
draw = "all";
//------------------------------------

use <ToolsLib.scad>;
use <StepMotor_28BYJ-48.scad>;

_version = "v0.8";

// Cylinder granularity
$fn=120;

// XBridge general sizes
XB_h=52;    // Height
XB_w=47;    // Width
XB_f=30;    // Length of foot piece
XB_t=2;     // Wall thickness
XB_rd=6;    // Diameter of rail rods
XB_rcd=20;  // Rails center distance - distance center-to-center
XB_md=4;    // Mount slits diameter in foot.
XB_dwd=1;   // Drive wire diameter

// XBridge bearing side bearing params
B_od = 11;
B_id = 5;
B_t = 5;

// Direct from the StepMotor28BYJ library
MBH = 18.8;   // motor body height
MBD = 28.25;  // motor body OD
MTH  = 0.8;   // mounting tab thickness
MTW  = 7.0;   // mounting tab width
MHCC = 35.0;  // mounting hole center-to-center
SHH = 9.75;   // height of shaft above motor body 

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

    // Bearing clearance to face plate. Make this big enough to allow a shaft
    // to fit for holding the bearing.
    b_c = 4;

    // The base bridge and a cut out for the bearing box
    difference() {
        XBridge(h, w, f, t, rd, rcd, md, dwd);
        translate([XB_w/2, XB_h-(XB_rd*7/5)/2-XB_rcd/2, b_od/2+XB_t+b_c])
            // Cut out bearing space
            cube([rOd+1, b_t+0.4, b_od+1], center=true);
    }
    
    // Placement of the bearing box
    translate([XB_w/2, XB_h-(XB_rd*7/5)/2-XB_rcd/2, b_od/2+XB_t+b_c]) {
        // The bearing box.
        difference() {
            // Outer box including 0.2 mm clearance above/below bearing
            cube([rOd, b_t+t*2+0.4, b_od], center=true);
            // Cut out bearing space
            cube([rOd+1, b_t+0.4, b_od+1], center=true);
            // mounting holes
            rotate([-90, 0, 0])
                cylinder(d=b_id, h=b_t+t*2+1, center=true);
        }
        // The bearing sample if not printing
        if (print == false) {
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
