final float KCORRECTION = 0.005;
final float RCORRECTION = 0.01;

void stress_update(EnrichedEmbedding ebd)
{
  for(int i =0; i < 10; i++)
  {
    for(Edge e : ebd.G.edges)
     {
       float target = sqrt((((e.v1.x-e.v2.x)*(e.v1.x-e.v2.x) + (e.v1.y-e.v2.y)*(e.v1.y-e.v2.y))));
        
       if(e.v1.r + e.v2.r < target)
       {      //increase the stress on this edge
        e.stress += KCORRECTION;
        e.h1.v.r += KCORRECTION*10; 
        e.h2.v.r += KCORRECTION*10; 
       }
        
       else
       {
         if(e.stress > 0)
           e.stress -= KCORRECTION;//decrease stress
         e.h1.v.r -= KCORRECTION*10; 
         e.h2.v.r -= KCORRECTION*10; 
       }
     }
     ebd.cEmbedding_stress();
  }
}

void radii_update(EnrichedEmbedding t)
{
  for(int i =0; i < 10; i++)
  {
    if(!t.isPacking())
    {
      for(Vertex v : t.G.verts)
      {
        if(v.angleSum() > 2*PI)
        {
          v.r += RCORRECTION;
        }
        else
        {
          v.r -= RCORRECTION;
        }
      }
    }
    t.cEmbedding_radii();
  }
}