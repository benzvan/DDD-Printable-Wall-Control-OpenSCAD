// Dependencies
// https://github.com/rcolyer/threads-scad // fast, low-element
use <../resources/rcolyer/threads-scad/threads.scad>

// wall control has a 1" pitch DDD has a 1" pitch to match
wc_xPitch = inchesToMM(1);
wc_yPitch = inchesToMM(1);
wc_zPitch = inchesToMM(1);

// spacers have different heights and pitch
wc_centerpieceZPitch = inchesToMM(1.65);
wc_spacerHeight = 1/4; // inches

// some cylinders need to be fine to work
wc_fa = 1;
wc_fs = 0.4;

wc_tabHeight = 3.9; // 0.15"
wc_tabDepth = 3.9;
wc_tabWidth = 9.8;

// epsilon minimal size for hull points and overlaps
EPS = .01;

module externalFiletCylinder(h=0, r=4) {
    fineCylinder(h=h, r=r);
}

module internalFilet(h, r) {
    difference() {
        cube([r,r,h]);
        fineCylinder(h=h, r=r);
    }
}

module fineCylinder(h, r, fa=wc_fa, fs=wc_fs) {
    cylinder(h=h, r=r, $fa=fa, $fs=fs);
}

// tabs, also used for slots
module tab(tabDepth = wc_tabDepth,
           tabTaper = .5,
           tabHeight = wc_tabHeight,
           tabWidth = wc_tabWidth,
           slot=false,
           fitSpace = 0) {
    fitSpace = slot ? fitSpace : 0;
    noTaper = slot ? 0 : 1;
    translate([0,slot ? -tabWidth : 0,0]) minkowski() {
        hull() {
            cube([tabDepth-tabTaper, tabWidth, tabHeight]);
            translate([tabDepth,noTaper*tabTaper,noTaper*tabTaper]) cube([EPS, tabWidth-(noTaper*2*tabTaper), tabHeight-(noTaper*2*tabTaper)]);
        }
        cube(2*fitSpace, center=true);
    }
}

// --------
// common functions
// --------

// centerpieceWidth calculates the width of a centerpice to fit between two brackets or flats
centerpieceFitSpaceX = 1.2;
function centerpieceWidth(xCount) = (wc_xPitch*xCount)-(centerpieceFitSpaceX*2);

// getYforX calculates the y position at x on a slope defined by numY and numZ for brackets
// zOffset moves the zero of the line on the slope to accomodate a blunt end to the bracket
// numY    = number of grid units in Y
// numZ    = number of grid units in Z
// x       = position to get Y position from in mm
// zOffset = distance from y axis at numZ in mm
function getYforX(numY, numZ, x, zOffset=0) = -(numY/(numZ-(zOffset/wc_zPitch)))*(x-zOffset) + (numY * wc_yPitch);

// wall control is made to match traditional pegboard, so its measurements are in inches
function inchesToMM(inches) = inches * 25.4;
