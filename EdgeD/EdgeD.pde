/**
 * Getting Started with Capture.
 * 
 * Reading and displaying an image from an attached Capture device. 
 */

import processing.video.*;
import java.io.*;
import java.util.*;

int thresh = 20;
Capture cam;
int imgC = 0;

float xpos, ypos;    // Starting position of shape    

float xspeed = 2.8;  // Speed of the shape
float yspeed = 2.2;  // Speed of the shape

int xdirection = 1;  // Left or Right
int ydirection = 1;  // Top to Bottom
boolean go = true;
boolean whiteBack = false;
import ddf.minim.*;

Minim minim;
AudioPlayer player;



void setup() {
  size(640, 480);

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
    cam.start();
  }
  rectMode(CORNER);
  minim = new Minim(this);
  
}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  image(cam, 0, 0);
  
  if (go) {
  loadPixels();
  
  color[] temp = new color[ 640 * 480 ];
  
  for (int y =1; y < 479; y++ ) {
    for (int x = 1; x <639; x++) {
        int loc = y*640 + x;
        color c = pixels[loc];
        color left = pixels[loc - 1];
        color right = pixels[loc + 1];
        color up = pixels[loc - 640];
        color down = pixels[loc + 640];
        
        float rVal = sqrt( sq( red(left) - red(right)) + sq(red(up) - red(down)));
        float gVal = sqrt( sq( green(left) - green(right)) + sq(green(up) - green(down)));
        float bVal = sqrt( sq( blue(left) - blue(right)) + sq(blue(up) - blue(down)));
        int value = (int) ((rVal + gVal + bVal) / 3);
        if (value>thresh) {
          value = 255;
        } else {
          value = 0;
        }
        if (whiteBack) {
          value = 255-value;
        }
        temp[loc] = color(value);
    }
  }
  
  for (int i = 0; i< temp.length; i++) {
    pixels[i] = temp[i];
  }
  
  updatePixels();
  }
  
  xpos = xpos + ( xspeed * xdirection );
  ypos = ypos + ( yspeed * ydirection );
  
  
  if (xpos > 540  || xpos < 0) {
    xdirection *= -1;
  }
  if (ypos > 400 || ypos < 0) {
    ydirection *= -1;
  }
  
  image( cam, xpos, ypos, 100, 80 );
}


void keyPressed() {
  
  if (keyCode == 32) {
    imgC++;
    saveFrame("image-" + imgC + ".jpg");
    player = minim.loadFile("shutter.mp3");
    player.play();
    pause(2);
  }
  else if ( keyCode == 61) {
    thresh += 2;
  }
  else if (keyCode == 45){
  thresh -= 2;
  }
  else if (keyCode == 8) {
     go = !go;
  }
  else if (keyCode == 10) {
    whiteBack = !whiteBack;
  }
  keyCode = 0;
 
}

void pause(int seconds){
  Date start = new Date();
  Date end = new Date();
  while(end.getTime() - start.getTime() < seconds * 1000){
      end = new Date();
  }
}
  
