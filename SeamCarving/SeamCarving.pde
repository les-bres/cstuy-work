import java.util.*;

PImage img;
int l, h, l2;
int[][] diffs;
ArrayList<Circle> careful;
boolean draw = true;
int prevSize;
int pos = 0;
int sensitivity;
int eSize;
Integer[][] expHor, expVer;
int horPos, verPos;
boolean needResHor, needResVer;
boolean removing, blurring;
PFont mono;

void setup() {  
  
  img = loadImage("beach.jpg");
  
  l = img.width;
  l2 = l;
  h = img.height;
  size(l, h);

  image(img, 0, 0);
  loadPixels();
  careful = new ArrayList<Circle>();
  prevSize = 0;
  sensitivity = 500;
  eSize = 20;
  expHor = new Integer[h][h];
  expVer = new Integer[l][l];
  needResHor = true;
  needResVer = true;
  horPos = 2;
  verPos = 2;
  mono = loadFont("AndaleMono-48.vlw");
}

void draw() {

  //color[] temp = new color[ l * h ];
  
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
  
  updatePixels();
    
  if (draw) {
    Circle cur = new Circle( mouseX,mouseY, eSize );
    cur.display();

    for (Circle c: careful) {
      c.display();
    }
  }
  
  if (removing) {
    noTint();
    fill(254,0,0);
    ellipse(mouseX,mouseY, eSize, eSize);
  }
  
  if (blurring) {
    noTint();
    fill(0,0,255);
    ellipse(mouseX,mouseY, eSize, eSize);
  }
}

void keyPressed() {
  // left = 37
  if (keyCode == 37) {
    removeVer();
    //shiftLeft();
  }
  // top = 38
  if (keyCode == 38) {
    removeHor();
    shiftUp();
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
  //println(keyCode);
  keyCode = 0;
  updatePixels();
  
}

void mouseDragged() {
  if (draw)
    careful.add( new Circle(mouseX, mouseY, eSize));
  if (removing) {
    for (int i = mouseX - eSize; i < mouseX+eSize; i++) {
      for (int j = mouseY - eSize; j < mouseY + eSize; j++) {
        if ( j > 0 && j < h-1 && i > 0 && i < l2-1) {
          if (sq(j-mouseY) + sq(i-mouseX) < sq(eSize) * .3)
            pixels[j*l + i] = color(254,0,0);
        }
      }
    }
    updatePixels();
  }
  if (blurring) {
    blurArea(  mouseY,  mouseX, eSize);
  } 
    
}

void mousePressed() {
  println( "r=" + red(pixels[mouseY * l + mouseX]) + "g=" + green(pixels[mouseY * l + mouseX]) + "b=" + blue(pixels[mouseY * l + mouseX]) );
}
void expVer() {
  int[][] temp = new int[h][l];
  
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
  for (Circle c: careful) {
    int x = c.x;
    int y = c.y;
    int size = c.size;
    
    for (int i = y - size; i <= y + size; i++) {
      for (int j = x - size; j <= x + size; j++) {
        if ( i > 0 && i < h && j>0 && j < l2) {
          if ( sq( j - x) + sq( i - y) <= sq(size) && temp[i][j] < sensitivity) {
            temp[i][j] += sensitivity;
          }
        }
      }
    }
  }
  
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
    
    //move left
    int max = l * (i+1) - 1;
    for (int j = max; j > loc; j-= 1) {
      pixels[j] = pixels[j-1];
    }
    pixels[loc] = color( rVal, gVal, bVal);
    cur = getMinIndexRow2( cur, i-1, temp2);
  }
  l2++;
  updatePixels();
}

void expHor() {
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
  //marksens
  for (Circle c: careful) {
    int x = c.x;
    int y = c.y;
    int size = c.size;
    
    for (int i = y - size; i <= y + size; i++) {
      for (int j = x - size; j <= x + size; j++) {
        if ( i > 0 && i < h && j>0 && j < l2) {
          if ( sq( j - x) + sq( i - y) <= sq(size) && temp[i][j] < sensitivity) {
            temp[i][j] += sensitivity;
          }
        }
      }
    }
  }
  
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
      
    cur = getMinIndexCol2( cur, i-1, temp2);
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
  
  
  int cur = shortestI;
  
  for (int i = l2-2; i > 0; i--) {
    pixels[ cur * l + i] = color(255,0,0);
    
    for (int j =0; j < careful.size(); j++) {
      Circle c = careful.get(j);
        if ( cur < c.y && c.needShift && c.x == i) {
          if (c.y > 0 ) {
            c.y--;
            c.needShift = false;
           }
           else {
            careful.remove(j);
           }
       }
    }
    cur = getMinIndexCol( cur, i-1, temp);
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
    //println( temp[h-2][i]);
    if (temp[h-2][i] < temp[h-2][shortestI]) {
      shortestI = i;
    }
  }
  
  
  int cur = shortestI;
  for (int i = h-2; i > 0; i--) {
    //pixels[ l * i + cur] = color(255,0,0);
    for (int j = cur; j < l2-1; j++) {
      pixels[i*l + j] = pixels[i*l+j+1];
    }
    
    for (int j = 0; j < careful.size(); j++) {
      Circle c = careful.get(j);
      if (cur < c.x && c.needShift && c.y == i) {
        if (c.x > 0) {
          c.x--;
          c.needShift = false;
        }
        else { 
        careful.remove(j);
        }
      }
    }
    pixels[i*l + l2 -1] = color(0);
    cur = getMinIndexRow( cur, i-1, temp);
  }
  l2--;
  updatePixels();
}

void shiftUp() {
  boolean shift = false;
  for (int i = 1; i < l-1; i++) {
    for (int j = 1; j < h-2; j++) {
      if (!shift) {
        if ( pixels[ l * j + i] == color(255,0,0)) {
          shift = true;
        }
      }
      if (shift) {
        pixels[ l * j + i ] = pixels[l * (j+1) + i];
      }
    }
    pixels[ l * (h-1) + i] = color(0);
    shift = false;
  }
  h--;
  updatePixels();
}
  
void shiftLeft() {
  boolean shift = false;
  for (int y =0; y < h; y++) {
    for (int x = 0; x < l-2; x++) {
      if (!shift) {
        if (pixels[l*y + x] == color(255,0,0)) {
          shift = true;
        }
      }
      if (shift) {
        pixels[l*y + x] = pixels[l * y + x + 1];
      }
    }
    pixels[l * y + l2 - 1] = color(0);
    shift = false;
  }
  l2--;
  updatePixels();
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
  if ((a-1) > 0) 
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

int getMinIndexCol2( int a, int col, int[][] t) {
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

int getMinIndexRow2( int a, int row, int[][] t) {

  //println(a + ", " + row);
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
  //println ( left + ", " + mid + ", " + right);
  int min = getMin( left, mid, right);
    //println(min);
  if (min == mid)
    return a;
  if (min == left)
    return a-1;
  else
    return a+1;
  
}

int getMinIndexRow( int a, int row, int[][] t) {

  //println(a + ", " + row);
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
  //println ( left + ", " + mid + ", " + right);
  int min = getMin( left, mid, right);
    //println(min);
  if (min == mid)
    return a;
  if (min == left)
    return a-1;
  else
    return a+1;
  
}


void markSens() {
    for (Circle c: careful) {
    c.needShift = true;
    int x = c.x;
    int y = c.y;
    int size = c.size;
    
    boolean[][] used = new boolean[h][l];
    for (int i = y - size; i <= y + size; i++) {
      for (int j = x - size; j <= x + size; j++) {
        if ( i > 0 && i < h && j>0 && j < l2) {
          if ( sq( j - x) + sq( i - y) <= sq(size) && used[i][j] ==false) {
            used[i][j] = true;
            diffs[i][j] += sensitivity;
          }
        }
      }
    }
  }
}

void markDel() {
  for (int y = 1; y < h-1; y++) {
    for (int x = 1; x < l2-1; x++) {
      if (pixels[ y*l + x] == color(254,0,0)) {
        diffs[y][x] -= 1000;
      }
    }
  }
}
      
void blurArea( int y, int x, int size ) {      
  int rSum = 0;
  int bSum = 0;
  int gSum = 0;
  int totalNum = 0;
  for (int i = x - eSize; i < x + size; i++) {
    for (int j = y - eSize; j < y + size; j++) {
      if ( j > 0 && j < h-1 && i > 0 && i < l2-1) {
        if (sq(j-y) + sq(i-x) < sq(size) * .3) {
          totalNum++;
          rSum += red( pixels[j*l + i]);
          bSum += blue( pixels[j*l+ i]);
          gSum += green( pixels[j*l+i]);
        }
      }
    }
  }
  rSum /= totalNum;
  bSum /= totalNum;
  gSum /= totalNum;
  for (int i = x - size; i < x + size; i++) {
    for (int j = y - size; j < y + size; j++) {
      if ( j > 0 && j < h-1 && i > 0 && i < l2-1) {
        if (sq(j-y) + sq(i-x) < sq(eSize) * .3) {
          pixels[j*l + i] = color ( (red( pixels[j*l + i]) + rSum) / 2, (green( pixels[j*l + i]) + gSum) / 2, (blue( pixels[j*l + i]) + bSum) / 2);
        }
      }
    }
  }
  updatePixels();
}
      
