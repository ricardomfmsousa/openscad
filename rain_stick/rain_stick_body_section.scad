include <BOSL2/std.scad>
include <BOSL2/threading.scad>

include <rain_stick_parameters.scad>

module draw_texture(height, outter_diameter) {
  tex = texture("hex_grid", border = .07);
  linear_sweep(circle(d = outter_diameter), texture = tex, h = height,
               tex_size = [ 10, 10 * sqrt(3) ], tex_depth = thikness / 2);
}
module draw_thorns() {
  thorn_angle = 45;
  thorn_step = 4;
  thorn_height = outter_diameter * sin(thorn_angle) + thikness / 2;
  thron_pole_height =
      section_height - thorn_height * sin(thorn_angle) + thikness;
  thorn_pole_diameter = thorn_diammeter * 2;
  z_start = 0;
  z_end = section_height + outter_diameter * sin(thorn_angle) - 10;

  // Center pole
  cylinder(h = thron_pole_height, d = thorn_pole_diameter, center = false);
  // Bottom pole skirt
  cylinder(h = 0.4, d = thorn_pole_diameter * 3, center = false);

  module draw() {
    for (z = [z_start:thorn_step:z_end]) {
      rotate([ 0, 0, z * 360 / 90 ]) {
        translated_z =
            z * sin(thorn_angle); // Adjusting for the rotation in x-axis
        translate([ 0, 0, translated_z ]) {
          rotate([ thorn_angle, 0, 0 ]) {
            cylinder(h = thorn_height, d = thorn_diammeter, center = false);
          }
        }
      }
    }
  }

  difference() {
    draw();
    down(thikness) cyl(h = thikness, d = thorn_pole_diameter, center = false);
  }
}

module draw_shell(height, outter_diameter, inner_diameter, draw_texture) {
  difference() {
    union() {
      // Draw texture/outer tube wall
      up(thread_height) if (draw_texture && enable_texture) {
        draw_texture(height - 2 * thread_height, outter_diameter);
      }
      else {
        cylinder(h = height - 2 * thread_height, d = outter_diameter,
                 center = false);
      }
      // Draw threads
      up(thread_height / 2) threaded_rod(
          d = outter_diameter + thread_pitch, height = thread_height,
          pitch = thread_pitch, $fa = 1, $fs = 1);
      up(section_height - thread_height / 2) threaded_rod(
          d = outter_diameter + thread_pitch, height = thread_height,
          pitch = thread_pitch, $fa = 1, $fs = 1);
    }
    // Draw tube hole
    translate([ 0, 0, -0.01 ])
        cylinder(h = height + 0.02, d = inner_diameter, center = false);
  }
}

module draw_section() {
  difference() {
    draw_thorns();
    draw_shell(section_height, outter_diameter + thikness * 2, outter_diameter,
               false);
  }
  draw_shell(section_height, outter_diameter, outter_diameter - thikness / 2,
             true);
}

module draw_cap() {

  difference() {
    cylinder(thread_height + thikness, d = outter_diameter + thread_pitch,
             center = false);

    up(thread_height - thikness) threaded_rod(
        d = outter_diameter, height = thread_height, blunt_start = false,
        internal = true, bevel = true, pitch = thread_pitch, $fa = 1, $fs = 1,
        orient = TOP, center = false);
  }
}

module main() {
  // draw_section();
#draw_cap();
}

main();