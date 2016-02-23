import java.util.Random;

final int NUM_OUTER_VERTS = 3;
final int INF = 1<<30;
final int orthoSphereR = 200;
float sx, sy;

EnrichedEmbedding test;

void setup() 
{
  size(1024, 768, P3D);
  background(255);
  fill(0, 0);
  test = new EnrichedEmbedding(NUM_OUTER_VERTS);
}

boolean drawing = false;

void draw()
{
  background(255);
  test.drawPSLG();
  test.drawRadii();
  
  if(keyPressed)
    switch(keyCode)
    {
      case(LEFT):
      {
        radii_update(test);
        break;
      }
      case(RIGHT):
      {
        stress_update(test);
        break;
      }
    }
   if(drawing)
   {
     float dx = mouseX - sx, dy = mouseY - sy, r = sqrt(dx*dx + dy*dy);
     
     pushStyle();
     
     noStroke();
     fill(185,205,240);
     ellipse(sx, sy, 2*r, 2*r);
     
     popStyle();
   }
}



void mousePressed()
{
  sx = mouseX; sy = mouseY;
  drawing = true;
}
void mouseReleased()
{
  float dx = mouseX - sx, dy = mouseY - sy;
  test.addVertex(sx, sy, sqrt(dx*dx + dy*dy));
  drawing = false;
}
void keyPressed()
{

}