uCNC mechanics remix
====================

This is a remix (rebuild, really) of the mechanical part of the
_uCNC Controller_ by **dherrendoerfer** :

  https://github.com/dherrendoerfer/uCNC_controller

The 3D printable CNC mechanical parts have been re-designed in OpenSCAD based on
the original design, but have been made parametric so that they can be easily
scalled or modified to fit other specific requirements.

The uCNC overall design is very nice and it was made for 28BYJ-48 stepper motors
which I already have. Also note that order to draw a sample of the designs with
the motors fitted, you will need the excellent OpenSCAD _28BYJ-48_ stepper
drawing by **RGriffoGoes**:

  http://www.thingiverse.com/thing:204734


X Bridges
=========
The X Bridges follows the original uCNC design very closely, but is made from a
base design for both sides, and then additions per side for the motor and
bearing mounts.

The motor side mount is specific for the 28BYJ-48 motor (althought still
customisable), but the bearing side is easier to adapt using variables.

X Carraige
==========
The X Carriage has the same base design as the original uCNC design, but since
the drive wires runs center between the upper and lower X rails, the space to
add the "springs" like in the original is limited.

The OpenSCAD config is mostly parameteric and does allow for the springs to be
added, but this will probably only work well on a larger scale plotter (which is
possible with the parametric design).

This carraige also has screw holes that can be used to anker the drive wires to
the carraige. This makes it easier to thread the drive wire and also to adjust
the tension.

The parameteric design allows the distance between the drive wires (based on the
sizes of the X bearing and X motor shaft/coupling) to be supplied. The code will
then automatically figure out the correct depth for the carraige based on the
wider of the drive wire distance apprat, or the outer diameter for the rail
bushings.

Y Bridges
=========
To be completed...

Y Carraige
==========
To be completed...

Motor Coupling
==============
The Motor Coupling SCAD file can be used to print a coupling that fits snugly
over the 28BYJ-48 motor shaft. This is also a parametric design and outer
diameter, height, internal spacing, etc. may be supplied.

The coupling makes it easy to get the motor side outer diamer in line with the
bearing outer diameter on the other side to allow the drive wires to run
parallel across the X axis.
