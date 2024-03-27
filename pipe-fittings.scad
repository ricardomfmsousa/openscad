/* [Reinforcement] */
reinforcement = "none"; // [none, hull, bracket]
// 1 = full arm length, 2 = 1/2 arm length 
reinforcement_factor = 1;
/* [Dimensions] */
// inner DIAMETER for all profile shapes other than rectangle
inner_width = 25.7;
// outer DIAMETER for all profile shapes other than rectangle
outer_width = 32.5;  //
inner_height = 10; // Used for rectagle profiles only
outer_height = 13; // Used for rectagle profiles only
arm_length = 35;

// clang-format off
/* [Geometry] */
// Shape of the profile
shape = 150;// [150:circle, 8:octagon, 6:hexagon, 5:penthagon, 4:square, 0:rectangle]
$fn = shape;

/* [Presets] */
presets = "custom";// [custom, end-cap, tee-90, tee-45, elbow-90, elbow-45, cross-sleeve, 3-way-elbow, 4-way-elbow, 5-way-elbow, 6-way-elbow]

// clang-format on

// X angle, Y angle, Z angle
custom = [
  [ 30, 0, 0 ], [ 10.12, -28.39, 0 ], [ -25, -17, 0 ], [ -25.04, 17, 0 ],
  [ 10.12, 28.39, 0 ]
];

/* [Hidden] */
preset_data = [
  [ "end-cap", [[ 0, 0, 0 ]] ], [ "elbow-90", [ [ 0, 0, 0 ], [ 90, 0, 0 ] ] ],
  [ "elbow-45", [ [ 0, 0, 0 ], [ 135, 0, 0 ] ] ],
  [ "tee-90", [ [ -90, 0, 0 ], [ 0, 0, 0 ], [ 90, 0, 0 ] ] ],
  [ "tee-45", [ [ -90, 0, 0 ], [ 45, 0, 0 ], [ 90, 0, 0 ] ] ],
  [
    "cross-sleeve",
    [
      [ -90, 0, 0 ],
      [ 90, 0, 0 ],
      [ 0, 90, 0 ],
      [ 0, -90, 0 ],
    ]
  ],
  [ "3-way-elbow", [ [ 0, 0, 0 ], [ 0, 90, 0 ], [ -90, 0, 0 ] ] ],
  [ "4-way-elbow", [ [ 0, 0, 0 ], [ 0, 90, 0 ], [ -90, 0, 0 ], [ 90, 0, 0 ] ] ],
  [
    "5-way-elbow",
    [ [ 0, 0, 0 ], [ 0, -90, 0 ], [ 0, 90, 0 ], [ -90, 0, 0 ], [ 90, 0, 0 ] ]
  ],
  [
    "6-way-elbow",
    [
      [ 0, 0, 0 ], [ 180, 0, 0 ], [ 0, -90, 0 ], [ 0, 90, 0 ], [ -90, 0, 0 ],
      [ 90, 0, 0 ]
    ]
  ]
];

function get_preset_data(preset_name) =
    preset_data[search([preset_name], preset_data)[0]][1];

function slice(list, start, end) = [for (i = [start:end - 1]) list[i]];
function int(s, ret = 0, i = 0) = i >= len(s)
                                      ? ret
                                      : int(s, ret * 10 + ord(s[i]) - ord("0"),
                                            i + 1);

module draw_arms(data, width, height, length) {
  for (arm = data) {
    angles = slice(arm, 0, 2);
    rotate(angles) {
      if (!shape)
        translate([ -width / 2, -height / 2, 0 ])
            cube([ width, height, length ]);
      else
        cylinder(h = length, d = width);
    }
  }
}

module draw_reinforcement(data, width, height, length) {
  if(reinforcement=="none") {
    children(0);
  }
if(reinforcement=="hull") {
    hull() children(0);
  }

  if(reinforcement=="bracket") {
    // TODO
    children(0);

    angles = slice(data[8], 0, 2);

    polyhedron(points=[[0,0,0], [arm_length*2*(len(angles)-1),0,0], [arm_length*(len(angles)-1),arm_length*sqrt(3),0]],
               faces=[[0,1,2]]);

  }

}

module draw_inner_elbow() {
  if (!shape) {
      translate([ -inner_width / 2, -inner_height / 2, -inner_height / 2 ])
          color("red", 1) cube([ inner_width, inner_height, outer_height ]);
  } else {
    $fn = 100;
      color("red", 1) sphere(r = (inner_width) / 2);
  }
}

module draw_outer_elbow() {
  if (!shape) {
       translate([ -outer_width / 2, -outer_height / 2, -outer_height / 2 ])
              cube([ outer_width, outer_height, outer_height ]);
   } else {
    $fn = 100;
    sphere(r = (outer_width) / 2);
   }
}

module draw_fitting(data) {
  difference() {
    union() {
      color("green", 0.5)   
      draw_reinforcement(data = data, width = outer_width,
                                    height = outer_height, length = arm_length)
      draw_arms(data = data, width = outer_width,
                                    height = outer_height, length = arm_length);
      color("yellow", 0.5) draw_outer_elbow();
    }
    color("red", 0.5)
        draw_arms(data = data, width = inner_width, height = inner_height,
                  length = arm_length + 0.1);
    color("orange", 0.5) draw_inner_elbow();
  }
  echo(shape);
}

module draw_error(msg) {
  color("red")
  text("ERROR", size=20);
  for(m=[0:len(msg)-1])
   color("yellow") translate([0, -15*(1+m), 0]) text(msg[m]);
}

module main() {
  if(inner_width > outer_width || inner_height > outer_height) {
   draw_error([
    "Values out of range!",
    "inner_width < outer_width, inner_height < outer_height"
   ]);
  } else {
  data = presets == "custom" ? custom : get_preset_data(presets);
  draw_fitting(data);
   }
}

main();
