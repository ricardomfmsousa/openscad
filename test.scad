// Import texture image
texture_image = "texture.png";

// Define cylinder dimensions
cylinder_radius = 10;
cylinder_height = 20;

// Create cylinder
difference() {
  cylinder(r = cylinder_radius, h = cylinder_height, center = true);
  translate([ 0, 0, -0.01 ]) // Slightly offset to avoid Z-fighting
      surface(file = texture_image, center = true, convexity = 10);
}