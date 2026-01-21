// tools for creating regular pollygons and regular prisms

// public modules

// regularPolygon: creates a polygon with sides=sides and radius to face or to point/corner
// Example to create a hexagon with a radius of 10mm to the corner
// regularPolygon(sides=6, pr=10);
module regularPolygon(
    sides,
    pr = 0,  // point radius // circumradius
    fr = 0, // face radius // apothem
) {
    default_radius = 10;
    r = pr > 0 ? pr : fr > 0 ? (circumradius(fr,sides)) : default_radius;
    circle(r=r, $fn=sides);
}

// regularPrism: creates a prism by extruding regularPolygon by length
// Example to create a nonagonal prism with a radius of 10mm to the face and length of 10mm
// regularPrism(sides=9, fr=10,length=10);
module regularPrism(sides, pr=0, fr=0, length, center = false) {
    linear_extrude(length)
    regularPolygon(sides, pr, fr);
}

function circumradius(apothem, sides) = apothem / (cos(180/sides));

