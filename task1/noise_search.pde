import processing.sound.*;
import java.util.ArrayDeque;

// background perlin noise
float noiseScale = 130;
float noiseResolution = 0.02;
float iterationScale = 3;

// background noise map coloration
int GREEN_SKY = 28;
int BLUE_SKY = 29;

// looping + time keeping
int iteration = 0;
int delayTime = 10;

// geometry
int blockSize = 10;

BrownNoise bgNoise;

ArrayDeque<Integer> pointsToDraw;
ArrayList<SearchHead> searchHeads;

enum Direction {
    LEFT,
    RIGHT,
    UP,
    DOWN
}

class SearchHead {

  int currX, currY;
  Direction previousDir;

  public SearchHead (int currX, int currY) {
    this.currX = currX;
    this.currY = currY;
    this.previousDir = null;
  }

  private void moveInDirection(Direction dir) {
    if (dir == Direction.LEFT) {
      this.currX -= 1;
    } else if (dir == Direction.RIGHT) {
      this.currX += 1;
    } else if (dir == Direction.UP) {
      this.currY -= 1;
    } else if (dir == Direction.DOWN) {
      this.currY += 1;
    }
  }

  public void moveOnRandomPath() {
    // moves one pixel NOT in the previous direction
    Direction newDir = this.previousDir;

    while (newDir == this.previousDir) {
      int choice = (int) random(0, 3.999);
      if (choice == 0) {
        newDir = Direction.LEFT;
      } else if (choice == 1) {
        newDir = Direction.RIGHT;
      } else if (choice == 2) {
        newDir = Direction.UP;
      } else if (choice == 3) {
        newDir = Direction.DOWN;
      }
      println(choice);
    }

    
    this.moveInDirection(newDir);
  }

}

boolean withinBounds(int x, int y) {
  return (x > 0 && y > 0 && x < width && y < height);
}

void setup() {
    size(512, 512);
    // fullScreen();
    bgNoise = new BrownNoise(this);
    bgNoise.play();
    bgNoise.amp(0.003);

    searchHeads = new ArrayList<SearchHead>();
    pointsToDraw = new ArrayDeque<Integer>();
    for (int i = 0; i < 5; i++) {
      searchHeads.add(new SearchHead((int) random(0, width-5), (int) random(0, height-5)));
    }
}

void animatePoints() {
  int initialSize = pointsToDraw.size();
  for (int i = 0; i < initialSize/2; i++) {
    int x = pointsToDraw.remove();
    int y = pointsToDraw.remove();

    // draw around the point
    for (int j = blockSize/-2; j < blockSize/2; j++) {
      for (int k = blockSize/-2; k < blockSize/2; k++) {
        if (withinBounds(x+j, y+k)) {
          pixels[(k+y)*width+(j+x)] = color(0, 255, 0);
        }
      }
    }
  
    if (withinBounds(x-5, y-5)) {
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
  iterationScale += map(noise(iteration*0.02), 0, 1, -0.0005, 0.001);
  // println(iterationScale);
  // println(iteration); // combine this with iterationScale to one var
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
        float red = noise((i+iteration*iterationScale)*noiseResolution, (j+iteration*iterationScale)*noiseResolution) *noiseScale + 20;
        pixels[j*width+i] = color(red, GREEN_SKY, BLUE_SKY);
    }
  }

  int startingHeadNum = searchHeads.size();
  for (int i = 0; i < startingHeadNum; i++) {
    SearchHead head = searchHeads.get(i);
    head.moveOnRandomPath();

    pointsToDraw.add(head.currX);
    pointsToDraw.add(head.currY);

    if (random(0, 1) < 0.002) {
      searchHeads.add(new SearchHead(head.currX, head.currY));
    }
  }

  if (searchHeads.size() > 10) {
    if (random(0, 1) < 0.1) {
      searchHeads.remove(int(random(0, searchHeads.size())));
    }
  }


  animatePoints();
  updatePixels();
  iteration++;
  delay(delayTime);
}
