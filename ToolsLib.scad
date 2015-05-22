/**
 * Library of various tools used for the machine parts.
 **/

include <Configuration.scad>;
use <publicDomainGearV1.1.scad>;
use <StepMotor_28BYJ-48.scad>;
use <MotorCoupling.scad>;

/**
 * A general bearing module
 **/
module Bearing(id, od, h) {
    difference() {
        // OD
        cylinder(h=h, d=od, center=true);

        // ID
        cylinder(h=h+1, d=id, center=true);
        
        // Top / bottom recess
        for(z=[h/2, -h/2]) {
            translate([0,0, z])
                difference() {
                    cylinder(h=h*0.1, d=od-od*0.2, center=true);
                    cylinder(h=h*0.1+1, d=id+id*0.2, center=true);

                }
        }
    }
}

/**
 * Draws a corner block with a 45° top right side (a right triangle)
 *
 * @param xy The x and y length for the triangle
 * @param h  The height
 */
module Corner45(xy, h) {
    // We draw x and y 1mm thick cubes and use hulling to traw the 45° side.
    hull() {
        cube([1, xy, h]);
        cube([xy, 1, h]);
    }
}

/**
 * Module to draw a servo.
 *
 * The servo is parametric, but draws a 9g Servo shape specifically.
 *
 * @param w   Body width
 * @param lh  Lower body height - up to bottom of mounting tabs
 * @param d   Body depth
 * @param tw  Width of one tab
 * @param th  Height of tab
 * @param uh  Upper body height - from top of mounting tabs to body top
 * @param gh  Height og top round gear extrusion
 * @param bgd Top back smaller gear extrusion diameter
 * @param sd  Shaft diameter
 * @param sh  Shaft height
 * @param mhd Mounting hole diameter
 * @param wt Wire thickness
 * @param wo Wire offset from bottom
 **/
module Servo(w=SRV_w, d=SRV_d, lh=SRV_lh, uh=SRV_uh, tw=SRV_tw, th=SRV_th,
             gh=SRV_gh, bgd=SRV_bgd, sd=SRV_sd, sh=SRV_sh, mhd=SRV_mhd,
             wt=1.2, wo=4.2) {
    color("blue", 0.5) {
        // Lower body
        cube([w, d, lh]);
        // Mounting tab layer on top of lower body
        translate([-tw, 0, lh])
            difference() {
                cube([w+2*tw, d, th]);
                // Left mounting hole and opening
                translate([tw/2, d/2, -1])
                    cylinder(h=th+2, d=mhd);
                translate([0, d/2-mhd/4, -1])
                    cube([tw/2, mhd/2, th+2]);
                // Right mounting hole and opening
                translate([w+tw*2-tw/2, d/2, -1])
                    cylinder(h=th+2, d=mhd);
                translate([w+tw*2-tw/2, d/2-mhd/4, -1])
                    cube([tw/2, mhd/2, th+2]);
            }
        // Upper body on top of that
        translate([0, 0, lh+th])
            cube([w, d, uh]);
        // Gearbox extrusion top left
        translate([d/2, d/2, lh+th+uh])
            cylinder(h=gh, d=d);
        // The smaller gear extrusion behind the big one
        translate([d, d/2, lh+th+uh])
            cylinder(h=gh, d=bgd);
    }
    // The shaft
    color("white") {
        translate([d/2, d/2, lh+th+uh+gh]) 
            difference() {
                cylinder(h=sh, d=sd);
                cylinder(h=sh+1, d=sd/4);
            }
    }
    // The wires
    for (y=[[d/2-wt,"orange"], [d/2,"red"], [d/2+wt,"brown"]]) {
        translate([0, y[0], wo])
            rotate([0, -90, 0])
                color(y[1])
                    cylinder(h=tw, d=wt);
    }
}

/**
 * A Single sided servo horn.
 *
 * @param sOD Shaft side outer diameter
 * @param eOD Edge side outer diameter
 * @param l Total length
 * @param t Thickness
 * @param sh Shaft side full height
 * @param sd Shaft diameter
 * @param si Shaft inset into the horn - how deep does the shaft fit into the horn
 * @param sr Screw recess - the amount of recess for the screw in the horn top
 * @param srd Screw recess diameter
 * @param shd Screw hole diameter
 * @param lh Number of link holes
 * @param lhd Link hole diameter
 **/
module ServoHorn(sOD=SH_sOD, eOD=SH_eOD, l=SH_l, t=SH_t, sh=SH_sh, sd=SH_sd,
                 si=SH_si, sr=SH_sr, srd=SH_srd, shd=SH_shd, lh=SH_lh,
                 lhd=SH_lhd) {
    difference() {
        union() {
            // The shaft side outer cylinder
            cylinder(h=sh, d=sOD);
            // The horn part
            translate([0, 0, sh-t])
                hull() {
                    cylinder(h=t, d=sOD);
                    translate([l-(sOD+eOD)/2, 0, 0])
                        cylinder(h=t, d=eOD);
                }
        }
        translate([0, 0, -1]) {
            // Screw hole
            cylinder(d=shd, h=sh+2);
            // Shaft insert
            cylinder(h=si+1, d=sd);
        }
        // Top screw recess
        translate([0, 0, sh-sr])
            cylinder(d=srd, h=sr+1);

        // Distance between first and last link hole center
        linkHolesDist = l - sOD - lhd/2 - eOD/2;
        // Distance between link hole centers
        lhcd = linkHolesDist/(lh-1);
        // Link holes
        translate([sOD/2+lhd/2, 0, 0])
            for(c=[0:lh-1]) {
                translate([c*lhcd, 0, 0])
                    cylinder(h=sh+1, d=lhd);
            }
    }
}

/**
 * Servo with horn using default config
 *
 * @param ha horn angle
 **/
module ServoAndHorn(ha=-90) {
    Servo();
    // The servo horn
    translate([SRV_d/2, SRV_d/2, SRV_fh-SH_si])
        rotate([0, 0, ha])
            color("white")
                ServoHorn();
}

/**
 * Servo and pinion using default config values.
 *
 * @param a Pinion angle
 **/
module ServoAndPinion(a=0) {
    Servo();
    // The servo horn
    translate([SRV_d/2, SRV_d/2, SRV_fh+RP_pT])
        rotate([180, 0, a])
            color("white")
                Pinion();
}

/**
 * The pinion gear for driving the rack on the Z carraige
 *
 * @param mmpt Millimeters per tooth - must match that used for rack
 * @param nt Number of teeth
 * @param t Thickness
 * @param pa Pressure angle - lowering this helps for small hears and racks.
 *        Must be the same as for the rack.
 * @param hd Screw hole diameter
 * @param cOD Shaft collar outer diameter
 * @param cID Shaft collar inner diameter - fits over servo shaft
 * @param ch Shaft collar height
 **/
module Pinion(mmpt=RP_mmpt, nt=RP_pt, t=RP_pT, pa=RP_pa, hd=RP_phd, cOD=RP_pcOD, cID=RP_pcID, ch=RP_pch) {
    // Make the gear level on the XY plane
    translate([0, 0, t/2]) {
        // The gear
        gear(mmpt, nt, t, hd, pressure_angle=pa);
        // The shaft collar
        translate([0, 0, t/2])
            difference() {
                // Outer cylinder
                cylinder(d=cOD, h=ch);
                // cut out the inner hole
                translate([0, 0, -1])
                    cylinder(d=cID, h=ch+2);
            }
    }
}

/**
 * Rack gear using the rack and pinion config params (RP_*) as defaults.
 *
 * The position for the default rack puts 0,0,0 in the center of the first tooth
 * on the pitch radius. This makes it difficult to position the rack since
 * special function ins the gear lib needs to be used to determine the exact movement
 * amounts.
 *
 * This module does that and places the bottom left corner of the rack on 0,0,0.
 *
 * @param mmpt Millimeters per tooth - must match that used for pinion
 * @param nt Number of teeth
 * @param t Thickness
 * @param pa Pressure angle - lowering this helps for small gears and racks.
 *        Must be the same as for the rack.
 * @param h Rack height
 **/
module Rack(mmpt=RP_mmpt, nt=RP_rt, t=RP_rT, h=RP_rH, pa=RP_pa) {
    // The rack is not drawn at 0,0,0 so we position it there by moving
    // it to the left ¾ of the circular_pitch, up by the height minus the
    // module_value (or addendum circle)
    translate([circular_pitch(mmpt)*3/4, h-module_value(mmpt), t/2])
        rack(mmpt, nt, t, h, pa);
}

module Version(h=1, s=4, v="_ver_", halign="left", valign="bottom") {
    linear_extrude(height=h, convexity=4)
                text(v, size=s, font="Bitstream Vera Sans",
                     halign=halign,
                     valign=valign);
}

module StepMotor28BYJAndCoupling() {
    StepMotor28BYJ();
    // These are the coupling standard params
    // TODO: Find a better way to auto import these
    couplingH = 8;     // The coupling height
    shaftH = 8.4;   // Shaft height
    // From StepMotor_28BYJ-48.scad
    SBH = 1.45;   // shaft boss height above motor body
    SBO = 7.875;  // offset of shaft/boss center from motor center

    translate([SBO, 0, -MBH/2-shaftH-SBH+couplingH])
        rotate([180, 0, 0])
            Coupling();
}

// Demos

// Servo
translate([]) {
    Servo();
    // Servo horn
    translate([0, -10, 0])
        ServoHorn();
    // Servo and horn
    translate([0, 30, 0])
        ServoAndHorn();
    // Servo and pinion
    translate([0, 60, 0])
        ServoAndPinion();
}

// The rack and pinion
translate([-40, 0, 0]) {
    // The default rack is thicker than the pinion, and the servo shaft collar
    // interferes with the rack unless the pinion is moved over in the rack.
    // Also, the pinion is drawn with the collar on top which looks odd when
    // viewed the first time, so we flip the hole thing around.
    rotate([180, 0, 0]) {
        // Move the pinion up by it's pitch radius and half a rack width in z
        // direction
        translate([0, pitch_radius(RP_mmpt, RP_pt), RP_rT/2])
            Pinion();
        // Move the rack down by it's pitch radius (only one tooth used for this
        // calculation on a rack) 
        translate([-circular_pitch(RP_mmpt)*5/4, module_value(RP_mmpt)-RP_rH-pitch_radius(RP_mmpt,1), 0])
            Rack();
    }
}

// Corners
translate([60, 0, 0]) {
    Corner45(10, 10);
    translate([0, 15, 0])
        rotate([0, 90, 0])
            Corner45(6, 20);
}

// Bearing
translate([40, 40, 0])
    color("silver")
        Bearing(8, 18, 10);

// Stepper
translate([-50, 50, 0])
    rotate([180, 0, 90])
        StepMotor28BYJAndCoupling();
