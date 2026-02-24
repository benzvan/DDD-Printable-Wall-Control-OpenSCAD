$fs = 0.4;
$fa = 1;

include<../src/centerpieces.scad>
include<../src/sidepieces.scad>
include<../src/sidepieces.scad>

bin_xCount = 6; // width of bin
bin_yCount = 3; // depth of bin
bin_zCount = 2; // height of bin

sidepiece_yCount = 2;   // height of bracket
sidepiece_zCount = 3;   // depth of bracket

thickness = 1;

tabs_at_top = true;
tabHeight = tabs_at_top ? bin_zCount * wc_zPitch - wc_sidepieceTabFromTop - wc_tabHeight: 0;

preview = true;
// orient for preview image
rotate([0,0,preview ? 180 : 0]) {
    // renders just the sidepiece
    bin(numX = bin_xCount, numY = bin_yCount, numZ = bin_zCount, tabHeight = tabHeight);

    // renders full parts list in place
    if (preview) { parts(); }
}

module bin(numX, numY, numZ, tabHeight) {
    filetRadius = 1;
    insideXMM = centerpieceWidth(numX) - (2 * thickness) - (2 * filetRadius); 
    insideYMM = (numY * wc_yPitch) - (2 * thickness) - (2 * filetRadius);
    insideZMM = (numZ * wc_zPitch) - thickness;
    difference() {
        spacer(numX, numY, numZ, tabHeight = tabHeight);
        translate([thickness + filetRadius, thickness + filetRadius, thickness + filetRadius]) minkowski() {
            cube([insideXMM, insideYMM, insideZMM]);
            sphere(r=filetRadius);
        }
        translate([centerpieceWidth(1) / 2 - .25 + (0 * wc_xPitch), -EPS, .5 * wc_yPitch + ((bin_zCount - 1) * wc_yPitch)]) lockCutout();
        translate([centerpieceWidth(1) / 2 - .25 + (5 * wc_xPitch), -EPS, .5 * wc_yPitch + ((bin_zCount - 1) * wc_yPitch)]) lockCutout();
    }
}

module lockCutout() {
    cutoutRadius = 18 / 2;
    rotate([-90,0,0]) cylinder(r = cutoutRadius, h = wc_yPitch); // 4 EPS is weird here, 2 should work but doesn't. I blame minkowski.
}

module parts() {
    translate([0, 0, -wc_tabHeight - wc_sidepieceTabFromTop]) {
        color("grey") sidepiece(numY=sidepiece_yCount,numZ=sidepiece_zCount, type=BRACKET, vertical=true, place=[-1, 0, bin_zCount]);
        color("grey") sidepiece(numY=sidepiece_yCount,numZ=sidepiece_zCount, type=BRACKET, side=LEFT, vertical=true, place=[bin_xCount + 1 , 0, bin_zCount ]);
    }
    color("white") spacer(numX=bin_xCount,numY=1, locking=true, vertical=true, place=[0,-1, bin_zCount]);
}