// Based on the info from https://www.domerama.com/calculators/

DEBUG = false;

$fn = 8;
dome_frequency = "1V";  // [1V, 2V, 3V3/8, 5V Mexican]
hub_body_type = "pipe"; // [pipe, solid]
hub_min_thikness = 2;
strut_diameter = 16.05;
screw_holde_diameter = 3;

/* [Hidden] */
font_size = (strut_diameter + hub_min_thikness) / 1.5;
hub_diameter = strut_diameter * 5;
hub_radius = hub_diameter / 2;
strut_radius = strut_diameter / 2;
render_all_spacing = strut_diameter * 8;
// Strut socket angles
freq_1V_strut_angles = [[ "A", 31.72 ]];
freq_2V_strut_angles = [ [ "A", 15.86 ], [ "B", 18 ] ];
freq_3V_3_8_strut_angles = [ [ "A", 10.04 ], [ "B", 11.64 ], [ "C", 11.90 ] ];
freq_5V_mexican_strut_angles =
    [ [ "A", 12.6 ], [ "B", 12.4 ], [ "C", 11.7 ], [ "D", 10.6 ], [ "E", 9 ] ];

// clang-format off
/* [1V] */
render_1V = "all";// [all, penth, quad]
/* [2V] */
render_2V = "all";// [all, hex, penth, quad_left, quad_right]
/* [3V3/8] */
render_3V_3_8 = "all";// [all, hex1, hex2, penth, quad_left, quad_center, quad_right]
/* [5V Mexican] */
render_5V_mexican = "all";// [all, hex1, hex2, hex3, hex4, full_quad, half_quad1_left, half_quad1_right, half_quad2_left, half_quad2_right, tri]
// clang-format on

// Returns all angles from the frequecy_angles structure in a new array
function get_strut_angles(frequecy_angles) = [for (a = frequecy_angles) a[1]];

// Returns the strut angle for the strut_id from frequecy_angles array
function get_strut_angle(frequecy_angles, strut_id) =
    frequecy_angles[search(strut_id, frequecy_angles)[0]][1];

function get_socket_config_angles(frequency_angles, socket_config) = [for (
    strut_id = socket_config) get_strut_angle(frequency_angles, strut_id)];

// Returns the max circumference angle (in degrees) given it's
// full_hub_sector_count and strut_count
function get_circle_angle(full_hub_sector_count, strut_count) =
    full_hub_sector_count ? 360 / full_hub_sector_count * strut_count : 360;

module translate_to_origin(frequency_angles, socket_config) {
  outer_radius = strut_radius + hub_min_thikness;
  max_angle = max(get_socket_config_angles(frequency_angles, socket_config));
  origin_offset = outer_radius * cos(max_angle) + hub_radius * sin(max_angle);
  translate([ 0, 0, origin_offset ]) children();
}

module grid_layout(render_what, col, row, coloration) {
  grid = render_what == "all"
             ? [ render_all_spacing * row, render_all_spacing * col, 0 ]
             : [ 0, 0, 0 ];
  translate(grid) color(DEBUG ? undef : coloration) children();
}

// Renders the strut_id letter on the top of the hub
module strut_id_letters(frequency_angles, socket_config,
                        full_hub_sector_count) {
  strut_count = len(socket_config);
  circle_angle = get_circle_angle(full_hub_sector_count, strut_count);
  min_angle = min(get_strut_angles(frequency_angles));
  difference() {
    for (i = [0:strut_count - 1]) {
      strut_angle = get_strut_angle(frequency_angles, socket_config[i]);
      rotate([ -min_angle, 0, 180 + i * circle_angle / strut_count ])
          translate([ 0, hub_radius / 2.5, strut_diameter / 2 ]) rotate(180)
              linear_extrude(hub_min_thikness * 2) {
        text(socket_config[i], size = font_size,
             font = "DejaVu Sans Mono:style=Bold", valign = "center",
             halign = "center");
      }
    }
    translate([ 0, 0, -hub_min_thikness / 2 ])
        body(frequency_angles, socket_config, full_hub_sector_count);
  }
}

// Renders the screw holes on the bottom of the hub
module screw_holes(frequency_angles, socket_config, full_hub_sector_count) {
  strut_count = len(socket_config);
  circle_angle = get_circle_angle(full_hub_sector_count, strut_count);
  min_angle = min(get_strut_angles(frequency_angles));
  for (i = [0:strut_count - 1]) {
    strut_angle = get_strut_angle(frequency_angles, socket_config[i]);
    for (mult = [2.7:1:2.7]) { // Tweak for multiple screws
      screw_hole_start = (mult + hub_min_thikness) * sin(min_angle);
      rotate([ -min_angle, 0, 180 + i * circle_angle / strut_count ])
          translate([ 0, hub_diameter / mult, screw_hole_start ]) cylinder(
              h = strut_diameter, d = screw_holde_diameter, center = false);
    }
  }
}

// Renders the main body of the hub
module body(frequency_angles, socket_config, full_hub_sector_count) {
  module rotate_cylinder() {
    strut_count = len(socket_config);
    circle_angle = get_circle_angle(full_hub_sector_count, strut_count);
    for (i = [0:strut_count - 1]) {
      // Hull between all angle variations for a regular hub top and base
      hull() for (strut_socket = socket_config) {
        strut_angle = get_strut_angle(frequency_angles, strut_socket);
        rotate([ 90 + strut_angle, 0, i * circle_angle / strut_count ])
            cylinder(h = hub_radius, d = strut_diameter + hub_min_thikness * 2,
                     center = false);
      }
    }
  }
  if (hub_body_type == "solid") {
    hull() rotate_cylinder();
  } else if (hub_body_type == "pipe") {
    rotate_cylinder();
  }
}

// Renders all the peripheral strut sockets
module peripheral_socket(frequency_angles, socket_config, hub_min_thikness,
                         full_hub_sector_count) {
  strut_count = len(socket_config);
  min_angle = min(get_strut_angles(frequency_angles));
  circle_angle = get_circle_angle(full_hub_sector_count, strut_count);
  strut_hub_center_offset = 9 * strut_diameter / 10;
  strut_hub_depth =
      hub_radius - strut_hub_center_offset + hub_min_thikness * cos(min_angle);
  for (i = [0:strut_count - 1]) {
    strut_angle = get_strut_angle(frequency_angles, socket_config[i]);
    rotate([ 90 + strut_angle, 0, i * circle_angle / strut_count ])
        translate([ 0, 0, strut_hub_center_offset ])
            cylinder(h = strut_hub_depth, d = strut_diameter, center = false);
  }
}

// Renders a center strut socket
module center_socket(frequency_angles, socket_config,
                     diameter = strut_diameter) {
  max_angle = max(get_socket_config_angles(frequency_angles, socket_config));
  outer_radius = strut_radius + hub_min_thikness;
  origin_offset = outer_radius * cos(max_angle) + hub_radius * sin(max_angle);
  offset = outer_radius * cos((max_angle));
  center_socket_height = origin_offset + offset + hub_min_thikness / 4;
  translate([ 0, 0, -origin_offset ])
      cylinder(h = center_socket_height, d = diameter, center = false);
}

module center_reinforcement(frequency_angles, socket_config) {
  center_socket(frequency_angles, socket_config,
                strut_diameter + hub_min_thikness * 2);
}

module bottom_support(frequency_angles, socket_config, full_hub_sector_count) {
  strut_count = len(socket_config);
  circle_angle = get_circle_angle(full_hub_sector_count, strut_count);
  min_angle = min(get_socket_config_angles(frequency_angles, socket_config));
  outer_radius = strut_radius + hub_min_thikness;
  origin_offset = outer_radius * cos(min_angle) + hub_radius * sin(min_angle);
  for (i = [0:strut_count - 1]) {
    // Hull between all angle variations for a regular hub top and base
    for (strut_socket = socket_config) {
      strut_angle = get_strut_angle(frequency_angles, strut_socket);
      rotate([ 0, 0, 270 + i * circle_angle / strut_count ])
          translate([ 0, -hub_min_thikness / 2, -origin_offset ]) hull() {
        cube([
          hub_radius * cos(min_angle) -
              sin(min_angle) * (strut_radius + hub_min_thikness) -
              hub_min_thikness / 2,
          hub_min_thikness, strut_radius * 2
        ]);
        // rotate([ 90, 0, 0 ])
        //     translate([ 0, 6, -(strut_radius + hub_min_thikness) / 2 ])
        //     cube([
        //       hub_radius * cos(min_angle) -
        //           sin(min_angle) * (strut_radius + hub_min_thikness),
        //       origin_offset / 4,
        //       strut_radius
        //     ]);
      };
    }
  }
}

// Fully renders the hub both in debugging or production modes
module hub(frequency_angles, socket_config, full_hub_sector_count = undef) {
  // Align the hub base with the origin
  translate_to_origin(frequency_angles, socket_config) {
    if (DEBUG) {
      color("grey")
          screw_holes(frequency_angles, socket_config, full_hub_sector_count);
      color([ 0.5, 0.1, 0.5, 0.5 ])
          peripheral_socket(frequency_angles, socket_config, hub_min_thikness,
                            full_hub_sector_count);
      color("green", 0.7) center_socket(frequency_angles, socket_config);
      color("red") strut_id_letters(frequency_angles, socket_config,
                                    full_hub_sector_count);
      color([ 1, 1, 0, 0.7 ])
          body(frequency_angles, socket_config, full_hub_sector_count);
      color([ 0, 1, 0, 0.7 ]) bottom_support(frequency_angles, socket_config,
                                             full_hub_sector_count);
      color("cyan", 0.5) center_reinforcement(frequency_angles, socket_config);
    } else {
      difference() {
        union() {
          body(frequency_angles, socket_config, full_hub_sector_count);
          center_reinforcement(frequency_angles, socket_config);
          bottom_support(frequency_angles, socket_config,
                         full_hub_sector_count);
        }
        strut_id_letters(frequency_angles, socket_config,
                         full_hub_sector_count);
        peripheral_socket(frequency_angles, socket_config, hub_min_thikness,
                          full_hub_sector_count);
        center_socket(frequency_angles, socket_config);
        screw_holes(frequency_angles, socket_config, full_hub_sector_count);
      }
    }
  }
}

// http://www.domerama.com/calculators/1v-geodesic-dome-calculator/
// A x25
module hubs_1V() {
  // PENTH x6
  if (render_1V == "all" || render_1V == "penth")
    grid_layout(render_1V, 0, 0, "red")
        hub(freq_1V_strut_angles, [ "A", "A", "A", "A", "A" ]);
  // QUAD x5
  if (render_1V == "all" || render_1V == "quad")
    grid_layout(render_1V, 0, 1, "orange")
        hub(freq_1V_strut_angles, [ "A", "A", "A", "A" ], 5);
}

// http://www.domerama.com/calculators/2v-geodesic-dome-calculator/
// A x30
// B x35
module hubs_2V() {
  // HEX x10
  if (render_2V == "all" || render_2V == "hex")
    grid_layout(render_2V, 0, 0, "red")
        hub(freq_2V_strut_angles, [ "A", "B", "B", "A", "B", "B" ]);
  // PENTH x6
  if (render_2V == "all" || render_2V == "penth")
    grid_layout(render_2V, 0, 1, "orange")
        hub(freq_2V_strut_angles, [ "A", "A", "A", "A", "A" ]);
  // QUAD_LEFT x5
  if (render_2V == "all" || render_2V == "quad_left")
    grid_layout(render_2V, 1, 0, "green")
        hub(freq_2V_strut_angles, [ "B", "A", "B", "B" ], 6);
  // QUAD_RIGHT x5
  if (render_2V == "all" || render_2V == "quad_right")
    grid_layout(render_2V, 1, 1, "purple")
        hub(freq_2V_strut_angles, [ "B", "B", "A", "B" ], 6);
}

// TODO: TO TEST
// http://www.domerama.com/calculators/3v-geodesic-dome-calculator/
// (non-flat at base)
// A x30
// B x40
// C x50
module hubs_3V_3_8() {
  // HEX1 x20
  if (render_3V_3_8 == "all" || render_3V_3_8 == "hex1")
    grid_layout(render_3V_3_8, 0, 0, "red")
        hub(freq_3V_3_8_strut_angles, [ "A", "B", "C", "B", "C", "B" ]);
  // HEX2 x5
  if (render_3V_3_8 == "all" || render_3V_3_8 == "hex2")
    grid_layout(render_3V_3_8, 0, 1, "gray")
        hub(freq_3V_3_8_strut_angles, [ "C", "C", "C", "C", "C", "C" ]);
  // PENTH x6
  if (render_3V_3_8 == "all" || render_3V_3_8 == "penth")
    grid_layout(render_3V_3_8, 1, 0, "orange")
        hub(freq_3V_3_8_strut_angles, [ "A", "A", "A", "A", "A" ]);
  // QUAD_LEFT x5
  if (render_3V_3_8 == "all" || render_3V_3_8 == "quad_left")
    grid_layout(render_3V_3_8, 1, 1, "green")
        hub(freq_3V_3_8_strut_angles, [ "B", "A", "B", "C" ], 6);
  // QUAD_CENTER x5
  if (render_3V_3_8 == "all" || render_3V_3_8 == "quad_center")
    grid_layout(render_3V_3_8, 2, 0, "blue")
        hub(freq_3V_3_8_strut_angles, [ "C", "C", "C", "C" ], 6);
  // QUAD_RIGHT x5
  if (render_3V_3_8 == "all" || render_3V_3_8 == "quad_right")
    grid_layout(render_3V_3_8, 2, 1, "purple")
        hub(freq_3V_3_8_strut_angles, [ "C", "B", "A", "B" ], 6);
}

// TODO: TO TEST
// https://www.domerama.com/calculators/octahedral-5v-mexican-method/
// (flat at base)
// A x12
// B x24
// C x36
// D x48
// E x40
module hubs_5V_mexican() {
  // HEX1 x12
  if (render_5V_mexican == "all" || render_5V_mexican == "hex1")
    grid_layout(render_5V_mexican, 0, 0, "red")
        hub(freq_5V_mexican_strut_angles, [ "A", "D", "E", "D", "A", "E" ]);
  // HEX2 x8
  if (render_5V_mexican == "all" || render_5V_mexican == "hex2")
    grid_layout(render_5V_mexican, 0, 1, "gray")
        hub(freq_5V_mexican_strut_angles, [ "B", "C", "E", "C", "B", "E" ]);
  // HEX3 x12
  if (render_5V_mexican == "all" || render_5V_mexican == "hex3")
    grid_layout(render_5V_mexican, 0, 2, "orange")
        hub(freq_5V_mexican_strut_angles, [ "C", "C", "D", "C", "C", "D" ]);
  // HEX4 x12
  if (render_5V_mexican == "all" || render_5V_mexican == "hex4")
    grid_layout(render_5V_mexican, 1, 0, "green")
        hub(freq_5V_mexican_strut_angles, [ "D", "D", "B", "D", "D", "B" ]);
  // FULL_QUAD x1
  if (render_5V_mexican == "all" || render_5V_mexican == "full_quad")
    grid_layout(render_5V_mexican, 1, 1, "blue")
        hub(freq_5V_mexican_strut_angles, [ "E", "E", "E", "E" ]);
  // HALF_QUAD1_LEFT x4
  if (render_5V_mexican == "all" || render_5V_mexican == "half_quad1_left")
    grid_layout(render_5V_mexican, 1, 2, "coral")
        hub(freq_5V_mexican_strut_angles, [ "E", "A", "D", "E" ], 6);
  // HALF_QUAD1_RIGHT x4
  if (render_5V_mexican == "all" || render_5V_mexican == "half_quad1_right")
    grid_layout(render_5V_mexican, 2, 0, "cyan")
        hub(freq_5V_mexican_strut_angles, [ "E", "D", "A", "E" ], 6);
  // HALF_QUAD2_LEFT x4
  if (render_5V_mexican == "all" || render_5V_mexican == "half_quad2_left")
    grid_layout(render_5V_mexican, 2, 1, "pink")
        hub(freq_5V_mexican_strut_angles, [ "E", "B", "C", "E" ], 6);
  // HALF_QUAD2_RIGHT x4
  if (render_5V_mexican == "all" || render_5V_mexican == "half_quad2_right")
    grid_layout(render_5V_mexican, 2, 2, "bisque")
        hub(freq_5V_mexican_strut_angles, [ "E", "C", "B", "E" ], 6);
  // TRI x4
  if (render_5V_mexican == "all" || render_5V_mexican == "tri")
    grid_layout(render_5V_mexican, 3, 0, "purple")
        hub(freq_5V_mexican_strut_angles, [ "E", "E", "E" ], 4);
}

module main() {
  if (dome_frequency == "1V")
    hubs_1V();
  if (dome_frequency == "2V")
    hubs_2V();
  if (dome_frequency == "3V3/8")
    hubs_3V_3_8();
  if (dome_frequency == "5V Mexican")
    hubs_5V_mexican();
}

main();