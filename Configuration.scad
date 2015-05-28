/**
 * A configuration file that contains all the parameters for the mechanical
 * parts of the uCNC frame.
 *
 * The configuration is split out like this to make it easy for all the part
 * files to _include_ this file and thus give all parts access to the various
 * sizes used to define the frame.
 **/

// Cylinder granularity
$fn=120;

// General paramaters
wallT = 1.8;    // General wall thicknes for more uniform parts
railD = 6;      // Rails rod diameter

// XBridge general sizes
XB_h = 52;    // Height
XB_w = 47;    // Width
XB_f = 30;    // Length of foot piece
XB_t = wallT; // Wall thickness
XB_rd = railD;// Diameter of rail rods
XB_rcd = 20;  // Rails center distance - distance center-to-center
XB_md = 4;    // Mount slits diameter in foot.
XB_dwd = 1;   // Drive wire diameter

// XBridge bearing side bearing params
B_od = 11;
B_id = 5;
B_t = 5;

// XCarriage parameters
XC_w = 20;      // Width
XC_h = 40;      // Height
XC_t = wallT;   // Wall Thickness
XC_rd = XB_rd;  // Rails are the same diameter as for the X Bridge
XC_rhc = 0.4;     // Clearance across rail hole diameter for easier fit of rods.
XC_rcd = XB_rcd;// Rails are same distance apart as for X Bridge
XC_bw = 5;      // Total width for each bushing
XC_dwd = B_od-2;  // The distance between the holes for the drive wires through
                // the carraige. It is best to have this width the same as the
                // bearing OD and the drive shaft/motor coupling OD to ensure
                // the wires stay the same width apart at points in the carraige
                // travel. This value also determines the depth of the carraige.
XC_springs = false; // The original uCNC plotter design had "springs" between the
                    // Top and bottom parts which I assume was to help in case
                    // the top and bottom rods were not perfectly parallel. Since
                    // moving the drive wire to the center between the top and
                    // bottom rods in the carraige, there is not much space left
                    // to add the springs and get them to print properly. For
                    // this reason, this option allows them to be added possbily
                    // when upscaling the complete design.

// PenTool parameters
PT_w = XC_w;        // Width is the same as the X-carraige
PT_h = XC_h * 2;    // Height is the X-carriage + servo height
PT_t = wallT;       // Wall thickness
PT_psw = PT_w-PT_t*2; // The width (at face level) for the pen holder slides
SRV_hornPos = 20;   // How far above the tool face the top of the servo horn
                    // should be
PEN_coffs = 9;      // The offset from the tool face to the pen center

// Magnet size is used for attachment method
magSize = [6, 3];   // 6mm diameter by 3mm thick

// Servo horn parameters
SH_sOD = 7;   //Shaft side outer diameter
SH_eOD = 4;   //Edge side outer diameter
SH_l = 17.2;  //Total length
SH_t = 1.6;   //Thickness
SH_sh = 4.5;  //Shaft side full height
SH_sd = 4.6;  //Shaft diameter
SH_si = 2.4;  //Shaft inset into the horn - how deep does the shaft fit into the horn
SH_sr = 1;    //Screw recess - the amount of recess for the screw in the horn top
SH_srd = 4.8; //Screw recess diameter
SH_shd = 2.3; //Screw hole diameter
SH_lh = 5;    //Number of link holes
SH_lhd = 1;   //Link hole diameter

// 9g Micro servo parameters
SRV_w = 22.5;   // Body width
SRV_lh = 15.9;  // Lower body height - up to bottom of mounting tabs
SRV_d = 11.8;   // Body depth
SRV_tw = 4.7;   // Width of one tab
SRV_th = 2.5;  // Height of tab
SRV_uh = 22.7-SRV_th-SRV_lh;  // Upper body height - from top of mounting tabs to body top
SRV_gh = 4;   // Height of top round gear extrusion
SRV_bgd = 5;  // Top back smaller gear extrusion diameter
SRV_sd = 4.6;     // Shaft diameter
SRV_sh = 2.75;   // Shaft height
SRV_mhd = 2;  // Mounting hole diameter
SRV_fh = SRV_lh+SRV_th+SRV_uh+SRV_gh+SRV_sh; // The full servo height
SRV_fhh = SRV_fh+SH_sh-SH_si;   // Servo full height including horn
// See below rack/pinion (RP_*) params for servo full height with pinion

// Direct from the StepMotor28BYJ library
MBH = 18.8;   // motor body height
MBD = 28.25;  // motor body OD
MTH  = 0.8;   // mounting tab thickness
MTW  = 7.0;   // mounting tab width
MHCC = 35.0;  // mounting hole center-to-center
SBH = 1.45;   // shaft boss height above motor body
SHH = 9.75;   // height of shaft above motor body 
WBW  = 14.6;  // plastic wiring box width
WBD  = 31.3;  // body diameter to outer surface of wiring box

// Rack and pinion parameters
RP_mmpt = 4;     // Millimeters per tooth for the rack/pinion gears
RP_pt = 6;       // Number of teeth on the pinion gear
RP_rt = 8;       // Number of teeth on the rack gear
RP_pT = 2.5;     // Thickness of the pinion gear
RP_rT = 5;       // Thickness of the rack gear
RP_rH = 5;       // Height of the rack gear
RP_pa = 5;       // Pressure angle for the gears. Small value for small gears
RP_phd = 2;      // Pinion screw hole diameter
RP_pcOD = SRV_sd+2;// Pinion shaft collar outer diameter
RP_pcID = SRV_sd+0.3;// Pinion shaft collar inner diameter - fits over servo shaft
RP_pch = SRV_sh-0.25;// Pinion shaft collar height - slightly less than servo shaft height
// Calculate the servo full height with pinion mounted
SRV_fhp = SRV_fh+RP_pT;   // Servo full height including pinion

// Z carriage config
ZC_sd = 3;  // Shaft diameter
ZC_sl = 90; // Shaft length
ZC_bh = 5;     // Height for each of the 3 bushings
ZC_bt = 3;     // Wall thickness for the bushings
ZC_cw = PT_w-2*PT_t; // Carraige width - same width as the pen tool, sans a pen
                     // tool wall thicknes left and right
ZC_cd = ZC_cw+2;  // Carraige depth excluding the rear half bushings
ZC_ch = 50;   // Carraige height

// Y Bridge config
YB_t = wallT; // Thickness for all walls
// The height of the bridge should be just enough to clear the motor shaft plus
// a 4mm tolerance. The motor sticks through the top of the bridge which also
// has a thickness to take into account.
YB_h = SHH+5-YB_t;  // Height
YB_l = 40;          // Lenght (front to back)
YB_rcd = 50;        // Rails center distance - distance center-to-center
YB_rd = railD;      // Diameter of rail rods
YB_dwd = 1;         // Drive wire diameter

YB_mscd = 10; // The motor shaft coupling diameter that will be used motor.
              // This is to determine the how wide apart to make the drive wire
              // guide slits on the motor side bridge.


// Y Carraige parameters
YC_t = wallT; // Thickness for all walls
YC_l = 40;          // Lenght (front to back)
YC_rcd = 50;        // Rails center distance - distance center-to-center
YC_rd = railD;      // Diameter of rail rods
YC_bl = 13;         // Bushing length
YC_bt = YC_t;       // Bushing wall thickness - should not be greater than YC_t
YC_bmhd = 5;        // Mounting hole diameter to mount bed
YC_bmmd = 9 + 0.4;  // Magnet dimeter if used for bed mounting

// The bed parameters
YBD_x = 60;     // Size in x direction
YBD_y = 60;     // Size in y direction
YBD_t = 1;      // Thickness. For the bed, 1mm is enough
YBD_mhd = 3;    // Diameter for mounting holes
YBD_mmd = 6 + 0.4;  // Diameter of magnets used for quick release mounting
YBD_mmt = 3 + 0.2;  // Thickness of magnets, including play
