include<./modules.scad>

// --------
// - spacer(numX, numY)                                             : a spacer with the given dimensions in wc_pitch units

// example
// spacer(3, 2, locking=true); // creates a 3x2 spacer with locking screw holes
spacer(1,1, locking=true);

// a spacer / centerpiece
module spacer(numX, numY, numZ=wc_spacerHeight, tabHeight=0, locking=false, customHoles=undef) {
    centerpieceFitSpaceY = 0.2;
    difference() {
        union() {
            cube([centerpieceWidth(numX), numY*wc_yPitch-centerpieceFitSpaceY, numZ*wc_zPitch]);
            translate([0,0,tabHeight]) centerpieceTabs(numX, numY);
        }
        if (customHoles) {
            customLockingHoles(customHoles);
        } else if (locking==true) {
            lockingHoles(numX, numY);
        }
    }

    module centerpieceTabs(numX, numY) {
        for(i=[0:numY-1]) {
            translate([centerpieceWidth(numX),(i*wc_yPitch)+7.55,0]) tab();
            translate([0,(i*wc_yPitch)+7.55,0]) mirror([1,0,0]) tab();
        }
    }
}

// creates a grid numX by numY
module lockingHoles(numX, numY) {
    for(x=[0:numX-1]) {
        for(y=[0:numY-1]) {
            translate([centerpieceWidth(1)/2-.25+x*wc_xPitch,.5*wc_yPitch+y*wc_yPitch,inchesToMM(1)+inchesToMM(1/4)-EPS])  lockingHole();
        }
    }
}

module customLockingHoles(customHoles) {
    for(i=[0:len(customHoles)-1]) {
        hole = customHoles[i];
        translate([centerpieceWidth(1)/2-.25+hole.x*wc_xPitch,.5*wc_yPitch+hole.y*wc_yPitch,inchesToMM(1)+inchesToMM(1/4)-EPS])  lockingHole();
    }
}

// threaded holes for inserting 8mm lock pins
module lockingHole() {
    // from rcolyer thread library. Fast but still a little chonky for a lot of holes
    rotate([180,0,0]) RodStart(diameter=17, thread_len=inchesToMM(1/4), thread_diam=17, thread_pitch=2.5, height=inchesToMM(1));
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