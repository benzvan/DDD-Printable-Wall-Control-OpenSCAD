$fa = 1;
$fs = 0.4;

include<../src/centerpieces.scad>
include<../src/sidepieces.scad>

centerpiece_numX = 1; // width of centerpice
centerpiece_numY = 3; // depth of centerpiece
chargerPegSpace = 40;

spacerThickness = wc_spacerHeight+.5/wc_zPitch; // adds .5mm to spacer thickness to cover existing tabs on imported battery mount
tabOffset = .5; // raise tabs to center on spacer to match top position

preview = true;
parts = true;
// orient for preview image
rotate([preview ? 90 : 0 ,0 ,0]) {
    // renders just the sidepiece
    RigidCharger(centerpiece_numX, centerpiece_numY, chargerPegSpace);

    // renders full parts list in place
    if (preview) { parts(); }
}

module RigidCharger(numX, numY, pegSpace) {
    spacer(numX, numY, locking=true, customHoles=[[0,0]]);
    translate([0,numY*wc_yPitch-pegSpace-8,0]) {
        translate([centerpieceWidth(numX)/2,0,wc_spacerHeight*wc_zPitch]) keyholePeg(shaftWidth=5,headDiameter=7); 
        translate([centerpieceWidth(numX)/2,pegSpace,wc_spacerHeight*wc_zPitch]) keyholePeg(shaftWidth=5,headDiameter=7);
    }
}

module parts() {
    color("grey") sidepiece(numY=1, numZ=centerpiece_numY, bracket=false, side="right", place=[1,0,0]);
    color("grey") sidepiece(numY=1, numZ=centerpiece_numY, bracket=false, side="left");
}
