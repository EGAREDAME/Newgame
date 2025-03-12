import processing.sound.*;
import java.util.ArrayList;

// Global Variables
PImage playerImg, splat;
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

void setup() {
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
  splat = loadImage("splat.png");
  
  // Create player (starting at center)
  player = new Player(playerImg, width/2, height/2);
  
  // Initialize game objects
  chasers = new ArrayList<Chaser>();
  scoreTracker = new ScoreTracker();
  
  previousMillis = millis();
}

void draw() {
  // Compute delta time
  int currentMillis = millis();
  float dt = currentMillis - previousMillis;
  previousMillis = currentMillis;
  
  // Set background based on score
  int r = (int)map(scoreTracker.getScore(), 0, 100, 51, 150);
  background(r, 51, 51);
  
  // Draw background grid
  drawBackgroundGrid();
  
  // Update score
  scoreTracker.update(dt);
  
  // Spawn new chasers at regular intervals
  if (millis() - lastSpawnTime > spawnInterval) {
    chasers.add(new Chaser());
    lastSpawnTime = millis();
    soundSpawn.play();
  }
  
  // Update and display each chaser
  for (Chaser c : chasers) {
    c.update();
    c.display();
    
    // Check collision between chaser and player
    if (c.isActive() && c.hits(player.x, player.y)) {
      if (invulnerable) {
        // When invulnerable, damage (and potentially kill) enemy and bounce both
        c.takeDamage(50); // damage chaser; if health < 10, it will splat and deactivate
        c.bounce();
        player.bounce();
      } else {
        // When not invulnerable, player takes damage and bounces
        player.takeDamage(50);
        c.bounce();
        player.bounce();
        if (player.health <= 0) {
          soundCatch.play();
          println("Game Over! Final Score: " + int(scoreTracker.getScore()));
          noLoop();
        }
      }
    }
  }
  
  // Check for chaser-to-chaser collisions (bounce off each other)
  for (int i = 0; i < chasers.size(); i++) {
    for (int j = i + 1; j < chasers.size(); j++) {
      Chaser c1 = chasers.get(i);
      Chaser c2 = chasers.get(j);
      if (c1.isActive() && c2.isActive()) {
        float d = dist(c1.x, c1.y, c2.x, c2.y);
        if (d < (c1.size/2 + c2.size/2)) {
          c1.bounce();
          c2.bounce();
        }
      }
    }
  }
  
  // Display splat effects (if any)
  for (int i = splaters.size()-1; i >= 0; i--) {
    Splat s = splaters.get(i);
    s.drawSplat();
    if (s.timer < 0) {
      splaters.remove(i);
    }
  }
  
  // Manage invulnerability meter
  if (!invulnerable) {
    meter += dt * (meterMax / invulTime);
    if (meter >= meterMax) {
      invulnerable = true;
      invulStartTime = millis();
      meter = meterMax;
      soundInvul.play();
    }
  } else {
    if (millis() - invulStartTime > invulTime) {
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
  if (invulnerable) {
    float remaining = (invulTime - (millis() - invulStartTime)) / 1000.0;
    fill(255);
    textSize(20);
    text("Invulnerability: " + nf(remaining,1,1) + "s", 10, 60);
  }
}

// -------------------------------
// Utility Functions
// -------------------------------
void drawMeter() {
  int numSegments = 10;
  int segmentWidth = 10;
  int gap = 2;
  int x = 10;
  int y = height - 30;
  for (int i = 0; i < numSegments; i++) {
    if (meter >= ((i+1) * (meterMax/(float)numSegments))) {
      fill(0, 0, 255);
    } else {
      fill(50);
    }
    rect(x + i*(segmentWidth+gap), y, segmentWidth, 20);
  }
}

void drawBackgroundGrid() {
  stroke(255,50);
  for (int i = 0; i < width; i += 50) {
    for (int j = 0; j < height; j += 50) {
      ellipse(i, j, 5, 5);
    }
  }
}

// -------------------------------
// Class Definitions
// -------------------------------

// Player class with health, bounce effect, and following behavior.
class Player {
  PImage img;
  float x, y;
  float vx = 0, vy = 0;  // Bounce velocity
  float size = 20;
  float health = 100;
  
  public Player(PImage img, float startX, float startY) {
    this.img = img;
    x = startX;
    y = startY;
  }
  
  public void update() {
    // Follow the mouse with a smoothing factor plus bounce velocity.
    float followStrength = 0.2;
    x += followStrength * (mouseX - x) + vx;
    y += followStrength * (mouseY - y) + vy;
    // Decay bounce velocity.
    vx *= 0.9;
    vy *= 0.9;
  }
  
  public void bounce() {
    vx = -5;
    vy = -5;
  }
  
  public void takeDamage(float dmg) {
    health -= dmg;
    if (health < 0) health = 0;
  }
  
  public void display() {
    if (img != null) {
      imageMode(CENTER);
      image(img, x, y);
    } else {
      noStroke();
      fill(invulnerable ? color(0,255,0) : color(255,0,0));
      ellipse(x, y, size, size);
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

// ScoreTracker class.
class ScoreTracker {
  private float score;
  public ScoreTracker() {
    score = 0;
  }
  public void update(float dt) {
    score += dt / 1000.0;
  }
  public float getScore() {
    return score;
  }
  public void display() {
    fill(255);
    textSize(20);
    text("Score: " + int(score), 10, 30);
  }
}

// Chaser class with health, bounce, and damage.
class Chaser {
  float x, y;
  float xSpd, ySpd;
  float accelerationFactor;
  float frictionFactor = 0.9;
  float size;
  boolean active;
  boolean large;
  char appearance;
  float health = 50;
  
  public Chaser() {
    int side = int(random(4));
    if (side == 0) {
      x = -20;
      y = random(height);
    } else if (side == 1) {
      x = width + 20;
      y = random(height);
    } else if (side == 2) {
      x = random(width);
      y = -20;
    } else {
      x = random(width);
      y = height + 20;
    }
    
    xSpd = 0;
    ySpd = 0;
    
    large = random(1) < 0.3;
    if (large) {
      size = 40;
      accelerationFactor = 0.5;
    } else {
      size = 20;
      accelerationFactor = 1.0;
    }
    
    char[] possibleAppearances = {'X','O','@'};
    appearance = possibleAppearances[int(random(possibleAppearances.length))];
    active = true;
  }
  
  public void update() {
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
  
  public void bounce() {
    xSpd = -1.2 * xSpd;
    ySpd = -1.2 * ySpd;
  }
  
  public void takeDamage(float dmg) {
    health -= dmg;
    if (health <= 10 && active) {
      // Trigger a splat effect when health is low.
      splaters.add(new Splat(x, y, size));
      deactivate();
    }
    if (health <= 0) {
      deactivate();
    }
  }
  
  public boolean hits(float px, float py) {
    float d = dist(x, y, px, py);
    return (d < size/2 + 10);
  }
  
  public void deactivate() {
    active = false;
  }
  
  public boolean isActive() {
    return active;
  }
  
  public void display() {
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

// Splat class for a simple splat effect.
class Splat {
  float xPos, yPos;
  int timer = 255;
  float angle;
  float size;
  
  public Splat(float x, float y, float s) {
    xPos = x;
    yPos = y;
    size = s;
    angle = random(TWO_PI);
  }
  
  public void drawSplat() {
    pushMatrix();
    translate(xPos, yPos);
    rotate(angle);
    tint(255, timer);
    image(splat, 0, 0, size, size);
    popMatrix();
    timer--;
  }
}

// -------------------------------
// Key Event Handlers and Reset
// -------------------------------
void keyPressed() {
  if (key == 'p' || key == 'P') {
    if (isLooping()) {
      noLoop();
      println("Game Paused");
    } else {
      loop();
      println("Game Resumed");
    }
  }
  if (key == 'r' || key == 'R') {
    resetGame();
    println("Game Reset");
  }
  if (keyCode == UP) {
    println("UP key pressed");
  } else if (keyCode == DOWN) {
    println("DOWN key pressed");
  } else if (keyCode == LEFT) {
    println("LEFT key pressed");
  } else if (keyCode == RIGHT) {
    println("RIGHT key pressed");
  }
}

void keyReleased() {
  println("Key released: " + key);
}

void resetGame() {
  chasers = new ArrayList<Chaser>();
  scoreTracker = new ScoreTracker();
  meter = 0;
  invulnerable = false;
  lastSpawnTime = millis();
  splaters = new ArrayList<Splat>();  // Clear splat effects.
  player.health = 100;  // Reset player health.
  loop();
}
