// ScoreTracker class.
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
    text("Score: " + int(score), 40, 60);
  }
}
