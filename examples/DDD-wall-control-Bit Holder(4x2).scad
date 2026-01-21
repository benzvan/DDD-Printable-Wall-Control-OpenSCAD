$fa = 1;
$fs = 0.4;

include<../src/modules.scad> 
use<./regular-polygon.scad>

HexBitFaceWidth = 7;
HexBitCornerWidth = 2 * circumradius(HexBitFaceWidth/2, 6);
HexBitClearance = 2;
HexBitPocketDepth = 10;

bitHolder(4, 2, 3, 8);
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