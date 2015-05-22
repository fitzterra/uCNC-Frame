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
 * General X bridge.
 *
 * @param h: Height
 * @param w: Width
 * @param f: Length of foot piece
 * @param t: Wall thickness
 * @param rd: Diameter of rail rods
 * @param rcd: Rails center distance - distance center-to-center
 * @param md: Mount slits diameter in foot.
 * @param dwd: Drive wire diameter. The slit for the drive wire will be this
 *        wide with a small clearence top and bottom.
 **/
module XBridge(h, w, f, t, rd, rcd, md, dwd) {
    // We draw the bridge laying flat on it's face because it's better to print
    // this way.

    // The face has a 45° corner top and left and right. The length of this 45°
    // angle is ¼ the width. Using Pythagoras theorem, calculate the lenght of
    // the inner triagle sides formed by the corner angle.
    cornerSide = sqrt((pow(w/4, 2)*2))/2;

    // The rod holes outer diameter is 2/5ths larger than the inner diameter
    rOd = rd+rd*2/5;

    // Clearance amount for drive wire thickness - i.o.w how much wider is the
    // total width including clearance
    dwdC = 1.2;

    // The face
    difference() {
        union() {
            // Face plate
            cube([w, h, t]);
            // Support rib in the middle 3x the plate thickness
            translate([w/2-rOd/2, 0, t])
                cube([rOd, h-rOd/2, t*3]);
            // Round at the top
            translate([w/2, h-rOd/2, t])
                cylinder(d=rOd, h=t*3);
            // Additional gusset support
            hull() {
                translate([w/2-rOd/2, h-rcd-rOd-1, t])
                   cube([rOd, 1, t*3]);
                translate([w/2-rOd/2, 0, t])
                    cube([rOd, 1, t*5]);
            }
        }

        // 45° corners at ¼ the width - left
        translate([-cornerSide, h, -1])
            rotate([0, 0, -45])
                cube([w/4, w/4, t+2]);
        // 45° corners at ¼ the width - right
        translate([w-cornerSide, h, -1])
            rotate([0, 0, -45])
                cube([w/4, w/4, t+2]);
        // Rod holes
        for(y=[h-rOd/2, h-rOd/2-rcd]) {
            translate([w/2, y, -1])
                cylinder(h=t*4+2, d=rd);
        }

        // The drive wire slit ½ way between the hole centers
        translate([w/2-rOd*1.4/2, h-rOd/2-rcd/2-(dwd*dwdC)/2, -1])
            cube([rOd*1.4, dwd*dwdC, t*4+2]);
    }

    // A thin support rib on each side
    for(i=[
            [0, 0, t],      // Left rib position
            [w-t, 0, t]     // Right rib position
          ]) {
        translate(i)
            cube([t, h-cornerSide, t]);
    }
    // A gusset on each side
    for(x=[0, w-t]) {
        hull() {
            translate([x, h*2/3, t])
                cube([t, 1, t]);
            translate([x, 0, t])
                cube([t, 1, f/2]);
        }
    }

    // The foot
    difference() {
        // The full foot
        cube([w, t, f]);

        // The mounting slits
        for(i=[
                [w/4-md/2, -1, f/2],  // Left slot
                [(w/4)*3-md/2, -1, f/2],  // Right slot
              ]) {
            translate(i){
                cube([md, t+2, f]);
                // Rounding at the end
                translate([md/2, 0, 0])
                    rotate([-90, 0, 0])
                        cylinder(d=md, h=t+2);
            }
        }
    }

}

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
