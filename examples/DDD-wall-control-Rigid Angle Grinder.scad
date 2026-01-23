$fa = 1;
$fs = 0.4;

include<../src/centerpieces.scad>
include<../src/sidepieces.scad>

centerpiece_numX = 4; // width of centerpice
centerpiece_numY = 4; // depth of centerpiece
centerpiece_tabHeight = 15; // height of tabs from bottom of centerpiece
sidepiece_numY = 4;   // depth of bracket
sidepiece_numZ = 4;   // height of bracket

preview = true;
parts = true;
printAll = true;
// orient for preview image
rotate([0,0,0]) {
    // renders just the sidepiece
    grinderHanger(numX = centerpiece_numX, numY = centerpiece_numY, tabHeight = centerpiece_tabHeight);

    // renders full parts list in place
    if (parts) { translate([0,0,centerpiece_tabHeight]) mirror([0,1,0]) parts(forPrint = printAll); }
}

// holder for a rigid angle grinder based on Oclure's tool holders
// https://makerworld.com/en/models/73318-dewalt-oscillating-tool-wall-control

module grinderHanger(numX, numY, mmHeight=30, tabHeight) {
    difference() {
        spacer(numX, numY, 30/wc_zPitch, tabHeight=tabHeight);
        translate([centerpieceWidth(numX)/2,0,0]) batteryToolSlot(42, numX*wc_yPitch-40, mmHeight/wc_zPitch);
    }
}

module parts(forPrint) {
    color("grey") sidepiece(numY=sidepiece_numY,numZ=sidepiece_numZ, vertical=true, place=[(forPrint ? -1 : 0),-sidepiece_numY,0]);
    color("grey") sidepiece(numY=sidepiece_numY,numZ=sidepiece_numZ, side="left", vertical="true", place=[centerpiece_numX + (forPrint ? 1 : 0),-sidepiece_numY,0]);
    color("white") spacer(numX=centerpiece_numX,numY=2, locking=true, vertical=true, place=[0,-sidepiece_numY,-1]);
}