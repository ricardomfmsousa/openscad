use <list-comprehension-demos/skin.scad>
use <scad-utils/shapes.scad>
use <scad-utils/transformations.scad>

fn = 32;
$fn = 60;

module tube(r1, r2, R, th, angle, ) {
  translate([ R, 0, 0 ]) difference() {
    skin([for (i = [0:fn]) transform(rotation([ 0, angle / fn * i, 0 ]) *
                                         translation([ -R, 0, 0 ]),
                                     circle(r1 + (r1 - r2) / fn * i))]);
    assign(r1 = r1 - th, r2 = r2 - th) skin([for (i = [0:fn + 1]) transform(
        rotation([ 0, angle / fn * i, 0 ]) * translation([ -R, 0, 0 ]),
        circle(r1 + (r1 - r2) / fn * i))]);
  }
}

radius = 35;
for (a = [0:3])
  tube(r1 = radius - 2 - a * 1.4, r2 = radius - a * 1.4, R = 200, th = 0.1,
       angle = 35);