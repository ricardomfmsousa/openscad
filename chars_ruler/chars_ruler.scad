// Character ruler v3.0
use <fonts/BigShouldersStencilText-VariableFont_wght.ttf>

$fn=5;
/* [Ruler dimensions parameters] */
x_width = 210; 
y_depth = 70; 
z_height = 1.5; 
/* [Metric scale parameters] */
scale_start_x_offset = 5;
scale_line_width = 0.25;
scale_line_depression = 1;
tall_scale_line_height = 8;
medium_scale_line_height = 6;
small_scale_line_height = 4;
scale_numbers_font_size = 3.5;

/* [Character parameters] */
chars = [
  "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz",
  "0123456789-+×÷=%$€£:;!?"
];
char_row_width=203;
char_row_y_top_offset = 16;
char_height = 16;


/* [Hidden] */
char_row_spacing=[char_height,char_height*0.94,char_height*1.03];
char_x_left_offset=floor((x_width-char_row_width)/2);
scale_numbers_height = scale_numbers_font_size * 2.54;

module round_cube(side1, side2, height, corner_radius) {
  fn=4;
  translate([ corner_radius, corner_radius, 0 ]) {
    hull() {
      cylinder(r = corner_radius, h = height, $fn=fn);
      translate([ side1 - corner_radius * 2, 0, 0 ])
          cylinder(r = corner_radius, h = height, $fn=fn);
      translate([ 0, side2 - corner_radius * 2, 0 ])
          cylinder(r = corner_radius, h = height, $fn=fn);
      translate([ side1 - corner_radius * 2, side2 - corner_radius * 2, 0 ])
          cylinder(r = corner_radius, h = height, $fn=fn);
    }
  }
}

module characters() {
  color("blue") translate(
      [ char_x_left_offset, y_depth - char_row_y_top_offset - char_height, 0 ])
      linear_extrude(z_height) for (row = [0:len(chars)-1]) {
    translate([ 0, -row * char_row_spacing[row], 0 ])
        resize([char_row_width, char_height, 1])
        text(chars[row], 12,
             font = "BigShouldersStencilText:style=Bold");
  }
}

module scale_line(line_width, line_height, line_depression) {
  translate([ 0, 0, z_height - line_depression ])
      cube([ line_width, line_height, line_depression ]);
}

module tall_scale_line(number) {
  color("red") scale_line(scale_line_width, tall_scale_line_height,
                          scale_line_depression);
}

module medium_scale_line() {
  color("red") scale_line(scale_line_width, medium_scale_line_height,
                          scale_line_depression);
}

module small_scale_line() {
  color("green") scale_line(scale_line_width, small_scale_line_height,
                            scale_line_depression);
}

module scale_lines() {
  centimeter_to_millimeter = 10;
  scale_count = x_width - scale_start_x_offset * 2;
  for (cent_step = [0:10:scale_count]) {
     color("red") translate([
      scale_start_x_offset + cent_step, y_depth - tall_scale_line_height, 0
    ]) {
      tall_scale_line();
      number = cent_step / centimeter_to_millimeter;
      font_x_offset = -scale_numbers_font_size / (number < 10 ? 2.9 : 1.4);
      translate([
        font_x_offset, -scale_numbers_font_size * 1.5, z_height -
        scale_line_depression
      ]) linear_extrude(scale_line_depression)  
          text(str(number), scale_numbers_font_size,
               font = "Liberation Sans:style=Bold");
    }
    if (cent_step != scale_count) {
      for (mill_step = [1:1:9]) {
        translate([
          scale_start_x_offset + cent_step + mill_step,
          y_depth - small_scale_line_height, 0
        ]) small_scale_line();
        if (mill_step == 4) {
          translate([
            scale_start_x_offset + cent_step + mill_step + 1,
            y_depth - medium_scale_line_height, 0
          ]) medium_scale_line();
        }
      }
    }
  }
}

module scale_chanfer() {
  translate([ x_width, y_depth+5, 2.5 ]) rotate([ 180, 90, 0 ]) linear_extrude(x_width)
      polygon([ [ 0, 5 ], [ 2.2, 0 ], [ 0, 25 ] ], 10);
}

module ruler() {
  difference() {
    color("gray", 0.5) round_cube(x_width, y_depth, z_height, 2.5);
    scale_chanfer();
    scale_lines();
    characters();
  }
}

ruler();