$fa = 1;
$fs = 0.4;

include<./DDDModules.scad> 

baseDepth = 120; // front to back of battery
baseWidth = 81;
baseThickness = 4;

contactInsideWidth = 43;
contactInsideDepth = 48;
contactOutsideWidth = 67;
contactInsideHeight = 12;
contactBottomDepth = 27; // top of back ramp
contactTopDepth = 20;

ryobiDualBatteryHolder();
module ryobiDualBatteryHolder() {
    xCount = 4;
    yCount = 4;
    difference() {
        translate([-wc_xPitch/2+3.9,0,-3]) spacer(xCount,yCount, 7/wc_zPitch, 2);
        translate([4,2*wc_yPitch,-3.5]) cube([centerpieceWidth(3)-1,3*wc_yPitch,8]);
    }
    ryobiBatteryHolder();
    mirror([0,0,1])  ryobiBatteryHolder();
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
                    translate([0,0,railBottomHeight]) cube([railBottomWidth, railTopDepth+railOverhangDepth, 0.001]);
                    translate([0,0,railHeight]) cube([railTopWidth, railTopDepth+railOverhangDepth, 0.001]);
                }
            }
            // rail ramp 1
            translate([railOverhangWidth,railBottomDepth,0]) hull() {
                translate([0,0,railHeight]) cube([railTopWidth, railTopDepth-railBottomDepth+railOverhangDepth, .001]);
                translate([0,railTopDepth-railBottomDepth,0]) cube([railTopWidth, railOverhangDepth, .001]);
            }
            // rail ramp 2 (overhang)
            translate([0,railBottomDepth+railOverhangDepth,0]) hull() {
                translate([0,0,railHeight]) cube([railTopWidth, railTopDepth-railBottomDepth+railOverhangDepth, .001]);
                translate([0,railTopDepth-railBottomDepth,0]) cube([railTopWidth, railOverhangDepth, .001]);
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
            translate([0,clipDepth,0]) cube([clipWidth,.001,clipHeight]);
            translate([0,0,clipHeight]) cube([clipWidth,.001,.001]);
        }
        // ramp
        hull() {
            translate([0,clipGapDepth+clipDepth,clipHeight]) cube([clipWidth,.001,.001]);
            translate([-baseWidth/2 +clipWidth/2,1+clipDepth+frontToClip,clipHeight/2]) cube([baseWidth, .001, clipHeight/2]);
        }
    }
}