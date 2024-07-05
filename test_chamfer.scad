$fn = 30;

// Examples

Chamfer_3d(mode = "sphere") {
  // Chamfer_3d(mode="fast",dir=[true,true,false,false,true,true]) {
  // Chamfer_3d(mode="sphere") {
  // Chamfer_3d(mode="cube") {
  // Chamfer_3d([[0,1],[0,2],[1,2]],.5) {
  // Chamfer_3d([[0,1],[0,2]]) {
  // Chamfer_3d([[0,1],[0,2]],.5) {
  cylinder(r = 2, h = 10);

  rotate([ 30, 30, 30 ]) cube([ 20, 20, 2 ]);

  translate([ 0, 0, 5 ]) cube([ 20, 20, 2 ], center = true);
};

// for two arrays, generate permutations of their members
// generate [1,2], exclude [1,1] and [2,1]
function permutations(arr1, arr2) =
    [for (i = 0, j = 1; (i < len(arr1)) && (j < len(arr2));
          i = (j == len(arr2) - 1) ? i + 1 : i,
          j = (j == len(arr2) - 1) ? i + 1 : j + 1)[arr1[i], arr2[j]]];
// generate permutations of an array's members with itself
function permSelf(arr) = permutations(arr, arr);

//-----------------------------------------------
// Create a chamfer between two or more surfaces
//
// A subset of surface pairs may be specified
//
// Call with N = List of surface subsets
//           N = [[child#,child#],[child#,child#,]...]
//           for 2 objects N = [[0,1]]
//           for 3 objects intersection 0 and 1 N = [[0,1],[0,2]]
// dr   = chamfer height (approx)
// mode = chamfer mode: fast (uses shifting), sphere, cube (use minkowski())
// dir  = use to restrict shifting in certain directions

module Chamfer_3d(N, dr = .5, mode = "fast",
                  dir = [ true, true, true, true, true, true ]) {
  children();

  _n = (N != undef) ? N : permSelf([for (i = [0:$children - 1]) i]);

  for (i = _n) {
    hull() {
      intersection() {
        children(i[0]);
        Expand_3d(dr, mode, dir) children(i[1]);
      }

      intersection() {
        Expand_3d(dr, mode, dir) children(i[0]);
        children(i[1]);
      }
    }
  }
}

//--------------------------------------------------
// Expand a child object by shifting or minkowski
// Since the center of an object is not known,
//     a simple scale(S) children() is not possible
//
// An object can be expanded by creating a composite object
// either using minkowski() children(); sphere(r),cube(r,center=true) etc.
// or by shifting the object on multiple axis
//
// dr   = absolute expansion
// mode = fast (uses shifting), sphere, cube (use minkowski())
// dir  = use to restrict shifting in certain directions

module Expand_3d(dr = .5, mode = "fast",
                 dir = [ true, true, true, true, true, true ]) {

  assert(((mode == "fast") || (mode == "sphere") || (mode == "cube")));

  if (mode == "fast") {

    shiftList = [[dr, 0, 0], [-dr, 0, 0], [0, dr, 0], [0, -dr, 0], [0, 0, dr],
                 [0, 0, -dr]];
    for (i = [0:5]) {
      if (dir[i] == true) {
        translate(shiftList[i]) children();
      }
    }

  } else {
    minkowski() {
      children();
      if (mode == "sphere") {
        sphere(r = dr);
      } else if (mode == "cube") {
        cube(dr, center = true);
      }
    }
  }
}