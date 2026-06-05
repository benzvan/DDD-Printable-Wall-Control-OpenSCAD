$fa = 1;
$fs = 0.4;

include<../src/centerpieces.scad>
include<../src/sidepieces.scad>
use<../src/modules.scad>

numY = 2;
numZ = 4;

num_slots = 4;
back_space = wc_zPitch/2;
slot_width = inchesToMM(.25);
rounding = 2;
centerpiece_tabHeight = 0;

numX = num_slots;
parts = true;
for_print = true;
printAll = true;

shelf(numX, numY, numZ);

module shelf(numX, numY, numZ) {
    difference() {
        union() {
            spacer(numX, numZ);
            translate([0, 0, inchesToMM(wc_spacerHeight) + rounding]) rotate([0, 90, 0]) hull() {
                translate([rounding, centerpieceDepth(numZ) - rounding, 0]) cylinder(h=centerpieceWidth(numX), r=rounding);
                translate([rounding, 0, 0]) cylinder(h=centerpieceWidth(numX), r=EPS);
            }
        }
        for (i=[0:numX-1]) {
            translate([wc_xPitch/2 - centerpieceFitSpaceX - slot_width/2 + i * wc_xPitch, back_space, 0]) {
                cube([slot_width, numZ * wc_yPitch, 2*inchesToMM(wc_spacerHeight)]);
            }
        }
    }
    if (parts) { translate([0, (numZ/2)*wc_zPitch, centerpiece_tabHeight]) parts(forPrint = printAll); }
}

module parts(forPrint) {
    color("grey") sidepiece(numY=numY,numZ=numZ, type=BRACKET, vertical=true, place=[(forPrint ? -1 : 0),-numY,0]);
    color("grey") sidepiece(numY=numY,numZ=numZ, type=BRACKET, side=LEFT, vertical=true, place=[numX + (forPrint ? 1 : 0),-numY,0]);
    color("white") spacer(numX=numX,numY=2, locking=true, vertical=true, place=[0,-numY,-1]);
    color("blue") translate([0, -(((2+numZ)/2)*wc_zPitch), 0]) lockingScrew();
    color("blue") translate([wc_xPitch, -(((2+numZ)/2)*wc_zPitch), 0]) lockingScrew();
}