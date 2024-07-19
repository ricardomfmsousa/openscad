$fn = $preview ? 60 : 128;

// Function to calculate the distance between two points
function distance(p1,
                  p2) = norm([ p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2] ]);

// Function to calculate the direction vector
function direction(p1, p2) = [ p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2] ];

// Function to create a transformation matrix for look_at
function look_at(from, to) = let(dir = direction(from, to), up = [ 0, 0, 1 ],
                                 z = normalize(dir),
                                 x = normalize(cross(up, z)), y = cross(z, x))
    [[x [0], y [0], z [0], from [0]], [x [1], y [1], z [1], from [1]],
     [x [2], y [2], z [2], from [2]], [0, 0, 0, 1]];

// Function to normalize a vector
// (scale it to have a magnitude of 1 while preserving its direction)
function normalize(v) = let(mag = norm(v)) v / mag;

// Function to calculate the cross product of two vectors
function cross(v1, v2) = [
  v1[1] * v2[2] - v1[2] * v2[1], v1[2] * v2[0] - v1[0] * v2[2],
  v1[0] * v2[1] - v1[1] * v2[0]
];

// Module to create a cylinder between two points with a given diameter
module cylinder_between_points(p1, p2, d) {
  // Calculate the height of the cylinder
  h = distance(p1, p2);

  // Create the transformation matrix
  m = look_at(p1, p2);

  // Apply the transformation and create the cylinder
  multmatrix(m) {
    translate([ 0, 0, h / 2 ]) cylinder(d = d, h = h, center = true);
  }
}

// Example usage
p1 = [ -10, -100, -30 ];
p2 = [ 10, 10, 10 ];
d = 2;

// cylinder_between_points(p1, p2, d);
// translate(p1) sphere(d);
// translate(p2) sphere(d);

PHI = (1 + sqrt(5)) / 2;

function geodesic_dome(d, f) = let(
    vertices = project_to_sphere(subdivide_faces(icosahedron_faces(), f),
                                 d / 2),
    struts = generate_struts(vertices),
    unique_struts = unique_strut_lengths(struts, vertices))[for (
    strut =
        struts)[vertices[strut[0]], vertices[strut[1]],
                strut_length(vertices[strut[0]], vertices[strut[1]]),
                strut_type(unique_struts, strut_length(vertices[strut[0]],
                                                       vertices[strut[1]]))]];

// Icosahedron initial vertices and faces
function icosahedron_vertices() = [
  [ 0, -1, PHI ], [ 0, 1, PHI ], [ 0, -1, -PHI ], [ 0, 1, -PHI ],
  [ PHI, 0, -1 ], [ PHI, 0, 1 ], [ -PHI, 0, -1 ], [ -PHI, 0, 1 ], [ 1, PHI, 0 ],
  [ -1, PHI, 0 ], [ 1, -PHI, 0 ], [ -1, -PHI, 0 ]
];
function icosahedron_faces() = [
  [ 0, 1, 7 ], [ 0, 5, 1 ],  [ 0, 10, 5 ],  [ 0, 7, 11 ], [ 0, 11, 10 ],
  [ 1, 5, 9 ], [ 5, 10, 4 ], [ 10, 11, 2 ], [ 11, 7, 6 ], [ 7, 1, 8 ],
  [ 3, 9, 4 ], [ 3, 4, 2 ],  [ 3, 2, 6 ],   [ 3, 6, 8 ],  [ 3, 8, 9 ],
  [ 1, 9, 8 ], [ 5, 4, 9 ],  [ 10, 2, 4 ],  [ 11, 6, 2 ], [ 7, 8, 6 ]
];

// Subdivision of faces
function subdivide_faces(faces, freq) = concat([for (face = faces)
        subdivide(face, freq)]);

function subdivide(face, freq) = let(a = icosahedron_vertices()[face[0]],
                                     b = icosahedron_vertices()[face[1]],
                                     c = icosahedron_vertices()[face[2]],
                                     subdivided_points = [[a, b, c]])
    subdivide_recursive(subdivided_points, freq - 1);

function subdivide_recursive(points, freq) =
    freq == 0
        ? points
        : let(new_points = concat([for (
                  triangle = points)[mid_point(triangle[0], triangle[1]),
                                     mid_point(triangle[1], triangle[2]),
                                     mid_point(triangle[2], triangle[0]),
                                     triangle[0], triangle[1], triangle[2]]]))
              subdivide_recursive(new_points, freq - 1);

function mid_point(p1, p2) = [
  (p1[0] + p2[0]) / 2, (p1[1] + p2[1]) / 2, (p1[2] + p2[2]) / 2
];

// Project points to sphere
function project_to_sphere(points,
                           radius) = [for (p = points) project(p, radius)];

function project(p, r) = let(
    l = norm(p), p_0 = p[0] == undef ? 0 : p[0], p_1 = p[1] == undef ? 0 : p[1],
    p_2 = p[2] == undef ? 0 : p[2])[r * p_0 / l, r *p_1 / l, r *p_2 / l];

// Generate struts
function generate_struts(vertices) =
    concat([for (i = [0:len(vertices) - 1], j = [i + 1:len(vertices)]) if (
        close_to_edge(vertices[i], vertices[j])) [[i, j]]]);

function close_to_edge(v1 = [ 0, 0, 0 ], v2 = [ 0, 0, 0 ]) =
    let(v1_0 = v1[0] == undef ? 0 : v1[0], v2_0 = v2[0] == undef ? 0 : v2[0],
        v1_1 = v1[1] == undef ? 0 : v1[1], v2_1 = v2[1] == undef ? 0 : v2[1],
        v1_2 = v1[2] == undef ? 0 : v1[2], v2_2 = v2[2] == undef ? 0 : v2[2])
        norm([ v1_0 - v2_0, v1_1 - v2_1, v1_2 - v2_2 ]) <
    1.1; // Adjust threshold as needed

// Calculate strut length
function strut_length(v1, v2) =
    norm([ v1[0] - v2[0], v1[1] - v2[1], v1[2] - v2[2] ]);

// Unique strut lengths and types
function unique_strut_lengths(struts, vertices) = unique([for (s = struts)
        strut_length(vertices[s[0]], vertices[s[1]])]);

function strut_type(unique_lengths,
                    length) = chr(65 + search(length, unique_lengths));

echo(geodesic_dome(10, 5)); // Test with diameter 1 and frequency 1