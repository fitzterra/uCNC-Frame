/**
 * Y Bridges
 **/

//-----------------------------------
// Draw/print Control

// What setting to draw? One of
// "print" - plate for printing
// "model" - model the Y Axis
// "design" - work on one part at position 0,0,0
// "designFit" - work on one part at position 0,0,0, but fit any external
//               components like motors, bearings etc to test.
_setting = "model";


// What to draw? One of:
// "bs" for bearing side bridge
// "ms" for motor side bridge
// "c"  for the carraige
// "b"  for the carraige
// "all" to draw both bridges and carraige
draw = "all";
//------------------------------------

// Version number for X Bridges
_version = "v0.6";

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
            translate([x, -1, h/3]) {
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

    // Add the motor if we are design fitting or modeling
    if(_setting=="designFit" || _setting=="model") {
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

    // Add the bearing if we are modeling or design fitting
    if(_setting=="designFit" || _setting=="model") {
        translate([w/2, bco, t+bft+b_t/2])
            color("silver", 0.7)
            Bearing(b_id, b_od, b_t);
    }
}

/**
 * Y Carraige
 *
 * @param l Length (front to back)
 * @param t Thickness
 * @param rcd Rods center-to-center distance apart
 * @param rd Rod diameter
 * @param bl Bushings length - how long to make the bushings over the shaft
 * @param bt Bushing wall tickness
 * @param bmhd Bed mount holes diameter - 0 for no bed mount holes
 * @param bmmd Bed mount magnets diameter. Can be used to create a recessed round
 *        area on the carriage underside into which magnets can be fitted as
 *        mounting option for the bed. The bed has the same option for magnets
 *        on that side. If this is not to  be used, set to 0, else it should be
 *        the magnet diameter. The recess would be made such that there is 0.8mm
 *        left to the carriage top.
 * @param dwhd Drive wire hode distance - how far apart the drive wires will run
 **/
module YCarraige(l=YC_l, t=YC_t, rcd=YC_rcd, rd=YC_rd, bl=YC_bl, bt=YC_bt,
                 bmhd=YC_bmhd, bmmd=YC_bmmd, dwhd=10) {
    // Calculate the carraige width based on distance between rods and bushing
    // wall thickness
    w = rcd + rd + 2*bt;

    // The full bushing width
    bw = rd + 2*bt;

    // Some clearance in the bushing hole for the shaft to easily slide
    bc = 0.3;

    // Bed Mount Holes or Mag recess?
    mhd = max(bmhd, bmmd);  // Find the larger of the two possible diameters

    difference() {
        union() {
            // The bed
            cube([w, l, t]);
            // Bushings
            for (x=[0, w-bw])
                for (y=[0, l-bl]) {
                    translate([x, y, t])
                        // The additional 0.2mm is to ensure the bushing hole is
                        // slightly above the base so there is less friction on
                        // the rod.
                        cube([bw, bl, rd/2+bc+0.2]);
                    translate([x+bw/2, y, t+rd/2+bc+0.2])
                        rotate([-90, 0, 0])
                            cylinder(d=bw, h=bl);
                }
            // Central cube for drive wire attachment
            translate([(w-dwhd)/2-t*1.5, (l-10)/2, t])
                cube([dwhd+t*3, 10, t*2]);
        }
        // Stuff to remove
        // The bushing holes
        for (x=[bw/2, w-bw/2])
            translate([x, -1, t+rd/2+bc+0.2])
                rotate([-90, 0, 0])
                    cylinder(d=rd+bc, h=l+2);
        // Drive wire securing holes in the drive wire securing block
        for (x=[(w-dwhd)/2, (w+dwhd)/2])
            for (y=[(l-10)/2, (l+10)/2 - 4])
                translate([x, y+2, t])
                    cylinder(d=2, h=t*2+1);
        
        // Do we make either magnet recess or mount holes, or both?
        if(mhd>0) {
            // X position for the holes is ¼ in from the edges
            for (x=[w/4, w-w/4])
                // TODO: We need to refactor this somehow since we do the same
                //       thing in multiple places on the carraige and bed
                // Y position is so that hole edges are 4mm in from the
                // carraige edge
                for (y=[2+mhd/2, l-2-mhd/2]) {
                    // The mag recess leave 0.8mm to the carraige top
                    translate([x, y, 0.8])
                        cylinder(d=bmmd, h=t+2);
                    // The mount hole if any
                    translate([x, y, -1])
                        cylinder(d=bmhd, h=t+2);
                }
        }
    }
    // The version number
    translate([w/2, t+2, t])
            Version(h=0.5, s=3, v=_version, valign="bottom", halign="center");
    // Show the magnets if we are modeling or design fitting
    if((_setting=="designFit" || _setting=="model") && bmmd>0) {
        for (x=[w/4, w-w/4])
            // TODO: We need to refactor this somehow since we do the same
            //       thing in multiple places on the carraige and bed
            for (y=[2+mhd/2, l-2-mhd/2]) {
                translate([x, y, 0.8])
                    color("silver")
                        // Assume 3mm thick magnets
                        cylinder(d=bmmd, h=3);
            }
    }
}

/**
 * Plot bed. The bed will be printer at t thickness but will have 4 mount
 * extrusions protruting from the based to be used for mounting the bed to the
 * Y carraige.
 *
 * Either screws or magnets could be used for mounting. ???????
 *
 * @param x Size in X direction.
 * @param y Size in Y direction.
 * @param cl Carraige length (in Y direction) the deb would fit onto
 * @param rcd Rods center-to-center distance apart. Along with rd is used to
 *        calculate the width of the carraige so we can center the bed on it.
 * @param rd Rod diameter. See also rcd.
 * @param mhd Bed mount holes diameter. Use 0 for no mounting holes.
 * @param mmd Bed mount magnet diameter. Use 0 if not needed.
 * @param mmt Bed mount magnet thickness. This is used to make the recess into
 *        which the magnet fits deep enough to allow them to be sunken completely
 **/
module YBed(x=YBD_x, y=YBD_y, t=YBD_t, cl=YC_l, rcd=YC_rcd, rd=YC_rd,
            mhd=YBD_mhd, mmd=YBD_mmd, mmt=YBD_mmt) {
    // We use the same function used to calculate the carriage width as to 
    // calculate the bridge width.
    w = yBridgeWidth(rcd, rd);

    // Find the larger diameter between mounting hole and magnet
    mmhd = max(mhd, mmd);
    // The mounting extrusion is either 3mm if we do not use magnets, or the
    // magnet thickness
    met = max(3, mmt);

    difference() {
        union() {
            cube([x, y, t]);
            // Position to the bottom left corner of where the carraige would
            // fit to add the bottom mount extrusions
            translate([(x-w)/2, (y-cl)/2]) {
                // Use the same code as for creating the mounting holes on the
                // Y Carraige to add the mount points on the bed
                for (X=[w/4, w-w/4])
                    // TODO: we need to use the Y Carraige magnet mount diameter here
                    //       to ensure it lines up with the carraige. We need to
                    //       refactor this somehow since we do the same thing in
                    //       multiple places on the carraige ans bed
                    for (Y=[2+YC_bmmd/2, cl-2-YC_bmmd/2])
                        translate([X, Y, 0])
                            // We add 3mm to the diameter for the extrusion,
                            // with a 0.8mm cover
                            cylinder(d=mmhd+3, h=met+0.8);
            }
        }
        //Position to the bottom left corner to where the carraige would fit to
        // make sure the mounting holes/extrusions fits the carraige exactly.
        translate([(x-w)/2, (y-cl)/2]) {
            // Use the same code as for creating the mounting holes on the
            // Y Carraige to add the mount holes/magnet recesses on the bed
            for (X=[w/4, w-w/4])
                // TODO: we need to use the Y Carraige magnet mount diameter here
                //       to ensure it lines up with the carraige. We need to
                //       refactor this somehow since we do the same thing in
                //       multiple places on the carraige ans bed
                for (Y=[2+YC_bmmd/2, cl-2-YC_bmmd/2])
                    translate([X, Y, -1]) {
                        // The mounting hole right through the base and extrusion
                        cylinder(d=mhd, h=met+0.8+2);
                        // The recess leaving 1mm covering for the magnet/screw
                        // to grip
                        cylinder(d=mmd, h=0.8+met);
                    }
        }
    }

    // The version number
    translate([w/2, t+2, t])
            Version(h=0.5, s=3, v=_version, valign="bottom", halign="center");
    // Show the magnets if we are modeling or design fitting
    if((_setting=="designFit" || _setting=="model") && mmd>0) {
        translate([(x-w)/2, (y-cl)/2]) {
            for (X=[w/4, w-w/4])
                // TODO: we need to use the Y Carraige magnet mount diameter here
                //       to ensure it lines up with the carraige. We need to
                //       refactor this somehow since we do the same thing in
                //       multiple places on the carraige ans bed
                for (Y=[2+YC_bmmd/2, cl-2-YC_bmmd/2])
                    translate([X, Y, 0])
                        color("silver")
                            cylinder(d=mmd, h=mmt);
        }
    }
}

// Make a print tray if we need to print
if (_setting=="print") {
    if (draw=="all" || draw=="ms")
        translate([0, 0, 0])
            YBridgeMotorSide();
    if (draw=="all" || draw=="bs")
        translate([0, draw=="all" ? YB_l+5 : 0, 0])
            YBridgeBearingSide();
    if (draw=="all" || draw=="c")
        translate([0, draw=="all" ? (YB_l+5)*2 : 0, 0])
            YCarraige();
    if (draw=="all" || draw=="b")
        translate([0, draw=="all" ? (YB_l+5)*3 : 0, 0])
            YBed();
} else if (_setting=="model") {
    // Model the Y Axis, using only the parts specified
    // Determine the bridge and carriage widths
    w = yBridgeWidth(YB_rcd, YB_rd);
    // The carraige width
    cw = YC_rcd+YC_rd+YC_bt*2;
    if (draw=="all" || draw=="ms")
        translate([0, -100, YB_h])
            rotate([0, 180, 180])
                YBridgeMotorSide();
    if (draw=="all" || draw=="bs")
        translate([w, 100, YB_h])
            rotate([0, 180, 0])
                YBridgeBearingSide();
    // TODO: Fix positioning of YCarraige here
    if (draw=="all" || draw=="c")
        translate([cw+(w-cw)/2, -YC_l/2, YB_h+1.1])
            rotate([0, 180, 0])
                YCarraige();
    // TODO: Fix positioning of YBed here
    if (draw=="all" || draw=="b")
        translate([(cw+YBD_x)/2, -YBD_y/2, YB_h+YC_t+YBD_mmt+0.8])
            rotate([0, 180, 0])
                YBed();
    if (draw=="all")
        for (x=[(w-YB_rcd)/2, (w+YB_rcd)/2])
            translate([x, -105, YB_h-yBridgeFootWidth(YB_rd)/2])
                rotate([-90, 0, 0])
                    color("silver", 0.7)
                        cylinder(d=YB_rd, h=210);
} else if (_setting=="design" || _setting=="designFit") {
    // Design mode, only draw the part being designed
    if (draw=="ms")
        YBridgeMotorSide();
    if (draw=="bs")
        YBridgeBearingSide();
    if (draw=="c")
        YCarraige();
    if (draw=="b")
        YBed();
}


