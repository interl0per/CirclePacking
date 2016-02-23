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
    for(Vertex v : G.outerVerts)
      v.draw();
  }
  void drawDualRadii()
  {
    for(Vertex v : G.dual.verts)
      v.draw();
    for(Vertex v : G.dual.outerVerts)
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
    for(int i =0; i < 200; i++)
    {
      float maxS = 0;
      for(Edge e : G.edges)
      {
       maxS = max(maxS, e.stress);
      }
      float mul = 1/maxS;
      for(Edge e : G.edges)
      {
       e.stress *= mul;
      }
      
       for(Edge e : G.edges)
       {
         double vx = (e.v1.x - e.v2.x)*e.stress/10000;
         double vy = (e.v1.y - e.v2.y)*e.stress/10000;
          
         if(e.v2.internal)
         {
           e.v2.x+=vx;
           e.v2.y+=vy;
         }
    
         if(e.v1.internal)
         {
           e.v1.x-=vx;
           e.v1.y-=vy;
         }
       }
    }
  }
  
  void cStress_embedding()
  {
    //maxwell
     for(Edge e : G.edges)
     {
       Vertex grad1 = grad(e.h1);
       Vertex grad2 = grad(e.h2);

       e.stress = grad1.add(grad2.negate()).magnitude()/distv(e.h1.v, e.h2.v);

         if(e.h1.v.internal || e.h2.v.internal)
         {
           println(e.stress);
       }
     }
     println();
     println();
     
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
    HashMap placed = new HashMap();
    HashMap processed = new HashMap();

    placed.put(G.verts.get(0), true);

    placed.put(G.verts.get(0), true);
    
    JQueue<Vertex> q = new JQueue<Vertex>();
    q.add(G.verts.get(0));

    while(!q.isEmpty())
    {
       Vertex iv = q.remove();
       ArrayList<Vertex> adjacent = iv.neighbors();//ordered neighbors
    
       int i,j;
       for(i = 0; i < adjacent.size() && !placed.containsKey(adjacent.get(i)); i++);
       //find a placed petal, if there is one
       float lastAngle = 0;
            
       if(i==adjacent.size() && !placed.containsKey(adjacent.get(i-1)))  
       {//initialization
         i--; 
         lastAngle = atan2((float)(adjacent.get(i).y-iv.y),(float)(adjacent.get(i).x-iv.x));
         G.placeVertex(adjacent.get(i), lastAngle, iv);
         placed.put(adjacent.get(i), true);
         
         if(adjacent.get(i).internal)  
           q.add(adjacent.get(i));
       }
       
      j = i;
         
      while(++j % adjacent.size() != i)
      {
        Vertex v = adjacent.get(j % adjacent.size());
        if(!placed.containsKey(v))
        {
          Vertex lastKnown = adjacent.get((j-1)%adjacent.size());
          lastAngle = atan2((float)(lastKnown.y-iv.y),(float)(lastKnown.x-iv.x));
        
          float x = iv.r;
          float y = lastKnown.r;
          float z = v.r;
     
          float theta = (float)Math.acos(((x+y)*(x+y) + (x+z)*(x+z) - (y+z)*(y+z))/(2*(x+y)*(x+z)));
          G.placeVertex(v, lastAngle-theta, iv);
          placed.put(v, true);
        }
        if(!processed.containsKey(v) && v.internal)
          q.add(v);
      }
      processed.put(iv, true);
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
    if(error > 0.005)
      return false;
    return true;
  }
  void addVertex(float x, float y, float r)
  {
    G.addVertex(new Vertex(x,y,0,r,G));
  }
}