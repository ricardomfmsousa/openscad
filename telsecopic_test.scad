include <BOSL2/rounding.scad>
include <BOSL2/std.scad>
include <BOSL2/threading.scad>
include <BOSL2/turtle3d.scad>
include<BOSL2/skin.scad>

$fn = $preview ? 20 : 100;

section_height = 25;
locking_edge_thinkess = 0.8; // 2x 0.4mm nozzle
top_locking_edge_xy_distance = 1.35;

module fillet2D(r) {
  offset(r = -r) {
    offset(delta = r) { children(); }
  }
}
module draw_slice() {
  // Draw outer locking edges
  module draw_half_slice() {
    hull() {
      square(size = locking_edge_thinkess, center = false);
      move([ top_locking_edge_xy_distance, top_locking_edge_xy_distance, 0 ])
          square(size = locking_edge_thinkess, center = false);
    }
    hull() {
      move([ top_locking_edge_xy_distance, top_locking_edge_xy_distance, 0 ])
          square(size = locking_edge_thinkess, center = false);
      move([ top_locking_edge_xy_distance, section_height / 2, 0 ])
          square(size = locking_edge_thinkess, center = false);
    }
  }
  color("blue") draw_half_slice();
  color("cyan") yflip() fwd(section_height) draw_half_slice();
  // Draw inner locking edge
  color("cyan") hull() {
    move([ top_locking_edge_xy_distance, top_locking_edge_xy_distance, 0 ])
        square(size = locking_edge_thinkess, center = false);
    move([ top_locking_edge_xy_distance, 3 * top_locking_edge_xy_distance, 0 ])
        square(size = locking_edge_thinkess, center = false);
    move([
      2 * top_locking_edge_xy_distance, 2 * top_locking_edge_xy_distance, 0
    ]) square(size = locking_edge_thinkess, center = false);
  }
}

module draw_sections() {
  step = locking_edge_thinkess + top_locking_edge_xy_distance;
  clearance = 0.1;
  down(0) rotate_extrude() left(10) draw_slice();

  rotate_extrude() left(10 + step + clearance) draw_slice();
}

left_half() draw_sections();
right(3.55) color("red") ycyl(h = 30, d = 0.01);

difference() {
  linear_extrude(height = 5, center = false) fillet2D(30) {
    diam = 200;
    circle(d = diam);
    for (a = [0:60:360])
      zrot(a) translate([ -diam / 2, 0, 0 ]) circle(d = 15);
  }
  zcyl(h = 10, d = 180);
}