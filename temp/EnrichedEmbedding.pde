class EnrichedEmbedding
{
  Triangulation G;
  Triangulation DG;
  
  //Drawing methods
  void drawPSLG()
  {
    G.draw();
  }
  void drawDualPSLG()
  {
  }
  void drawRadii()
  {
    for(v : G.verticies)
      v.draw();
    
  }
  void drawDualRadii()
  {
    for(v : DG.verticies)
      v.draw();
  }
  void drawKoebe()
  {
    
  }
  //Data transformations
  void cEmbedding_stress()
  {
    
  }
  void cStress_embedding()
  {
    
  }
  void cEmbedding_radii()
  {
    
  }
  
  void cDualRadii_embedding()
  { 
    //Calculate dual radii as incircles of faces of embedding
    
  }
  void cDualRadii_radii()
  {
    //Calculate dual radii as orthocircles of radii in embedding.
    
  }
  void cRadii_dualRadii()
  {
    
  }
  void cStress_radii()
  {
    //calculate stress from dual+primal radii, assuming packing
    
  }
  
  //Auxillary methods
  boolean isPacking()
  {
    float error = 0;
    for(Vertex v : G.verticies)
      error += abs(v.angleSum() - 2*PI);
    
    error/=G.verticies.size();
    if(error > 0.1)
      return false;
    return true;
  }
}