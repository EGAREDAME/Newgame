void resetGame() 
{
  chasers = new ArrayList<Chaser>();
  scoreTracker = new ScoreTracker();
  meter = 0;
  invulnerable = false;
  lastSpawnTime = millis();
  splaters = new ArrayList<Splat>();  // Clear splat effects.
  player.health = 100;  // Reset player health.
  loop();
}
