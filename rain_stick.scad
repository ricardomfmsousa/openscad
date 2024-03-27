include <lib/wood_texture.scad>

$fn = $preview ? 50 : 100;
thikness = 2;
outter_diameter = 60;
section_height = 200;
thorn_diammeter = 2.5;

module draw_thorns() {
  thorn_angle = 45;
  thorn_step = 4;
  z_start = 0;
  z_end = section_height + outter_diameter * sin(thorn_angle);
  cylinder(h = section_height, d = thorn_diammeter * 2, center = false);
  for (z = [z_start:thorn_step:z_end]) {
    rotate([ 0, 0, z * 360 / 90 ]) {
      translated_z =
          z * sin(thorn_angle); // Adjusting for the rotation in x-axis
      translate([ 0, 0, translated_z ]) {
        rotate([ thorn_angle, 0, 0 ]) {
          cylinder(h = outter_diameter * sin(thorn_angle), d = thorn_diammeter,
                   center = false);
        }
      }
    }
  }
}

module draw_shell(height, outter_diameter, inner_diameter) {
  difference() {
    cylinder(h = height, d = outter_diameter, center = false);
    translate([ 0, 0, -0.01 ])
        cylinder(h = height + 0.02, d = inner_diameter, center = false);
  }
}

module draw_section() {
  difference() {
    draw_thorns();
    draw_shell(section_height, outter_diameter, outter_diameter * 2);
  }
  draw_thorns();

  draw_shell(section_height, outter_diameter, outter_diameter - thikness);
}

module draw_cap() {}

module main() {
  od = outter_diameter - thikness;
  if ($preview) {
    draw_section();
  } else {
    wood_texture([ od, od, section_height ]) { draw_section(); }
  }
}

main();