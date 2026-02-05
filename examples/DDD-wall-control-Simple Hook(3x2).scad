$fa = 1;
$fs = 0.4;

include<../src/centerpieces.scad>
include<../src/sidepieces.scad>

hookHeight = 3;
hookDepth = 2;

preview=true;
rotateForPreview = preview ? -90 : 0;

rotate([0,0,rotateForPreview]) {
    sidepiece(numY = hookDepth, numZ = hookHeight, type=UHOOK, vertical=preview);
    if (preview) {
        rotate([0,0,0]) spacer(numX=1, numY = hookHeight, locking=true, oneSide=true, vertical=preview, place=[1,0,hookHeight]);
    }
}