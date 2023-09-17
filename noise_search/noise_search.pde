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
int timeSinceBgDraw = -delayTime;

// geometry
int blockSize = 5;
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
    }

    
    this.moveInDirection(newDir);
  }

}

boolean withinBounds(int x, int y) {
  return (x > 0 && y > 0 && x < width && y < height);
}

void setup() {
  size(2000, 2000);
  // fullScreen();
  int numClusters;
  // set update speed based on screen dimensions 
  // TODO: set new head generation rate based off screen size
  if (width <= 128 || height <= 128) {
    delayTime = 10;
    numClusters = 5;
  } else if (width <= 256 || height <= 256) {
    delayTime = 50;
    numClusters = 8;
  } else if (width <= 512 || height <= 512) {
    delayTime = 100;
    numClusters = 10;
  } else if (width <= 1024 || height <= 1024) {
    delayTime = 750;
    numClusters = 20;
  } else {
    delayTime = 2500;
    numClusters = 25;
  }
  // set the timer back so that we draw right away on first frame
  timeSinceBgDraw = -delayTime - 5;

  searchHeads = new ArrayList<SearchHead>();
  pointsToDraw = new ArrayDeque<Integer>();

  for (int j = 0; j < numClusters; j++) {
    int clusterWidth = int(random(0, width));
    int clusterHeight = int(random(0, height));
    for (int i = 0; i < 5; i++) {
      searchHeads.add(new SearchHead(clusterWidth + int(random(width/-20, width/20)), clusterHeight + int(random(height/-20, height/20))));
    }
  }

  noiseDetail(7);
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
          pixels[(k+y)*width+(j+x)] = color(21, 138, 52, 54);
        }
      }
    }

    // add some chance that we don't re-draw this point again
    if (withinBounds(x, y) && random(0, 1) < 0.65) {
      pointsToDraw.add(x);
      pointsToDraw.add(y);
    }
  }
}

void drawBackground() {
  noiseSeed(int(random(0, 100000000)));
  iterationScale += map(noise(iteration*0.02), 0, 1, -0.0005, 0.001);
  for (int i = 0; i < width; i++) {
    for (int j = 0; j < height; j++) {
        float red = noise((i+iteration*iterationScale)*noiseResolution, (j+iteration*iterationScale)*noiseResolution) *noiseScale + 20;
        pixels[j*width+i] = color(red, GREEN_SKY, BLUE_SKY);
    }
  }

  timeSinceBgDraw = millis();
}


void draw() {
  loadPixels();

  if (millis() - timeSinceBgDraw > delayTime) {
    drawBackground();
  }

  int start = millis();
  int startingHeadNum = searchHeads.size();
  for (int i = 0; i < startingHeadNum; i++) {
    SearchHead head = searchHeads.get(i);
    head.moveOnRandomPath();

    pointsToDraw.add(head.currX);
    pointsToDraw.add(head.currY);

    if (random(0, 1) < 0.001) {
      searchHeads.add(new SearchHead(head.currX, head.currY));
    }

  }

  if (searchHeads.size() > 10) {
    if (random(0, 1) < 0.1) {
      searchHeads.remove(int(random(0, searchHeads.size())));
    }
  }

  if (random(0, 1) < 0.001) {
    searchHeads.add(new SearchHead(int(random(0, width)), int(random(0, height))));
  }
  animatePoints();
  int end = millis();
  println(end-start);

  updatePixels();
  iteration++;
}
