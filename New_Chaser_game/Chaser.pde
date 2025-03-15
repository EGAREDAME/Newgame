// Chaser class with health, bounce, and damage.
class Chaser 
{
  float x, y;
  float xSpd, ySpd;
  float accelerationFactor;
  float frictionFactor = 0.9;
  float size;
  boolean active;
  boolean large;
  char appearance;
  float health = 50;
  
  public Chaser() 
  {
    int side = int(random(4));
    if (side == 0) 
    {
      x = -20;
      y = random(height);
    }
    else if (side == 1) 
    {
      x = width + 20;
      y = random(height);
    } 
    else if (side == 2) 
    {
      x = random(width);
      y = -20;
    } 
    else 
    {
      x = random(width);
      y = height + 20;
    }
    
    xSpd = 0;
    ySpd = 0;
    
    large = random(1) < 0.3;
    if (large) 
    {
      size = 40;
      accelerationFactor = 0.5;
    } 
    else 
    {
      size = 20;
      accelerationFactor = 1.0;
    }
    
    char[] possibleAppearances = {'X','O','@'};
    appearance = possibleAppearances[int(random(possibleAppearances.length))];
    active = true;
  }
  
  public void update() 
  {
    if (!active) return;
    if (mouseX > x) xSpd += accelerationFactor;
    if (mouseX < x) xSpd -= accelerationFactor;
    if (mouseY > y) ySpd += accelerationFactor;
    if (mouseY < y) ySpd -= accelerationFactor;
    x += xSpd;
    y += ySpd;
    xSpd *= frictionFactor;
    ySpd *= frictionFactor;
  }
  
  public void bounce() 
  {
    xSpd = -1.2 * xSpd;
    ySpd = 1.2 * ySpd;
  }
  
  public void takeDamage(float dmg) 
  {
    health -= dmg;
    if (health <= 10 && active) 
    {
      
      // Trigger a splat effect when health is low.
      splaters.add(new Splat(x, y, size));
      deactivate();

      
    }
    if (health <= 0) 
    {
      deactivate();
    }
  }
  
  public boolean hits(float px, float py) 
  {
    float d = dist(x, y, px, py);
    return (d < size/2 + 10);
  }
  
  public void deactivate() 
  {
    active = false;
  }
  
  public boolean isActive() 
  {
    return active;
  }
  
  public void display() 
  {
    if (!active) return;
    textAlign(CENTER, CENTER);
    textSize(size);
    fill(255,255,0);
    text(appearance, x, y);
    // Draw health bar above the chaser.
    float barWidth = 30;
    float barHeight = 4;
    float healthRatio = health / 50.0;
    fill(0);
    rect(x, y - size/2 - 10, barWidth, barHeight);
    fill(255,0,0);
    rectMode(CORNER);
    rect(x - barWidth/2, y - size/2 - 10 - barHeight/2, barWidth * healthRatio, barHeight);
    rectMode(CENTER);
  }
}
