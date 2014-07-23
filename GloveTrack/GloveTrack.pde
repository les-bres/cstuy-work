import processing.video.*;

Capture cam;
int[][] objects;
int l,h;
//ArrayList<Integer> label;
//ArrayList<Integer> unique;
int[][] edges;

void setup() {
  l = 640;
  h = 480;
  size(l, h);

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 640, 480);
  } if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    cam = new Capture(this, cameras[0]);
    
    cam.start();
  }
  
}
  
void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  image(cam, 0, 0);
  objects = new int[h][l];
  
  loadPixels();
  markBlobs();
  updatePixels();
  
  findEdges();
  updatePixels();
}

void markBlobs() {
  for (int y = 0; y < h; y++) {
    for (int x = 0; x <l; x++) {
      if (isHand( pixels[y*l + x])) {
        pixels[ y * l + x ] = color(255);
        objects[y][x] = 255;
      }
      else {
        pixels[ y * l + x ] = color(0);
        objects[y][x] = 0;
      }
        
    }
  }
}

boolean isHand(color c) {
  float green = green(c);
  float blue = blue(c);
  if ((green/blue < (0.6307366 + 0.15)) && (green/blue > (0.6307366 - 0.15))) {
    return true;
  }
  else {
    return false;
  }
}

void findEdges() {
  edges = new int[4][2];
  // find top
  A:for (int y = 0; y<h; y++) {
    B: for (int x = 0; x < l; x++) {
        if (pixels[ y*l + x] != color(0) ) {
          edges[0][0] = y;
          edges[0][1] = x;
          break A;
        }
    }
  }
  
  // find bottom
  C: for (int y = h-1; y > -1; y--) {
     D: for (int x = 0; x < l; x++) {
        if (pixels[ y*l + x] != color(0) ) {
          edges[1][0] = y;
          edges[1][1] = x;
          break C;
        }
      }
  }
  
    // find left
  E: for (int x = 0; x < l; x++) {
     F: for (int y = 0; y < h; y++)  {
        if (pixels[ y*l + x] != color(0) ) {
          edges[2][0] = y;
          edges[2][1] = x;
          break E;
        }
      }
  }
  
  // right
  G: for (int x = (l-1); x > -1; x--) {
     H: for (int y = 0; y < h; y++)  {
        if (pixels[ y*l + x] != color(0) ) {
          edges[3][0] = y;
          edges[3][1] = x;
          break G;
        }
      }
  }
  /*
  ellipseMode(CENTER);
  fill(255);
  for (int i =0; i < edges.length; i++) {
    ellipse( edges[i][1], edges[i][0], 10, 10);
    println( edges[i][0] + " , " + edges[i][1] );
  }
  */
  makeRect( edges );
}

void makeRect( int[][] coords ) {
  // order: top, bottom, left, right
  int maxY, minY, maxX, minX;
  maxY = coords[0][0];
  minY = coords[1][0];
  maxX = coords[3][1];
  minX = coords[2][1];
  rectMode(CORNER);
  noFill();
  stroke(255,0,0);
  rect( minX, minY, maxX - minX, maxY - minY );
  fill(255);
}
