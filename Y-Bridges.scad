/**
 * Y Bridges
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
_version = "v0.2";

include <Configuration.scad>;
use <ToolsLib.scad>;
use <StepMotor_28BYJ-48.scad>;

// The width of the bridge feet is 2/5ths wider than the rod diameter that fits
// into it.
function yBridgeFootWidth(rd=YB_rd) = rd+rd*2/5;
// The Y Bridge width depends on the rod centers distance and the rod diameters
// which are used to calculate the bridge foot width
function yBridgeWidth(rcd=YB_rcd, rd=YB_rd) = rcd + yBridgeFootWidth(rd);

/**
 * General Y Bridge base.
 *
 * @param h Height
 * @param l Length (front tot back)
 * @param t Thickness
 * @param rcd Rods center-to-center distance apart
 * @param rd Rod diameter
 * @param dwd: Drive wire diameter. The drive wire guide holes and slits will
 *        be this wide with a small clearance either side.
 * @param dwhd The distance between the drive wire holes
 **/
module YBridge(h=YB_h, l=YB_l, t=YB_t, rcd=YB_rcd, rd=YB_rd, dwd=YB_dwd, dwhd=10) {
    // We draw it upside down, which is also the way it will be printed

    // The block that the rods fit though is 2/5ths larger than the rod diameter
    rbw = yBridgeFootWidth(rd);
    // From this we can calculate the bridge width using the rod centers as base
    w = yBridgeWidth(rcd, rd);
    // The depth for the hole the rod fits into
    rhd = 8;

    // Clearance amount for drive wire thickness - i.o.w how much wider is the
    // total width including clearance
    dwdC = 1.8;
    
    difference() {
        union() {
            // The bridge top
            cube([w, l, t]);
            // The two side walls
            for (x=[0, w-rbw])
                translate([x, 0, 0]) {
                    // We leave one wall thickness off the height for the feet
                    // circles.
                    cube([rbw, l, h-t]);
                    // Add the lips to the front like in the original uCNC
                    // plotter design.
                    cube([rbw, t*2, h]);
                }
            // Add the circular feet
            for (x=[rbw/2, w-rbw/2])
                for (y=[rhd+rbw/2, l-rbw/2])
                    translate([x, y, h-t])
                        cylinder(d=rbw, h=t);
            // Add the front wall - 1/3rd of height below top surface
            cube([w, t, h/3+t]);
            // The center lower bit for the wire guide slots. We use the motor
            // shaft coupling diameter variable (YB_mscd) direct from the config
            // imported here since it is not passed in as parameter - not sure
            // how to handle this in a better way yet.
            // This value is used to determine the width of the lower center bit.
            mscd = YB_mscd+4;
            hull() {
                translate([w/2-mscd, 0, h/3+t-1])
                    cube([mscd*2, t, 1]);
                translate([w/2-mscd/2, 0, t])
                    cube([mscd, t, h*2/3]);
            }
            // Add the gussets at the back
            translate([rbw, l, 0])
                rotate([90, 0, 0])
                    Corner45(h-t, t);
            translate([w-rbw, l, 0])
                rotate([0, -90, 90])
                    Corner45(h-t, t);
        }
        
        // Rod holes
        for (x=[rbw/2, w-rbw/2])
            translate([x, -1, rbw/2])
                rotate([-90, 0, 0])
                    cylinder(d=rd, h=rhd+1);
        // Mounting holes
        for (x=[rbw/2, w-rbw/2])
            for (y=[rhd+rbw/2, l-rbw/2])
                translate([x, y, -1])
                    cylinder(d=rd, h=h+2);
        // Unneeded foot bits
        translate([-1, rhd+rbw, t+1])
            cube([w+2, l-rhd-2*rbw, h]);

        // Drive wire holes and slits
        for(x=[w/2-dwhd/2, w/2+dwhd/2])
            translate([x, -1, h/2]) {
                rotate([-90, 0, 0])
                    cylinder(d=dwd*dwdC, h=t+2);
                translate([-(dwd*dwdC/2), 0, 0])
                    cube([dwd*dwdC, t+2, h]);
            }
    }
    // The version number
    translate([rbw+2, t+2, t])
        rotate([0, 0, 90])
            Version(h=0.5, s=3, v=_version, valign="top", halign="left");
}

/**
 * Y Bridge for motor side based on Y Bridge base.
 * This bridge is made for a 28BYJ-48 motor.
 *
 * @param h Height
 * @param l Length (front tot back)
 * @param t Thickness
 * @param rcd Rods center-to-center distance apart
 * @param rd Rod diameter
 * @param dwd: Drive wire diameter. The drive wire guide holes and slits will
 *        be this wide with a small clearance either side.
 **/
module YBridgeMotorSide(h=YB_h, l=YB_l, t=YB_t, rcd=YB_rcd, rd=YB_rd, dwd=YB_dwd) {
    
    // We need to know the bridge width
    w = yBridgeWidth(rcd, rd);
    // The motor offset from the front edge
    mo = 10;

    difference() {
        // The base bridge
        YBridge(h, l, t, rcd, rd);
        // The motor body cutout
        translate([w/2, mo+MBD/2, -1]) {
            cylinder(d=MBD+0.4, h=t+2);
            // The wiring box cutout
            translate([-WBW/2+0.2, 0, 0])
                cube([WBW+0.4, WBD+0.2, t+2]);
        }
        // The mounting holes
        for (x=[w/2-MHCC/2, w/2+MHCC/2])
            translate([x, mo+MBD/2, -1]) {
                cylinder(d=4, h=t+2);
            }
    }

    // Add the motor if we are not printing
    if(print==false) {
        translate([w/2, mo+MBD/2, -MBH/2+MTH+t])
            rotate([180, 0, -90])
                StepMotor28BYJAndCoupling();
    }
}

/**
 * Y Bridge for motor side based on Y Bridge base.
 *
 * @param h Height
 * @param l Length (front tot back)
 * @param t Thickness
 * @param rcd Rods center-to-center distance apart
 * @param rd Rod diameter
 * @param dwd: Drive wire diameter. The drive wire guide holes and slits will
 *        be this wide with a small clearance either side.
 * @param b_id: Bearing inner diameter
 * @param b_od: Bearing outer diameter
 * @param b_t: Bearing thickness
 
 **/
module YBridgeBearingSide(h=YB_h, l=YB_l, t=YB_t, rcd=YB_rcd, rd=YB_rd, dwd=YB_dwd,
                          b_id=B_id, b_od=B_od, b_t=B_t) {
    
    // The feet widths
    rbw = yBridgeFootWidth(rd);
    // We need to know the bridge width
    w = yBridgeWidth(rcd, rd);

    // We try to get the bearing as close to the front wall as possible. This
    // value is the gap between the bearing and the front wall
    bg = 1;
    // Now we can calculate the bearing center offset from the front
    bco = t+bg+b_od/2;
    // We want the bearing verticle center to be in the in the bridge verticle
    // center. Calculate the thickness for filling we need to place the bearing
    // in the center
    bft = (h-t*2)/2 - b_t/2;

    // Diameter for hole in the back to save print time and material and to
    // look funky? The diameter is determined by the width and length to fit
    // the best
    vhd = min(w-rbw*2-2, l-t-bg-b_od-4);

    difference() {
        union() {
            // The base bridge
            YBridge(h, l, t, rcd, rd, dwhd=b_od);
            // The bearing filling to center it vertcally - we remove 1mm off
            // the fill to add it as a smaller washer area in the bearing
            // center later
            translate([w/2, bco, t])
                cylinder(d=b_od+bg+t, h=bft-1);
            // Square the fill off to the front edge
            translate([w/2-(bco+bg+t)/2, 0, t])
                cube([bco+bg+t, bco+bg+t, bft-1]);
            // Add the 1mm shim so we do not need a washer
            translate([w/2, bco, t])
                cylinder(d=b_id+(b_od-b_id)/2, h=bft);
            // And add a center piece to fit bearing over, slightly less than
            // the ID
            translate([w/2, bco, t+bft])
                cylinder(d=b_id-0.4, h=b_t-1);
        }
        
        // Hole for screw to secure bearing
        translate([w/2, bco, -1])
            cylinder(d=2.5, h=h+2);

        // The "vent" hole in the back
        translate([w/2, l-(l-t-bg-b_od-2)/2, -1])
            cylinder(d=vhd, h=t+2);
    }

    // Add the bearing if we are not printing
    if (print==false) {
        translate([w/2, bco, t+bft+b_t/2])
            color("silver", 0.3)
            Bearing(b_id, b_od, b_t);
    }
}

// Make a print tray if we need to print
if (print==true) {
    if (draw=="all" || draw=="ms")
        YBridgeMotorSide();
    if (draw=="all" || draw=="bs")
        translate([0, YB_l+5, 0])
            YBridgeBearingSide();
} else if (print==false) {
    w = yBridgeWidth(YB_rcd, YB_rd);
    // We show the Y Axis if possible
    if (draw=="all" || draw=="ms")
        translate([0, -100, YB_h])
            rotate([0, 180, 180])
                YBridgeMotorSide();
    if (draw=="all" || draw=="bs")
        translate([w, 100, YB_h])
            rotate([0, 180, 0])
                YBridgeBearingSide();
    if (draw=="all")
        for (x=[(w-YB_rcd)/2, (w+YB_rcd)/2])
            translate([x, -105, YB_h-yBridgeFootWidth(YB_rd)/2])
                rotate([-90, 0, 0])
                    color("silver", 0.7)
                        cylinder(d=YB_rd, h=210);
}

