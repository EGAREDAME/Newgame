// Splat class for a simple splat effect.
class Splat 
{
  PImage splat;
  float xPos, yPos;
  int timer = 255;
  float angle;
  float size;
  
  public Splat(float x, float y, float s) 
  {
    xPos = x;
    yPos = y;
    size = s;
    angle = random(TWO_PI);
  }
  
  public void drawSplat() 
  {
    pushMatrix();
    translate(xPos, yPos);
    rotate(angle);
    tint(255, timer);
    circle( xPos, yPos,5);
    popMatrix();
    timer--;
  }
}
