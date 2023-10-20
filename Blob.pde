
class Blob {
  float minx;
  float miny;
  float maxx;
  float maxy;
  float theta;
  float atantheta;
  float noiseMax;


  int id = 0;

  int lifespan = maxLife;

  boolean taken = false;

  Blob(float x, float y) {
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
  }

  boolean checkLife() {
    lifespan--; 
    if (lifespan < 0) {
      return true;
    } else {
      return false;
    }
  }


  void show() {
    stroke(0);
    fill(255, lifespan);
    strokeWeight(2);
    rectMode(CORNERS);
    //rect(minx, miny, maxx, maxy);

    textAlign(CENTER);
    textSize(64);
    fill(0);
    //text(id, minx + (maxx-minx)*0.5, maxy - 10);
    textSize(32);
    //text(lifespan, minx + (maxx-minx)*0.5, miny - 10);
  }


  void add(float x, float y) {
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
  }

  void become(Blob other) {
    minx = other.minx;
    maxx = other.maxx;
    miny = other.miny;
    maxy = other.maxy;
    lifespan = maxLife;
  }

  float size() {
    return (maxx-minx)*(maxy-miny);
  }

  PVector getCenter() {
    float x = (maxx - minx)* 0.5 + minx;
    float y = (maxy - miny)* 0.5 + miny;    
    return new PVector(x, y);
  }

  boolean isNear(float x, float y) {

    float cx = max(min(x, maxx), minx);
    float cy = max(min(y, maxy), miny);
    float d = distSq(cx, cy, x, y);

    if (d < distThreshold*distThreshold) {
      return true;
    } else {
      return false;
    }
  }
  
  
  float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}

void drawEllipse(){
    float x = (maxx - minx)* 0.5 + minx;
    float y = (maxy - miny)* 0.5 + miny;
    noFill();
    strokeWeight(2);
    stroke(255);
    //ellipse(x,y,90,90);
    ellipse(x,y,(maxx - minx)*1.1,(maxy - miny)*1.1);
}



void drawline(Blob temp_b){
      float x = (maxx - minx)* 0.5 + minx;
      float y = (maxy - miny)* 0.5 + miny;
      float x1 = (temp_b.maxx - temp_b.minx)* 0.5 + temp_b.minx;
      float y1 = (temp_b.maxy - temp_b.miny)* 0.5 + temp_b.miny;
      float dblobs = distSq(x,y,x1,y1);
      //println("dblobs "+ dblobs);
      noiseMax = map(dblobs,27000,223000,0,100);
      //noiseMax = 10;
      //draw blob 0
      pushMatrix();
      translate(x,y);
      stroke(255);
      noFill();
      strokeWeight(1);
      beginShape();
      for (float a =0; a<TWO_PI; a+=0.2){
        float x_offset = map(cos(a+phase),-1,1,0,noiseMax);
        float y_offset = map(sin(a+phase),-1,1,0,noiseMax);
        float r = map(noise(x_offset,y_offset),0,1,45,90);
        //float r = map(noise(x_offset,y_offset),0,1,min((maxx-minx),(maxy-miny)),max((maxx-minx),(maxy-miny)));
        float x_c = r * cos(a);
        float y_c = r * sin(a);
        vertex(x_c,y_c);
            }
      endShape(CLOSE);
      popMatrix();
      
      //draw blob 0
      pushMatrix();
      translate(x1,y1);
      beginShape();
      for (float a =0; a<TWO_PI; a+=0.2){
        float x_offset = map(cos(a+phase),-1,1,0,noiseMax);
        float y_offset = map(sin(a+phase),-1,1,0,noiseMax);
        float r = map(noise(x_offset,y_offset),0,1,45,90);
        //float r = map(noise(x_offset,y_offset),0,1,min((temp_b.maxx-temp_b.minx),(temp_b.maxy-temp_b.miny)),max((temp_b.maxx-temp_b.minx),(temp_b.maxy-temp_b.miny)));
        float x_c = r * cos(a);
        float y_c = r * sin(a);
        vertex(x_c,y_c);
            }
      endShape(CLOSE);
      popMatrix();
      
      if (x1>x){
        theta = (y1-((y1+y)/2))/(x1-(x1+x)/2);
        }
      if (x1<x){
        theta = (y-((y1+y)/2))/(x-(x1+x)/2);
        }
      atantheta = atan(theta);
  
      pushMatrix();
      translate((x1+x)/2,(y1+y)/2);
      rotate(atantheta); 
      stroke(255);
      strokeWeight(5);
      if (dblobs<45000 ){
      beginShape();
      for (float line_y = -600; line_y<600 ; line_y+=2){
      //vertex(map(noise(t),0,1,-100,100),line_y);
      vertex(random(-10,10),line_y);
      }
      endShape();
      }
      else {
      line(0,-600,0,600);
      }
      popMatrix(); 
      
      //textSize(24);
      //fill(255,0,0);
      //text(dblobs,100,30);
      


  
}


}
