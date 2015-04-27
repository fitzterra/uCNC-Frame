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
XC_rcd = XB_rcd;// Rails are same distance apart as for X Bridge
XC_bw = 5;      // Total width for each bushing


// Direct from the StepMotor28BYJ library
MBH = 18.8;   // motor body height
MBD = 28.25;  // motor body OD
MTH  = 0.8;   // mounting tab thickness
MTW  = 7.0;   // mounting tab width
MHCC = 35.0;  // mounting hole center-to-center
SHH = 9.75;   // height of shaft above motor body 

