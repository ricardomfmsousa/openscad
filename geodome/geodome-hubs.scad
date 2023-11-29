// Base on the info from:
// https://www.domerama.com/calculators/3v-geodesic-dome-calculator/3v-58-assembly-diagram/

DEBUG = true;

strut_diameter = 3;
hub_min_thikness = 2;
hub_diameter = strut_diameter * 5;

strut_angles = [ [ "A", 10.04 ], [ "B", 11.64 ], [ "C", 11.90 ] ];

$fn = DEBUG ? 6 : 50;
hex_hub(DEBUG ? undef : "red");
translate([ hub_diameter * 2, 0, 0 ])
penth_hub(DEBUG ? undef : "orange");
translate([ hub_diameter * 4, 0, 0 ])
quad_hub_left(DEBUG ? undef : "green");
translate([ hub_diameter * 6, 0, 0 ])
quad_hub_right(DEBUG ? undef : "purple");

function get_strut_angle(strut) = strut_angles[search(strut, strut_angles)[0]][1];

module strut_id(strut_sockets, circle_angle) {
  strut_count = len(strut_sockets);
  for (i = [0:strut_count - 1]) {
    strut_angle = get_strut_angle(strut_sockets[i]);
    rotate([ -strut_angle - 1.1, 0, 180 + i * circle_angle / strut_count ])
    translate([ 0, hub_diameter / 2.7, (strut_diameter + hub_min_thikness) / 2 ])
    rotate(180)
    linear_extrude((strut_diameter) / 17) {
      text(strut_sockets[i], size = strut_diameter / 2, font = "Liberation Sans:style=Bold", valign = "center",
           halign = "center");
    }
  }
}

module hub(strut_sockets, circle_angle) {
  if (DEBUG) {
    color("purple") peripheral_socket(strut_sockets, circle_angle);
    color("green") center_socket();
    color("red") strut_id(strut_sockets, circle_angle);
    color([ 1, 1, 0, 0.5 ]) body(strut_sockets, circle_angle);
  } else {
    difference() {
      union() {
        body(strut_sockets, circle_angle);
        strut_id(strut_sockets, circle_angle);
      }
      peripheral_socket(strut_sockets, circle_angle);
      center_socket();
    }
  }
}

module body(strut_sockets, circle_angle) {
  strut_count = len(strut_sockets);
  hull() for (i = [0:strut_count - 1]) {
    strut_angle = get_strut_angle(strut_sockets[i]);
    rotate([ 90 + strut_angle, 0, i * circle_angle / strut_count ])
    cylinder(h = hub_diameter / 2, d = strut_diameter + hub_min_thikness, center = false);
  }
}

module peripheral_socket(strut_sockets, circle_angle) {
  strut_count = len(strut_sockets);
  for (i = [0:strut_count - 1]) {
    strut_angle = get_strut_angle(strut_sockets[i]);
    rotate([ 90 + strut_angle, 0, i * circle_angle / strut_count ])
    translate([ 0, 0, strut_diameter - strut_diameter / 10 ])
    cylinder(h = hub_diameter / 2 + hub_min_thikness, d = strut_diameter, center = false);
  }
}

module center_socket() { cylinder(h = 2 * (strut_diameter + hub_min_thikness), d = strut_diameter, center = true); }

module hex_hub(color) { color(color) hub([ "A", "A", "A", "A", "A", "A" ], 360); }

module penth_hub(color) { color(color) hub([ "A", "B", "C", "B", "C" ], 360); }

module quad_hub_left(color) { color(color) hub([ "C", "B", "C", "B" ], 240); }

module quad_hub_right(color) { color(color) hub([ "B", "C", "B", "C" ], 240); }
