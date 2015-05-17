/**
 * X Carraige
 **/
//-----------------------------------
// Draw/print Control

// Set to true to draw for printing
print = true;

// Draw the pen tool?
drawPenTool = true;

// Mounting option? One of:
// "mag" for magnet mounts
// "M2" for M2 screw mounting
//mount = "mag";
mount = "M2";

// Draw the Z Carriage?
drawZCarriage = true;

// Draw pinion gear if we are printing?
drawPinion = true;

/**
 *  TODO:
 **/

//------------------------------------

// Version number for Pen Tool
_version = "v0.6";

include <Configuration.scad>;
use <ToolsLib.scad>;
use <Pens.scad>;
use <publicDomainGearV1.1.scad>;

/**
 * Pen Tool Holder
 *
 * @param w The tool width
 * @param h The tool height
 * @param t The thickness
 * @param mag If supplied, caveties for magnets of this size will be added to be
 *        used as a means of attaching to the base. The value should be a vector
 *        of [d, t] where d is the magnet diameter (additional clearance will be
 *        added), and t is the magnet thickness. Once cavety bottom center, and
 *        one each top left and right will be added.
 **/
module PenTool(w, h, t, mag="") {
    // Position of the servo with pinion gear to mesh with rack on Z Carraige.
    // 1. Move servo halfway in to get pinion center on left edge of Pen tool: SRV_d/2
    // 2. Move servo left again to get pitch radius on the pen tool left edge
    // 3. Move it right again to get the pitch radius level with Z Carraige left edge
    // 4. Move right by the addendum of the rack gear to get the pressure points lined up
    srvX = SRV_d/2 - pitch_radius(RP_mmpt, RP_pt) + module_value(RP_mmpt);
    // Calculate where the servo will be placed along the tool height. The servo
    // is mounted with the wires pointing up, and then the bottom mount tab is
    // 2mm above the X Carraige top - this should give enough space for the M2
    // mounting screws, but does not work with the magnet mounting yet!
    srvY = XC_h+SRV_tw+2;
    // Calculate where the servo base will sit below the pentool face bottom.
    // This position is calculated based on the position the pinion gear top
    // should be above the face top. We get the pinion gear is thinner than the
    // rack and we try to get the gear center on the rack center.
    srvZ = t*3 + (RP_pT+RP_rT)/2 - SRV_fhp;

    // The x and y length to cut in at the bottom corners for the 45° corners
    cut45len = w/4;

    // The Z Carriage shaft fittings outer diameter
    zcsOD = ZC_sd+t*2;

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
            // The Z Carriage shaft fittings, bottom and top of the shaft
            for (y=[0, ZC_sl-t*2])
                translate([(w-zcsOD)/2, y, t])
                    difference() {
                        union() {
                            // Block to center of fitting radius
                            cube([zcsOD, t*2, zcsOD/2]);
                            // Outer fitting cylinder
                            translate([zcsOD/2, 0, zcsOD/2])
                                rotate([-90, 0, 0])
                                    cylinder(d=zcsOD, h=t*2);
                        }
                        // Hole in the middle. For the bottom fitting, the hole
                        // does not go all the way through
                        translate([zcsOD/2, -1, zcsOD/2])
                            rotate([-90, 0, 0])
                                cylinder(d=ZC_sd, h=t*2+2);
                    }

            // Z Carriage guide plate
            translate([w-t, cut45len, t]) {
                cube([t, ZC_sl-t*5, zcsOD+1]);
                // A fillet for extra support
                translate([-t, 0, 0])
                    difference() {
                        cube([t, ZC_sl-t*5, t]);
                        translate([0, -1, t])
                            rotate([-90, 0, 0])
                                cylinder(r=t, h=ZC_sl-t*5+2);
                    }
            }

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
            // Servo moutning plate
            translate([srvX-SRV_d, srvY-SRV_tw-2, 0])
                cube([SRV_d, SRV_w+2*SRV_tw+4, t]);
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
        translate([w/2, t+2+tabOD/2, mh_z])
            cylinder(h=mh_d, d=tabID);
        // Left tab
        translate([-1-tabOD/2, XC_h-tabOD/2, mh_z])
            cylinder(h=mh_d, d=tabID);
        // Right tab
        translate([w+1+tabOD/2, XC_h-tabOD/2, mh_z])
            cylinder(h=mh_d, d=tabID);
        // The Servo cutout using a larger sized servo and slight poitioning
        // adjustments to allow the real servo to be adjusted closer/further
        // from the rack gear on the Z Carraige.
        translate([srvX, srvY-1, srvZ]) {
            rotate([0, 0, 90])
                Servo(d=SRV_d+2, w=SRV_w+2);
        }
        // Servo mounting holes
        translate([srvX-SRV_d, srvY-SRV_tw, 0]) {
            for(y=[SRV_tw/2, SRV_w+SRV_tw*2-SRV_tw/2])
                translate([SRV_d/2, y, -1])
                    hull() {
                        cylinder(d=SRV_mhd, h=SRV_th+2);
                        translate([-2, 0, 0])
                            cylinder(d=SRV_mhd, h=SRV_th+2);
                    }
        }
    }
    
    // The version number
    translate([5, h-5, t])
        rotate([0, 0, -90])
            Version(h=0.5, s=3, v=_version, valign="top");

    // The Servo
    if (print==false)
        translate([srvX, srvY, srvZ])
            rotate([0, 0, 90])
            ServoAndPinion();
}

/**
 * Z Carraige.
 *
 * @param sd Shaft diameter
 * @param sl Shaft Length
 * @param cw Carraige width
 * @param cd Carraige depth
 * @param ch Carraige height
 * @param bh Bushings height
 * @param bt Wall thickness for bushings
 * @param so When not printing, and the shaft is drawn, how far to offset the
 *        base from the bottom of the shaft. Or, how far should the carriage be
 *        up the shaft.
 **/
module ZCarriage(sd, sl, cw, cd, ch, bh, bt, so=5) {
    // Calculate the rack length
    rackL = RP_rt*RP_mmpt+RP_mmpt/2;

    // The z carraige
    difference() {
        union() {
            // The central carraige
            cube([cw, cd, ch]);
            // Bushings with the shaft half sunk into the central carraige
            for(z=[0, (ch-bh)/2, ch-bh]) {
                translate([cw/2, cd, z])
                    cylinder(d=sd+bt, h=bh);
            }
        }
        // Take away the shaft center with a 0.3mm clearance
        translate([cw/2, cd, -1])
            cylinder(d=sd+0.3, h=ch+2);
        // The pen position
        pd = cw-4; // Leave 2mm flat on each side to allow printing face down
        translate([cw/2, 0, -1])
            rotate([0, 0, 360/16])
                cylinder(d=pd, h=ch+2, $fn=8);
        // Remove a space for the rack gear
        translate([-1, cd-RP_rT, ch-5-rackL])
            cube([RP_rH+1, RP_rT+1, rackL]);
        // Holes for the pen straps
        for(z=[5, ch-5]) {
            translate([-1, 3, z])
                rotate([0, 90, 0])
                    cylinder(d=2, h=cw+2);
        }
    }

    // Z Shaft if not ready for printing
    if(print==false)
        color("silver")
            translate([cw/2, cd, -so])
                cylinder(d=sd, h=sl);
    
    // Rack gear
    translate([RP_rH, cd, ch-5-rackL])
        rotate([0, -90, 90])
            Rack();

}

// Draw what is required
if (drawPenTool)
    PenTool(PT_w, PT_h, PT_t, mount=="mag" ? magSize : "");

if(drawZCarriage) 
    if (print==false) {
        // Position on the pen tool
        translate([(PT_w-ZC_cw)/2, PT_t+22, ZC_cd+ZC_sd/2+PT_t*2])
            rotate([-90, 0, 0])
                ZCarriage(ZC_sd, ZC_sl, ZC_cw, ZC_cd, ZC_ch, ZC_bh, ZC_bt, so=22);
        // Draw the Artliner725 pen
        translate([PT_w/2, 0, 14.5])
            rotate([-90, 0, 0])
                Artliner725();
    } else {
        // Postion next to the pen tool, pen side down for print
        translate([-10, 0, 0])
            rotate([-90, 180, 0])
                ZCarriage(ZC_sd, ZC_sl, ZC_cw, ZC_cd, ZC_ch, ZC_bh, ZC_bt);
    }

// Pinion gear only if we are printing
if(print && drawPinion)
    translate([-10-ZC_cw/2, ZC_ch+10, 0])
        Pinion();
