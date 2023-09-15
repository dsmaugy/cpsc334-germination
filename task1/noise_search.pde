import processing.sound.*;
import java.util.ArrayDeque;

// noise constants
float noiseScale = 130;
float noiseResolution = 0.02;
float iterationScale = 5;

// color constants
int GREEN_SKY = 28;
int BLUE_SKY = 29;

// looping constants
int iteration = 0;
int delayTime = 10;

BrownNoise bgNoise;

ArrayDeque<Integer> pointsToDraw;

void setup() {
    size(512, 512);
    // fullScreen();
    bgNoise = new BrownNoise(this);
    bgNoise.play();
    bgNoise.amp(0.003);

    pointsToDraw = new ArrayDeque<Integer>();
    for (int i = 0; i < 10; i++) {
      pointsToDraw.add((int) random(0, width-5));
      pointsToDraw.add((int) random(0, height-5));
    }
}

void animatePoints() {
  int initialSize = pointsToDraw.size();
  for (int i = 0; i < initialSize/2; i++) {
    int x = pointsToDraw.remove();
    int y = pointsToDraw.remove();

    // draw around the point
    // square(x, y, 5);
    for (int j = 0; j < 5; j++) {
      for (int k = 0; k < 5; k++) {
        if (x+j >= 0 && y+k >= 0) {
          pixels[(k+y)*width+(j+x)] = color(0, 255, 0);
        }
      }
    }

    if (x > 0 && y > 0) {
      pointsToDraw.add(x-5);
      pointsToDraw.add(y-5);
    }
  }
}


void draw() {
  background(204);
  loadPixels();
  noiseDetail(7);
  // stroke(100, 255, 0);
  // fill(100, 255, 0);

  // noiseResolution += map(noise(iteration*0.05), 0, 1, -0.0001, 0.0001);
  iterationScale += map(noise(iteration*0.02), 0, 1, -0.002, 0.002);
  println(iterationScale);
  println(iteration); // combine this with iterationScale to one var
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
        float red = noise((i+iteration*iterationScale)*noiseResolution, (j+iteration*iterationScale)*noiseResolution) *noiseScale + 20;
        pixels[j*width+i] = color(red, GREEN_SKY, BLUE_SKY);
    }
  }

  if (random(0, 1) < 0.2) {
    pointsToDraw.add((int) random(0, width-5));
    pointsToDraw.add((int) random(0, height-5));
  }
  

  animatePoints();


  updatePixels();
  iteration++;
  delay(delayTime);
}
