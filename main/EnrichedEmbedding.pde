class EnrichedEmbedding
{
  Triangulation G;
  
  public EnrichedEmbedding(int n)
  {
    G = new Triangulation(n);
  }
  /////////////////
  //Drawing methods
  /////////////////
  void drawPSLG()
  {
    G.draw();
  }
  void drawDualPSLG()
  {
    G.dual.draw();
  }
  void drawRadii()
  {
    for(Vertex v : G.verts)
      v.draw();
  }
  void drawDualRadii()
  {
    for(Vertex v : G.dual.verts)
      v.draw();
  }
  void drawKoebe()
  {
    
  }
  //////////////////////
  //Data transformations
  //////////////////////
  void cDual_primal()
  {
    //construct new dual embedding
  }
  void cPrimal_dual()
  {
    //construct new primal embedding
    
  }
  
  void cEmbedding_stress()
  {
    //force simulation
    
  }
  void cStress_embedding()
  {
    //maxwell
   
  }
  void cStress_radii()
  {
    //calculate stress from dual+primal radii, assuming packing
    for(Edge e : G.edges)
    {
      e.stress = (e.dual.v1.r + e.dual.v2.r) / (e.v1.r + e.v2.r);
    }
  }
  void cEmbedding_radii()
  {
    //layout algorithm
    
  }
  
  void cDualRadii_embedding()
  { 
    //Calculate dual radii as incircles of faces of embedding
    for(Vertex v : G.dual.verts)
    {
      
    }
  }
  void cDualRadii_radii()
  {
    //Calculate dual radii as orthocircles of radii in embedding.
    
  }
  void cRadii_dualRadii()
  {
    
  }

  
  //Auxillary methods
  boolean isPacking()
  {
    float error = 0;
    for(Vertex v : G.verts)
      error += abs(v.angleSum() - 2*PI);
    
    error/=G.verts.size();
    if(error > 0.05)
      return false;
    return true;
  }
  void addVertex(float x, float y, float r)
  {
    G.addVertex(new Vertex(x,y,0,r,G));
  }
}