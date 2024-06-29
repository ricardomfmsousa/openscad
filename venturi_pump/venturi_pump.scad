$fn = $preview ? 50 : 100;
pipe_length = 50;
pipe_inner_diameter = 13;
pipe_thickness = 4;
shower_diameter = 1.3;
cross_cut = false;

module draw_pipe(length, inner_diameter, thikness) {
  difference() {
    cylinder(h = length, d = inner_diameter + 2 * thikness);
    cylinder(h = length, d = inner_diameter);
  }
}

module draw_pipe_reduction(length, inner_diameter1, inner_diameter2, thikness) {
  difference() {
    cylinder(h = length, d1 = inner_diameter1 + 2 * thikness,
             d2 = inner_diameter2 + 2 * thikness);
    cylinder(h = length, d1 = inner_diameter1, d2 = inner_diameter2);
  }
}

module draw_hose_connector() {
  translate([ 0, 0, pipe_length + 10 ]) draw_pipe(
      length = 15, inner_diameter = 10, thikness = pipe_thickness / 2);
  difference() {
    translate([ 0, 0, pipe_length + 25 ])
        cylinder(h = 10, d1 = 10 + pipe_thickness, d2 = 10);
    translate([ 0, 0, pipe_length + 25 ])
        cylinder(h = 10, d1 = 7 + pipe_thickness, d2 = 7);
  }
  translate([ 0, 0, pipe_length ]) draw_pipe_reduction(
      length = 10, inner_diameter1 = 15, inner_diameter2 = 10, thikness = 3);
}

// Calculate outer diameter and the full diameter of the U bend
pipe_outer_diameter = pipe_inner_diameter + 2 * pipe_thickness;
bend_radius = pipe_outer_diameter / 2; // Radius of the U bend
full_bend_diameter = bend_radius * 2 + pipe_outer_diameter;
module ubend_pipe(inner_dia, thk, radius) {
  translate([ 0, 0, bend_radius ]) rotate([ -90, 0, 0 ]) difference() {
    // Outer bend
    translate([ radius, radius, 0 ]) rotate_extrude(angle = 180)
        translate([ radius, 0, 0 ]) circle(d = inner_dia + 2 * thk);

    // Inner bend
    translate([ radius, radius, 0 ]) rotate_extrude(angle = 180)
        translate([ radius, 0, 0 ]) circle(d = inner_dia);
  }
}

module ubend(dia, radius) {
  translate([ 0, 0, bend_radius ]) rotate([ -90, 0, 0 ]) difference() {
    // Outer bend
    translate([ radius, radius, 0 ]) rotate_extrude(angle = 180)
        translate([ radius, 0, 0 ]) circle(d = dia);
  }
}

module draw_shower_holes(
    max_diam = 2 * (pipe_inner_diameter + 2 * pipe_thickness) - 5) {
  for (step = [0:10:max_diam])
    for (angle = [0:600 / step:360]) {
      x = step / 2 * cos(angle);
      y = step / 2 * sin(angle);
      translate([ x, y, -23 ])
          cylinder(h = pipe_thickness * 3, d = shower_diameter);
    }
}

module draw_shower_head() {
  // Draw shower head
  translate([ (pipe_inner_diameter + 2 * pipe_thickness) / 2, 0, 0 ]) {
    difference() {
      translate([ 0, 0, -22 ])
          cylinder(h = pipe_thickness / 2,
                   d = 2 * (pipe_inner_diameter + 2 * pipe_thickness));
      draw_shower_holes();
    }
  }
}

module draw_pump() {
  union() {
    venturi_cut = 20;
    translate([ 0, 0, venturi_cut ]) draw_pipe(
        length = pipe_length - venturi_cut,
        inner_diameter = pipe_inner_diameter, thikness = pipe_thickness);
    draw_hose_connector();

    translate([ pipe_inner_diameter + 2 * pipe_thickness, 0, 0 ]) {
      draw_pipe(length = pipe_length, inner_diameter = pipe_inner_diameter,
                thikness = pipe_thickness);
      draw_hose_connector();
    }

    // Render the U bend pipe with shower holes
    difference() {
      ubend_pipe(pipe_inner_diameter, pipe_thickness, bend_radius);
      translate([ (pipe_inner_diameter + 2 * pipe_thickness) / 2, 0, 0 ])
          draw_shower_holes(10);
      translate([ 22, 0, -20 ]) cylinder(h = 15, d = pipe_inner_diameter / 2);
    }

    // Draw shower body
    translate([ (pipe_inner_diameter + 2 * pipe_thickness) / 2, 0, -21 ]) {
      draw_pipe(length = 10,
                inner_diameter = 2 * pipe_inner_diameter + 2 * pipe_thickness,
                thikness = pipe_thickness);
      difference() {
        translate([ 0, 0, 10 ]) draw_pipe_reduction(
            length = 11,
            inner_diameter1 = 2 * pipe_inner_diameter + 2 * pipe_thickness,
            inner_diameter2 = 0, thikness = pipe_thickness);
        translate([ -10.5, 0, 21 ]) ubend(13, 10.5);
      }
    }

    // Draw ventury upper cone
    translate([ 0, 0, 10 ]) difference() {
      cylinder(h = 10, d1 = pipe_inner_diameter + pipe_thickness * 2,
               d2 = pipe_inner_diameter + pipe_thickness * 2);
      cylinder(h = 10,
               d1 = pipe_inner_diameter + pipe_thickness * 2 -
                    pipe_thickness / 2,
               d2 = pipe_inner_diameter);
    }

    // Draw ventury lower cone
    difference() {
      cylinder(h = 10, d1 = pipe_inner_diameter + pipe_thickness * 2,
               d2 = pipe_inner_diameter / 2 + pipe_thickness);
      cylinder(h = 10, d1 = pipe_inner_diameter, d2 = pipe_inner_diameter / 2);
    }

    // Draw lower to upper venturi support
    for (angle = [0:60:360])
      rotate([ 0, 0, angle ]) translate([ 9, 0, 0 ]) cylinder(h = 20, d = 3);
  }
}

module main() {
  draw_pump();
  draw_shower_head();
}

if (cross_cut) {
  difference() {
    main();
    translate([ -pipe_inner_diameter * 5, 0, -40 ]) cube([
      pipe_inner_diameter * 10, pipe_inner_diameter * 10, pipe_length * 10
    ]);
  }
} else {

  main();
}