$fa = 1;
$fs = 0.4;

include<./DDDModules.scad> 

dualBattery();
module dualBattery() {
    xCount = 4;
    yCount = 3;
    difference() {
        translate([-wc_xPitch/2+3.9,0,-3]) spacer(xCount,yCount, 7/wc_zPitch, 2);
        translate([4,2*wc_yPitch,-3.5]) cube([centerpieceWidth(3)-1,wc_yPitch,8]);
    }
    import("../downloads/DDD Wall Control/3x3 DeWalt 20v+60v battery mount.stl", convexity=3); 
    translate([0,0,1]) mirror([0,0,1]) import("../downloads/DDD Wall Control/3x3 DeWalt 20v+60v battery mount.stl", convexity=3);
}