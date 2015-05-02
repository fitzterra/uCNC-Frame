/**
 * X Carraige
 **/
//-----------------------------------
// Draw/print Control

// Set to true to draw for printing
print = true;

// What to draw? One of:
// "bs" for bearing side bridge
// "ms" for motor side bridge
// "all" to draw both bridges
draw = "all";
//------------------------------------

// Version number for Pen Tool
_version = "v0.1";

include <Configuration.scad>;
include <ToolsLib.scad>;

/**
 * Module to create a V type edge extension.
 *
 * The edge is always drawn in the Y-axis.
 *
 * @param wb The bottom (inner) width
 **/
module VEdge(wb, wt, l, d, es="r") {
    // With the edge side on the right, there is no rotation or translation
    // With the edge on the left side, we rotate round the z axis, but then
    // have to translate to bring it back into position.
    rot = (es=="r") ? [0, 0, 0] : [0, 0, 180];
    tr = (es=="r") ? [0, 0, 0] : [wb, l, 0];
    translate(tr)
        rotate(rot)
            hull() {
                cube([wb, l, 0.01]);
                translate([0, 0, d-0.01])
                    cube([wt, l, 0.01]);
            }
}

/**
 * Pen Tool Holder
 *
 * @param w The tool width
 * @param h The tool height
 * @param t The thickness
 * @param psw The base width for the V type pen holder slides
 **/
module PenTool(w, h, t, psw) {
    // Calculate where the servo will be placed along the tool height. We place
    // the servo bottom 10mm above the point to which the X-Carraige will reach.
    // Remember that the bottom of the pen tool lines up with the bottom of the
    // X-Carraige.
    srvY = XC_h + 10;
    // Calculate where the servo base will sit below the pentool face bottom.
    // This position is calculated based on the position the servo horn top
    // should be above the face top.
    srvZ = SRV_hornPos + t - SRV_fh;

    // The x and y length to cut in at the bottom corners for the 45° corners
    cut45len = w/4;

    difference() {
        // Parts we add
        union() {
            // Face
            cube([w, h, t]);
            // The bottom foot piece
            translate([cut45len, 0, t])
                cube([w-2*cut45len, t, t*3]);
            // The left support ridge on the 45° corner edge - well cut the
            // corner bit later
            Corner45(cut45len+1.5, t*2);
            // The left side support ridge up to the servo start
            translate([0, cut45len, t])
                cube([t, srvY-cut45len, t]);

            // The servo box
            bh = SRV_lh + srvZ;  // Box height from faceplate bottom
            // Side support wall
            translate([0, srvY, 0])
                cube([t, SRV_w, bh]);
            // Bottom under tab support
            translate([-SRV_d, srvY-SRV_tw, 0])
                cube([SRV_d+t, SRV_tw, bh]);
            // Top under tab support
            translate([-SRV_d, srvY+SRV_w, 0])
                cube([SRV_d+t, SRV_tw, bh]);
            // The support gussets
            hull() {
                translate([0, srvY-SRV_tw, bh-t])
                    cube([t, t, t]);
                translate([0, srvY-SRV_tw-t*2, t])
                    cube([t, t*2, t]);
            }
            hull() {
                translate([-SRV_d, srvY-SRV_tw, 0])
                    cube([t, t, t]);
                translate([0, srvY-SRV_tw-t*2, 0])
                    cube([t, t*2, t]);
            }
            hull() {
                translate([-SRV_d, srvY+SRV_w+SRV_tw-t, 0])
                    cube([SRV_d, t, t]);
                translate([0, h-t, 0])
                    cube([t, t, t]);
            }

            // The pen holders slide
            translate([(w-psw)/2-t, XC_h/2, t])
                VEdge(t, t*1.2, XC_h/2, t, "r");
            translate([(w+psw)/2, XC_h/2, t]) 
                VEdge(t, t*1.2, XC_h/2, t, "l");
            translate([(w-psw)/2-t, XC_h/2-t, t]) 
                cube([psw+t*2, t, t]);
        }

        // Parts we subtract
        // The two 45° corners
        translate([-1, -1, -1])
            Corner45(cut45len+1, t*2+2);
        translate([w+1, -1, -1])
            rotate([0, 0, 90])
                Corner45(cut45len+1, t*2+2);

        // Some holes
        translate([w/2, h/8, -1])
            cylinder(h=t+2, d=w-t*5);
        hb = h-XC_h;
        Ylen = h-hb;
        hd = w/3;
        translate([w/2, hb+t+hd/2, -1])
            cylinder(h=t+2, d=hd);
        translate([w/2, hb+Ylen/2, -1])
            cylinder(h=t+2, d=hd);
        translate([w/2, h-t-hd/2, -1])
            cylinder(h=t+2, d=hd);
            
    }
    
    // The version number
    translate([w-1, h-5, t])
        rotate([0, 0, -90])
            Version(h=0.5, s=3, v=_version, valign="top");

    // The Servo
    if (print==false)
        translate([0, srvY, srvZ])
            rotate([0, 0, 90])
            servo(SRV_w, SRV_d, SRV_lh, SRV_uh, SRV_tw, SRV_th, SRV_gh, SRV_bgd,
                  SRV_sd, SRV_sh, SRV_mhd);
}

module PenLoop(id, bw, bt, bh) {
    // Auto adjust base width for slight clearance for sliding in
    bw = bw-0.4;

    // Calculate the loop OD
    od = bw - 2*(bt*0.2);

    // The Pen (loop) center is always 8mm from the face.
    lc = 9;

    // Start with the V slide base
    translate([0, 0, bh])
        rotate([-90, 0, 0]) {
            translate([bt, 0, 0])
                cube([bw-2*bt, bh, bt]); 
            VEdge(bt, bt/1.2, bh, bt, "l");
            translate([bw-bt, 0, 0])
                VEdge(bt, bt/1.2, bh, bt, "r");
        }
    // Loop and neck
    difference() {
        union() {
            translate([bw/2, lc, 0])
                cylinder(h=bt, d=od);
            translate([bt*0.2, 0, 0])
                cube([od, lc, bt]);
            translate([od+bt*0.2, bt/4, bt/4])
                rotate([0, -90, 0])
                    Corner45(bt*2, od);
        }
            translate([bw/2, lc, -1])
                cylinder(h=bt+2, d=id);
    }
}

if (draw=="all" || draw=="pentool")
    PenTool(PT_w, PT_h, PT_t, PT_psw);

if(print==false && draw=="all") {
    translate([(PT_psw+PT_w)/2, XC_h/2, PT_t])
        rotate([-90, 180, 0])
            color("green")
            PenLoop(9, PT_psw, PT_t, XC_h/4);
    translate([PT_psw/2-PT_t, XC_h, PT_t])
        rotate([-90, 180, 180])
            color("green")
            PenLoop(9, PT_psw, PT_t, XC_h/4);
}

if (print==true) {
    translate([-PT_psw-3, 0, 0])
        PenLoop(9, PT_psw, PT_t, XC_h/4);
    translate([-PT_psw-3, XC_h/2, 0])
        PenLoop(9, PT_psw, PT_t, XC_h/4);
}
