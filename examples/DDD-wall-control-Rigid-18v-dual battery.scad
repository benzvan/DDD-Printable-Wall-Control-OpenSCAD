$fa = 1;
$fs = 0.4;

include<../src/centerpieces.scad>
include<../src/sidepieces.scad>

baseDepth = 120; // front to back of battery
baseWidth = 81;
baseThickness = 4;

contactInsideWidth = 43;
contactInsideDepth = 48;
contactOutsideWidth = 67;
contactInsideHeight = 12;
contactBottomDepth = 27; // top of back ramp
contactTopDepth = 20;

centerpiece_numX = 4; // width of centerpice
centerpiece_numY = 4; // depth of centerpiece
sidepiece_numY = 4;   // depth of bracket
sidepiece_numZ = 4;   // height of bracket

spacerThickness = wc_spacerHeight;
spacerThicknessMM = wc_zPitch * spacerThickness;
tabOffset = .5; // raise tabs to center on spacer to match top position

preview = true;
parts = true;
printAll = true;
// orient for preview image
rotate([0,0,preview ? 180 : 0]) {
    // renders just the sidepiece
    ryobiDualBatteryHolder(numX=centerpiece_numX, numY=centerpiece_numY, spacerThickness=spacerThickness);

    // renders full parts list in place
    if (parts) { parts(forPrinting = printAll); }
}

module parts(forPrinting) {
    color("grey") sidepiece(numY=sidepiece_numY, numZ=sidepiece_numZ, type=BRACKET, vertical=true, place=[forPrinting ? -1 : 0, 0, 0]);
    color("grey") sidepiece(numY=sidepiece_numY, numZ=sidepiece_numZ, type=BRACKET, side=LEFT, vertical=true, place=[centerpiece_numX + (forPrinting ? 1 : 0), 0, 0]);
    color("white") spacer(numX=centerpiece_numX, numY=2, locking=true, vertical=true, place=[0,0,-1]);
}

module ryobiDualBatteryHolder(numX, numY, spacerThickness) {
    difference() {
        spacer(numX,numY, spacerThickness);
        translate( [ ( centerpiece_numX * wc_xPitch ) / 2 - ( centerpieceWidth( centerpiece_numX - 1 ) ) / 2 , ( centerpiece_numY / 2 ) * wc_yPitch, -EPS ] ) {
            cube( [ centerpieceWidth( centerpiece_numX - 1 ) - 1, 3 * wc_yPitch, spacerThicknessMM + 2* EPS ] );
        }
    }
    translate([ centerpieceWidth( centerpiece_numX ) / 2 - baseWidth / 2, 0, spacerThicknessMM / 2 ] ) {
        ryobiBatteryHolder();
        mirror([0,0,1])  ryobiBatteryHolder();
    }
}

module ryobiBatteryHolder() {
    difference() {
        base();
        clip();
    }
    contactBox();
    rails();
}

module base() {
    cube([baseWidth, baseDepth, baseThickness]);
}

module contactBox() {
    translate([baseWidth/2 - contactInsideWidth/2,0,baseThickness]) cube([contactInsideWidth, contactInsideDepth, contactInsideHeight]);
}

// Rail
/*
                v railTopWidth
               _________
 railHeight -> |      /
               |     /
               |    |
               |    | <- railBottomHeight
               |    |
               ------
                 ^ railBottomWidth

*/

railHeight = contactInsideHeight;
railTopWidth = 9.75; // full depth of rail
railBottomWidth = 7; // battery edge to outside of rail
railBottomHeight = 5.6;
railOverhangDepth = 8;
railOverhangWidth = 3;

railBottomDepth = 57;
railTopDepth = 63;
railPostInsideSeparation = 67;

module rails() {
    translate([0,0,0]) rail();
    translate([2*railBottomWidth+railPostInsideSeparation,0,0]) mirror([1,0,0]) rail();
}

module rail() {
    translate([0,0,baseThickness]) {
        difference() {
            union() {
                // rail post
                cube([railBottomWidth, railTopDepth+railOverhangDepth, railBottomHeight]);
                // rail hook
                hull() {
                    translate([0,0,railBottomHeight]) cube([railBottomWidth, railTopDepth+railOverhangDepth, EPS]);
                    translate([0,0,railHeight]) cube([railTopWidth, railTopDepth+railOverhangDepth, EPS]);
                }
            }
            // rail ramp 1
            translate([railOverhangWidth,railBottomDepth,0]) hull() {
                translate([0,0,railHeight]) cube([railTopWidth, railTopDepth-railBottomDepth+railOverhangDepth, 2*EPS]);
                translate([0,railTopDepth-railBottomDepth,0]) cube([railTopWidth, railOverhangDepth, EPS]);
            }
            // rail ramp 2 (overhang)
            translate([0,railBottomDepth+railOverhangDepth,0]) hull() {
                translate([-EPS,0,railHeight]) cube([railTopWidth, railTopDepth-railBottomDepth+railOverhangDepth, 2*EPS]);
                translate([-EPS,railTopDepth-railBottomDepth,0]) cube([railTopWidth, railOverhangDepth, EPS]);
            }
        }
    }
}

// Clip measurements
contactToClip = 48.5;
frontToClip = 19;
backToClip = 103;
clipWidth = 24;
clipHeight = 5 + .5;
clipDepth = 8; //ish
clipGapDepth = 2; //ish

module clip() {
    translate([baseWidth/2 - clipWidth/2,backToClip-clipDepth,baseThickness-clipHeight]) {
        // clip
        hull() {
            translate([0,clipDepth,0]) cube([clipWidth,EPS,clipHeight+EPS]);
            translate([0,0,clipHeight]) cube([clipWidth,EPS,EPS]);
        }
        // ramp
        hull() {
            translate([0,clipGapDepth+clipDepth,clipHeight]) cube([clipWidth,EPS,EPS]);
            translate([-baseWidth/2 +clipWidth/2,1+clipDepth+frontToClip,clipHeight/2]) cube([baseWidth, EPS, clipHeight/2]);
        }
    }
}