# DDD Printable Wall Control OpenSCAD

This project is an OpenSCAD library for producing the excellent [DDD Wall Control System](https://github.com/aderusha/DDD-Printable-Wall-Control-System) by Alen Derusha.

## Examples
There are a few [examples](examples) to get you started. These files are intended to:
- Provide patterns for usage
- Serve as regression tests
- Make this README look cool

Some of the exmple files are inline here with others in the [examples](examples) directory.
### Bit Holder (4x2)
![Wall Control Bit Holder (4x2)](thumbnails/DDD-wall-control-Bit%20Holder(4x2).png)

### DeWalt 20v Dual Battery (4x4)
![DeWalt 20v Dual Battery (4x4)](thumbnails/DDD-wall-control-DeWalt%20Dual%20Battery(4x4).png)

### Rigid 18v Dual Battery (4x4)
![Rigid 18v Dual Battery (4x4)](thumbnails/DDD-wall-control-Rigid-18v-dual%20battery.png)

## Getting Started
Most users will only need to include `src/centerpieces.scad` or `src/sidepieces.scad` for their project and can ignore the rest.

### Sidepieces/brackets
Sidepeices directly connect to the Wall Control slots.

```
sidepiece(
  numY,                // depth from wall (grid units)
  numZ,                // height on wall (grid units)
  bracket=true,        // include diagonal bracket
  invert=false,        // flip bracket direction
  side="right"         // "left" or "right"
);
```

### Centerpices/spacers
Centerpieces go between sidepeices and can either be tool holders or spacers

#### Basic centerpice/spacer
```
spacer(
  numX,                // width (grid units)
  numY,                // height/depth (grid units)
  numZ=wc_spacerHeight,
  tabHeight=0,         // distance above the bottom of the pice to place the tabs (millimeters)
  locking=false,       // adds threaded locking holes for 8mm locking pins
  customHoles=undef    // optional [[x,y], [x,y]] grid positions
);
```

#### U shape to cut out of centerpice for holding a tool
```
batteryToolSlot(
  width,               // width of slot (millimeters)
  depth,               // depth of slot from front (millimeters)
  numZ                 // height of slot (grid units)
);
```

#### keyhole pegs for mounting things like battery chargers
```
keyholePeg(
  shaftWidth=5.75,     // width of peg shaft
  shaftDepth=4,        // depth of peg shaft
  headDepth=1,         // height of "screw head" at top of shaft 
  headDiameter=10      // diameter of "screw head" at top of shaft
);
```

### Project layout
```
.
 ├── bambu-files
 │   └── Pre-generated .3mf files for printing in Bambu Studio.
 │     These are often also published on MakerWorld.
 ├── examples
 │   └── Example Wall Control accessories built using this library.
 ├── generate-thumbnails.sh
 │   └── Script to generate thumbnails for files in the examples directory.
 ├── README.md
 │   └── You are here.
 ├── resources
 │   ├── DDD Wall Control
 │   │ └── Files imported from Alen Derusha’s Wall Control project.
 │   └── rcolyer
 │       └── threads-scad
 │           └── Git subtree of rcolyer/threads-scad, used for threaded locking centerpieces.
 ├── src
 │   ├── centerpieces.scad
 │   │   └── Include this to create custom centerpieces and spacers.
 │   ├── modules.scad
 │   │   └── Core primitives, constants, and helper functions (tabs, dimensions, utilities).
 │   ├── regular-polygon.scad
 │   │   └── Helper for creating non-round holes (e.g. hex bit holders).
 │   └── sidepieces.scad
 │       └── Include this to create sidepieces and brackets.
 └── thumbnails
     └── Generated thumbnails for example files (used in this and the examples README).
```
## Acknowledgements
- [Wall Control Metal Pegboard System](https://www.wallcontrol.com/)
- OpenSCAD Community Libraries
  - [aderusha/DDD-Printable-Wall-Control-System](https://github.com/aderusha/DDD-Printable-Wall-Control-System) (MIT License)
  - [rcolyer/threads-scad](https://github.com/rcolyer/threads-scad) (CC0 1.0 Universal)