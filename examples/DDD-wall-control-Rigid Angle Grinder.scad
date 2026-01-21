$fa = 1;
$fs = 0.4;

include<./DDDModules.scad> 

grinderHanger();
module grinderHanger(numX=4, numY=4, mmHeight=30) {
    difference() {
        spacer(numX, numY, 30/wc_zPitch, tabHeight=15);
        translate([centerpieceWidth(numX)/2,0,0]) batteryToolSlot(42, numX*wc_yPitch-40, mmHeight/wc_zPitch);
    }
}