 include <BOSL2/std.scad>

$fn = $preview ? 50 : 200;
drone_pocket_diameter = 30;
tube_outer_diam = 40;
tube_inner_diam = 36.8;
mouth_piece_outter_height = 10;
mouth_piece_inner_height = 15;

tube_thikness = tube_outer_diam - tube_inner_diam;

module draw_outter_piece() {
  torus(od = tube_outer_diam, id = drone_pocket_diameter);
  difference() {
    cyl(h = mouth_piece_outter_height, d = tube_outer_diam, center = false);
    cyl(h = tube_outer_diam - drone_pocket_diameter,
        d1 = tube_inner_diam - tube_thikness,
        d2 = tube_inner_diam - tube_thikness, center = false);
  }
}

module draw_inner_piece() {
  up(mouth_piece_outter_height) difference() {
    cyl(h = mouth_piece_inner_height, d1 = tube_inner_diam,
        d2 = tube_inner_diam - 0.5, center = false);
    cyl(h = mouth_piece_inner_height, d = tube_inner_diam - tube_thikness,
        center = false);
  }
  up(mouth_piece_outter_height + mouth_piece_inner_height)
      torus(od = tube_inner_diam - 0.5, id = tube_inner_diam - tube_thikness);
}

module main() {
  union() {
    draw_outter_piece();
    draw_inner_piece();
  }
}

main();