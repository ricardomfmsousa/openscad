use <fonts/Pacifico.ttf>

first_word = "Olívia";
last_word = "";
// Defaults to font_size / 2
words_spacing = 0;

base_text_padding = 4;

base_color = "red";
base_height = 4;
text_contour_color = "black";
text_contour_height = 2;
text_contour_padding = 2;
text_color = "white";
text_height = 2;

font_name = "Pacifico:style=Regular";
font_size = 18;

$fn = $preview ? 50 : 150;

module draw_text() {
  spacing = words_spacing ? words_spacing : font_size / 2;
  translate([ 0, last_word ? spacing : 0 ])
      text(first_word, size = font_size, font = font_name, valign = "center");
  translate([ 0, -spacing ])
      text(last_word, size = font_size, font = font_name, valign = "center");
}

module main() {
  bore_size = base_text_padding * 1.5;
  color(base_color) union() {
    linear_extrude(height = base_height) {
      offset(r = base_text_padding) draw_text();
    }
    difference() {
      hull() {
        translate([ -bore_size, 0, 0 ])
            cylinder(h = base_height, r = bore_size, center = false);
        translate([ -bore_size, -bore_size, 0 ])
            cube([ bore_size * 2, bore_size * 2, base_height ], false);
      }
      translate([ -bore_size, 0, 0 ])
          cylinder(h = base_height * 2, r = bore_size / 2, center = true);
    }
  }
  color(text_contour_color)
      linear_extrude(height = base_height + text_contour_height) {
    offset(r = text_contour_padding) draw_text();
  }

  color(text_color)
      linear_extrude(height = base_height + text_contour_height + text_height)
          draw_text();
}

main();