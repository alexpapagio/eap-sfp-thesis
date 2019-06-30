import org.openkinect.processing.*;
import codeanticode.syphon.*;

SyphonServer server;

//declare Kinect
Kinect kinect;

//declare the camvas
PImage img;

//declare an array list with blobs
ArrayList<Blob> blobs = new ArrayList<Blob>();

int n = 3000;
Thing[] array = new Thing[n];
float t1=1;

boolean recording = false;
color trackColor;
int maxLife = 50;
float distThreshold = 50;
int blobCounter = 0;

float depth_max = 800;
float depth_min = 350 ;

float phase =0;
float t=0;

void setup() {
  //fullScreen();
  size(640, 480, P3D);

  //initialize kinect and its depth camera
  kinect = new Kinect(this);
  kinect.initDepth();

  //create my camvas
  img = createImage(kinect.width, kinect.height, RGB);

  server = new SyphonServer(this, "Processing Syphon");

  trackColor = color(255, 0, 150);
  
  for (int i=0; i<n ; i++){
    array[i] = new Thing();
  }
}

void draw() {
  background(0);

  img.loadPixels();

  //declare an array list with blobs
  ArrayList<Blob> currentBlobs = new ArrayList<Blob>();

  //Get the raw depth as array of integers
  int[] depth = kinect.getRawDepth();

  //scan the feed from the kinect draw the objects that are close to it
  for (int x=0; x<kinect.width; x+=1) {
    for (int y=0; y<kinect.height; y+=1) {
      int offset = x + y*kinect.width;
      int d = depth[offset];

      if (d>depth_min && d<depth_max) {
        img.pixels[offset] = color(255, 0, 150);
      } else {
        img.pixels[offset] = color(0);
      }
    }
  }

  img.updatePixels();
  image(img,0,0);

  img.loadPixels();

  //Begin loop walk through every pixel of the camvas
  for ( int x=0; x<img.width; x++) {
    for ( int y=0; y<img.height; y++) {
      int loc = x + y*img.width;

      color currentColor = img.pixels[loc];

      if (currentColor == trackColor) {
        boolean found = false;
        for (Blob b : currentBlobs) {
          if (b.isNear(x, y)) {
            b.add(x, y);
            found = true;
            break;
          }
        }

        if (!found) {
          Blob b = new Blob(x, y);
          currentBlobs.add(b);
        }
      }
    }
  }
  //end of loop

  for (int i = currentBlobs.size()-1; i >= 0; i--) {
    if (currentBlobs.get(i).size() < 500) {
      currentBlobs.remove(i);
    }
  }

  // There are no blobs!
  if (blobs.isEmpty() && currentBlobs.size() > 0) {
    println("Adding blobs!");
    for (Blob b : currentBlobs) {
      b.id = blobCounter;
      blobs.add(b);
      blobCounter++;
    }
  } else if (blobs.size() <= currentBlobs.size()) {
    // Match whatever blobs you can match
    for (Blob b : blobs) {
      float recordD = 1000;
      Blob matched = null;
      for (Blob cb : currentBlobs) {
        PVector centerB = b.getCenter();
        PVector centerCB = cb.getCenter();         
        float d = PVector.dist(centerB, centerCB);
        if (d < recordD && !cb.taken) {
          recordD = d; 
          matched = cb;
        }
      }
      matched.taken = true;
      b.become(matched);
    }

    // Whatever is leftover make new blobs
    for (Blob b : currentBlobs) {
      if (!b.taken) {
        b.id = blobCounter;
        blobs.add(b);
        blobCounter++;
      }
    }
  } else if (blobs.size() > currentBlobs.size()) {
    for (Blob b : blobs) {
      b.taken = false;
    }


    // Match whatever blobs you can match
    for (Blob cb : currentBlobs) {
      float recordD = 1000;
      Blob matched = null;
      for (Blob b : blobs) {
        PVector centerB = b.getCenter();
        PVector centerCB = cb.getCenter();         
        float d = PVector.dist(centerB, centerCB);
        if (d < recordD && !b.taken) {
          recordD = d; 
          matched = b;
        }
      }
      if (matched != null) {
        matched.taken = true;
        // Resetting the lifespan here is no longer necessary since setting `lifespan = maxLife;` in the become() method in Blob.pde
        // matched.lifespan = maxLife;
        matched.become(cb);
      }
    }

    for (int i = blobs.size() - 1; i >= 0; i--) {
      Blob b = blobs.get(i);
      if (!b.taken) {
        if (b.checkLife()) {
          blobs.remove(i);
        }
      }
    }
  }

  if (currentBlobs.size()==0) {
    for (int i=0; i<n; i++){
    array[i].show();
  }
    } 
  
  else if (currentBlobs.size()==1) {
    for (Blob b : blobs) {
    b.drawEllipse();
    } 
   }else if (blobs.size()>1) { 
    blobs.get(1).drawline(blobs.get(0));
  }

   phase+=0.005;
   t+=0.1;
     t1+=0.02;
 
  for (Blob b : blobs) {
    b.show();
  } 
  
  server.sendScreen();
  
  if (recording){
    saveFrame("output/blobs_####.tif");
  }

 // println(depth_min, depth_max);
} //end of draw


void keyPressed() {
  if ( key == 'a' ) {
    depth_min++;
  }

  if ( key == 'z' ) {
    depth_min--;
  }

  if ( key == 's' ) {
    depth_max++;
  }

  if ( key == 'x' ) {
    depth_max--;
  }
  
  if ( key == 'r' ) {
    recording = !recording;
  }
}
