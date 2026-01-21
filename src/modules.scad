// Dependencies
// https://github.com/verhas/OpenScad/blob/main/threads.scad // slow, high-element
use <../shapes/threads.scad>

// https://github.com/rcolyer/threads-scad // fast, low-element
use <../../threads-scad/threads.scad>

// wall control has a 1" pitch DDD has a 1" pitch to match
wc_xPitch = inchesToMM(1);
wc_yPitch = inchesToMM(1);
wc_zPitch = inchesToMM(1);

// spacers have different heights and pitch
wc_centerpieceZPitch = inchesToMM(1.65);
wc_spacerHeight = 1/4;

// some cylinders need to be fine to work
wc_fa = 1;
wc_fs = 0.4;

// epsilon minimal size for hull points and overlaps
EPS = .01;

// --------
// Public Modules
// - spacer(numX, numY)                                             : a spacer with the given dimensions in wc_pitch units
// - sidepeice(numX, numY, side="left|right", invert=true|false)    : a standard bracket side 

// spacer(3, 2, locking=true);

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
    // from verhas thread library. May create too many objects.
    // metric_thread(diameter=17, pitch=2.5, length=10, internal=true);

    // from rcolyer thread library. Fast but still a little chonky for a lot of holes
    rotate([180,0,0]) RodStart(diameter=17, thread_len=inchesToMM(1/4), thread_diam=17, thread_pitch=2.5, height=inchesToMM(1));
}


// example
sidepiece(numY=4, numZ=3, invert=false, side="right");

// standard sidepiece/bracket
// numY: distance out from wall
// numZ: distance vertically on wall (will be rendered in x)
module sidepiece(numY, numZ, bracket=true, invert=false, side="right") {
    bracketWidth = inchesToMM(1/4);
    difference() {
        mirror([0,side == "left" ? 1 : 0,0]) union() {
            wallControlHooks(numZ);
            flat(numZ, bracket=bracket);
            if (bracket) {
                bracket(numY, numZ, invert=invert, bracketWidth=bracketWidth);
            }
        }
        sideSlots(numZ);
    }
    
    module bracket(numY, numZ, bracketWidth, invert=false) {
        translate([invert ? 0 : numZ*wc_zPitch,0,0]) mirror([invert ? 0: 1,0,0]) union() {
            difference() {
                linear_extrude(h=bracketWidth) {
                    polygon([
                        [0,0],
                        [0,numY*wc_yPitch],
                        [bracketWidth, numY*wc_yPitch], // the blunt end is square
                        [numZ*wc_zPitch, 0]
                    ]);
                }
                firstSlotPosition = inchesToMM(3/32);
                steps = (numZ*wc_zPitch)/wc_centerpieceZPitch;
                for(i=[0:steps]) { 
                    zPos = firstSlotPosition + (i*wc_centerpieceZPitch);
                    translate([zPos,0,0]) rotate([0,0,90]) sideSlots(numY=numY, numZ=numZ, zPos=zPos, zOffset=bracketWidth);
                }
                for(i=[0:steps]) {
                    zPos = i*wc_centerpieceZPitch+wc_zPitch;
                    translate([zPos,0,0]) bracketHoles(numY=numY, numZ=numZ, zPos=zPos, zOffset=bracketWidth);
                }
            }
            filetRadius=inchesToMM(1/16);
            color("gold") rotate([0,90,0]) translate([-(filetRadius+bracketWidth),filetRadius,0]) rotate([0,0,-90]) internalFilet(r=filetRadius, h=numZ*wc_zPitch);
        }

        module bracketHoles(numY, numZ, zPos, zOffset=0) {
            largeHoleRadius=wc_zPitch/2;
            smallHoleRadius=wc_zPitch/4;
            largeHoleYAtZPos = getYforX(numY, numZ, zPos+largeHoleRadius, zOffset);
            largeHoleMaxY=largeHoleYAtZPos-(wc_zPitch/4);
            smallHoleYAtZPos = getYforX(numY, numZ, zPos+smallHoleRadius, zOffset);
            smallHoleMaxY=smallHoleYAtZPos-(wc_zPitch/4);
            bufferZone = 5;
            bracketHoleFilet = inchesToMM(1/32);

            steps = (numY*wc_yPitch)/wc_centerpieceZPitch;
            for(i=[0:steps-1]) {
                translate([0,wc_yPitch+(i*wc_centerpieceZPitch),0]) {
                    if (wc_zPitch+(i*wc_centerpieceZPitch)+largeHoleRadius+bufferZone < largeHoleMaxY) {
                        bracketHole(r=largeHoleRadius, h=bracketWidth, f=bracketHoleFilet);
                    } else if (wc_zPitch+(i*wc_centerpieceZPitch)+smallHoleRadius+bufferZone < smallHoleMaxY) {
                        translate([-smallHoleRadius,0,0]) bracketHole(r=smallHoleRadius, h=bracketWidth, f=bracketHoleFilet);
                    }
                }
            }
        }

        module bracketHole(r, h, f) {
            module face(r, h, f) {
                fineCylinder(r=r+f, h=EPS);
            }
            module body(r, h, f) {
                fineCylinder(r=r, h=EPS);
            }
            // top filet
            hull() {
                translate([0,0,h+EPS]) face(r, h, f);
                translate([0,0,h-f-EPS]) body(r, h, f);
            }
            // center hole body
            hull() {
                translate([0,0,h]) body(r, h, f);
                translate([0,0,0]) body(r, h, f);
            }
            // bottom filet
            hull() {
                translate([0,0,f+EPS]) body(r, h, f);
                translate([0,0,-EPS]) face(r, h, f);
            }
        }
    }

    module flat(numZ, bracket=true) {
        flatFiletRadius = inchesToMM(1/8);
        flatSlotAllowance = inchesToMM(3/32); // flat needs to be thicker if it isn't a bracket
        flatThickness = inchesToMM(1/4) + ( bracket ? 0 : flatSlotAllowance ); // distance out from wall
        flatWidth = wc_xPitch/2; // two should fit next to each other.
        flatFitSpace = inchesToMM(1/32);

        translate([0, (bracket ? 0 : flatSlotAllowance),0]) rotate([90,0,0]) hull() {
            translate([flatFiletRadius,flatWidth-flatFiletRadius-flatFitSpace,0]) externalFiletCylinder(flatThickness, flatFiletRadius);
            translate([-flatFiletRadius+numZ*wc_xPitch,flatWidth-flatFiletRadius-flatFitSpace,0]) externalFiletCylinder(flatThickness, flatFiletRadius);
            cube([numZ*wc_xPitch,5,flatThickness]);
        }
    }

    // could be a public module in case people want to add them to other objects
    module wallControlHooks(numZ) {
        slotWidth = inchesToMM(3/32)-.3;
        slotThickness = 1.4;
        flatThickness = inchesToMM(1/4);
        
        backOfBoard = flatThickness+slotThickness;
        bottomOfHook = -3.1;
        slotConnectorHeight = 21.6;

        translate([wc_zPitch*(numZ-1),0,0]) wallControlTopHook();
        wallControlBottomHook();

        module wallControlTopHook() {
            topOfHook = 31.8;
             difference() {
                // wall control top hook main geometry (much like botom hook)
                hull() {
                    translate([27.8,-11.6,0]) externalFiletCylinder(slotWidth); // external filet top of hook
                    translate([13.5,-10.6,0]) externalFiletCylinder(slotWidth, r=5); // curve in middle of hook
                    translate([2.2,-7,0]) externalFiletCylinder(slotWidth, r=5); // external filet bottom of hook
                    translate([topOfHook,-backOfBoard,0]) cube([EPS,EPS,slotWidth]); // point at top of hook
                    translate([bottomOfHook,-backOfBoard,0]) cube([EPS,EPS,slotWidth]); // point at bottom of hook
                }
                translate([bottomOfHook,-backOfBoard,-.5]) cube([topOfHook-bottomOfHook,backOfBoard,slotWidth+1]); // cut flat surface behind wall control board
                translate([21.6,-backOfBoard,-.5]) linear_extrude(h=slotWidth+1) { // cut inside insertion hook at top off hook
                    polygon([
                        [0,1],
                        [0,0],
                        [.36,-1.52],
                        [4.3,-.5],
                        [5.7,-.25],
                        [7,-.1],
                        [8,-.05],
                        [9,-.05]
                    ]);
                }
            }
            translate([0,-backOfBoard,0]) cube([slotConnectorHeight,2,slotWidth]); // connection from hook through wall control board
        }

        module wallControlBottomHook() {
            topOfHook = 21.6;
            difference() {
                hull() {
                    translate([17.6,-11.6,0]) externalFiletCylinder(slotWidth); // external filet top of hook
                    translate([13.5,-10.6,0]) externalFiletCylinder(slotWidth, r=5); // curve in middle of hook
                    translate([2.2,-7,0]) externalFiletCylinder(slotWidth, r=5); // external filet bottom of hook
                    translate([topOfHook,-2,0]) cube([EPS,EPS,slotWidth]); // point at top of hook
                    translate([bottomOfHook,-backOfBoard,0]) cube([EPS,EPS,slotWidth]); // point at bottom of hook
                }
                translate([bottomOfHook,-backOfBoard,-.5]) cube([topOfHook-bottomOfHook,backOfBoard,slotWidth+1]); // cut flat surface behind wall control board
            }
            translate([0,-backOfBoard,0]) cube([slotConnectorHeight,2,slotWidth]); // connection from hook through wall control board
        }

    }
}

module sideSlots(numY, numZ=undef, zPos=0, zOffset=0) {
    tabWidth = 9.8;
    tabDepth = 3.9;
    fitSpace = .1;
    bufferZone = 5;
    maxY = is_undef(numZ) ? round(1/0) : getYforX(numY, nz, zPos+tabDepth, zOffset=zOffset);
    firstSlotPosition = 7.6;

    // translate([maxY,-tabDepth,0]) cylinder(h=10, r=1); // uncomment to show calculated edge of triangle

    for(i=[0:numY-1]) {
        yPos = firstSlotPosition+fitSpace+(i*wc_yPitch);
        if (yPos+tabWidth+bufferZone < maxY) {
            translate([yPos,-fitSpace,0]) rotate([0,-90,90]) tab(slot=true, fitSpace=fitSpace);
        }
    }
}

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
module tab(tabDepth = 3.9,
           tabTaper = .5,
           tabHeight = 3.8, // 0.15"
           tabWidth = 9.8,
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