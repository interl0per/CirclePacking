import java.util.Random;

final int NUM_OUTER_VERTS = 3;
final int INF = 1<<30;
final int orthoSphereR = 200;

EnrichedEmbedding test;

void setup() 
{
  size(1024, 768, P3D);
  background(255);
  fill(0, 0);
  test = new EnrichedEmbedding(NUM_OUTER_VERTS);
}

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
        test.cEmbedding_radii();
        break;
      }
      case(RIGHT):
      {
        stress_update(test);
        break;
      }
      case (UP):
        test.cStress_embedding();
        break;
      case (DOWN):
        test.cEmbedding_stress();
        break;
    }
}
void mouseReleased()
{
  test.addVertex(mouseX, mouseY, 1);
}
void keyPressed()
{

}