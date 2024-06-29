include <BOSL2/rounding.scad>
include <BOSL2/std.scad>

$fn = $preview ? 64 : 128;

// Enable Orthogonal view mode to prevent preview issues
section_cut = false;
draw_lid = true;
draw_body = true;

general_thikness = 1.5;
/* [Spike tunnel - section that will be burried underground] */
spike_length = 100;
spike_radius = 7.5;
/* [Climb tunnel - ant entrance holes to access the cup] */
outter_cup_climb_tunnel_length = 70;
climb_tunnel_entry_radius = 2.5;
/* [Cup - holds liquid or solid poison] */
poison_cup_radius = 32;
poison_cup_length = 50;
/* [Lid - closes the cup] */
lid_height = 8;
lid_snap_sections = 3;
lid_tolerance = 0.4;
lid_text_depth = 0.7;

module draw_lid_snap(radius, sections = 0) {
  module draw_raw_lid_snap(extrude_angle) {
    rotate_extrude(angle = extrude_angle)
        polygon([[radius, 0], [radius, general_thikness * 4],
                 [radius + general_thikness, general_thikness * 2]]);
  }
  if (sections > 0) {
    offset = 22.5;
    for (angle = [offset:360 / sections:359 + offset])
      zrot(angle) draw_raw_lid_snap(general_thikness * 10);
  } else {
    draw_raw_lid_snap(360);
  }
}

module draw_lid_text() {
  xrot(180) move([ 0, 2, -lid_text_depth ])
      linear_extrude(height = lid_text_depth)
          text(text = "POISON", halign = "center", size = 10,
               font = "Impasto:style=Bold");

  xrot(180) move([ 0, -10, -lid_text_depth ])
      linear_extrude(height = lid_text_depth)
          text(text = "DO NOT TOUCH", halign = "center", size = 8,
               font = "Impasto:style=Regular");
  offset = -145;
  text_path = path3d(
      arc(360, r = poison_cup_radius - 4, angle = [ offset, 360 + offset ]));
  path_text(text_path, "* ANTS BE GONE * GEL - GRANULAR - ANT BAIT STATION",
            font = "Fira Sans Condensed:style=Bold", size = 4,
            lettersize = 4.13 / 1.2, normal = DOWN, thickness = lid_text_depth);
}

module draw_lid() {
  zmove(-general_thikness) difference() {
    cyl(r = poison_cup_radius + 2 * general_thikness, l = lid_height,
        rounding = 1, center = false);
    zmove(general_thikness - lid_tolerance)
        cyl(r = poison_cup_radius + lid_tolerance,
            l = lid_height - general_thikness + lid_tolerance, center = false);
    zmove(general_thikness)
        draw_lid_snap(radius = poison_cup_radius + lid_tolerance, sections = 0);
    draw_lid_text();
  }
}

module draw_poison_cup() {
  cup_rounding_divider = 1.3;
  cup_rounding = poison_cup_radius / cup_rounding_divider;
  difference() {
    union() {
      // Draw cup shell
      difference() {
        cut_radius = poison_cup_radius - general_thikness;
        cut_length = poison_cup_length - general_thikness;
        cut_rounding = cut_radius / cup_rounding_divider;
        cyl(r = poison_cup_radius, l = poison_cup_length,
            rounding2 = cup_rounding, center = false);
        cyl(r = cut_radius, l = cut_length, rounding2 = cut_rounding,
            center = false);
      }
      // Draw cup divider
      up(poison_cup_length / 2)
          cuboid([ poison_cup_radius * 2, general_thikness, poison_cup_length ],
                 rounding = cup_rounding, edges = [ TOP + LEFT, TOP + RIGHT ]);
    }
    // Draw center pocket
    cyl(r = spike_radius - general_thikness, l = poison_cup_length,
        center = false);
  }
  // Draw lid snap points
  draw_lid_snap(radius = poison_cup_radius, sections = lid_snap_sections);
}

module draw_outer_cup_climb_tunnel() {
  difference() {
    union() {
      // Climb tunnel shell
      up(poison_cup_length)
          cyl(r = spike_radius, l = outter_cup_climb_tunnel_length,
              rounding1 = -1, center = false);
      // Cup climb tunnel shell round end-cap
      up(poison_cup_length + outter_cup_climb_tunnel_length) {
        difference() {
          sphere(r = spike_radius);
          sphere(r = spike_radius - general_thikness);
        }
      }
    }
    // Climb tunnel shell pocket
    cyl(r = spike_radius - general_thikness,
        l = outter_cup_climb_tunnel_length + poison_cup_length, center = false);
    // Climb tunnel entry pocket
    up(poison_cup_length + climb_tunnel_entry_radius * 5) {
      p_count = outter_cup_climb_tunnel_length / climb_tunnel_entry_radius / 5;
      for (i = [0:p_count])
        up(climb_tunnel_entry_radius * i * 4)
            ycyl(r = climb_tunnel_entry_radius, l = spike_radius * 2);
    }
  }
}

module draw_inner_cup_climb_tunnel() {
  difference() {
    // Climb tunnel shell
    cyl(r = spike_radius, l = poison_cup_length - general_thikness,
        rounding2 = -8, center = false);
    // Climb tunnel shell pocket
    cyl(r = spike_radius - general_thikness,
        l = outter_cup_climb_tunnel_length + poison_cup_length, center = false);
    // Pockets to access from climb tunnel to cup chambers
    hull() {
      ycyl(r = 2.5, l = spike_radius * 2);
      up(3.5) ycyl(r = 2.5, l = spike_radius * 2);
    }
  }
}

module draw_spike() {
  spike_thikness = general_thikness * 1.2;
  zmove(poison_cup_length + outter_cup_climb_tunnel_length) union() {
    // Shape that defines one spike triangle
    shape = [
      [ -spike_thikness, 0 ],
      [ spike_thikness, 0 ],
      [ spike_radius / 1.5, spike_length / 10 ],
      [ spike_radius, spike_length ],
      [ -spike_radius, spike_length ],
      [ -spike_radius / 1.5, spike_length / 10 ],
    ];
    difference() {
      union() {
        // Draw both spikes already oriented in the z axis
        zmove(spike_length) xrot(-90) for (a = [0:90:179]) yrot(a)
            zmove(-spike_thikness / 2) linear_extrude(height = spike_thikness)
                polygon(round_corners(shape, radius = spike_thikness));
        // Draw the center reinforcement spike spine
        cyl(r1 = spike_thikness, r2 = spike_thikness,
            rounding2 = spike_thikness, l = spike_length + general_thikness / 2,
            center = false);
      }
      // Pocket to remove the spike leftovers inside the climb tunnel
      sphere(r = spike_radius - general_thikness);
    }
  }
}

module main() {
  if (draw_lid)
    draw_lid();
  if (draw_body) {
    union() {
      draw_poison_cup();
      draw_inner_cup_climb_tunnel();
      draw_outer_cup_climb_tunnel();
      draw_spike();
    }
  }
}

if (section_cut) {
  left_half(s = 1000) main();
} else {
  main();
}