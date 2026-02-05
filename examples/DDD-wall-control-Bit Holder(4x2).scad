$fa = 1;
$fs = 0.4;

include<../src/centerpieces.scad>
include<../src/sidepieces.scad>
use<../src/regular-polygon.scad>

HexBitFaceWidth = 7;
HexBitCornerWidth = 2 * circumradius(HexBitFaceWidth/2, 6);
HexBitClearance = 2;
HexBitPocketDepth = 10;

bitHolder_xCount = 4;
bitHolder_yCount = 2;
bitHolder_zCount = 3;
bitHolder_bitsPerShelf = 8;

centerpiece_xCount = 4; // width of centerpice
centerpiece_yCount = 2; // depth of centerpiece
sidepiece_yCount = 2;   // depth of bracket
sidepiece_zCount = 2;   // height of bracket


preview = true;
// orient for preview image
    // renders just the sidepiece
    translate([0, 0, preview ? wc_sidepieceTabFromTop : 0]) bitHolder(bitHolder_xCount, bitHolder_yCount, bitHolder_zCount, bitHolder_bitsPerShelf);

    // renders full parts list in place
mirror([0,1,0]) {
    if (preview) { parts(); }
}

module bitHolder(xCount, yCount, stepCount, bitCount) {
    stepDepth = (wc_yPitch * yCount) / stepCount;
    spacer(xCount, yCount, 6.5/wc_zPitch);
    bitSteps(xCount, yCount, stepDepth, stepCount, bitCount);
}

module bitStep(numX, height, bitCount, stepDepth) {
    betweenBits = (centerpieceWidth(numX)-(bitCount * HexBitCornerWidth))/(bitCount+1);
    bitSpacing =  betweenBits + HexBitCornerWidth;
    difference() {
        cube([centerpieceWidth(numX),stepDepth,height]);
        // center bit
        for (i=[0:bitCount-1]) {
            translate([HexBitCornerWidth/2 + betweenBits + (i*bitSpacing),stepDepth/2,height-HexBitPocketDepth]) rotate([0,0,0]) regularPrism(sides=6, fr=HexBitFaceWidth/2, length=HexBitPocketDepth+1);
        }
    }
}

module bitSteps(numX, numY, stepDepth, stepCount, bitCount) {
    for (i=[0:stepCount-1]) {
        translate([0,0+(i*stepDepth),wc_spacerHeight]) bitStep(numX, HexBitPocketDepth+(HexBitPocketDepth*.5*i), bitCount, stepDepth);
    }
}

module parts() {
    color("grey") sidepiece(numY=sidepiece_yCount,numZ=sidepiece_zCount, type=BRACKET, invert=true, vertical=true, place=[0,-sidepiece_yCount,sidepiece_zCount]);
    color("grey") sidepiece(numY=sidepiece_yCount,numZ=sidepiece_zCount, type=BRACKET, invert=true, side=LEFT, vertical=true, place=[centerpiece_xCount,-sidepiece_yCount,sidepiece_zCount]);
    color("white") spacer(numX=centerpiece_xCount,numY=1, locking=true, vertical=true, place=[0,-sidepiece_yCount,sidepiece_zCount]);
}