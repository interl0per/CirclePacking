import java.util.Random;

final int NUM_OUTER_VERTS = 6;
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
}
void mouseReleased()
{
  test.addVertex(mouseX, mouseY, 1);
}