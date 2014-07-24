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
    fill(0,255,0);
    tint(255,10);
    noStroke();
    ellipse( x,y,size,size );
  }
}
