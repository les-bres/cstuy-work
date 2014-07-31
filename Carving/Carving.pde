import processing.video.*;
import java.io.*;
import java.util.*;
Capture cam;
import ddf.minim.*;

Minim minim;
AudioPlayer player;


PImage img, bkg;
int l, h, l2;
int[][] diffs;
ArrayList<Circle> careful,delete,blur;
int[][] carefulA, deleteA, blurA;
boolean draw;
int prevSize;
int pos = 0;
int sensitivity;
int eSize;
Integer[][] expHor, expVer;
int horPos, verPos;
boolean needResHor, needResVer;
boolean removing, blurring;
int picNum = 1;

PFont mono;
boolean editing;
boolean saving;
boolean begin;
boolean camera;
boolean asking;
boolean done;
String typing = "";
String saved = "";
boolean first = true;

int rect1X, rect1Y;
int rect2X, rect2Y;
int rectSize = 60;
color rect1Color, rect2Color;
color rect1Highlight, rect2Highlight;
boolean rect1Over = false;
boolean rect2Over = false;


void setup() {  
  frame.setResizable(true);
  //l = 640;
  //h = 480;
  //l2 = l;
  size(640,480);
  frame.setSize(640,480);
 
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

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[0]);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);
    
    // Start capturing the images from the camera
    
  }
  minim = new Minim(this);
  
  careful = new ArrayList<Circle>();
  delete = new ArrayList<Circle>();
  blur = new ArrayList<Circle>();
  /*
  carefulA = new int[h][l];
  deleteA = new int[h][l];
  blurA = new int[h][l];
  */
  sensitivity = 500;
  eSize = 20;
  /*
  expHor = new Integer[h][h];
  expVer = new Integer[l][l];
  */
  needResHor = true;
  needResVer = true;
  horPos = 2;
  verPos = 2;
  bkg = loadImage("background.jpg");
  begin = true;
  
  rect1Color = color(48,100,48);
  rect1Highlight = color(78,165,77);
  rect2Color = color(50,75,113);
  rect2Highlight = color(84,127,193);
  rect1X = width/4 ;
  rect1Y = 300;
  rect2X = width/4 * 3 ;
  rect2Y = 300;
  ellipseMode(CENTER);
  //rectMode(CENTER);
}

void draw() {
  if (begin) {
    tint(255,50);
    image(bkg, 0,0, bkg.width, bkg.height * 1.1);
    noTint();
    textSize(32);
    textAlign(CENTER);
    fill(0);
    text("Welcome to Seam Carving.", width/2, 100);
    textSize(15);
    text("Take a Photo to Edit", rect1X + 20, rect1Y - 10);
    text("Upload Your own Photo", rect2X + 20, rect2Y - 10);
    update(mouseX,mouseY);
    if (rect1Over) {
      fill(rect1Highlight);
    }
    else {
      fill(rect1Color);
    }
    stroke(0);
    rect(rect1X,rect1Y, rectSize, rectSize,11);
    
    if (rect2Over) {
      fill(rect2Highlight);
    }
    else {
      fill(rect2Color);
    }
    stroke(0);
    rect(rect2X,rect2Y, rectSize, rectSize,11);
    
    
  }
  else if (asking) {
    image(bkg, 0,0, bkg.width, bkg.height * 1.1);
    textSize(20);
    fill(0);
    rectMode(CENTER);
    text("Drag your file to the this folder and type it's name exactly as it appears. Ex: jump.jpg", width/2, 200,400,200);
    fill(255);
    rect( width/2, 300, 300, 50, 10);
    fill(0);
    textSize(15);
    text(typing,width/2, 300);
    
    
  }
  else if (editing) {
    if (first) {
      if (camera) {
      img = loadImage("cur.jpg");
      }
      else {
        img = loadImage(saved);
      }
      size(img.width,img.height);
      frame.setSize(img.width, img.height);
      l = img.width;
      h = img.height;
      l2 =l;
      carefulA = new int[h][l];
      deleteA = new int[h][l];
      blurA = new int[h][l];
      expHor = new Integer[h][h];
      expVer = new Integer[l][l];
      
      image(img,0,0);
      loadPixels();
      first = false;
      addBlack();

    }
    else {
      diffs = new color[h][l];
      
      for (int y =1; y < (h-1); y++ ) {
        for (int x = 1; x < (l-1); x++) {
            int loc = y*l + x;
            color c = pixels[loc];
            color left = pixels[loc - 1];
            color right = pixels[loc + 1];
            color up = pixels[loc - l];
            color down = pixels[loc + l];
            
            float rVal = sqrt( sq( red(left) - red(right)) + sq(red(up) - red(down)));
            float gVal = sqrt( sq( green(left) - green(right)) + sq(green(up) - green(down)));
            float bVal = sqrt( sq( blue(left) - blue(right)) + sq(blue(up) - blue(down)));
        
            int value = (int) ((rVal + gVal + bVal) / 3);
            //temp[loc] = color(value);
            diffs[y][x] = value;
            //println(value);
        }
      }
      
      for (int i = 0; i< l; i++) {
        pixels[i] = color(0);
      }
      
      for (int j = 0; j < h; j++) {
        pixels[j*l] = color(0);
      }
      
      for (int j = 0; j < h; j++) {
        pixels[(j+1)*l -1 ] = color(0);
      }
      
        
      for (int i = 0; i< l; i++) {
        pixels[l*(h-1)+i] = color(0);
      }
      
      updatePixels();
        
      if (draw) {
        fill(0,255,0);
        Circle cur = new Circle( mouseX,mouseY, eSize, 1 );
        cur.display();
        displaySens();
      }
      
      if (removing) {
        noTint();
        fill(254,0,0);
        ellipse(mouseX,mouseY, eSize, eSize);
        
        displayDel();
      }
      
      if (blurring) {
        noTint();
        fill(0,0,255);
        ellipse(mouseX,mouseY, eSize, eSize);
        displayBlur();
      }
    }
  }
  else if (done) {
    PImage i = loadImage("edited" + picNum + ".jpg");
    image(i,0,0);
    fill(0);
    textSize(20);
    textAlign(LEFT);
    text("Your Saved Image",20,20);
    fill(230,10,10);
    rectMode(CORNER);
    rect(40,30,100,30);
    fill(0);
    textSize(14);
    text("Start Over", 50,50);
  }
    else {
      if (!saving) {
        cam.start();
        if (cam.available() == true) {
        cam.read();
        }
        image(cam, 0, 0);
      }
    }
}

void keyPressed() {
    // left = 37
    if (editing) {
      // left = 37
    if (keyCode == 37) {
      removeVer();
      //shiftLeft();
    }
    // top = 38
    if (keyCode == 38) {
      removeHor();
      //shiftUp();
    }
    // right = 39
    if (keyCode == 39) {
      if (l2 < img.width)
        expVer();
      else
        needResVer = true;
    }
    // down = 40
    if (keyCode == 40) {
      if (h < img.height)
        expHor();
      else
        needResHor = true;
    }
    if (keyCode==32) {
      draw = !draw;
      removing = false;
      blurring = false;
    }
    if (keyCode == 61) {
      eSize += 4;
    }
    if (keyCode == 45) {
      eSize -=4;
    }
    if (keyCode == 46) {
      sensitivity += 20;
      println(sensitivity);
    }
    if (keyCode ==44) {
      sensitivity -= 20;
      println(sensitivity);
    }
    if (keyCode ==82) {
      removing = !removing;
      blurring = false;
      draw = false;
    }
    if (keyCode == 66) {
      blurring = !blurring;
      draw = false;
      removing = false;
    }
    if (keyCode == 10) {
      if (blurring) {
        blurArea();
      }
    }
    if (keyCode == 83) {
      saving = true;
      removing = false;
      blurring = false;
      draw = false;
      editing = false;
      
      saveFrame("edited" + picNum + ".jpg");
      
      PImage i = loadImage("edited" + picNum + ".jpg");
      
      size(l2, h);
      frame.setSize(l2,h);
      image(i, 0,0);
      editing = false;
      done = true;
      saveFrame("edited" + picNum + ".jpg");
      
    }
  }
  else {
    if (camera) {
      saveFrame("cur.jpg");
      player = minim.loadFile("shutter.mp3");
      player.play();
      editing = true;
    }
    if (asking) {
      if (key == '\n' ) {
        saved = typing;
        typing = ""; 
        asking = false;
        editing = true;
      } 
      else if ( keyCode == 8) {
        if (typing.length() > 0 ) 
          typing = typing.substring(0, typing.length()-1);
      }
      else {
        typing = typing + key; 
      }
      
    }
  }

  keyCode = 0;
  //updatePixels();
  
}

void mouseDragged() {
  if (editing) {
    if (draw)
      careful.add( new Circle(mouseX, mouseY, eSize,1 ));
      updateSens();
    if (removing) {
      delete.add( new Circle(mouseX, mouseY, eSize, 2));
      updateDel();
    }
    if (blurring) {
      blur.add( new Circle(mouseX, mouseY, eSize, 3));
      updateBlur();
    } 
    addBlack();
  }
}

void mousePressed() {
  if (begin) {
    if (rect1Over) {
      begin = false;
      camera = true;
    }
    if (rect2Over) {
      begin = false;
      asking = true;
    }
  }
  if (done) {
    if (overRect(40,30,100,30)) {
      reset();
    }
  }
    
}
    

void expVer() {
  int[][] temp = new int[h][l];
  markSens();
  
  //use all surrounding
  for (int y = 1; y< (h-1); y++) {
    for (int x = 2; x < (l2-1); x++) {
      temp[y][x] = diffs[y][x];
    }
  }
  
  /*
  //uses only pixels directly right
  for (int x = 2; x < (l2-1); x++) {
    for (int y = 1; y < (h-1); y++) {
      int loc = y*l + x;
      color c = pixels[loc];
      color right = pixels[loc-1];
      float rVal = sqrt( sq( red(c) - red(right)) );
      float gVal = sqrt( sq( green(c) - green(right)) ) ;
      float bVal = sqrt( sq( blue(c) - blue(right)) );
      
      int value = (int) ((rVal + gVal + bVal) / 3);
      temp[y][x] = value;
    }
  }
  */

  int[][] temp2 = new int[h][l];
  for (int i = 2; i < l2-1; i++) {
    temp2[1][i] = temp[1][i];
  }
  
  for (int j = 2; j < h-1; j++) {
    for (int i = 2; i < (l2-1); i++) {
      int cur = temp[j][i];
      int a = temp2[j-1][i];
      int b,c;
      if (i-1 > 1)
        b = temp2[j-1][i-1];
      else
        b = -1;
      if (i+1< l2-1)
        c = temp2[j-1][i+1];
      else 
        c = -1;
      int min = getMin(a,b,c);
      temp2[j][i] = min + cur;
    }
  }
  if (needResVer) {
    for (int i =2; i < l2-1; i++) {
      expVer[i][0] = i;
      expVer[i][1] = temp2[h-2][i];
    }
    
    Arrays.sort( expVer, 2, l2-1, new Comparator<Integer[]>() {
      public int compare(final Integer[] a, final Integer[] b) {
        return a[1].compareTo( b[1] );
      }
    });
    verPos = 2;
    needResVer = false; 
  }

  int cur = expVer[verPos][0];
  println("cur=" +cur + " val=" + expVer[verPos][1]);
  
  verPos++;
  for (int i = verPos; i < l2-1-(verPos-3); i++) {
    if (expVer[i][0] > cur) {
      expVer[i][0]++;
    }
  }
  
  for (int i = h-2; i>0; i--) {
    
    int loc = i * l + cur;
    
    color c = pixels[loc];
    color right = pixels[loc-1];
    
    float rVal = (red(c) + red(right)) /2 ;
    float gVal = (green(c) + green(right)) /2 ;
    float bVal = (blue(c) + blue(right)) /2;
    
    //move right
    int max = l * (i+1) - 1;
    for (int j = max; j > loc; j-= 1) {
      pixels[j] = pixels[j-1];
    }
    pixels[loc] = color( rVal, gVal, bVal);
    cur = getMinIndexRow( cur, i-1, temp2);
  }
  l2++;
  updatePixels();
}

void expHor() {
  markSens();
  int[][] temp = new int[h][l];
  
  // uses all surrounding pixels
  for (int y = 2; y< (h-1); y++) {
    for (int x =1; x < (l2-1); x++) {
      temp[y][x] = diffs[y][x];
    }
  }
  
  //uses only pixels directly above
  /*
  for (int y =2; y < (h-1); y++ ) {
    for (int x = 1; x < (l2-1); x++) {
        int loc = y*l + x;
        color c = pixels[loc];
        color up = pixels[loc - l];
        
        float rVal = sqrt( sq( red(c) - red(up)) );
        float gVal = sqrt( sq( green(c) - green(up)) ) ;
        float bVal = sqrt( sq( blue(c) - blue(up)) );
    
        int value = (int) ((rVal + gVal + bVal) / 3);
        //temp[loc] = color(value);
        temp[y][x] = value;
        //println(value);
    }
  }
  */
  
  int[][] temp2 = new int[h][l];
  for (int i = 2; i < h-1; i++) {
    temp2[i][1] = temp[i][1];
  }
  
  for (int i = 2; i < (l2 - 1); i++) {
    for (int j = 2; j < (h-1); j++) {
      int cur = temp[j][i];
      int a = temp2[j][i-1];
      int b,c;
      if (j-1 > 1)
        b= temp2[j-1][i-1];
      else
        b = -1;
      if (j+1 < h-1)
        c = temp2[j+1][i-1];
      else
        c = -1;
      int min = getMin(a,b,c);
      temp2[j][i] = min + cur;
      if (temp2[j][i] == 0) {
        //println( "j=" + j + " i=" + i);
      }
    }
  }
  if (needResHor) {
    for (int i =2; i < (h-1); i++) {
      expHor[i][0] = i;
      expHor[i][1] = temp2[i][l2-2];
    }
    
    Arrays.sort( expHor, 2, h-1, new Comparator<Integer[]>() {
      public int compare(final Integer[] a, final Integer[] b) {
        return a[1].compareTo( b[1] );
      }
    });
   horPos = 2;
   needResHor = false;
   
   for (int i=2; i < h-1; i++) {
     //println("{" + expHor[i][0] + ", " + expHor[i][1] + "}");
   }
  }
  

 int cur = expHor[horPos][0];
 println("cur=" +cur + " val=" + expHor[horPos][1]);
 
 horPos++;
 println(horPos);
 for (int i = horPos; i < h-1-(horPos-3); i++) {
   if ( expHor[i][0] > cur) {
     expHor[i][0]++;
   }
 }
 
  for (int i = l2-2; i > 0; i--) {
    
    int loc = cur * l + i;
    
    color c = pixels[loc];
    color up = pixels[loc - l];
    
    float rVal = (red(c) + red(up)) /2 ;
    float gVal = (green(c) + green(up)) /2 ;
    float bVal = (blue(c) + blue(up)) /2;

    //move down
    int max = pixels.length - l + i;
    for (int j = max; j > loc; j-= l) {
      pixels[ j ] = pixels[j - l];
    }
    pixels[loc] = color( rVal, gVal, bVal);
      
    cur = getMinIndexCol( cur, i-1, temp2);
  }
  h++;
  updatePixels();
}

void removeHor() {
  
  int[][] temp = new int[h][l2];
  markSens();
  markDel();
  
  for (int i = 1; i < (h-1); i++) {
    temp[i][1] = diffs[i][1];
  }
  
  for (int i = 2; i < (l2-1); i++) {
    for (int j = 1; j < (h-1); j++) {
      int cur = diffs[j][i];
      int a = temp[j][i-1];
      int b, c;
      if (j-1 > 0)
        b = temp[j-1][i-1];
      else
        b = -1;
      if (j+1 < (h-1))
        c = temp[j+1][i-1];
      else
        c = -1;
      int min = getMin(a,b,c);
      temp[j][i] = min + cur;
    }
  }
   
  int shortestI = 1;     
  for (int i = 2; i < (h-1); i++)  {
    if (temp[i][l2-2] < temp[shortestI][l2-2]) {
      shortestI = i;
    }
  }
  
  int[][] coords = new int[l2-1][4];
  for (int[] row: coords)
    Arrays.fill(row, -1);
  
  int cur = shortestI;
  
  for (int i = l2-2; i > 0; i--) {
    coords[i][0] = cur;
    for (int j = cur; j < h-1; j++) {
      pixels[l*j+i] = pixels[l*(j+1) + i];
      deleteA[j][i] = deleteA[j+1][i];
      carefulA[j][i] = carefulA[j+1][i];
    }
    
    cur = getMinIndexCol( cur, i-1, temp);
  }
  h--;
  
  for (int n = 0; n <2; n++) {
    for (int i = 1; i < coords.length; i++) {
      double[] colors = blurPixel( coords[i][0], i);
      
      coords[i][1] = (int) colors[0];
      coords[i][2] = (int) colors[1];
      coords[i][3] = (int) colors[2];
    }
    
    for (int i = 1; i < coords.length; i++) {
      if (coords[i][1] != -1) {
        pixels[coords[i][0] * l + i] = color( coords[i][1], coords[i][2], coords[i][3] );
      }
    }
    updatePixels();
  }
}
void removeVer() {
  int[][] temp = new int[h][l2];
  
  markSens();
  markDel();

  for (int i = 1; i < (l2-1); i++) {
    temp[1][i] = diffs[1][i];
  }
  
  for (int i = 2; i < (h-1); i++) {
    for (int j = 1; j < (l2-1); j++) {
      int cur = diffs[i][j];
      int a = temp[i-1][j];
      int b,c;
      if (j-1 > 0)
        b = temp[i-1][j-1];
      else 
        b = -1;
      if (j+1 < (l2-1) )
        c = temp[i-1][j+1];
      else
        c = -1;
      int min = getMin(a,b,c);
      temp[i][j] = min + cur;

    }
  }
  
   
  int shortestI = 1;     
  for (int i = 2; i < (l2-1); i++)  {
    if (temp[h-2][i] < temp[h-2][shortestI]) {
      shortestI = i;
    }
  }
  
  int[][] coords = new int[h-1][4];
  for (int[] row: coords)
    Arrays.fill(row, -1);
  
  int cur = shortestI;
  for (int i = h-2; i > 0; i--) {
    coords[i][0] = cur;
    for (int j = cur; j < l2-1; j++) {
      pixels[i*l + j] = pixels[i*l+j+1];
      deleteA[i][j] = deleteA[i][j+1];
      carefulA[i][j] = carefulA[i][j+1];
    }
    cur = getMinIndexRow( cur, i-1, temp);
  }
  l2--;
  
  for (int n=0; n < 10; n++) {
    for ( int i = 1; i < coords.length; i++) {
      double[] colors = blurPixel(i, coords[i][0]);
      
      coords[i][1] = (int) colors[0];
      coords[i][2] = (int) colors[1];
      coords[i][3] = (int) colors[2];
    }
    
    for ( int i = 1; i < coords.length; i++) {
      if (coords[i][1] != -1) {
        pixels[i*l + coords[i][0]] = color( coords[i][1], coords[i][2], coords[i][3] );
      }
    }
    updatePixels();
  }
}



int getMin( int a, int b, int c) {
  if ( a!= -1 && b != -1 && c!= -1 ) {
    return min(a,b,c);
  }
  else {
    if (a== -1)
      return min(b,c);
    if (b == -1)
      return min(a,c);
    else
      return min(a,b);
  }

}
  
int getMinIndexCol( int a, int col, int[][] t) {
  int mid = t[a][col];
  int up,down;
  if ((a-1) > 1) 
    up = t[a-1][col];
  else
    up = -1;
  if ((a+1) < (h-1)) {
    down = t[a+1][col];
  }
  else
    down = -1;
    
  int min = getMin( up, mid, down);

  if (min == mid)
    return a;
  if (min == up)
    return a-1;
  else
    return a+1;
}


int getMinIndexRow( int a, int row, int[][] t) {

  int mid = t[row][a];
  int left, right;
  if ((a-1) > 1) 
    left = t[row][a-1];
  else
    left = -1;
  if ((a+1) < l2-2)
    right = t[row][a+1];
  else
    right = -1;
 
  int min = getMin( left, mid, right);
   
  if (min == mid)
    return a;
  if (min == left)
    return a-1;
  else
    return a+1;
  
}

void updateBlur() {
  for (int n = 0; n < blur.size(); n++) {
    Circle c = blur.get(n);
    int x = c.x;
    int y = c.y;
    int size = c.size;
    for (int i = y - size; i <= y+size; i++) {
      for (int j = x - size; j <= x+size; j++) {
        if ( i > 0 && i < h && j>0 && j < l2) {
          if ( sq( j - x) + sq( i - y) <= sq(size/2)) {
            blurA[i][j] = 1;
          }
        }
      }
    }
    blur.remove(n);
  }
}   

void displayBlur() {
  fill(0,0,255);
  noStroke();
  for (int y = 0; y < blurA.length; y++) {
    for (int x = 0; x < blurA[0].length; x++) {
      if (blurA[y][x] == 1) {
        rect(x,y,1,1);
      }
    }
  }
}  

void blurArea() {
  
  color[] newPs = new color[pixels.length];
  Arrays.fill(newPs, -1);
  
  for (int y = 2; y < blurA.length; y++) {
    for (int x = 2; x < blurA[0].length; x++) {
      if (blurA[y][x] == 1) {
        
        double[] colors = blurPixel(y,x);
        newPs[y*l+x] = color( (int)colors[0], (int)colors[1], (int)colors[2]);
      }
    }
  } 

  for (int[] row: blurA) {
    Arrays.fill(row, 0);
  }
  for (int i = 0; i < newPs.length; i++) {
    if (newPs[i] != -1) {
      pixels[i] = newPs[i];
    }
  }
  updatePixels();
}

void updateSens() {
  for (int num = 0; num < careful.size(); num++) {
    Circle c = careful.get(num);
    int x = c.x;
    int y = c.y;
    int size = c.size;
    for (int i = y - size; i <= y+size; i++) {
      for (int j = x - size; j <= x+size; j++) {
        if ( i > 0 && i < h && j>0 && j < l2) {
          if ( sq( j - x) + sq( i - y) <= sq(size/2)) {
            carefulA[i][j] = 1;
          }
        }
      }
    }
    careful.remove(num);
  }
}

void displaySens() {
  fill(0,255,0);
  noStroke();
  for (int y = 0; y < carefulA.length; y++) {
    for (int x = 0; x < carefulA[0].length; x++) {
      if (carefulA[y][x] == 1) {
        rect(x,y,1,1);
      }
    }
  }
}  

void markSens() {
  for (int y = 0; y < carefulA.length; y++) {
    for (int x = 0; x < carefulA[0].length; x++) {
      if (carefulA[y][x] == 1) {
        diffs[y][x] += sensitivity;
      }    
    }
  }
}


void markDel() {
  for (int y = 0; y < deleteA.length; y++) {
    for (int x = 0; x < deleteA[0].length; x++) {
      if (deleteA[y][x] == 1) {
        diffs[y][x] -= 500;
      }    
    }
  }
}

void updateDel() {
  
  for (int num = 0; num < delete.size(); num++) {
    Circle c = delete.get(num);
    int x = c.x;
    int y = c.y;
    int size = c.size;
    for (int i = y - size; i <= y+size; i++) {
      for (int j = x - size; j <= x+size; j++) {
        if ( i > 0 && i < h && j>0 && j < l2) {
          if ( sq( j - x) + sq( i - y) <= sq(size/2)) {
            deleteA[i][j] = 1;
          }
        }
      }
    }
    delete.remove(num);
  }
}

void displayDel() {
  fill(255,0,0);
  noStroke();
  for (int y = 0; y < deleteA.length; y++) {
    for (int x = 0; x < deleteA[0].length; x++) {
      if (deleteA[y][x] == 1) {
        rect(x,y,1,1);
      }
    }
  }
}
       

double[] blurPixel(int y, int x) {
  
  if (y<2 || y>(h-3) || x<2 || x > (l2-3)) {
    double[] ret = new double[3];
    ret[0] = red(pixels[l*y+x]);
    ret[1] = green(pixels[l*y+x]);
    ret[2] = blue(pixels[l*y+x]);
    return ret;
  }
  
  double red = 1.0/16 * red(pixels[(y-1)*l+x-1]) + 1.0/8 * red(pixels[(y-1)*l+x]) + 1.0/16 * red(pixels[(y-1)*l+x+1]);
  red+= 1.0/8 * red(pixels[l*y+x-1]) + 1.0/4 * red(pixels[l*y+x]) +1.0/8 * red(pixels[l*y+x+1]);
  red += 1.0/16 * red(pixels[(y+1)*l+x+1]) + 1.0/8 * red(pixels[(y+1)*l+x]) + 1.0/16 * red(pixels[(y+1)*l+x+1]);
  double green = 1.0/16 * green(pixels[(y-1)*l+x-1]) + 1.0/8 * green(pixels[(y-1)*l+x]) + 1.0/16 * green(pixels[(y-1)*l+x+1]);
  green+= 1.0/8 * green(pixels[l*y+x-1]) + 1.0/4 * green(pixels[l*y+x]) +1.0/8 * green(pixels[l*y+x+1]);
  green += 1.0/16 * green(pixels[(y+1)*l+x+1]) + 1.0/8 * green(pixels[(y+1)*l+x]) + 1.0/16 * green(pixels[(y+1)*l+x+1]);
  
  double blue = 1.0/16 * blue(pixels[(y-1)*l+x-1]) + 1.0/8 * blue(pixels[(y-1)*l+x]) + 1.0/16 * blue(pixels[(y-1)*l+x+1]);
  blue+= 1.0/8 * blue(pixels[l*y+x-1]) + 1.0/4 * blue(pixels[l*y+x]) +1.0/8 * blue(pixels[l*y+x+1]);
  blue += 1.0/16 * blue(pixels[(y+1)*l+x+1]) + 1.0/8 * blue(pixels[(y+1)*l+x]) + 1.0/16 * blue(pixels[(y+1)*l+x+1]);
  
  double[] ret = new double[3];
  ret[0] = red;
  ret[1] = green;
  ret[2] = blue;
  return ret;
}
  
      

void addBlack() {
  for ( int x = 0; x < l; x++) {
    pixels[ x ] = color(0);
  }
  for ( int y = 0; y< img.height; y++) {
    pixels[y*l] = color(0);
  }
  for ( int x = l2; x<l; x++) {
    for (int y = 0; y < img.height; y++) {
      pixels[y*l + x] = color(0);
    }
  }
  for (int y = h; y < img.height; y++) {
    for (int x = 0; x < l; x++) {
      pixels[y*l + x] = color(0);
    }
  }
}

void update(int x, int y) {
  if ( overRect(rect1X, rect1Y, rectSize, rectSize) ) {
    rect1Over = true;
    rect2Over = false;
  } else if ( overRect(rect2X, rect2Y, rectSize, rectSize) ) {
    rect2Over = true;
    rect1Over = false;
  } else {
    rect1Over = rect2Over = false;
  }
}

boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

void reset() {
  l = 640;
  h = 480;
  l2 = l;
  careful.clear();
  delete.clear();
  blur.clear();
  carefulA = new int[h][l];
  picNum++;
  editing = false;
  saving = false;
  begin = true;
  camera = false;
  asking = false;
  done = false;
  typing = "";
  saved = "";
  first = true;
  rect1Over = false;
  rect2Over = false;
  sensitivity = 500;
  eSize = 20;
  needResHor = true;
  needResVer = true;
  horPos = 2;
  verPos=2;
  size(640,480);
  frame.setSize(640,480);
  
}
  
