class Circle {
  
  int x, y, size;
  boolean needShift;
  
  Circle( int x2, int y2, int size2) {
    x = x2;
    y = y2;
    size = size2;
    needShift = true;
  }
  
  void display() {
    noTint();
    fill(0,255,0);
    noStroke();
    ellipse( x,y,size,size );
  }
}
