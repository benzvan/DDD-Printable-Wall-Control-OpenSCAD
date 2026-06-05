$fs = 0.4;
$fa = 1;

include<../src/centerpieces.scad>
include<../src/sidepieces.scad>
include<../src/sidepieces.scad>

default_bin_xCount = 2; // width of bin
default_bin_yCount = 2; // depth of bin
default_bin_zCount = 3; // height of bin

default_bin_thickness = 1;
default_inside_filet_radius = 1;

default_tabs_at_top = true;

default_preview = true; // arranges all necessary parts for preview or printing

wallControlBin(
    bin_xCount = default_bin_xCount,
    bin_yCount = default_bin_yCount,
    bin_zCount = default_bin_zCount,
    bin_thickness = default_bin_thickness,
    inside_filet_radius = default_inside_filet_radius,
    tabs_at_top = default_tabs_at_top,
    preview = default_preview
);

module wallControlBin(
    bin_xCount, // width of bin (horizontal on wall control)
    bin_yCount, // depth of bin (from wall control surface outward)
    bin_zCount, // height of bin (vertical on wall conrol)
    bin_thickness, // thickness of walls of bin
    inside_filet_radius, // rounding radius inside the bin
    tabs_at_top, // tabs at the top true or bottom false
    preview, // prints in preview orientation for preview image in README
) {
    tabHeight = tabs_at_top ? bin_zCount * wc_zPitch - wc_sidepieceTabFromTop - wc_tabHeight: 0;

    // orient for preview image
    rotate([0,0,preview ? 180 : 0]) {
        // renders just the centerpiece
        bin(numX = bin_xCount, numY = bin_yCount, numZ = bin_zCount, tabHeight = tabHeight, bin_thickness, inside_filet_radius);

        // renders full parts list in place
        if (preview) { parts(bin_xCount, bin_yCount, bin_zCount, !tabs_at_top); }
    }
}

module parts(numX, numY, numZ, invert_sidepieces) {
    translate([0, 0, -wc_tabHeight - wc_sidepieceTabFromTop]) {
        color("grey") sidepiece(numY=numZ,numZ=numY, type=BRACKET, invert=invert_sidepieces, vertical=true, place=[-1, 0, numZ]);
        color("grey") sidepiece(numY=numZ,numZ=numY, type=BRACKET, invert=invert_sidepieces, side=LEFT, vertical=true, place=[numX + 1 , 0, numZ ]);
    }
    color("white") spacer(numX=numX,numY=1, locking=true, vertical=true, place=[0,-1, numZ]);
    color("pink") translate([centerpieceWidth(1) / 2 - .25 + (0 * wc_xPitch), -wc_zPitch/2, .5 * wc_yPitch + ((numZ - 1) * wc_yPitch)]) rotate([90, 0, 0]) lockingScrew();
    color("pink") translate([centerpieceWidth(1) / 2 - .25 + ((numX-1) * wc_xPitch), -wc_zPitch/2, .5 * wc_yPitch + ((numZ - 1) * wc_yPitch)]) rotate([90, 0, 0]) lockingScrew();
}