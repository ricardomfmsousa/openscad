include <BOSL2/std.scad>
include <BOSL2/threading.scad>

cap_height = 20;
thread_height = 15;

tex = [
  [ 0, 0, 0, 0 ],
  [ 0, 1, 1, 0 ],
  [ 0, 1, 1, 0 ],
  [ 0, 0, 0, 0 ],

];

tex = texture("diamonds");

difference() {
  zflip() cyl(h = cap_height, d = 60, rounding1 = 5, orient = UP, texture = tex,
              tex_size = [ 5, 5 ], center = false);

  translate([ 0, 0, -cap_height ])
      threaded_rod(d = 50, height = thread_height, pitch = 2, $fa = 1, $fs = 1);
}