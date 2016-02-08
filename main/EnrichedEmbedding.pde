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
    //for(int i =0; i < 100; i++)
    //{
    //  HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
    //   JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    //   q.add(G.verts.get(0).h);
    //   while(!q.isEmpty())
    //   {
    //     HalfEdge he = q.remove();
    //     if(visited.containsKey(he))
    //       continue;
            
    //     double vx = (he.v.x - he.next.v.x)*he.e.stress;
    //     double vy = (he.v.y - he.next.v.y)*he.e.stress;
  
    //     if(!he.next.v.internal)
    //     {
    //       vx = 0;
    //       vy = 0;
    //     }
    
    //     he.next.v.x += vx;
    //     he.next.v.y += vy;
    //     visited.put(he, true);
    //     q.add(he.next);
    //     q.add(he.twin);
    //   }
    //   //updateStress();
    // }
     for(Edge e : G.edges)
     {
       double vx = (e.v1.x - e.v2.x)*e.stress;
       double vy = (e.v1.y - e.v2.y)*e.stress;
       if(!e.v2.internal)
       {
         vx = 0; vy = 0;
       }
       e.v2.x+=vx;
       e.v2.y+=vy;
       
       vx = (e.v2.x - e.v1.x)*e.stress/100000;
       vy = (e.v2.y - e.v1.y)*e.stress/100000;
       if(!e.v1.internal)
       {
         vx = 0; vy = 0;
       }
       e.v1.x+=vx;
       e.v1.y+=vy;
     }
  }
  void cStress_embedding()
  {
    //maxwell
   //HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
   //JQueue<HalfEdge> q = new JQueue<HalfEdge>();
   //q.add(G.verts.get(0).h);
   //while(!q.isEmpty())
   //{
   //  HalfEdge he = q.remove();
  
   //  if(visited.containsKey(he))  
   //    continue;
        
   //  Vertex grad1 = new Vertex(he.ocx, he.ocy, 0, 0);
   //  Vertex grad2 = new Vertex(he.twin.ocx, he.twin.ocy, 0, 0);
   //  Vertex force = new Vertex(grad1.x - grad2.x, grad1.y - grad2.y, 0, 0);

   //  float magnitude = force.magnitude();
   //  float disp = sqrt((float)((he.v.x-he.next.v.x)*(he.v.x-he.next.v.x) + (he.v.y-he.next.v.y)*(he.v.y-he.next.v.y)));
   //  he.e.spring = magnitude/disp;

   //  visited.put(he, true);
   //  q.add(he.next);
   //  q.add(he.twin);
   //}
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

    //for(Vertex v : G.outerVerts)
    //  placed.put(v, false);
    //for(Vertex v : G.verts)
    //{
    //  placed.put(v, false);
    //  processed.put(v,false);
    //}
    //fix an arbitrary internal vertex
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