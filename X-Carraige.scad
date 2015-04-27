/**
 * X Carraige
 **/

// Version number for X Carraige
_version = "v0.1";

include <Configuration.scad>;
include <ToolsLib.scad>;

/**
 * Module to draw one rotated S shape spring.
 *
 * @param w: Spring width
 * @param h: Spring height
 * @param d: Spring depth (Z axis)
 * @param st: Spring thickness
 **/
module Spring(w, h, d, st) {
    // Circle diameter
    cd = w/2+st/2;

    // Circles center
    c = h/2;

    // Two half circles
    for(xy=[[cd/2,-cd/2], [w-cd/2,0]]) {
        translate([xy[0], c, 0])
            difference() {
                cylinder(h=d, d=cd);
                translate([0, 0, -0.1])
                    cylinder(h=d+0.2, d=cd-st*2);
                translate([-cd/2, xy[1], -0.1])
                    cube([cd, cd/2, d+0.2]);
            }
    }
    // Legs
    cube([st, h/2, d]);
    translate([w-st, h/2, 0])
        cube([st, h/2, d]);
}

/**
 * Draws the spring box.
 *
 * @param w: Outer width of the box
 * @param h: Outer height of the box
 * @param d: Depth of the box
 * @param wt: Wall thickness of the box (only has upper and lower walls)
 * @param st: Thickness of each spring
 * @param ss: Spacing between springs
 * @param ns: Number of springs
 **/
module SpringBox(w, h, d, wt, st, ss, ns=4) {

    // Calculate the width of one spring. Note springs form the left and right
    // edges since there are no walls on the sides.
    sw = (w - (ns-1)*ss) / ns;

    // Top and bottom walls
    cube([w, wt, d]);
    translate([0, h-wt, 0])
        cube([w, wt, d]);

    // The springs
    for (s=[0:ns-1]) {
        // We do rotation, etc if printing the 2nd half of the spring
        swop = s >= ns/2;
        // Calculate offset for each spring
        o = s*(sw+ss);
        // Rotation
        rot = [0, swop ? 180 : 0, 0];
        // Translation
        trans = [o+(swop ? sw : 0), 0, swop ? d : 0];
        translate(trans) {
            rotate(rot)
                Spring(sw, h, d, st);
        }
    }

}

/**
 * X Carriage
 *
 * @param h: Height
 * @param w: Width
 * @param f: Length of foot piece
 * @param t: Wall thickness
 * @param rd: Diameter of rail rods
 * @param rcd: Rails center distance - distance center-to-center
 * @param bw: Bushing width
 *
 **/
module XCarraige(w, h, t, rd, rcd, bw) {
    // We use the wall thickness as base for the rail bushings outer diameter,
    // which is also then the height for the side walls.
    b_od = rd + t*2;

    // Preset the diameter for the drive wire holes
    dwh = XB_dwd+1;

    // Precalculate the spring box params because we use it in multiple places.
    // Since the spring box may not have enough height in the original size, we
    // allow it to slightly extend into the lower bushings. This value sets by
    // how much it may be extended.
    sb_ext = 1.2;
    // The final spring box height
    sb_h = rcd/2-dwh/2-b_od/2+sb_ext;
    // The depth
    sb_d = b_od+t;
    // The wall thickness
    sb_wt = 0.8;
    // The spring thickness
    sb_st = 0.8;
    // The spacing between springs
    sb_ss = 0.5;
    // Number of springs
    sb_ns = 4;

    difference() {
        union() {
            // First the face
            cube([w, h, t]);

            // Draw the side walls. Side walls does not go all the way to the top, but
            // stops at the top of the topbussing outer wall.
            for(x=[0, w-t]) {
                // The side wall
                translate([x, 0, t])
                    cube([t, rcd+b_od, b_od]);
                // The lip on the upper part, and rounded gusset for smartness
                translate([x, rcd+b_od, t]) {
                    cube([t, h-rcd-b_od, t]);
                    difference() {
                        cube([t, (b_od-t)/2, (b_od-t)/2+t]);
                        translate([t+1, (b_od-t)/2, (b_od-t)/2+t])
                            rotate([0, -90, 0])
                               cylinder(h=t+2, d=b_od-t);
                    }
                }
            }

            // Bushings. Define the bushing translate positions
            btp = [
                    [0, 0],     // Bottom left, x and y
                    [w-bw, 0],  // Bottom right, x and y
                    [0, rcd],  // Top left, x and y
                    [w-bw, rcd],  // Bottom left, x and y
                ];
            for(bp=btp) {
                translate([bp[0], bp[1], 0])
                    cube([bw, b_od, b_od/2]);
                translate([bp[0], bp[1]+b_od/2, 0+b_od/2])
                    rotate([0, 90, 0])
                        cylinder(h=bw, d=b_od);
            }
        }

        // Stuff we want to remove goes here.
        // Rail holes
        for (y=[rd/2+t, rd/2+t+rcd]) {
            translate([-1, y, rd/2+t])
                rotate([0, 90, 0])
                    cylinder(h=w*1.3, d=rd);
        }
        // Drive wire holes ...
        for (z=[t+dwh/2, b_od-dwh/2]) {
            translate([-1, (b_od+rcd)/2, z])
                rotate([0, 90, 0])
                    cylinder(h=w*1.3, d=dwh);
        }
        // ... and through the face plate
        for (x=[t+1, w-t-dwh-1]) {
            translate([x, (b_od+rcd)/2-dwh/2, -1])
                cube([XB_dwd*1.3, dwh, t+2]);
        }

        // The spring box cutout.
        translate([-1, b_od-sb_ext+0.1, -1])
            cube([w+2, sb_h-0.2, sb_d+2]);

        // The two holes at the top like the original
        for (x=[w/4, w-w/4]) {
            translate([x, h-w/4, -0.1])
                cylinder(h=t+0.2, d=rd);
        }
    }

    // The spring box
    translate([0, b_od-sb_ext, 0])
        SpringBox(w, sb_h, sb_d, sb_wt, sb_st, sb_ss, sb_ns);


    // The version number
    //translate([t+2, t+2, t+4])
    translate([w/2, h-5, t])
        rotate([0, 0, -90])
            Version(h=0.5, s=3, v=_version, valign="center");

}


XCarraige(XC_w, XC_h, XC_t, XC_rd, XC_rcd, XC_bw);

*SpringBox(20, 5.4, 20, 0.8, 0.5, 0.5, 4);
