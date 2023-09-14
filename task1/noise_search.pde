
float noiseScale = 255;
float noiseResolution = 0.02;

int iteration = 0;

void setup() {
    size(512, 512);
}


void draw() {
  background(204);
  loadPixels();
  noiseDetail(7);
  //noiseResolution -= 0.1;
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
        float red = noise(i*noiseResolution, j*noiseResolution) *noiseScale;
        float green = red;
        float blue = red;
        //float green = noise(j*noiseResolution, i*noiseResolution) *noiseScale;
        //float blue = noise(i*noiseResolution, j*noiseResolution, iteration*0.0001) *noiseScale;
        pixels[j*width+i] = color(red, green, blue);
    }
  }
  
  iteration++;
  updatePixels();
  delay(100);
}
