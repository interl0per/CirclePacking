final float CORRECTION = 0.01;

void stress_update(EnrichedEmbedding ebd)
{
  for(Edge e : ebd.G.edges)
   {
     float target = sqrt((float)(((e.v1.x-e.v2.x)*(e.v1.x-e.v2.x) + (e.v1.y-e.v2.y)*(e.v1.y-e.v2.y))));
      
     if(e.v1.r + e.v2.r < target)
     {      //increase the stress on this edge
      e.stress += CORRECTION;
      e.h1.v.r += CORRECTION*10; 
      e.h2.v.r += CORRECTION*10; 
     }
      
     else
     {
       if(e.stress > 0)
         e.stress -= CORRECTION;//decrease stress
       e.h1.v.r -= CORRECTION*10; 
       e.h2.v.r -= CORRECTION*10; 
     }
   }
}

void radii_update(EnrichedEmbedding t)
{
  if(!t.isPacking())
  {
    for(Vertex v : t.G.verts)
    {
      if(v.angleSum() > 2*PI)
      {
        v.r += 0.05;
      }
      else
      {
        v.r -= 0.05;
      }
    }
  }
}