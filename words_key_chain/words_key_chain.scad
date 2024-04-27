use <fonts/Pacifico.ttf>

/* [Text parameters] */
first_word = "Olívia";
// Shift the first word left or right
first_word_offset = 0;
last_word = "";
// Shift the last word left or right
last_word_offset = 0;
// Defaults to font_size / 2 (spacing between first and last word)
words_spacing = 0;
font_size = 18;
font_name = "Pacifico:style=Regular";
// For previewing purposes only - it does not afect the stl rendering
text_color = "white";

/* [Base parameters] */
base_text_padding = 4;
base_height = 4;
// For previewing purposes only - it does not afect the stl rendering
base_color = "red";

/* [Contour/contrast parameters] */
text_contour_height = 2;
text_contour_padding = 2;
text_height = 2;
// For previewing purposes only - it does not afect the stl rendering
text_contour_color = "black";

/* [Chain Link] */
include_chain_link = true;
// Defaults to base_text_padding * 1.5
bore_size = 0;
// Defaults to bore_size * 2
chain_link_length = 0;

$fn = $preview ? 50 : 150;

module draw_text() {
  spacing = words_spacing ? words_spacing : font_size / 2;
  translate([ first_word_offset, last_word ? spacing : 0 ])
      text(first_word, size = font_size, font = font_name, valign = "center");
  translate([ last_word_offset, -spacing ])
      text(last_word, size = font_size, font = font_name, valign = "center");
}

module draw_chain_link() {
  bore_size = bore_size ? bore_size : base_text_padding * 1.5;
  chain_link_length = chain_link_length ? chain_link_length : bore_size * 2;
  difference() {
    hull() {
      translate([ -bore_size, 0, 0 ])
          cylinder(h = base_height, r = bore_size, center = false);
      translate([ -bore_size, -bore_size, 0 ])
          cube([ chain_link_length, bore_size * 2, base_height ], false);
    }
    translate([ -bore_size, 0, 0 ])
        cylinder(h = base_height * 2, r = bore_size / 2, center = true);
  }
}

module main() {
  // Draw chain link
  if (include_chain_link) {
    color(base_color) draw_chain_link();
  }
  // Draw base
  color(base_color) linear_extrude(height = base_height) {
    offset(r = base_text_padding) draw_text();
  }
  // Draw contour
  color(text_contour_color)
      linear_extrude(height = base_height + text_contour_height) {
    offset(r = text_contour_padding) draw_text();
  }
  // Draw text
  color(text_color)
      linear_extrude(height = base_height + text_contour_height + text_height)
          draw_text();
}

main();