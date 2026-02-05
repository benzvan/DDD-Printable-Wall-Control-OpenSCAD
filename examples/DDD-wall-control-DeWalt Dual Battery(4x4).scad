$fa = 1;
$fs = 0.4;

include<../src/centerpieces.scad>
include<../src/sidepieces.scad>

centerpiece_xCount = 4; // width of centerpice
centerpiece_yCount = 3; // depth of centerpiece
sidepiece_yCount = 4;   // depth of bracket
sidepiece_zCount = 4;   // height of bracket

spacerThickness = wc_spacerHeight+.5/wc_zPitch; // adds .5mm to spacer thickness to cover existing tabs on imported battery mount
tabOffset = .5; // raise tabs to center on spacer to match top position

preview = true;
parts = true;
// orient for preview image
rotate([0,0,preview ? 180 : 0]) {
    // renders just the sidepiece
    dualBattery();

    // renders full parts list in place
    if (preview) { parts(); }
}

module dualBattery() {
    difference() {
        spacer(numX=centerpiece_xCount, numY=centerpiece_yCount, numZ=spacerThickness, tabOffset);
        translate([(-(centerpieceWidth(3)-1)/2+(centerpieceWidth(4)/2)),2*wc_yPitch,-EPS]) cube([centerpieceWidth(3)-1,wc_yPitch,spacerThickness*wc_zPitch+2*EPS]);
    }
    translate([-3.9-centerpieceWidth(3)/2+centerpieceWidth(4)/2,0,3]) {
        translate([0,0,0]) batteryMount();
        translate([0,0,1]) mirror([0,0,1]) batteryMount();
    }
}

module parts() {
    color("grey") sidepiece(numY=sidepiece_yCount,numZ=sidepiece_zCount, type=BRACKET, vertical=true, place=[0,-1,0]);
    color("grey") sidepiece(numY=sidepiece_yCount,numZ=sidepiece_zCount, type=BRACKET, side=LEFT, vertical=true, place=[4,-1,0]);
    color("white") spacer(numX=centerpiece_xCount,numY=2, locking=true, vertical=true, place=[0,-1,-1]);
}

module batteryMount() {
    import("../resources/DDD Wall Control/3x3 DeWalt 20v+60v battery mount.stl", convexity=3);
}