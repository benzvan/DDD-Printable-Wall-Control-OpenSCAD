include<./modules.scad>

wc_sidepieceTabFromTop = inchesToMM(3/32);
wc_bracketWidth = inchesToMM(1/4);

// example
//sidepiece(numY=4, numZ=4, invert=true, side="right");

// standard sidepiece/bracket
// numY: distance out from wall
// numZ: distance vertically on wall (will be rendered in x)
module sidepiece(numY, numZ, bracket=true, invert=false, side="right", bracketWidth=wc_bracketWidth) {
    mirror([0,side == "left" ? 1 : 0,0]) {
        difference() {
            union() {
                wallControlHooks(numZ);
                flat(numZ, bracket=bracket);
                if (bracket) {
                    bracket(numY, numZ, invert=invert, bracketWidth=bracketWidth);
                }
            }
            sideSlots(numZ);
        }
    }
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
            firstSlotPosition = wc_sidepieceTabFromTop;
            steps = (numZ*wc_zPitch)/wc_centerpieceZPitch;
            for(i=[0:steps-1]) { 
                zPos = firstSlotPosition + (i*wc_centerpieceZPitch);
                translate([zPos,0,0]) rotate([0,0,90]) sideSlots(numY=numY, numZ=numZ, zPos=zPos, zOffset=bracketWidth);
            }
            for(i=[0:steps-1]) {
                zPos = i*wc_centerpieceZPitch+wc_zPitch;
                translate([zPos,0,0]) bracketHoles(numY=numY, numZ=numZ, zPos=zPos, zOffset=bracketWidth);
            }
        }
        filetRadius=inchesToMM(1/16);
        color("gold") rotate([0,90,0]) translate([-(filetRadius+bracketWidth),filetRadius,0]) rotate([0,0,-90]) internalFilet(r=filetRadius, h=numZ*wc_zPitch);
    }

    module bracketHoles(numY, numZ, zPos, zOffset=0) { // Z is rendered in X
        // TODO: DRY this up and make it easier to read
        holePitch = wc_centerpieceZPitch;
        firstHoleCenterOffsetY = wc_yPitch;
        
        largeHoleRadius = wc_zPitch/2;
        largeHoleMaxZPos = holeMaxZPos(largeHoleRadius);
        largeHoleYAtZPos = getYforX(numY, numZ, zPos+largeHoleMaxZPos, zOffset);
        largeHoleMaxYPos = holeMaxYPos(largeHoleRadius);

        smallHoleRadius = wc_zPitch/4;
        smallHoleMaxZPos = holeMaxZPos(smallHoleRadius);
        smallHoleYAtZPos = getYforX(numY, numZ, zPos+smallHoleMaxZPos, zOffset);
        smallHoleMaxYPos = holeMaxYPos(smallHoleRadius);

        extraSmallHoleRadius = wc_zPitch/8;
        extraSmallHoleMaxZPos = holeMaxZPos(extraSmallHoleRadius);
        extraSmallHoleYAtZPos = getYforX(numY, numZ, zPos+extraSmallHoleMaxZPos, zOffset);
        extraSmallHoleMaxYPos = holeMaxYPos(extraSmallHoleRadius);

        bufferZone = 0;
        bracketHoleFilet = inchesToMM(1/32);

        // Holes are placed at the top (z) of a zPitch strip
        // function moves the center down by one hole radius to index on the top of the hole, 
        // then up by 1/2 pitch to move it to the top of the strip
        function holeCenterOffsetZ(holeR) = holeR - wc_zPitch/2;
        function holeMaxZPos(holeR) = holeCenterOffsetZ(holeR) + holeR;
        // holes are placed in the center of their holePitch front-to-back
        function holeCenterOffsetY(holeR) = 0;
        function holeMaxYPos(holeR) = holeCenterOffsetY(holeR) + holeR;

        debug = false;
        if (debug == true) {
            #translate([holeCenterOffsetZ(largeHoleRadius) + largeHoleRadius,largeHoleYAtZPos,0]) fineCylinder(h=20, r=1);
            #translate([holeCenterOffsetZ(smallHoleRadius) + smallHoleRadius,smallHoleYAtZPos,0]) fineCylinder(h=15, r=1);
            #translate([holeCenterOffsetZ(extraSmallHoleRadius) + extraSmallHoleRadius,extraSmallHoleYAtZPos,0]) fineCylinder(h=10, r=1);
        }

        steps = ((numY*wc_yPitch)/wc_centerpieceZPitch);
        for(i=[0:steps-1]) {
            originalHoleCenter = [0,firstHoleCenterOffsetY+(i*holePitch)];
            translate([0,originalHoleCenter.y,0]) {
                if ( originalHoleCenter.y + largeHoleMaxYPos < largeHoleYAtZPos ) {
                    translate([holeCenterOffsetZ(largeHoleRadius),0,0]) bracketHole(r=largeHoleRadius, h=bracketWidth, f=bracketHoleFilet);
                } else if ( originalHoleCenter.y + smallHoleMaxYPos < smallHoleYAtZPos ) {
                    translate([holeCenterOffsetZ(smallHoleRadius),0,0]) bracketHole(r=smallHoleRadius, h=bracketWidth, f=bracketHoleFilet);
                } else if ( originalHoleCenter.y + extraSmallHoleMaxYPos < extraSmallHoleYAtZPos ) {
                    translate([holeCenterOffsetZ(extraSmallHoleRadius),0,0]) bracketHole(r=extraSmallHoleRadius, h=bracketWidth, f=bracketHoleFilet);
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

    translate([wc_zPitch*(numZ-1),0,0]) wallControlTopHook(slotWidth, bottomOfHook, backOfBoard, slotConnectorHeight);
    wallControlBottomHook(slotWidth, bottomOfHook, backOfBoard, slotConnectorHeight);
}

module wallControlTopHook(slotWidth, bottomOfHook, backOfBoard, slotConnectorHeight) {
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

module wallControlBottomHook(slotWidth, bottomOfHook, backOfBoard, slotConnectorHeight) {
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

module sideSlots(numY, numZ=undef, zPos=0, zOffset=0) {
    fitSpace = .1;
    bufferZone = 5;
    maxY = is_undef(numZ) ? round(1/0) : getYforX(numY, numZ, zPos+wc_tabDepth, zOffset=zOffset);
    firstSlotPosition = 7.6;

    // translate([maxY,-wc_tabDepth,0]) cylinder(h=10, r=1); // uncomment to show calculated edge of triangle

    for(i=[0:numY-1]) {
        yPos = firstSlotPosition+fitSpace+(i*wc_yPitch);
        if (yPos+wc_tabWidth+bufferZone < maxY) {
            translate([yPos,-fitSpace,0]) rotate([0,-90,90]) tab(slot=true, fitSpace=fitSpace);
        }
    }
}
