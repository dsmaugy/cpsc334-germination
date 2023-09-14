
float noiseScale = 10.42;

void setup() {
    size(512, 512);
}


void draw() {
  background(204);
  loadPixels();

  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
        pixels[j*width+i] = color(map(noise(i, j), 0, 1, 0, 255)*random(0.1), map(noise(j, i)*random(0.1), 0, 1, 0, 255), 0);
    }
  }

  updatePixels();
  delay(100);
}
