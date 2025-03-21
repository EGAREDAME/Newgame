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
    if (meter >= ((i+1) * (meterMax/(float)numSegments))) 
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
  stroke(255,50);
  for (int i = 0; i < width; i += 50) 
  {
    for (int j = 0; j < height; j += 50) 
    {
      ellipse(i, j, 5, 5);
    }
  }
}
