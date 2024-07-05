include <BOSL2/std.scad>
$fn = $preview ? 64 : 128;
section_cut = false;

/*[Spine]*/
spine_height = 26;
spine_pipe_radius = 4.5;
spine_pipe_thinkess = 2.6;
spine_line_pocket_radius = 1.1;
/*[Hooks]*/
hook_count = 3;
hook_radius = 10;
hook_thinkness = 5;

module draw_spine_pipe_pocket() {
  radius = spine_pipe_radius - spine_pipe_thinkess;
  cyl(r = radius, rounding2 = 1, h = spine_height - spine_pipe_thinkess,
      center = false);
}

module draw_hooks() {
  difference() {
    for (angle = [0:360 / hook_count:359]) {
      zmove(hook_radius + hook_thinkness / 2) zrot(angle) {
        xmove(-hook_radius) xrot(-90) rotate_extrude(angle = 180)
            xmove(hook_radius) circle(d = hook_thinkness);
        zrot(360 / 2 * hook_count) xmove(hook_radius * 2)
            sphere(d = hook_thinkness);
      }
    }
    draw_spine_pipe_pocket();
  }
}

module draw_spine() {
  difference() {
    cyl(r = spine_pipe_radius, h = spine_height,
        chamfer1 = spine_pipe_radius / 3, rounding2 = spine_pipe_radius,
        center = false);
    draw_spine_pipe_pocket();
    // Draw fish line pocket
    cyl(r = spine_line_pocket_radius, h = spine_height + spine_pipe_thinkess,
        center = false);
  }
}

module main() {
  union() {
    Chamfer_3d() {

      draw_spine();
      zrot($t * 360) draw_hooks();
    }
  }
}

if (section_cut)
  left_half() main();
else
  color("red") main();

// ---------- chamfering ----------
// Posted on Reddit by u/Icy_Mix_6341:
// https://www.reddit.com/r/openscad/comments/s6twto/generate_a_bevel_along_the_intersecting_edge_3/
// --------------------------------
/*
// Example:
// mode can be fast, sphere, or cube
Chamfer_3d(dr=1,mode="fast") {
    cylinder(r=2,h=10, $fn=32);
    rotate([30,30,30]) cube([20,20,2]);
    translate([0,0,5]) cube([20,20,2],center=true);
}
*/

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
                 dir = [ true, true, true, true, true, true ], fn = 8) {
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
        sphere(r = dr, $fn = fn);
      } else if (mode == "cube") {
        cube(dr, center = true);
      }
    }
  }
}