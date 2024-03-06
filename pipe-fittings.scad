/* [Dimensions] */
// inner width = inner DIAMETER for all profiles other than rectangle
inner_width = 20;
// outer width = outer DIAMETER for all profiles other than rectangle
outer_width = 23;  //
inner_height = 10; // Used for rectagle profiles only
outer_height = 13; // Used for rectagle profiles only
arm_length = 50;

// clang-format off

shape = 150;// [150:circle, 8:octagon, 6:hexagon, 5:penthagon, 4:square, 0:rectangle]
$fn = shape;
// clang-format on

/* [Presets] */
presets = "custom"; // [custom, end-cap, tee, elbow]

// X angle, Y angle, Z angle
// custom = [ [ -30, 0, 0 ], [ 30, 0, 0 ], [ 0, 30, 0 ], [ 0, -30, 0 ] ];
custom = [
  [ -30, 0, 0 ],
  [ 30, 0, 0 ],
  [ 0, 30, 0 ],
  [ 0, -30, 0 ],
];

/* [Hidden] */
preset_data = [
  [ "end-cap", [[ 0, 0, 0 ]] ], [ "elbow", [ [ 0, 0, 0 ], [ 90, 0, 0 ] ] ],
  [ "tee", [ [ -90, 0, 0 ], [ 0, 0, 0 ], [ 90, 0, 0 ] ] ]
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

module draw_elbow(data) {
  if (!shape) {
    difference() {
      translate([ -outer_width / 2, -outer_height / 2, -outer_height / 2 ])
          color("yellow", 0.5)
              cube([ outer_width, outer_height, outer_height ]);
      translate([ -inner_width / 2, -inner_height / 2, -inner_height / 2 ])
          color("red", 1) cube([ inner_width, inner_height, outer_height ]);
    }
  } else {
    difference() {
      color("yellow", 0.5) sphere(r = (outer_width) / 2);
      color("red", 1) sphere(r = (inner_width) / 2);
    }
  }
}

module draw_fitting(data) {
  difference() {
    union() {
      color("green", 0.5) draw_arms(data = data, width = outer_width,
                                    height = outer_height, length = arm_length);
      draw_elbow(data);
    }
    color("red", 0.5)
        draw_arms(data = data, width = inner_width, height = inner_height,
                  length = arm_length + 0.1);
  }
  echo(shape);
}

module main() {

  data = presets == "custom" ? custom : get_preset_data(presets);
  draw_fitting(data);
  echo(get_preset_data("tee"));
}

main();