$fs = 0.4;
$fa = 1;

include<../src/centerpieces.scad>
include<../src/sidepieces.scad>

battery_width = 101;
mount_length = 100;
default_thumb_space = 17; // needed between back of battery and next thing (wall, other battery button, etc)
to_back_of_battery = 30; // needed between the closed end of the rails and the back of the unit
back_block_thickness = 5;

default_numX = 5; // width on wall
default_numY = (mount_length+to_back_of_battery + centerpieceFitSpaceX)/wc_zPitch; // distance out from wall
default_numZ = ((default_thumb_space)/wc_yPitch); // height on wall

rail_inside_width =  53.8; // 53 measured
rail_top_width = 10.5;
rail_total_height = 11.8;
rail_middle_width = 5;
rail_outside_width = rail_inside_width + 2 * rail_top_width;
rail_bottom_height = 5.5;

wall_block_thickness = 5;

lock_top = 89.5; // z
lock_height = 8; // z
lock_depth = 5; // y
lock_width = 32; // x
    
// orient for preview image
default_preview = true;

battery_holder(
    numX = default_numX,
    numY = default_numY,
    numZ = default_numZ,
    thumb_space = default_thumb_space,
    to_back_of_battery = to_back_of_battery,
    preview = default_preview,
);

module battery_holder(
    numX,
    numY,
    numZ,
    thumb_space,
    to_back_of_battery,
    preview,
) {
    rotate([0, 0, preview ? 180 : 0]) {
        translate([preview ? numX * wc_xPitch/2 : 0, 0, preview ? 3.5 * wc_zPitch + 2 : 0]) rotate([preview ? -90 : 0, 0, preview ? 0 : 0]) {
            dual_mount(thumb_space = thumb_space);
        }

        // renders full parts list in place
        if (preview) { parts(numX, numY, 4, false); }
    }
}

module parts(numX, numY, numZ, invert_sidepieces) {
    translate([0, 0, -wc_tabHeight - wc_sidepieceTabFromTop]) {
        color("grey") sidepiece(numY=numZ,numZ=numY, type=BRACKET, invert=invert_sidepieces, vertical=true, place=[-1, 0, numZ]);
        color("grey") sidepiece(numY=numZ,numZ=numY, type=BRACKET, invert=invert_sidepieces, side=LEFT, vertical=true, place=[numX + 1 , 0, numZ ]);
    }
    color("white") spacer(numX=numX,numY=2, locking=true, vertical=true, place=[0,-1, numZ - 1]);
    color("pink") translate([centerpieceWidth(1) / 2 - .25 + (0 * wc_xPitch), -wc_zPitch/2, .5 * wc_yPitch + ((numZ - 3) * wc_yPitch)]) rotate([90, 0, 0]) lockingScrew();
    color("pink") translate([centerpieceWidth(1) / 2 - .25 + ((numX-1) * wc_xPitch), -wc_zPitch/2, .5 * wc_yPitch + ((numZ - 3) * wc_yPitch)]) rotate([90, 0, 0]) lockingScrew();
}

module dual_mount(
    thumb_space = default_thumb_space
) {
    tabHeight = (thumb_space - wc_tabHeight);
    difference() {
        union() {
            translate([-(default_numX * wc_xPitch)/2, (default_numZ * wc_zPitch)/2, 0]) rotate([90, 0, 0]) spacer(default_numX, default_numY, default_numZ, tabHeight = tabHeight);
            translate([0, thumb_space/2, 0]) mount();
            mirror([0, 1, 0]) translate([0, thumb_space/2, 0]) mount();
        }
        //triangles();
    }
}

module triangles() {
    space = 9;
    radius = 1;
    mirror([1, 0, 0]) translate([ (rail_outside_width/2) + 2*centerpieceFitSpaceX, 0, -EPS]) linear_extrude(mount_length + to_back_of_battery + 10) {
        triangle(radius, space - 6);
        translate([0, 6 * radius, 0]) rotate([0, 0, 60]) triangle(radius, space);
        translate([0, -6 * radius, 0]) rotate([0, 0, -60]) triangle(radius, space);
    }
    translate([ (rail_outside_width/2), 0, -EPS]) linear_extrude(mount_length + to_back_of_battery + 10) {
        triangle(radius, space - 6);
        translate([0, 6 * radius, 0]) rotate([0, 0, 60]) triangle(radius, space);
        translate([0, -6 * radius, 0]) rotate([0, 0, -60]) triangle(radius, space);
    }
}

module triangle (radius, space) {
        hull() {
            circle(r = radius);
            rotate([0, 0, 30]) translate([centerpieceWidth(default_numX)/2 - rail_outside_width/2 - radius - space, 0]) circle(r = radius);
            rotate([0, 0, -30]) translate([centerpieceWidth(default_numX)/2 - rail_outside_width/2 - radius - space, 0]) circle(r = radius);
        }
}

module mount() {
    mount_width = centerpieceWidth(default_numX);
    // back
    translate([0, 0, to_back_of_battery]) {
        difference() {
            // back block
            translate([-centerpieceWidth(default_numX)/2 - centerpieceFitSpaceX, 0, -to_back_of_battery]) cube([centerpieceWidth(default_numX), back_block_thickness, mount_length + to_back_of_battery]);

            // lock and ramp
            translate([-lock_width/2, -EPS, lock_top - lock_height]) {
                cube([lock_width, back_block_thickness + 3 * EPS, lock_height]);
                translate([0, 0, lock_height]) hull () {
                    translate([0, lock_depth + EPS, 0]) cube([lock_width, EPS, EPS]);
                    translate([0, 0, mount_length - lock_top]) cube([lock_width, lock_depth + 2*EPS, EPS]);
                }
            }
        }
        // rail end
        wall_block_width = back_block_thickness + rail_total_height;
        // rails
        translate([-centerpieceFitSpaceX, back_block_thickness - EPS, 0]) rails(mount_length);
        // style
        difference() {
            hull () { 
                translate([-rail_outside_width/2 - centerpieceFitSpaceX, rail_total_height + back_block_thickness, 0]) cube([rail_outside_width, EPS, mount_length]);
                translate([-mount_width/2 - centerpieceFitSpaceX, back_block_thickness, -to_back_of_battery]) cube([mount_width, EPS, mount_length + to_back_of_battery]);
            }
            translate([-rail_outside_width/2 - centerpieceFitSpaceX, back_block_thickness - 5, 0]) cube([rail_outside_width, rail_total_height + 10, mount_length + EPS]);
        }
    }
}

module rails(length) {
    rail_inside_width =  53.8; // 53 measured
    translate([-rail_inside_width/2, 0, 0]) rail(length);
    translate([rail_inside_width/2, 0, 0]) mirror([1,0,0]) rail(length);
}

module rail(length) {
    difference() {
        linear_extrude(length) rail_profile();
        translate([0, 0, length-25]) rotate([0, -15, 0]) cube([12, 12, 30]);
    }
}

module rail_profile() {
    /*

                         top width
                       _______
                      |       |  <- rail inside
                      |       |  
    total height      |    ____  middle width
                      |   |
                      |   |   bottom height
                      _____

    */

    translate([-rail_top_width,0,0]) difference() {
        square([rail_top_width, rail_total_height]);
        translate([rail_top_width - rail_middle_width, -EPS]) square([rail_middle_width + EPS, rail_bottom_height + EPS]);
    }


}