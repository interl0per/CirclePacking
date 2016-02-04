class EnrichedEmbedding
{
  Complex G;
  
  public EnrichedEmbedding(int n)
  {
    G = new Complex(n);
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
    //layout algorithm, gives correct embedding given good radii
    G.verts.get(0).x = width/2;
    G.verts.get(0).y = height/2;
    
    for(Vertex v : G.outerVerts)
      v.placed = false;
    for(Vertex v : G.verts)
    {
      v.placed = false;
      v.processed = false;
    }
    //fix an arbitrary internal vertex
    G.verts.get(0).placed = true;
    JQueue<Vertex> q = new JQueue<Vertex>();
    q.add(G.verts.get(0));

    while(!q.isEmpty())
    {
      Vertex iv = q.remove();
      ArrayList<Vertex> adjacent = iv.neighbors();//ordered neighbors
  
      int i,j;
      for(i = 0; i < adjacent.size() && !adjacent.get(i).placed; i++);
      //find a placed petal, if there is one
      float lastAngle = 0;
          
      if(i==adjacent.size() && !adjacent.get(i-1).placed)  
      {//initialization
        i--; 
        lastAngle = atan2((float)(adjacent.get(i).y-iv.y),(float)(adjacent.get(i).x-iv.x));
        G.placeVertex(adjacent.get(i), lastAngle, iv);
        if(adjacent.get(i).internal)  
          q.add(adjacent.get(i));
      }
       
     j = i;
       
     while(++j % adjacent.size() != i)
     {
       Vertex v = adjacent.get(j % adjacent.size());
       if(!v.placed)
       {
         Vertex lastKnown = adjacent.get((j-1)%adjacent.size());
         lastAngle = atan2((float)(lastKnown.y-iv.y),(float)(lastKnown.x-iv.x));
      
         float x = iv.r;
         float y = lastKnown.r;
         float z = v.r;
   
         float theta = (float)Math.acos(((x+y)*(x+y) + (x+z)*(x+z) - (y+z)*(y+z))/(2*(x+y)*(x+z)));
         G.placeVertex(v, lastAngle-theta, iv);
       }
       if(!v.processed && v.internal)
         q.add(v);
     }
     iv.processed = true;
    }
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