class Circle {
  
  int x, y, size, type;
  boolean needShift;
  final int SENS = 1;
  final int REMOVE = 2;
  final int BLURRY = 3;
  
  
  Circle( int x2, int y2, int size2, int t) {
    x = x2;
    y = y2;
    size = size2;
    needShift = true;
    type = t;
  }
  
  void display() {
    
    noTint();
    noStroke();
    
    if (type == SENS) {
      fill(0,255,0);
    }
    if (type == REMOVE) {
      fill(255,0,0);
    }
    if (type == BLURRY) {
      fill(0,0,255);
    }
    
    ellipse( x,y,size,size );
  }
}
