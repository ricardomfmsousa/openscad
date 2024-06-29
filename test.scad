// include <BOSL2/std.scad>
// tex = texture("hex_grid", border = .07);
// linear_sweep(circle(30), texture = tex, h = quantup(30, 10 * sqrt(3)),
//              tex_size = [ 10, 10 * sqrt(3) ], tex_depth = 1);

$fn = $preview ? 50 : 200;

module torus(r1, r2) {
  rotate_extrude(angle = 180, convexity = 10) translate([ r2 - r1, 0, 0 ])
      circle(r = r1);
}

module torus_pipe(pipe_outter_radius, pipe_inner_radius, torus_radius,
                  torus_angle = 360) {
  if (pipe_outter_radius > torus_radius) {
    color("red") text("ERROR: pipe_outter_radius > torus_radius");
  }
  difference() {
    torus(pipe_outter_radius, torus_radius * 2);
    torus(pipe_inner_radius,
          torus_radius * 2 - (pipe_outter_radius - pipe_inner_radius));
  }
}

od = 17.5;
id = 16.3;
or = od / 2;
ir = id / 2;
tr = or ;

t = id * sin(60) + (od - id) / tan(60) + 2;

for (a = [0:120:360])
  rotate([ 90, 0, a ]) translate([ t, 0, 0 ]) rotate([ 0, 90, 0 ])
      torus_pipe(or, ir, tr, torus_angle = 180);

difference() {
  cylinder(h = od, d = 17.5);
  cylinder(h = od, d = 16.3);
}