

module wood_texture(size, depth = 0.2, width = 0.5, spacing = 1.65, angle = 6,
                    disable = false, fn = 4) {
  undersize = 0.6 * width;

  if (disable) {
    children(0);
  } else if ($preview) {
    // less intense rendering for previews
    intersection() {
      union() {
        resize([
          size.x - 2 * depth - undersize, size.y - 2 * depth - undersize, size.z
        ]) children(0);

        difference() {
          resize([ size.x, size.y, size.z ]) children(0);

          // etch wood grain
          rotate([ 0, 0, -3 ]) translate([ 0, 0, size.z / 2 ])
              rotate([ -angle, 0, 0 ]) for (y = [-size.y:spacing:size.y]) {
            translate([ 0, y + 0.5 * spacing, 0 ])
                cube([ 2 * size.x, width, 2 * size.z ], center = true);
          }
        }
      }
    }
  } else {
    // better rendering for final STL generation
    // this is going to take a while...
    // render()
    intersection() {
      // translate([0, 0, size.z])
      children(0);

      union() {
        resize([
          size.x - 4 * depth - undersize, size.y - 4 * depth - undersize, size.z
        ])
            // render()
            children(0);

        minkowski() {
          difference() {
            resize([ size.x - undersize, size.y - undersize, size.z ])
                // render()
                children(0);

            // etch wood grain
            render() rotate([ 0, 0, -3 ]) translate([ 0, 0, size.z / 2 ])
                rotate([ -angle, 0, 0 ]) for (y = [-size.y:spacing:size.y]) {
              translate([ 0, y + 0.5 * spacing, 0 ])
                  cube([ 2 * size.x, width, 2 * size.z ], center = true);
            }
          }
          sphere(r = 0.7 * width, $fn = fn);
        }
      }
    }
  }
}