class Thing{
  float x = random(0,640);
  float y = random(0,480);
  float size = random(1,2.5);
  float radius = random(2,15);
  //float phase = random(0,TWO_PI);
  float phase1 = 9*noise(0.02*x, 0.02*y);
  
  void show(){
    
    stroke(255,200);
    strokeWeight(size);
    point(x+radius*cos(TWO_PI*t1 + phase1),y+radius*sin(TWO_PI*t1 + phase1));
  }


}
