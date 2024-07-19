include <Round-Anything/MinkowskiRound.scad>
include <Round-Anything/polyround.scad>

$fn = $preview ? 15 : 60;

finger_radius = 10;
finger_separation_radius = 4;

function concat_points(arrays, result = [], i = 0) =

    i < len(arrays) ? concat_points(arrays, concat(result, arrays[i]), i + 1)
                    : [result][0];

function poly_arc(x = 0, y = 0, r = 10, a1 = 0, a2 = 359, step = 20) =
    [for (a = [a1:step:a2])[x + r * cos(a), y + r *sin(a)]];

points = [
  [[ 70, 0 ]],                                       //
  poly_arc(x = 0, y = 0, r = 20, a1 = 0, a2 = 180),  //
  poly_arc(x = 45, y = 0, r = 20, a1 = 0, a2 = 180), //
  [ [ -25, 0 ], [ -25, 30 ], [ 70, 30 ] ],           //
];

echo(concat_points(points));

polygon(concat_points(points));

// points = [
//   [ 0, 10, finger_radius ], [ 10, 0, finger_separation_radius ],
//   [ 13, 0, finger_separation_radius ], [ 23, 10, finger_radius ], [ 30,
//   7, 2 ], [ 30, 20, 2 ], [ 0, 20, 0 ],
//   //

// ];
// extrudeWithRadius(20, 3, 3, $fn)
//     polygon(polyRound(radiipoints = points, fn = $fn));

// $fn = 20;
// minkowskiRound(0.7, 1.5, 1, [
//   50, 50, 50
// ]) union() { //--example in the thiniverse thumbnail/main image
//   cube([ 6, 6, 22 ]);
//   rotate([ 30, 45, 10 ]) cylinder(h = 22, d = 10);
// } //--I rendered this out with a $fn=25 and it took more than 12 hours on
// my
//   // computer