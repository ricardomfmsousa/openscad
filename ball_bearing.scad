include <BOSL2/std.scad>
include <BOSL2/threading.scad>

// sphere_diam = 16;

// tube(h = 20, od = 80, id = 70);

// for (angle = [0:30:360]) {
//   zrot(angle) left(sphere_diam * 2) sphere(d = sphere_diam);
// }

$fn = 200;
sphere_count = 10;       // Total number of spheres
sphere_diameter = 16;    // Diameter of each sphere
spacing_tolerance = 0.3; // Tolerance between spheres
shell_thikness = 2;

// Function to calculate the distance between spheres
function calculate_distance(angle) = (sphere_diameter + spacing_tolerance) /
                                     (2 * sin(180 / sphere_count));

// Generate spheres
for (i = [0:sphere_count - 1]) {
  // Angle for positioning spheres evenly around the z-axis
  angle = i * (360 / sphere_count);
  // Calculate distance between spheres
  distance = calculate_distance(angle);
  // Calculate x and y coordinates based on angle and distance
  x = distance * cos(angle);
  y = distance * sin(angle);
  // Create sphere
  translate([ x, y, 0 ]) sphere(d = sphere_diameter);
}

tube_inner_diameter = calculate_distance(45) * sin(45);

difference() {
  tube(h = sphere_diameter, od = tube_inner_diameter + sphere_diameter / 1.5,
       id = tube_inner_diameter - shell_thikness);
  torus(od = tube_inner_diameter + sphere_diameter * 2,
        id = tube_inner_diameter);
}

#difference() {
tube(h = sphere_diameter,
     od = tube_inner_diameter + sphere_diameter * 2 + spacing_tolerance +
          shell_thikness,
     id = tube_inner_diameter + sphere_diameter * 1.5);
torus(od = tube_inner_diameter + sphere_diameter * 2, id = tube_inner_diameter);
}

color("yellow", 0.2)
    zcyl(h = 100, d = sphere_diameter - shell_thikness + spacing_tolerance);