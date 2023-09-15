import processing.sound.*;
import java.util.ArrayDeque;

float noiseScale = 130;
float noiseResolution = 0.02;

int GREEN_SKY = 28;
int BLUE_SKY = 29;

int iteration = 0;

BrownNoise bgNoise;

ArrayDeque<Integer> pointsToDraw;

void setup() {
    size(512, 512);
    bgNoise = new BrownNoise(this);
    bgNoise.play();
    bgNoise.amp(0.003);

    pointsToDraw = new ArrayDeque<Integer>();
    for (int i = 0; i < 10; i++) {
      pointsToDraw.add((int) random(0, width));
      pointsToDraw.add((int) random(0, height));
    }
}


void draw() {
  background(204);
  loadPixels();
  noiseDetail(7);
  stroke(100, 255, 0);
  fill(100, 255, 0);
  // noiseResolution -= 0.01;
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
        float red = noise((i+iteration*5)*noiseResolution, (j+iteration*5)*noiseResolution) *noiseScale + 20;
        pixels[j*width+i] = color(red, GREEN_SKY, BLUE_SKY);
    }
  }

  if (random(0, 1) < 0.2) {
    pointsToDraw.add((int) random(0, width-5));
    pointsToDraw.add((int) random(0, height-5));
  }
  
  int initialSize = pointsToDraw.size();
  for (int i = 0; i < initialSize/2; i++) {
    int x = pointsToDraw.remove();
    int y = pointsToDraw.remove();

    // draw around the point
    // square(x, y, 5);
    for (int j = 0; j < 5; j++) {
      for (int k = 0; k < 5; k++) {
        if (x+j > 0 && y+k > 0) {
          pixels[(k+y)*width+(j+x)] = color(0, 255, 0);
        }
      }
    }

    if (x > 0 && y > 0) {
      pointsToDraw.add(x-5);
      pointsToDraw.add(y-5);
    }
  }

  updatePixels();
  
  iteration++;
  
  delay(100);
}
