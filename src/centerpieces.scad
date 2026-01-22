include<./modules.scad>
    
wc_centerpieceFitSpaceY = 0.2;

// --------
// - spacer(numX, numY)                                             : a spacer with the given dimensions in wc_pitch units

// example
// spacer(3, 2, locking=true); // creates a 3x2 spacer with locking screw holes

// a spacer / centerpiece
module spacer(numX, numY, numZ=wc_spacerHeight, tabHeight=0, locking=false, customHoles=undef, vertical=false, place=undef) {
    xPlacement = place == undef ? 0 : place.x * wc_xPitch;
    yPlacement = place == undef ? 0 : place.y * wc_yPitch;
    zPlacement = ( place == undef ? 0 : place.z * wc_zPitch ) - ( vertical ? numY * wc_zPitch : 0 );

    xRotation = (vertical == true ? 90 : 0);

    translate([xPlacement, yPlacement, zPlacement]) {
        rotate([xRotation,0,0]) difference() {
            union() {
                cube([centerpieceWidth(numX), numY*wc_yPitch-wc_centerpieceFitSpaceY, numZ*wc_zPitch]);
                translate([0,0,tabHeight]) centerpieceTabs(numX, numY);
            }
            if (customHoles) {
                customLockingHoles(customHoles);
            } else if (locking==true) {
                lockingHoles(numX, numY);
            }
        }
    }
}

// generates tabs for left and right of centerpice
module centerpieceTabs(numX, numY) {
    for(i=[0:numY-1]) {
        translate([centerpieceWidth(numX),(i*wc_yPitch)+7.55,0]) tab();
        translate([0,(i*wc_yPitch)+7.55,0]) mirror([1,0,0]) tab();
    }
}

// creates a grid numX by numY
module lockingHoles(numX, numY) {
    for(x=[0:numX-1]) {
        for(y=[0:numY-1]) {
            translate([centerpieceWidth(1)/2+x*wc_xPitch,.5*wc_yPitch+y*wc_yPitch,0]) lockingHole();
        }
    }
}

module customLockingHoles(customHoles) {
    for(i=[0:len(customHoles)-1]) {
        hole = customHoles[i];
        translate([centerpieceWidth(1)/2-.25+hole.x*wc_xPitch,.5*wc_yPitch+hole.y*wc_yPitch,0]) lockingHole();
    }
}

// threaded holes for inserting 8mm lock pins
module lockingHole() {
    threadLength = inchesToMM(1/4);
    threadPitch = 2.5;
    diameter=17.4;
    holeLength = inchesToMM(1);
    // from rcolyer thread library. Fast but still a little chonky for a lot of holes
    //translate([0,0,holeLength+threadLength-EPS]) rotate([180,0,0]) RodStart(diameter=diameter, thread_len=threadLength, thread_diam=diameter, thread_pitch=threadPitch, height=inchesToMM(1));
    translate([0,0,-EPS]) ScrewThread(outer_diam=diameter, height=threadLength, pitch=threadPitch, tooth_angle=31, tolerance=.4, tip_height=0, tooth_height=2, tip_min_fract=0);
    translate([0,0,10+threadLength-2*EPS]) cylinder(d=diameter, h=20, center=true);
}

// --------
// parts for building complex centerpieces
// --------

// modules for cutting out a battery handle tool slot
module batteryToolSlot(width, depth, numZ) {
    // TODO use extrusions to get bevels.
    height = numZ * wc_zPitch;
    bevel = 5;
    hull() {
        translate([0,depth-width/2,0]) cylinder(r=width/2, h=height);
        translate([-width/2,0,0]) cube([width,EPS,height]);
    }
    translate([-width/2,0,height]) rotate([-90,0,0]) linear_extrude(depth-width/2) batteryToolSlotBevel(numZ=numZ, bevel=5);
    translate([width/2,0,height]) rotate([-90,0,0]) linear_extrude(depth-width/2) batteryToolSlotBevel(numZ=numZ, bevel=5);
    translate([-width/2,-height,0]) linear_extrude(depth-width/2) batteryToolSlotBevel(numZ=numZ, bevel=5);
    translate([width/2,-height,0]) linear_extrude(depth-width/2) batteryToolSlotBevel(numZ=numZ, bevel=5);
    translate([0,depth-width/2,0]) rotate_extrude(180) translate([width/2,0,0]) batteryToolSlotBevel(numZ=numZ, bevel=5);

    module batteryToolSlotProfile(numZ, bevel) {
        square([EPS,numZ*wc_zPitch]);
    }

    module batteryToolSlotBevel(numZ, bevel) {
        union() {
            translate([0,-5*sqrt(2)/2]) rotate(45) square(bevel);
            translate([0,(numZ*wc_zPitch) - 5*sqrt(2)/2]) rotate(45) square(bevel);
        }
    }
}

// keyhole pegs for things that mount to walls via screw or nail with keyhole slots on the back
module keyholePeg(shaftWidth=5.75, shaftDepth=4, headDepth=1, headDiameter=10) {
    translate([0,headDiameter/2,0]) {
        intersection() {
            cylinder(h=shaftDepth, d=headDiameter);
            hull() {
                cylinder(h=shaftDepth, d=shaftWidth);
                translate([0,-headDiameter/2,0]) cylinder(h=shaftDepth, d=shaftWidth);
            }
        }
        hull() {
            translate([0,0,shaftDepth]) cylinder(h=headDepth, d=headDiameter);
            translate([0,0,shaftDepth-.5]) cylinder(h=EPS, d=shaftWidth);
        }
    }
}