import java.util.Random;

final int NUM_OUTER_VERTS = 3;
final int INF = 1<<30;
final int orthoSphereR = 200;

boolean drawing = false;
boolean in = true;

EnrichedEmbedding test;

void setup() 
{
  size(1024, 768, P3D);
  background(255);
  fill(0, 0);
  //CPack = new Packing(NUM_OUTER_VERTS);
}