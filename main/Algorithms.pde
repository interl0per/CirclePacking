EnrichedEmbedding radii_update(EnrichedEmbedding ebd)
{
  return ebd;
}

void force_sim(EnrichedEmbedding t)
{
  if(!t.isPacking())
  {
    for(Vertex v : t.G.verts)
    {
      if(v.angleSum() > 2*PI)
      {
        v.r += 0.5;
      }
      else
      {
        v.r -= 0.5;
      }
    }
  }
}