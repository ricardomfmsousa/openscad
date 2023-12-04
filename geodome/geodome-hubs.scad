// Based on the info from https://www.domerama.com/calculators/

DEBUG = false;

$fn = 6;
dome_frequency = "1V"; // [1V, 2V, 3V3/8]
strut_diameter = 16.05;
hub_min_thikness = 2;
screw_holde_diameter = 3;

/* [Hidden] */
font_size = (strut_diameter + hub_min_thikness) / 1.5;
hub_diameter = strut_diameter * 5;
render_all_spacing = strut_diameter * 8;
// Strut socket angles
freq_1V_strut_angles = [[ "A", 31.72 ]];
freq_2V_strut_angles = [ [ "A", 15.86 ], [ "B", 18 ] ];
freq_3V_3_8_strut_angles = [ [ "A", 10.04 ], [ "B", 11.64 ], [ "C", 11.90 ] ];

// clang-format off
/* [1V] */
render_1V = "all";// [all, penth, quad]
/* [2V] */
render_2V = "all";// [all, hex, penth, quad_left, quad_right]
/* [3V3/8] */
render_3V_3_8 = "all";// [all, hex1, hex2, penth, quad_left, quad_center, quad_right]
// clang-format on

// Returns all angles from the frequecy_angles structure in a new array
function get_strut_angles(frequecy_angles) = [for (a = frequecy_angles) a[1]];

// Returns the strut angle for the strut_id from frequecy_angles array
function get_strut_angle(frequecy_angles, strut_id) =
    frequecy_angles[search(strut_id, frequecy_angles)[0]][1];

// Returns the max circumference angle (in degrees) for a hub socket config
function get_circle_angle(socket_config) = len(socket_config) > 4 ? 360 : 240;

// Renders the strut_id letter on the top of the hub
module strut_id_letters(frequency_angles, socket_config) {
  strut_count = len(socket_config);
  circle_angle = get_circle_angle(socket_config);
  max_angle = max(get_strut_angles(frequency_angles));
  for (i = [0:strut_count - 1]) {
    strut_angle = get_strut_angle(frequency_angles, socket_config[i]);
    rotate([ -max_angle, 0, 180 + i * circle_angle / strut_count ])
        translate([ 0, hub_diameter / 3.6, strut_diameter / 3 ]) rotate(180)
            linear_extrude(1.5 + strut_diameter / 2 + hub_min_thikness / 2) {
      text(socket_config[i], size = font_size,
           font = "DejaVu Sans Mono:style=Bold", valign = "center",
           halign = "center");
    }
  }
}

// Renders the screw holes on the bottom of the hub
module screw_holes(frequency_angles, socket_config) {
  strut_count = len(socket_config);
  circle_angle = get_circle_angle(socket_config);
  max_angle = max(get_strut_angles(frequency_angles));
  for (i = [0:strut_count - 1]) {
    strut_angle = get_strut_angle(frequency_angles, socket_config[i]);
    for (mult = [2.7:1:2.7]) { // Tweak for multiple screws
      screw_hole_start =
          -cos(max_angle) * strut_diameter * 2 + hub_min_thikness;
      rotate([ -max_angle, 0, 180 + i * circle_angle / strut_count ])
          translate([ 0, hub_diameter / mult, screw_hole_start ]) cylinder(
              h = cos(max_angle) * strut_diameter * 2 + hub_min_thikness * 2,
              d = screw_holde_diameter, center = false);
    }
  }
}

// Renders a z-axis translated hub body copy to intersect with the strut_id
module letter_body_intersection(frequency_angles, socket_config) {
  translate([ 0, 0, 1 ]) body(frequency_angles, socket_config);
}

// Renders the main body of the hub
module body(frequency_angles, socket_config) {
  strut_count = len(socket_config);
  circle_angle = get_circle_angle(socket_config);
  hull() for (i = [0:strut_count - 1]) {
    for (strut_socket = socket_config) {
      // Hull between all angle variations for a regular hub top and base
      strut_angle = get_strut_angle(frequency_angles, strut_socket);
      rotate([ 90 + strut_angle, 0, i * circle_angle / strut_count ])
          cylinder(h = hub_diameter / 2,
                   d = strut_diameter + hub_min_thikness * 2, center = false);
    }
  }
}

// Renders all the peripheral strut sockets
module peripheral_socket(frequency_angles, socket_config,
                         hub_min_thikness = hub_min_thikness) {
  strut_count = len(socket_config);
  circle_angle = get_circle_angle(socket_config);
  for (i = [0:strut_count - 1]) {
    strut_angle = get_strut_angle(frequency_angles, socket_config[i]);
    rotate([ 90 + strut_angle, 0, i * circle_angle / strut_count ])
        translate([ 0, 0, strut_diameter - strut_diameter / 10 ])
            cylinder(h = hub_diameter / 2 + hub_min_thikness,
                     d = strut_diameter, center = false);
  }
}

// Renders a center strut socket
module center_socket(frequency_angles) {
  max_angle = max(get_strut_angles(frequency_angles));
  center_socket_height = cos(max_angle) * hub_diameter * 2;
  cylinder(h = center_socket_height, d = strut_diameter, center = true);
}

// Fully renders the hub both in debugging and production modes
module hub(frequency_angles, socket_config) {
  if (DEBUG) {
    % color([ 0, 0, 1, 0.5 ])
            letter_body_intersection(frequency_angles, socket_config);
    color("grey") screw_holes(frequency_angles, socket_config);
    color([ 0.5, 0.1, 0.5, 0.5 ])
        peripheral_socket(frequency_angles, socket_config);
    color("green") center_socket(frequency_angles);
    color("red") strut_id_letters(frequency_angles, socket_config);
    color([ 1, 1, 0, 0.7 ]) body(frequency_angles, socket_config);
  } else {
    difference() {
      union() {
        body(frequency_angles, socket_config);
        intersection() {
          letter_body_intersection(frequency_angles, socket_config);
          strut_id_letters(frequency_angles, socket_config);
        }
      }
      peripheral_socket(frequency_angles, socket_config);
      center_socket(frequency_angles);
      screw_holes(frequency_angles, socket_config);
    }
  }
}

// http://www.domerama.com/calculators/1v-geodesic-dome-calculator/
// A x25
module hubs_1V() {
  // PENTH x6
  if (render_1V == "all" || render_1V == "penth")
    color(DEBUG ? undef : "red")
        hub(freq_1V_strut_angles, [ "A", "A", "A", "A", "A" ]);
  // QUAD x5
  if (render_1V == "all" || render_1V == "quad")
    translate([ render_1V == "all" ? render_all_spacing : 0, 0, 0 ]) {
      color(DEBUG ? undef : "orange")
          hub(freq_1V_strut_angles, [ "A", "A", "A", "A" ]);
    }
}

// TODO: TO TEST
// http://www.domerama.com/calculators/2v-geodesic-dome-calculator/
// A x30
// B x35
module hubs_2V() {
  // HEX x10
  if (render_2V == "all" || render_2V == "hex")
    color(DEBUG ? undef : "red")
        hub(freq_2V_strut_angles, [ "A", "B", "B", "A", "B", "B" ]);
  // PENTH x6
  if (render_2V == "all" || render_2V == "penth")
    translate([ render_2V == "all" ? render_all_spacing : 0, 0, 0 ]) {
      color(DEBUG ? undef : "orange")
          hub(freq_2V_strut_angles, [ "A", "A", "A", "A", "A" ]);
    }
  // QUAD_LEFT x5
  if (render_2V == "all" || render_2V == "quad_left")
    translate([ 0, render_2V == "all" ? render_all_spacing : 0, 0 ]) {
      color(DEBUG ? undef : "green")
          hub(freq_2V_strut_angles, [ "B", "A", "B", "B" ]);
    }
  // QUAD_RIGHT x5
  if (render_2V == "all" || render_2V == "quad_right")
    translate([
      render_2V == "all" ? render_all_spacing : 0,
      render_2V == "all" ? render_all_spacing : 0, 0
    ]) {
      color(DEBUG ? undef : "purple")
          hub(freq_2V_strut_angles, [ "B", "B", "A", "B" ]);
    }
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
    color(DEBUG ? undef : "red")
        hub(freq_3V_3_8_strut_angles, [ "A", "B", "C", "B", "C", "B" ]);
  // HEX2 x5
  if (render_3V_3_8 == "all" || render_3V_3_8 == "hex2")
    translate([ render_3V_3_8 == "all" ? render_all_spacing : 0, 0, 0 ]) {
      color(DEBUG ? undef : "gray")
          hub(freq_3V_3_8_strut_angles, [ "C", "C", "C", "C", "C", "C" ]);
    }
  // PENTH x6
  if (render_3V_3_8 == "all" || render_3V_3_8 == "penth")
    translate([ 0, render_3V_3_8 == "all" ? render_all_spacing : 0, 0 ]) {
      color(DEBUG ? undef : "orange")
          hub(freq_3V_3_8_strut_angles, [ "A", "A", "A", "A", "A" ]);
    }
  // QUAD_LEFT x5
  if (render_3V_3_8 == "all" || render_3V_3_8 == "quad_left")
    translate([
      render_3V_3_8 == "all" ? render_all_spacing : 0,
      render_3V_3_8 == "all" ? render_all_spacing : 0, 0
    ]) {
      color(DEBUG ? undef : "green")
          hub(freq_3V_3_8_strut_angles, [ "B", "A", "B", "C" ]);
    }
  // QUAD_CENTER x5
  if (render_3V_3_8 == "all" || render_3V_3_8 == "quad_center")
    translate([ 0, render_3V_3_8 == "all" ? render_all_spacing * 2 : 0, 0 ]) {
      color(DEBUG ? undef : "blue")
          hub(freq_3V_3_8_strut_angles, [ "C", "C", "C", "C" ]);
    }
  // QUAD_RIGHT x5
  if (render_3V_3_8 == "all" || render_3V_3_8 == "quad_right")
    translate([
      render_3V_3_8 == "all" ? render_all_spacing : 0,
      render_3V_3_8 == "all" ? render_all_spacing * 2 : 0, 0
    ]) {
      color(DEBUG ? undef : "purple")
          hub(freq_3V_3_8_strut_angles, [ "C", "B", "A", "B" ]);
    }
}

module main() {
  if (dome_frequency == "1V")
    hubs_1V();
  if (dome_frequency == "2V")
    hubs_2V();
  if (dome_frequency == "3V3/8")
    hubs_3V_3_8();
}

main();