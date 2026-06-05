include<./modules.scad>
    

// --------
// - spacer(numX, numY)                                             : a spacer with the given dimensions in wc_pitch units

// example
// spacer(3, 2, locking=true); // creates a 3x2 spacer with locking screw holes

// a spacer / centerpiece
module spacer(numX, numY, numZ=wc_spacerHeight, tabHeight=0, locking=false, customHoles=undef, vertical=false, oneSide=false, place=undef) {
    xPlacement = place == undef ? 0 : place.x * wc_xPitch;
    yPlacement = place == undef ? 0 : place.y * wc_yPitch;
    zPlacement = ( place == undef ? 0 : place.z * wc_zPitch ) - ( vertical ? numY * wc_zPitch : 0 );

    xRotation = (vertical == true ? 90 : 0);

    translate([xPlacement, yPlacement, zPlacement]) {
        rotate([xRotation,0,0]) difference() {
            union() {
                spacerBlock(numX, numY, numZ, oneSide=oneSide);
                translate([0,0,tabHeight]) centerpieceTabs(numX, numY, oneSide=oneSide);
            }
            if (customHoles) {
                customLockingHoles(customHoles);
            } else if (locking==true) {
                lockingHoles(numX, numY);
            }
        }
    }
}

module spacerBlock(numX, numY, numZ, oneSide) {
    totalXmm = centerpieceWidth(numX);
    totalYmm = centerpieceDepth(numY);
    totalZmm = numZ * wc_zPitch;
    if (oneSide) {
        filletR = totalZmm/2;
        hull() {
            cube([EPS, totalYmm, totalZmm]);
            translate([totalXmm-filletR,filletR,0]) fineCylinder(r=filletR, h=totalZmm);
            translate([totalXmm-filletR,totalYmm-filletR,0]) fineCylinder(r=filletR, h=totalZmm);
        }
    } else {
        cube([centerpieceWidth(numX), totalYmm, totalZmm]);
    }
}

module bin(numX, numY, numZ, tabHeight, thickness, inside_filet_radius) {
    filetRadius = inside_filet_radius > 0 ? inside_filet_radius : EPS;
    insideXMM = centerpieceWidth(numX) - (2 * thickness) - (2 * filetRadius); 
    insideYMM = (numY * wc_yPitch) - (3 * thickness) - (2 * filetRadius);
    insideZMM = (numZ * wc_zPitch) - thickness;
    difference() {
        spacer(numX, numY, numZ, tabHeight = tabHeight);
        translate([thickness + filetRadius, thickness + filetRadius, thickness + filetRadius]) minkowski() {
            hull() {
                translate([0, 0, 0]) sphere(r=filetRadius);
                translate([insideXMM, 0, 0]) sphere(r=filetRadius);
                translate([insideXMM, insideYMM, 0]) sphere(r=filetRadius);
                translate([0, insideYMM, 0]) sphere(r=filetRadius);
                translate([0, 0, insideZMM]) sphere(r=filetRadius);
                translate([insideXMM, 0, insideZMM]) sphere(r=filetRadius);
                translate([insideXMM, insideYMM, insideZMM]) sphere(r=filetRadius);
                translate([0, insideYMM, insideZMM]) sphere(r=filetRadius);
            }
        }
        translate([centerpieceWidth(1) / 2 - .25 + (0 * wc_xPitch), -EPS, .5 * wc_yPitch + ((numZ - 1) * wc_yPitch)]) lockCutout();
        translate([centerpieceWidth(1) / 2 - .25 + ((numX-1) * wc_xPitch), -EPS, .5 * wc_yPitch + ((numZ - 1) * wc_yPitch)]) lockCutout();
    }
}

module lockCutout() {
    cutoutRadius = 18 / 2;
    rotate([-90,0,0]) cylinder(r = cutoutRadius, h = wc_yPitch);
}

// generates tabs for left and right of centerpice
module centerpieceTabs(numX, numY, oneSide=false) {
    for(i=[0:numY-1]) {
        if (!oneSide) {
            translate([centerpieceWidth(numX),(i*wc_yPitch)+7.55,0]) tab();
        }
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
    threadLength = inchesToMM(wc_spacerHeight);
    threadPitch = wc_locking_hole_thread_pitch;
    diameter = wc_locking_hole_diameter;
    holeLength = inchesToMM(1);
    // from rcolyer thread library. Fast but still a little chonky for a lot of holes
    translate([0,0,-EPS]) ScrewThread(outer_diam=diameter, height=threadLength, pitch=threadPitch, tooth_angle=31, tolerance=.4, tip_height=0, tooth_height=2, tip_min_fract=0);
    translate([0,0,10+threadLength-2*EPS]) cylinder(d=diameter, h=20, center=true);
}


//difference() {
//rotate([0, 0, -130]) translate([-100, -175, 0]) import("/Users/bzvan/Documents/git/aderusha/DDD-Printable-Wall-Control-System/Accessories/8mm Lock Pin.stl", convexity=3);
//lockingScrew();
//}

module lockingScrew() {
    threadLength = inchesToMM(wc_spacerHeight);
    lockingHoleDiameter = inchesToMM(1/4);
    threadPitch = 2.5;
    diameter = 16.8;
    plate_thickness = 1;
    thread_flattening = 1;
    // from rcolyer thread library. Fast but still a little chonky for a lot of holes
    intersection() {
        difference() {
            translate([0,0,-EPS]) ScrewThread(outer_diam=diameter, height=threadLength, pitch=threadPitch, tooth_angle=31, tolerance=-.4, tip_height=4, tooth_height=2, tip_min_fract=0.75);
            cube(lockingHoleDiameter+.1, center=true);
        }
        cylinder(d=diameter-thread_flattening, h=threadLength);
    }
    translate([0, 0, threadLength+plate_thickness]) hull() {
        translate([0, 0, -lockingHoleDiameter/2]) cylinder(d=lockingHoleDiameter-.1, h=EPS);
        sphere(d=lockingHoleDiameter-.1);
    }
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
        translate([0,depth-width/2,-EPS]) cylinder(r=width/2, h=height + 2*EPS);
        translate([-width/2,-EPS,-EPS]) cube([width,EPS,height + 2*EPS]);
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