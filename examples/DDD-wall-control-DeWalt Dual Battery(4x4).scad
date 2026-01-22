$fa = 1;
$fs = 0.4;

include<../src/centerpieces.scad>
include<../src/sidepieces.scad>

centerpiece_xCount = 4; // width of centerpice
centerpiece_yCount = 3; // depth of centerpiece
sidepiece_yCount = 4;   // depth of bracket
sidepiece_zCount = 3;   // height of bracket

spacerThickness = wc_spacerHeight+.5/wc_zPitch; // adds .5mm to spacer thickness to cover existing tabs on imported battery mount
tabOffset = .5; // raise tabs to center on spacer to match top position

preview = true;
parts = true;
// orient for preview image
rotate([0,0,preview ? 180 : 0]) {
    // renders just the sidepiece
    dualBattery();

    // renders full parts list in place
    if (preview) { color("grey") translate([0,0,-wc_zPitch*3+wc_bracketWidth]) parts(); }
}

module dualBattery() {
    difference() {
        spacer(centerpiece_xCount, centerpiece_yCount, spacerThickness, tabOffset);
        translate([-centerpieceWidth(3)/2+centerpieceWidth(4)/2,2*wc_yPitch,-3.5]) cube([centerpieceWidth(3)-1,wc_yPitch,8]);
    }
    translate([-3.9-centerpieceWidth(3)/2+centerpieceWidth(4)/2,0,3]) {
        translate([0,0,0]) batteryMount();
        translate([0,0,1]) mirror([0,0,1]) batteryMount();
    }
}

module parts() {
    rotate([0,-90,0]) sidepiece(numY=sidepiece_yCount,numZ=sidepiece_zCount);
    translate([centerpieceWidth(4)+wc_centerpieceFitSpaceY,0,0]) rotate([0,-90,180]) sidepiece(numY=sidepiece_yCount,numZ=sidepiece_zCount, side="left");
    rotate([90,0,0]) spacer(numX=sidepiece_yCount,numY=2, locking=true);
}

module batteryMount() {
    import("../resources/DDD Wall Control/3x3 DeWalt 20v+60v battery mount.stl", convexity=3);
}