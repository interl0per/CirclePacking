final float KCORRECTION = 0.005;
final float RCORRECTION = 0.005;

void stress_update(EnrichedEmbedding ebd) 
{
  ebd.cEmbedding_stress();
}

void radii_update(EnrichedEmbedding t) 
{
  for (int i =0; i <  100; i++) 
  {
    for (Vertex v : t.G.verts) 
    {
      if (v.angleSum() > 2*PI) 
      {
        v.r += RCORRECTION;
      }
      else 
      {
        v.r -= RCORRECTION;
      }
    }
    t.cEmbedding_radii();
  }
}

void test(EnrichedEmbedding t)
{
  for(int i= 0; i < 100; i++)
  {
    t.cEmbedding_stress_f();
  }
  curr.cStress_radii();
}