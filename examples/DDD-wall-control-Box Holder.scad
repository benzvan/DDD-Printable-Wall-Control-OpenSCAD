$fs = 0.4;
$fa = 1;

include<../src/centerpieces.scad>
include<../src/sidepieces.scad>
include<../src/sidepieces.scad>

default_bin_xCount = 4; // width of bin on wall
default_bin_yCount = 2; // depth of bin
default_bin_zCount = 3; // height of bin

default_bin_thickness = 1;
default_inside_filet_radius = 0;

default_tabs_at_top = true;

default_front_cutout_radius = 10;
default_front_cutout_margin = 10;

// orient for preview image
default_preview = true;

box_holder(
    numX = default_bin_xCount,
    numY = default_bin_yCount,
    numZ = default_bin_zCount,
    bin_thickness = default_bin_thickness,
    inside_filet_radius = default_inside_filet_radius,
    tabs_at_top = default_tabs_at_top,
    front_cutout_radius = default_front_cutout_radius,
    front_cutout_margin = default_front_cutout_margin,
    preview = default_preview,
);

module box_holder(
    numX,
    numY,
    numZ,
    bin_thickness,
    inside_filet_radius,
    tabs_at_top,
    front_cutout_radius,
    front_cutout_margin,
    preview,
) {
    tabHeight = tabs_at_top ? numZ * wc_zPitch - wc_sidepieceTabFromTop - wc_tabHeight: 0;
    rotate([0,0,preview ? 180 : 0]) {
        // renders just the centerpiece
        difference() {
            bin(numX = numX,
                numY = numY,
                numZ = numZ, 
                thickness = bin_thickness,
                tabHeight = tabHeight,
                inside_filet_radius = inside_filet_radius,
                );
            cutoutWidth = centerpieceWidth(numX) - (2 * front_cutout_margin);
            cutoutThickness = bin_thickness + 2 * EPS;
            translate([front_cutout_margin, centerpieceDepth(numY) - cutoutThickness + EPS, front_cutout_margin]) 
            rotate([-90, 0, 0]) 
            translate([0, -front_cutout_radius, 0]) 
            hull() {
                translate([front_cutout_radius, 0, 0]) cylinder(h = cutoutThickness, r = front_cutout_radius);
                translate([cutoutWidth - front_cutout_radius, 0, 0]) cylinder(h=bin_thickness + 2 * EPS, r = front_cutout_radius);
                translate([0, -(numZ * wc_yPitch), 0]) cube([cutoutWidth, EPS, cutoutThickness]);
            }
        }

        // renders full parts list in place
        if (preview) { parts(numX, numY, numZ, !tabs_at_top); }
    }
}

module cutout(size, binsize, radius) {
    rotate([90, 0, 0]) translate([wc_xPitch * (binsize.x - size.x)/2, radius + (binsize.z - size.y) * wc_zPitch + thickness, 0]) hull() {
        translate([radius, 0, 0]) cylinder(h = size.z * wc_zPitch + 2 * thickness, r = 10);
        translate([size.x * wc_xPitch - radius, 0, 0]) cylinder(h = size.z * wc_zPitch + 2 * thickness, r = 10);
        cube([size.x * wc_xPitch, size.y * wc_yPitch - radius, size.z * wc_zPitch + 2 * thickness]);
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