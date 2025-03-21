
// Player class with health, bounce effect, and following behavior.
class Player 
{
  PImage img, messi;
  float x, y;
  float vx = 0, vy = 0;  // Bounce velocity
  float size = 20;
  float health = 100;
  
  public Player(PImage img, PImage messi, float startX, float startY) 
  {
    this.img = img;
    this.messi = messi;
    x = startX;
    y = startY;
  }
  
  public void update() 
  {
    // Follow the mouse with a smoothing factor plus bounce velocity.
    float followStrength = 0.2;
    x += followStrength * (mouseX - x) + vx;
    y += followStrength * (mouseY - y) + vy;
    // Decay bounce velocity.
    vx *= 0.9;
    vy *= 0.9;
  }
  
  public void bounce() 
  {
    vx = -5;
    vy = -5;
  }
  
  public void takeDamage(float dmg) 
  {
    health -= dmg;
    if (health < 0) health = 0;
  }
  
  public void display() 
  {
    if (img != null) 
    {
      imageMode(CENTER);
      image(playerImg, x, y);
      image(messi, x, y);
    } 
    else 
    {
      noStroke();
      fill(invulnerable ? color(0,255,0) : color(255,0,0));
      image(messi, x, y);
    }
    // Draw health bar above the player.
    float barWidth = 40;
    float barHeight = 5;
    float healthRatio = health / 100.0;
    fill(0);
    rect(x, y - 30, barWidth, barHeight);
    fill(0,255,0);
    rectMode(CORNER);
    rect(x - barWidth/2, y - 30 - barHeight/2, barWidth * healthRatio, barHeight);
    rectMode(CENTER);
  }
}
