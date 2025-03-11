import processing.sound.*;
import java.util.ArrayList;

// Global Variables
PImage playerImg;
Player player;
SoundFile soundCatch, soundSpawn, soundInvul;
ArrayList<Chaser> chasers;
ScoreTracker scoreTracker;

// Timing variables
float spawnInterval = 2000;   // ms between spawns
float lastSpawnTime = 0;
float meter = 0;
float meterMax = 100;
boolean invulnerable = false;
float invulTime = 5000;       // ms
float invulStartTime = 0;
int previousMillis = 0;

void setup()
{
  size(1500, 800);
  imageMode(CENTER);
  rectMode(CENTER);
  textAlign(CENTER);
  noCursor();
  background(51);
  // Load assets
  soundCatch = new SoundFile(this, "S_JOS_00000.wav");
  soundSpawn = new SoundFile(this, "click.wav");
  soundInvul = new SoundFile(this, "AV004_00.wav");
  playerImg = loadImage("player.png");

  // Create player (starting at center)
  player = new Player(playerImg, width/2, height/2);

  // Initialize game objects
  chasers = new ArrayList<Chaser>();
  scoreTracker = new ScoreTracker();

  previousMillis = millis();
}

void draw()
{
  // Compute delta time
  int currentMillis = millis();
  float dt = currentMillis - previousMillis;
  previousMillis = currentMillis;

  // Clear and set background based on score
  int r = (int)map(scoreTracker.getScore(), 0, 100, 51, 150);
  background(r, 51, 51);

  // Draw background grid
  drawBackgroundGrid();

  // Update score
  scoreTracker.update(dt);

  // Spawn new chasers at regular intervals
  if (millis() - lastSpawnTime > spawnInterval)
  {
    chasers.add(new Chaser());
    lastSpawnTime = millis();
    soundSpawn.play();
  }

  // Update and display each chaser
  for (Chaser c : chasers)
  {
    c.update();
    c.display();

    // Collision check with player: if chaser hits player and player is not invulnerable,
    // trigger game over; if invulnerable, kill enemy and bounce both.
    if (c.isActive() && c.hits(player.x, player.y))
    {
      if (invulnerable)
      {
        c.takeDamage(50);  // kill enemy (each chaser starts with 50 health)
        c.bounce();
        player.bounce();
      } 
      else
      {
        // In a full game you might have the player take damage here.
        soundCatch.play();
        println("Game Over! Final Score: " + int(scoreTracker.getScore()));
        noLoop();
      }
    }
  }

  // New: Check for collisions between chasers (bounce off each other)
  for (int i = 0; i < chasers.size(); i++)
  {
    for (int j = i+1; j < chasers.size(); j++)
    {
      Chaser c1 = chasers.get(i);
      Chaser c2 = chasers.get(j);
      if (c1.isActive() && c2.isActive())
      {
        float d = dist(c1.x, c1.y, c2.x, c2.y);
        if (d < (c1.size/2 + c2.size/2))
        {
          c1.bounce();
          c2.bounce();
        }
      }
    }
  }

  // Manage invulnerability meter
  if (!invulnerable)
  {
    meter += dt * (meterMax / invulTime);
    if (meter >= meterMax)
    {
      invulnerable = true;
      invulStartTime = millis();
      meter = meterMax;
      soundInvul.play();
    }
  } 
  else
  {
    if (millis() - invulStartTime > invulTime)
    {
      invulnerable = false;
      meter = 0;
    }
  }

  // Update and display the player
  player.update();
  player.display();

  // Display score and invulnerability meter
  scoreTracker.display();
  drawMeter();

  if (invulnerable)
  {
    float remaining = (invulTime - (millis()-invulStartTime)) / 1000.0;
    fill(255);
    textSize(20);
    text("Invulnerability: " + nf(remaining, 1, 1) + "s", 10, 60);
  }
}
// Note: The Collision and Splat classes have been removed as requested.

// -------------------------------
// Key Event Handlers and Reset
// -------------------------------

// -------------------------------
// Utility Functions
// -------------------------------
void drawMeter() 
{
  int numSegments = 10;
  int segmentWidth = 10;
  int gap = 2;
  int x = 10;
  int y = height - 30;
  for (int i = 0; i < numSegments; i++) 
  {
    if (meter >= ((i+1)*(meterMax/(float)numSegments))) 
    {
      fill(0, 0, 255);
    } 
    else 
    {
      fill(50);
    }
    rect(x + i*(segmentWidth+gap), y, segmentWidth, 20);
  }
}

void drawBackgroundGrid() 
{
  stroke(255, 50);
  for (int i = 0; i < width; i += 50) 
  {
    for (int j = 0; j < height; j += 50) 
    {
      ellipse(i, j, 5, 5);
    }
  }
}

class ScoreTracker 
{
  private float score;
  public ScoreTracker() 
  {
    score = 0;
  }
  public void update(float dt) 
  {
    score += dt / 1000.0;
  }
  public float getScore() 
  {
    return score;
  }
  public void display() 
  {
    fill(255);
    textSize(20);
    text("Score: " + int(score), 10, 30);
  }
}

// -------------------------------
// Class Definitions
// -------------------------------
class Player 
{
  PImage img;
  float x, y;
  float vx = 0, vy = 0;  // Bounce velocity
  float size = 20;
  float health = 100;

  public Player(PImage img, float startX, float startY) 
  {
    this.img = img;
    x = startX;
    y = startY;
  }

  public void update() 
  {
    // Follow the mouse with a smoothing factor and include bounce velocity
    float followStrength = 0.2;
    x += followStrength * (mouseX - x) + vx;
    y += followStrength * (mouseY - y) + vy;
    // Decay bounce velocity
    vx *= 0.9;
    vy *= 0.9;
  }

  public void bounce() 
  {
    // Reverse bounce velocity (simple fixed effect)
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
    if (img != null) {
      imageMode(CENTER);
      image(img, x, y);
    } 
    else 
    {
      noStroke();
      fill(invulnerable ? color(0, 255, 0) : color(255, 0, 0));
      ellipse(x, y, size, size);
    }
    // Draw health bar above the player
    float barWidth = 40;
    float barHeight = 5;
    float healthRatio = health / 100.0;
    fill(0);
    rect(x, y - 30, barWidth, barHeight);
    fill(0, 255, 0);
    rectMode(CORNER);
    rect(x - barWidth/2, y - 30 - barHeight/2, barWidth * healthRatio, barHeight);
    rectMode(CENTER);
  }
}

void keyPressed() {
  if (key == 'p' || key == 'P') 
  {
    if (isLooping()) 
    {
      noLoop();
      println("Game Paused");
    } 
    else 
    {
      loop();
      println("Game Resumed");
    }
  }
  if (key == 'r' || key == 'R') 
  {
    resetGame();
    println("Game Reset");
  }
  if (keyCode == UP) 
  {
    println("UP key pressed");
  } 
  else if (keyCode == DOWN) 
  {
    println("DOWN key pressed");
  } 
  else if (keyCode == LEFT) 
  {
    println("LEFT key pressed");
  } 
  else if (keyCode == RIGHT) 
  {
    println("RIGHT key pressed");
  }
}

void keyReleased() 
{
  println("Key released: " + key);
}
void resetGame() 
{
  chasers = new ArrayList<Chaser>();
  scoreTracker = new ScoreTracker();
  meter = 0;
  invulnerable = false;
  lastSpawnTime = millis();
  loop();
}# Newgame
