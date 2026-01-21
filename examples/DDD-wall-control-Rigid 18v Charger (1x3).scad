$fa = 1;
$fs = 0.4;

include<./DDDModules.scad>

RigidCharger();
module RigidCharger() {
    numX = 1;
    numY = 3;
    pegSpace = 40;
    spacer(numX, numY, locking=true, customHoles=[[0,0]]);
    translate([0,numY*wc_yPitch-pegSpace-8,0]) {
        translate([centerpieceWidth(numX)/2,0,wc_spacerHeight*wc_zPitch]) keyholePeg(shaftWidth=5,headDiameter=7); 
        translate([centerpieceWidth(numX)/2,pegSpace,wc_spacerHeight*wc_zPitch]) keyholePeg(shaftWidth=5,headDiameter=7);
    }
}
