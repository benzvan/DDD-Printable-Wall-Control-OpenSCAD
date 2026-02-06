$fa = 1;
$fs = 0.4;

include<../src/centerpieces.scad>
include<../src/sidepieces.scad>

guideHeight = 1;
guideDepth = 1;

preview=true;
rotateForPreview = preview ? -90 : 0;

rotate([0,0,rotateForPreview]) {
    sidepiece(numY = guideDepth, numZ = guideHeight, type=CABLE_GUIDE, vertical=preview);
    if (preview) {
        spacer(numX=1, numY = guideHeight, locking=true, oneSide=true, vertical=preview, place=[1,0,guideHeight]);
    }
}