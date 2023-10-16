// Character ruler v2.0
use <fonts/BigShouldersStencilText-VariableFont_wght.ttf>

// Ruler dimensions parameters
x_width = 210;
y_depth = 75;
z_height = 2;

// Metric scale parameters
scale_start_x_offset = 5;
scale_line_width = 0.25;
scale_line_depression = 1.5;
tall_scale_line_height = 8;
medium_scale_line_height = 6;
small_scale_line_height = 4;
scale_numbers_font_size = 3.5;

// Character parameters
chars = [ "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz.,:;", "Çç!?0123456789-+×÷=€" ];
char_start_x_offset = 7.5;
char_font_size = 12;

// CONSTANTS
char_height = char_font_size;
scale_numbers_height = scale_numbers_font_size * 2.54;

module right_triangle(side1, side2, corner_radius, triangle_height) {
  translate([ corner_radius, corner_radius, 0 ])
  {
    hull() {
      cylinder(r = corner_radius, h = triangle_height);
      translate([ side1 - corner_radius * 2, 0, 0 ])
      cylinder(r = corner_radius, h = triangle_height);
      translate([ 0, side2 - corner_radius * 2, 0 ])
      cylinder(r = corner_radius, h = triangle_height);
    }
  }
}

module round_cube(side1, side2, height, corner_radius) {
  translate([ corner_radius, corner_radius, 0 ])
  {
    hull() {
      cylinder(r = corner_radius, h = height);
      translate([ side1 - corner_radius * 2, 0, 0 ])
      cylinder(r = corner_radius, h = height);
      translate([ 0, side2 - corner_radius * 2, 0 ])
      cylinder(r = corner_radius, h = height);
      translate([ side1 - corner_radius * 2, side2 - corner_radius * 2, 0 ])
      cylinder(r = corner_radius, h = height);
    }
  }
}

module characters() {
  chars_y_top_offset = scale_numbers_font_size + tall_scale_line_height + 8;
  color("blue") translate([ char_start_x_offset, y_depth - chars_y_top_offset - char_font_size, 0 ])
  linear_extrude(z_height) for (row = [0:len(chars)]) {
    translate([ 0, -row * char_font_size * 1.5, 0 ])
    text(chars[row], char_font_size, font = "BigShouldersStencilText:style=Bold");
  }
}

module scale_line(line_width, line_height, line_depression) {
  translate([ 0, 0, z_height - line_depression ])
  cube([ line_width, line_height, line_depression ]);
}

module tall_scale_line(number) {
  color("red") scale_line(scale_line_width, tall_scale_line_height, scale_line_depression);
}

module medium_scale_line() {
  color("red") scale_line(scale_line_width, medium_scale_line_height, scale_line_depression);
}

module small_scale_line() {
  color("green") scale_line(scale_line_width, small_scale_line_height, scale_line_depression);
}

module scale_lines() {
  centimeter_to_millimeter = 10;
  scale_count = x_width - scale_start_x_offset * 2;
  for (cent_step = [0:10:scale_count]) {
    translate([ scale_start_x_offset + cent_step, y_depth - tall_scale_line_height, 0 ])
    {
      tall_scale_line();
      number = cent_step / centimeter_to_millimeter;
      font_x_offset = -scale_numbers_font_size / (number < 10 ? 2.9 : 1.4);
      translate([ font_x_offset, -scale_numbers_font_size * 1.5, z_height - scale_line_depression ])
      linear_extrude(scale_line_depression)
          text(str(number), scale_numbers_font_size, font = "Liberation Sans:style=Bold");
    }
    if (cent_step != scale_count) {
      for (mill_step = [1:1:9]) {
        translate([ scale_start_x_offset + cent_step + mill_step, y_depth - small_scale_line_height, 0 ])
        small_scale_line();
        if (mill_step == 4) {
          translate([ scale_start_x_offset + cent_step + mill_step + 1, y_depth - medium_scale_line_height, 0 ])
          medium_scale_line();
        }
      }
    }
  }
}

module chanfer() {
  translate([ x_width, 80, 2.5 ])
  rotate([ 180, 90, 0 ])
  linear_extrude(x_width) polygon([ [ 0, 5 ], [ 2.2, 0 ], [ 0, 25 ] ], 10);
}

module ruler() {
  difference() {
    color("gray", 0.5) round_cube(x_width, y_depth, z_height, 4);
    chanfer();
    scale_lines();
    characters();

    color("purple") translate([ 180, 10, z_height - scale_line_depression ])
    linear_extrude(scale_line_depression) text("OLÍVIA", 8, font = "BigShouldersStencilText:style=Medium");

    color("pink") translate([ 157, 10 ])
    linear_extrude(z_height) text("✸♥", 8, font = "Noto");
  }
}

ruler();
