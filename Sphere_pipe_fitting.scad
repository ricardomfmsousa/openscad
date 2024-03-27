$fn = 16; // Set the resolution of the sphere

fitting_diameter = 3;

sphere_diameter = fitting_diameter * 6;

module draw_cylinders() {
  $fn = 100;
  chanfer_diameter = fitting_diameter * 1.5;
  for (z_angle = [0:45:135]) {
    rotate([ 0, 0, z_angle ]) for (x_angle = [0:45:135]) {
      rotate([ 0, x_angle, 0 ]) {
        cylinder(h = sphere_diameter, d = fitting_diameter, center = true);
        for (edge = [ -1, 1 ])
          translate([ 0, 0, edge * sphere_diameter / 1.8 ])
              sphere(d = chanfer_diameter);
      }
    }
  }
}

difference() {
  rotate([ 0, 0, 360 / ($fn * 2) ]) sphere(d = sphere_diameter);
  draw_cylinders();
  color("red") sphere(d = fitting_diameter * 3);
}