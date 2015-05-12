/**
 * Sample fictituous pen.
 **/

$fn=100;

/**
 * This is a super fine point permenant marker.
 *
 * This pen has a uniform body diameter down to the point area that tapers
 * down in layers to the point. 
 **/
module Artliner725() {
    pTaperL = 4.4;  // Taper part of the point - length
    pFineD = 1;     // Point fine side diameter
    pTopL = 1.9;    // Top part of the point - length
    pTopD = 3.1;    // Top part of the point - diameter

    ppS1L = 10.1;   // Plastic point part stage 1 length
    ppS1Ds = 6;      // Palstic point part stage 1 small end diameter
    ppS1Dl = 7;      // Palstic point part stage 1 large end diameter

    ppS2L = 10.6;   // Plastic point part stage 2 length
    ppS2Ds = 10.35; // Plastic point part stage 2 small end diameter

    ppS2rw = 0.6;   // The indented ring at the bottom of stage 2. Width
    ppS2rd = 10.1;  // diameter
    ppS2ro = 1.2;   // offset from small end;

    bd = 11;    // Body diameter
    bl = 90.5;  // Body length - metal part

    // Start with the point
    color("gray")
        cylinder(d1=pFineD, d2=pTopD, h=pTaperL);
    color([50/255, 50/255, 50/255]) {
        translate([0, 0, pTaperL])
            cylinder(d=pTopD, h=pTopL);
        translate([0, 0, pTaperL+pTopL])
            cylinder(d1=ppS1Ds, d2=ppS1Dl, h=ppS1L);
        translate([0, 0, pTaperL+pTopL+ppS1L])
            cylinder(d1=ppS2Ds, d2=bd, h=ppS2L);
    }
    translate([0, 0, pTaperL+pTopL+ppS1L+ppS2L])
        color("yellow")
            cylinder(d=bd, h=bl);
    translate([0, 0, pTaperL+pTopL+ppS1L+ppS2L+bl-bd*0.5])
        color("silver")
            intersection() {
                sphere(d=bd*1.4);
                cylinder(h=bd, d=bd-0.1);
            }
}

Artliner725();
