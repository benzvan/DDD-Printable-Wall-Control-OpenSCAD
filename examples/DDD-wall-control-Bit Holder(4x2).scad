$fa = 1;
$fs = 0.4;

include<../src/centerpieces.scad>
include<../src/sidepieces.scad>
use<../src/regular-polygon.scad>

HexBitPocketDepth = 8;

bitHolder_xCount = 4;
bitHolder_yCount = 2;
bitHolder_zCount = 3;
bitHolder_bitsPerShelf = 8;

centerpiece_xCount = 4; // width of centerpice
centerpiece_yCount = 2; // depth of centerpiece
sidepiece_yCount = 2;   // height of bracket
sidepiece_zCount = 2;   // depth of bracket

// Clearance for the hex bit holder
TightClearance = 0.1; // pretty good grip.
CasualClearance = 0.15; // not too grippy. Good for static vertical storage like wall control
HexBitClearance = CasualClearance; 


// 1/4" hex shank face to face in mm
HexBitFaceToFaceWidth = 0.25 * 25.4 + HexBitClearance;
// Bit holder tightener diameter in mm
BitTightenerDiameter = 0.45;

// Bit holder tightener length in mm
BitTightenerLength = 5;

BitHolderHeight = 8;
BitHolderDepth = 5;
BitHolderLength = 9;

BitTightenerOffset = (BitHolderHeight - BitTightenerLength) / 2;
HexBitTipToTipWidth = HexBitFaceToFaceWidth / sin(60);


preview = true;
// orient for preview image
// renders just the sidepiece
translate([0, 0, preview ? wc_sidepieceTabFromTop : 0]) bitHolder(bitHolder_xCount, bitHolder_yCount, bitHolder_zCount, bitHolder_bitsPerShelf);

// renders full parts list in place
mirror([0,1,0]) {
    if (preview) { parts(); }
}

module bitHolder(xCount, yCount, stepCount, bitCount) {
    stepDepth = (wc_yPitch * yCount) / stepCount; // front to back
    spacer(xCount, yCount, 1 / wc_zPitch); // super thin just to get the tabs
    bitSteps(xCount, yCount, stepDepth, stepCount, bitCount);
}

module bitStep(numX, height, bitCount, stepDepth) {
    betweenBits = (centerpieceWidth(numX)-(bitCount * HexBitTipToTipWidth))/(bitCount+1);
    bitSpacing =  betweenBits + HexBitTipToTipWidth;
    difference() {
        cube([centerpieceWidth(numX),stepDepth,height]);
        // center bit
        for (i=[0:bitCount-1]) {
            translate([HexBitTipToTipWidth/2 + betweenBits + (i*bitSpacing), stepDepth/2, height - HexBitPocketDepth]) rotate([0,0,0]) bitHole(HexBitFaceToFaceWidth = HexBitFaceToFaceWidth, BitTightenerDiameter = BitTightenerDiameter);
        }
    }
}

module bitSteps(numX, numY, stepDepth, stepCount, bitCount) {
    for (i=[0:stepCount-1]) {
        translate([0,0+(i*stepDepth),wc_spacerHeight]) bitStep(numX, HexBitPocketDepth + (HexBitPocketDepth * i), bitCount, stepDepth);
    }
}

module bitHole(
    HexBitFaceToFaceWidth = 6,
    BitTightenerDiameter = .2,
) {
    translate( [ 0, 0, 0] ) rotate([ 0, 0, 0 ]) difference() {
        cylinder(d = HexBitTipToTipWidth, h = BitHolderLength, $fn = 6);
        translate([0, -HexBitFaceToFaceWidth / 2, BitTightenerOffset]) cylinder(d = BitTightenerDiameter, h = BitTightenerLength);
        translate([0, HexBitFaceToFaceWidth / 2, BitTightenerOffset]) cylinder(d = BitTightenerDiameter, h = BitTightenerLength);
    }
}

module parts() {
    color("grey") sidepiece(numY=sidepiece_yCount,numZ=sidepiece_zCount, type=BRACKET, invert=true, vertical=true, place=[-1, -centerpiece_yCount, sidepiece_yCount]);
    color("grey") sidepiece(numY=sidepiece_yCount,numZ=sidepiece_zCount, type=BRACKET, invert=true, side=LEFT, vertical=true, place=[centerpiece_xCount + 1, -centerpiece_yCount, sidepiece_yCount]);
    color("white") spacer(numX=centerpiece_xCount,numY=1, locking=true, vertical=true, place=[0, -centerpiece_yCount, sidepiece_yCount]);
}