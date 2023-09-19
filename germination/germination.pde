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
int extinctionThreshold = 20; // start an extinction event once drawing all the points begins to take too long

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

// nodes that move around on the canvas leaving a trail behind them
class SearchHead {
    
    int currX, currY;
    Direction previousDir;
    
    public SearchHead(int currX, int currY) {
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
        
        while(newDir == this.previousDir) {
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
    return(x > 0 && y > 0 && x < width && y < height);
}

void setup() {
    // size(1024, 1024);
    noCursor();
    fullScreen(P2D, SPAN);
    int numClusters;

    // set update speed based on screen dimensions 
    if(width <= 128 || height <= 128) {
        delayTime = 10;
        numClusters = 5;
        extinctionThreshold = 0;
    } else if (width <= 256 || height <= 256) {
        delayTime = 50;
        numClusters = 8;
        extinctionThreshold = 0;
    } else if (width <= 512 || height <= 512) {
        delayTime = 100;
        numClusters = 10;
        extinctionThreshold = 3;
    } else if (width <= 1024 || height <= 1024) {
        delayTime = 2000;
        numClusters = 20;
        extinctionThreshold = 10;
    } else {
        delayTime = 6000;
        numClusters = 25;
        extinctionThreshold = 50;
    }
    // set the timer back so that we draw right away on first frame
    timeSinceBgDraw = -delayTime - 5;
    
    searchHeads = new ArrayList<SearchHead>();
    pointsToDraw = new ArrayDeque<Integer>();
    
    // create initial cluster of heads
    for (int j = 0; j < numClusters; j++) {
        int clusterWidth = int(random(0, width));
        int clusterHeight = int(random(0, height));
        for (int i = 0; i < 5; i++) {
            searchHeads.add(new SearchHead(clusterWidth + int(random(width /-  20, width / 20)), clusterHeight + int(random(height /-  20, height / 20))));
        }
    }
    
    noiseDetail(7);
}

// redraw all nodes on noise map
void animatePoints() {
    int initialSize = pointsToDraw.size();
    for (int i = 0; i < initialSize / 2; i++) {
        int x = pointsToDraw.remove();
        int y = pointsToDraw.remove();
        
        // draw around the point
        for (int j = blockSize /-  2; j < blockSize / 2; j++) {
            for (int k = blockSize /-  2; k < blockSize / 2; k++) {
                if (withinBounds(x + j, y + k)) {
                    pixels[(k + y) * width + (j + x)] = color(21, 138, 52, 54);
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

// draw the noise map
void drawBackground() {
    noiseSeed(int(random(0, 100000000)));
    iterationScale += map(noise(iteration * 0.02), 0, 1, -0.0005, 0.001);
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            float red = noise((i + iteration * iterationScale) * noiseResolution,(j + iteration * iterationScale) * noiseResolution) * noiseScale + 20;
            pixels[j * width + i] = color(red, GREEN_SKY, BLUE_SKY);
        }
    }
    
    timeSinceBgDraw = millis();
}

// move all heads in a random direction with a random chance of:
// - moving head to a new location
// - adding a new head at the current spot
// - adding a new head in a random location
// - deleting a random head 
void moveHeads() {
    int startingHeadNum = searchHeads.size();
    for (int i = 0; i < startingHeadNum; i++) {
        SearchHead head = searchHeads.get(i);
        
        // random shuffling of head position
        if (random(0, 1) < 0.001) {
            head.currX = int(random(0, width));
            head.currY = int(random(0, height));
        }
        head.moveOnRandomPath();
        
        pointsToDraw.add(head.currX);
        pointsToDraw.add(head.currY);
        
        // random spawn event at the current head (a head split)
        if (random(0, 1) < 0.01) {  // 0.001
            searchHeads.add(new SearchHead(head.currX, head.currY));
        }
        
    }
    
    // random deletion of a head
    if(searchHeads.size() > 10) {
        if (random(0, 1) < 0.1) {
            searchHeads.remove(int(random(0, searchHeads.size())));
        }
    }
    
    // random spawn event in random location
    if(random(0, 1) < 0.05) {
        searchHeads.add(new SearchHead(int(random(0, width)), int(random(0, height))));
    }
}

// kill a random amount of heads and points
void doExtinctionEvent() {
    int removeLimit = int(random(int(searchHeads.size() / 2), searchHeads.size() * 3 / 4));
    int headIdx = searchHeads.size() - 1;
    for (int i = 0; i < removeLimit; i++) {
        searchHeads.remove(headIdx);
        headIdx--;
    }
    
    removeLimit = int(random(int(pointsToDraw.size() / 2), pointsToDraw.size() * 3 / 4));
    removeLimit = removeLimit % 2 == 0 ? removeLimit : removeLimit - 1; // ensure it's divisible by 2
    for (int i = 0; i < removeLimit; i++) {
        pointsToDraw.remove();
    }
}

void draw() {
    loadPixels();
    
    if(millis() - timeSinceBgDraw > delayTime) {
        drawBackground();
    }
    
    int start = millis();
    moveHeads();
    animatePoints();
    int end = millis();
    
    // start an extinction event when drawing all the points takes too long OR the points are drowning out the canvas
    if(end - start > extinctionThreshold || pointsToDraw.size() > (3.0 / 5.0) * width * height) {
        doExtinctionEvent();
    }
    
    delay(20);
    updatePixels();
    iteration++;
}
