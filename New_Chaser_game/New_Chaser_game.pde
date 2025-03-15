import processing.sound.*;
import java.util.ArrayList;

// Global Variables
PImage playerImg, splat, messi;
Player player;
SoundFile soundCatch, soundSpawn, soundInvul;
ArrayList<Chaser> chasers;
ScoreTracker scoreTracker;
ArrayList<Splat> splaters = new ArrayList<Splat>();

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
  playerImg = loadImage("player.png.png");
  splat = loadImage("splat.png.png");
  messi = loadImage("messi.png");
  // Create player (starting at center)
  //player = new Player(playerImg, width/2, height/2);
  
  
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
  
  // Set background based on score
  int r = (int)map(scoreTracker.getScore(), 11, 100, 51, 150);
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
    
    // Check collision between chaser and player
    if (c.isActive() && c.hits(player.x, player.y)) 
    {
      if (invulnerable) 
      {
        // When invulnerable, damage (and potentially kill) enemy and bounce both
        c.takeDamage(50); // damage chaser; if health < 10, it will splat and deactivate
        c.bounce();
        player.bounce();
      } 
      else 
      {
        // When not invulnerable, player takes damage and bounces
        player.takeDamage(50);
        c.bounce();
        player.bounce();
        if (player.health <= 0) 
        {
          //image(splat,c.x, c.y);
          soundCatch.play();
          println("Game Over! Final Score: " + int(scoreTracker.getScore()));
          noLoop();
        }
      }
    }
  }
  
  // Check for chaser-to-chaser collisions (bounce off each other)
  for (int i = 0; i < chasers.size(); i++) 
  {
    for (int j = i + 1; j < chasers.size(); j++) 
    {
      Chaser c1 = chasers.get(i);
      Chaser c2 = chasers.get(j);
      if (c1.isActive() && c2.isActive()) 
      {
        float d = dist(c1.x, c1.y, c2.x, c2.y);
        if (d < (c1.size/2 + c2.size/2)) {
          c1.bounce();
          c2.bounce();
        }
      }
    }
  }
  
  // Display splat effects (if any)
  for (int i = splaters.size()-1; i >= 0; i--) 
  {
    Splat s = splaters.get(i);
    image(splat, s.xPos, s.yPos);
    if (s.timer < 0) 
    {
      splaters.remove(i);
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
  
  // Display score and meter
  scoreTracker.display();
  drawMeter();
  
  // Display invulnerability timer
  if (invulnerable) 
  {
    float remaining = (invulTime - (millis() - invulStartTime)) / 1000.0;
    fill(255);
    textSize(20);
    text("Invulnerability: " + nf(remaining,1,1) + "s", 10, 60);
  }
}


// -------------------------------
// Key Event Handlers and Reset
// -------------------------------
void keyPressed() 
{
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
  else if (keyCode == LEFT) {
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
