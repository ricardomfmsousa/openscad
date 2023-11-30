// Based on the info from:
// https://www.domerama.com/calculators/3v-geodesic-dome-calculator/3v-58-assembly-diagram/

DEBUG = true;

$fn = 6;
render="all"; // [all, hex, penth, quad_left, quad_right]
strut_diameter = 20;
hub_min_thikness = 4;
screw_holde_diameter = 3;
strut_angles = [ [ "A", 10.04 ], [ "B", 11.64 ], [ "C", 11.90 ] ];

font_size = (strut_diameter + hub_min_thikness) / 1.5;
hub_diameter = strut_diameter * 5;

if(render == "all" || render == "hex") hex_hub(DEBUG ? undef : "red");
if(render == "all" || render == "penth") translate([ hub_diameter * 2, 0, 0 ]) penth_hub(DEBUG ? undef : "orange");
if(render == "all" || render == "quad_left") translate([ hub_diameter * 4, 0, 0 ]) quad_hub_left(DEBUG ? undef : "green");
if(render == "all" || render == "quad_right") translate([ hub_diameter * 6, 0, 0 ]) quad_hub_right(DEBUG ? undef : "purple");


// Returns all the strut angles in an array
function get_strut_angles() = [ for (a = strut_angles) a[1] ];

// Returns the strut angle corresponding to a strut_id
function get_strut_angle(strut_id) = strut_angles[search(strut_id, strut_angles)[0]][1];

module strut_id_letters(strut_sockets, circle_angle) {
  strut_count = len(strut_sockets);
  min_angle = min(get_strut_angles());
  for (i = [0:strut_count - 1]) {
    strut_angle = get_strut_angle(strut_sockets[i]);
    rotate([ -min_angle, 0, 180 + i * circle_angle / strut_count ])
    translate([ 0, hub_diameter / 3.5,strut_diameter/3  ])
    rotate(180) linear_extrude(1.5+strut_diameter/2+hub_min_thikness/2) {
    text(strut_sockets[i], size = font_size,
             font = "DejaVu Sans Mono:style=Bold", valign = "center",
             halign = "center");
    }
  }
}
// TODO: fix
module screw_holes(strut_sockets, circle_angle) {
  strut_count = len(strut_sockets);
   min_angle = min(get_strut_angles());
  for (i = [0:strut_count - 1]) {
    strut_angle = get_strut_angle(strut_sockets[i]);
    for(mult = [2.5:1:3.5]){
      rotate([ -min_angle, 0, 180 + i * circle_angle / strut_count ])
      translate([ 0, hub_diameter / mult, -strut_diameter / 2+ hub_min_thikness*1.5])
      rotate([180])
      cylinder(h = hub_min_thikness * strut_diameter , d = screw_holde_diameter,
              center = false);
    }
  }
}


module letter_body_intersection(strut_sockets,circle_angle) {
  translate([0,0,1]) 
  body(strut_sockets, circle_angle);
}

module body(strut_sockets, circle_angle) {
  strut_count = len(strut_sockets);
   hull()  for (i = [0:strut_count - 1]) {
     for (strut_socket=strut_sockets) {
      // Hull between all angle variations for a regular hub top and base
      strut_angle = get_strut_angle(strut_socket);
      rotate([ 90 + strut_angle, 0, i * circle_angle / strut_count ])
        cylinder(h = hub_diameter / 2, d = strut_diameter + hub_min_thikness*2,
                 center = false);
     }
  }
}

module peripheral_socket(strut_sockets, circle_angle, hub_min_thikness=hub_min_thikness) {
  strut_count = len(strut_sockets);
  for (i = [0:strut_count - 1]) {
    strut_angle = get_strut_angle(strut_sockets[i]);
    rotate([ 90 + strut_angle, 0, i * circle_angle / strut_count ])
        translate([ 0, 0, strut_diameter - strut_diameter / 10 ])
            cylinder(h = hub_diameter / 2 + hub_min_thikness,
                     d = strut_diameter, center = false);
  }
}

module center_socket() {
  cylinder(h = 4 * (strut_diameter + hub_min_thikness), d = strut_diameter,
           center = true);
}

module hub(strut_sockets, circle_angle) {
  if (DEBUG) {
    %color([0,0,1,0.5]) letter_body_intersection(strut_sockets, circle_angle);
    color("grey") screw_holes(strut_sockets, circle_angle);
    color([0.5,0.1,0.5,0.5]) peripheral_socket(strut_sockets, circle_angle);
    color("green") center_socket();
    color("red") strut_id_letters(strut_sockets, circle_angle);
    color([ 1, 1, 0, 0.7 ]) body(strut_sockets, circle_angle);
  } else {
    difference() {
      union()  {
        body(strut_sockets, circle_angle);
        intersection() {
          letter_body_intersection(strut_sockets, circle_angle);
          strut_id_letters(strut_sockets, circle_angle);
        }
      }
      peripheral_socket(strut_sockets, circle_angle);
      center_socket();
      screw_holes(strut_sockets, circle_angle);
    }
  }
}

module hex_hub(color) {
  color(color) hub([ "A", "A", "A", "A", "A", "A" ], 360);
}

module penth_hub(color) { color(color) hub([ "A", "B", "C", "B", "C" ], 360); }

module quad_hub_left(color) { color(color) hub([ "C", "B", "C", "B" ], 240); }

module quad_hub_right(color) { color(color) hub([ "B", "C", "B", "C" ], 240); }


 