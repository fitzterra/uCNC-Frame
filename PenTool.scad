/**
 * X Carraige
 **/
//-----------------------------------
// Draw/print Control

// Set to true to draw for printing
print = true;

// Draw the pen tool?
drawPenTool = false;

// How many pen holders to draw? 0 - 2
drawPenHolder = 2;

// Draw the pen lift?
drawPenLift = false;

// Mounting option? One of:
// "mag" for magnet mounts
// "M2" for M2 screw mounting
mount = "M2";

// Pen diameter
penD = 11;

//------------------------------------

// Version number for Pen Tool
_version = "v0.2";

use <Screw_Library/Thread_Library.scad>;

include <Configuration.scad>;
include <ToolsLib.scad>;
use <Pens.scad>;

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
 * @param mag If supplied, caveties for magnets of this size will be added to be
 *        used as a means of attaching to the base. The value should be a vector
 *        of [d, t] where d is the magnet diameter (additional clearance will be
 *        added), and t is the magnet thickness. Once cavety bottom center, and
 *        one each top left and right will be added.
 **/
module PenTool(w, h, t, psw, mag="") {
    // Calculate where the servo will be placed along the tool height. We place
    // the servo bottom 10mm above the point to which the X-Carraige will reach.
    // Remember that the bottom of the pen tool lines up with the bottom of the
    // X-Carraige.
    srvY = XC_h + 10;
    // Calculate where the servo base will sit below the pentool face bottom.
    // This position is calculated based on the position the servo horn top
    // should be above the face top.
    srvZ = SRV_hornPos + t - SRV_fhh;

    // The x and y length to cut in at the bottom corners for the 45° corners
    cut45len = w/4;

    // Mounting tabs are either for magnets or M2 screws. We calculate the
    // diameters and sizes here to be used in multiple places.
    tabID = mag=="" ? 2 : mag[0]+0.4;  // Inner diameter. Extra clearence for mag
    tabOD = tabID + 2;  // Outer diameter - rim width - must be doubled
    tabNeck = 1;        // Extra space for tab neck
    mh_d = mag=="" ? t+2 : mag[1];    // Mount hole depth
    mh_z = mag=="" ? -1 : 0.6;        // Mount hole Z offset

    difference() {
        // Parts we add
        union() {
            // Face
            cube([w, h, t]);
            // The bottom foot piece
            translate([cut45len, 0, t])
                cube([w-2*cut45len, t, t*3]);

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

            // Top mounting tabs.
            // Left tab
            translate([-tabOD/2-tabNeck, XC_h-tabOD/2, 0]) {
                cylinder(h=t, d=tabOD);
                translate([0, -tabOD/2, 0])
                    cube([tabOD/2+tabNeck, tabOD, t]);
            }
            // Right tab
            translate([w+tabOD/2+tabNeck, XC_h-tabOD/2, 0]) {
                cylinder(h=t, d=tabOD);
                translate([-tabNeck-tabOD/2, -tabOD/2, 0])
                    cube([tabOD/2+tabNeck, tabOD, t]);
            }
        }

        // Parts we subtract
        // The two 45° corners
        translate([-1, -1, -1])
            Corner45(cut45len+1, t*2+2);
        translate([w+1, -1, -1])
            rotate([0, 0, 90])
                Corner45(cut45len+1, t*2+2);
        
        // Mounting holes if not using magnets, else magnet indents.
        // Bottom center - we use the tab OD to determine the center
        translate([w/2, t+1+tabOD/2, mh_z])
            cylinder(h=mh_d, d=tabID);
        // Left tab
        translate([-1-tabOD/2, XC_h-tabOD/2, mh_z])
            cylinder(h=mh_d, d=tabID);
        // Right tab
        translate([w+1+tabOD/2, XC_h-tabOD/2, mh_z])
            cylinder(h=mh_d, d=tabID);

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

/**
 * Draws a pen holder that slides into the pentool.
 *
 * @param id The inner diameter. This is the pen diameter at halfway up the
 *        X-Carraige height, for the lower holder, and the full X-Carraige
 *        height for the top holder.
 * @param bw The width of the holder base. This should match the width of the
 *        slide used for the PenTool.
 * @param bt The base thickness. The PenTool thickness is used for the height
 *        or thickness of the slide walls. This value should match the PenTool
 *        thickness for that reason.
 * @param bh The height of the base - this should be half the slide height on
 *        the PenTool, which currently is half the height of the X-Carraige.
 **/
module PenLoop(id, bw, bt, bh) {
    // Auto adjust base width for slight clearance for sliding in
    bw = bw-0.3;

    // The base is a V type shape to it slides into the PenTool slide and stays
    // put. Calculate the narrow side width of the base where the loop is
    // attached to.
    bnw = bw - 2*(bt*0.2);

    // Loop OD is 1mm larger than the ID. This allows the ID to be almost exactly
    // that of the pen, but we can cut the loop in the front center to give a
    // tight fit, but not too tight to not allow it to slide up and down.
    od = id+2;

    // The Pen (loop) center is always this far from the face.
    lc = PEN_coffs;

    // Start with the V slide base
    translate([0, 0, bh])
        rotate([-90, 0, 0]) {
            // The inner square base with bt width edges on both sides
            translate([bt, 0, 0])
                cube([bw-2*bt, bh, bt]);
            // Add a slanted edge of bt base with a 20% slant on the left
            VEdge(bt, bt/1.2, bh, bt, "l");
            // Do the same for the right
            translate([bw-bt, 0, 0])
                VEdge(bt, bt/1.2, bh, bt, "r");
        }
    // Loop and neck
    difference() {
        union() {
            translate([bw/2, lc, 0])
                cylinder(h=bt, d=od);
            translate([(bw-od)/2, 0, 0])
                cube([od, lc, bt]);
            translate([(bw-od)/2+od, bt/4, bt/4])
                rotate([0, -90, 0])
                    Corner45(bt*2, od);
        }
            translate([bw/2, lc, -1])
                cylinder(h=bt+2, d=id);
    }
}

/**
 * Fits arounf the pen and connects to the servo horn to raise and lower the pen.
 *
 * @param pd Pen diameter at the point where this should fit.
 * @param ta Taper Angle for the inner cylinder. This should probably never be
 *        much more than 2° or 3°.
 **/
module PenLift(pd, ta=2) {
    h = 10; // height
    trt = pd/2+1; // Top radius for the tappered inner cylinder
    trb = h/tan(90-ta) + pd/2 + 1; // Bottom radius for tappered inner cylinder

    // The inner cylinder
    difference() {
        // The tappered outer side
        cylinder(r1=trb, r2=trt, h=h);
        // Remove the inner tube at 0.2mm less than the pen diameter
        translate([0, 0, -1])
            cylinder(d=pd-0.2, h=h+2);
        // Make a 1mm cut in the side of the inner cylinder
        translate([0, -0.5, -1])
            cube([trb+2, 1, h+2]);
    }

    // The outer fitting placed next to the inner for printing, or fitted over
    // the inner tube if not printing
    tr = print==true ? [trb*2+2, 0, 0] : [0, 0, 2];
    translate(tr)
        difference() {
            union() {
                // Outer diameter is the same as the bottom wider part of the
                // tappered inner tube plus 2mm wall thickness
                cylinder(d=trb*2+2, h=h);
                // The hook for the servo horn. The part of the servo horn reaching
                // over into the pen tool can be calculated as follows:
                hornBit = SH_l - (SRV_d+SH_sOD)/2;
                // We want the horn hook width to be 4mm
                hhw = 5;
                // The zero position for the pen lift will be the center of pen tool
                // width. We can then calculate the position for the horn hook.
                translate([0, -PT_w/2+hornBit-hhw, 0])//+hornBit-hhw, 0])
                    difference() {
                        // The hook distance beyound the outer tube edge, id the
                        // height of the servo horn above the tube when fitted
                        // to the pen, including a 2mm wall
                        cube([SRV_hornPos-PEN_coffs+2, hhw, h]);
                        // Remove a cube on the inside for the horn to fit in
                        translate([SRV_hornPos-PEN_coffs-SH_t-0.3, -1, 2])
                            cube([SH_t+0.6, 9, h-4]);
                    }
            }
            // Cut out the inner hole to be the same diameter as widest bottom
            // part of the inner tube
            translate([0, 0, -1])
                cylinder(d=trb*2, h=h+2);
        }

}

// Draw what is required
if (drawPenTool)
    PenTool(PT_w, PT_h, PT_t, PT_psw, mount=="mag" ? magSize : "");

if(print==false && drawPenHolder>0) {
    translate([PT_t+0.2, XC_h*3/4, PT_t])
        rotate([90, 0, 0])
            color("orange")
            PenLoop(penD+0.4, PT_psw, PT_t, XC_h/4);
    if (drawPenHolder>1)
        translate([(PT_w-PT_psw)/2+0.2, XC_h+5, PT_t])
            rotate([-90, 180, 180])
                color("green")
                PenLoop(penD+0.4, PT_psw, PT_t, XC_h/4+5);
    // Draw the pen
    translate([PT_w/2, 0, PT_t+PEN_coffs])
        rotate([-90, 0, 0])
            Artliner725();
}

if (print==true && drawPenHolder>0) {
    translate([PT_psw, 0, 0])
        rotate([0, 0, 180])
        PenLoop(penD+0.4, PT_psw, PT_t, XC_h/4);
    if (drawPenHolder>1)
        translate([0, 1, 0])
            PenLoop(penD+0.4, PT_psw, PT_t, XC_h/4+5);
}

if (drawPenLift==true) {
    if(print==true) {
        translate([-50, 0, 0])
            PenLift(penD);
    } else {
        translate([PT_w/2, 50, PT_t+PEN_coffs])
            rotate([-90, -90, 0])
            PenLift(penD);
    }
}

