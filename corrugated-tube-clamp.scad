$fn = 50;
diameter = 25;
length = 80;
fillet = 2;
factor = 1.6;

hole_distance = 1.5;
ring_space = diameter * 0.16;

module fillet_box(width, height, length, fillet_radius) {
  fillet_diameter = 2 * fillet_radius;
  module box_wall(width, height) {
    translate([ fillet_radius, 0, fillet_radius ]) hull() {
      rotate([ -90, 0, 0 ])
          cylinder(h = width, r = fillet_radius, center = false);
      translate([ 0, 0, height - fillet_diameter ]) rotate([ -90, 0, 0 ])
          cylinder(h = width, r = fillet_radius, center = false);
    }
  }
  hull() {
    box_wall(length, height);
    translate([ width - fillet_diameter, 0, 0 ]) box_wall(length, height);
  }
}

module screw_pocket() {
  cylinder(h = diameter + fillet * 2, d = 4.5, center = false);
  translate([ 0, 0, diameter * factor * 0.65 ])
      cylinder(h = 3, d = 10, center = false);
}

module half_rings() {
  module half_ring() {
    difference() {
      translate([ diameter / hole_distance, 0, 0 ]) rotate([ -90, 0, 0 ]) {
        difference() {
          cylinder(h = 1, d = diameter, center = false);
          cylinder(h = 1, d = diameter - 1.8, center = false);
        }
      }
      translate([ diameter / hole_distance, 0, -diameter / 1.2 ])
          rotate([ -90, 0, 0 ])
              cylinder(h = 0.9 * 2, d = diameter * 2, center = false);
    }
  }
  for (i = [length / 6:ring_space:length * 5 / 6])
    if (i < length / 2 - ring_space || i > length / 2 + ring_space)
      translate([ 0, i, 0 ]) half_ring();
}

module main() {
  rotate([ 0, 180, 0 ]) union() {
    difference() {
      union() {
        fillet_box(diameter * factor, diameter / factor, length, fillet);
        translate([ 0, 0, -diameter / 2 ])
            cube([ diameter * factor, length, diameter - fillet / 2 ],
                 center = false);
      }
      translate([ diameter / hole_distance, 0, 0 ]) rotate([ -90, 0, 0 ])
          cylinder(h = length, d = diameter, center = false);
      translate([ diameter / 6, 0, -diameter / 2 ])
          cube([ diameter, length, diameter / 2 ], center = false);

      translate([ diameter * factor / 1.17, length / 4, -diameter / 2 ]) {
        screw_pocket();
      }
      translate([ diameter * factor / 1.17, length * 3 / 4, -diameter / 2 ]) {
        screw_pocket();
      }
    }
    half_rings();
  }
}

main();