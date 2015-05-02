/**
 * Library of various tools used for the machine parts.
 **/

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
 **/
module servo(w, d, lh, uh, tw, th, gh, bgd, sd, sh, mhd, wt=1.2, wo=4.2) {
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
                    cylinder(h=4, d=wt);
    }
}


module Version(h=1, s=4, v="_ver_", halign="left", valign="bottom") {
    linear_extrude(height=h, convexity=4)
                text(v, size=s, font="Bitstream Vera Sans",
                     halign=halign,
                     valign=valign);
}
