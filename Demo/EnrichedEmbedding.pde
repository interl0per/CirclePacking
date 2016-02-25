class EnrichedEmbedding
{
  Complex G;
  
  public EnrichedEmbedding(int n)
  {
    G = new Complex(n);
  }
  
  void drawCircumcircles()
  {
    HashMap<HalfEdge, Boolean> ae = new HashMap<HalfEdge, Boolean>();
    
    for(Edge e: G.edges)
    {
      HalfEdge tc[] = {e.h1, e.h2};
      for(HalfEdge he : tc)
      {
         if(ae.containsKey(he) || ae.containsKey(he.next) || ae.containsKey(he.prev))
           continue;
           
         Vertex v1 = he.v, v2 = he.next.v, v3 = he.prev.v;
         
         if(!v1.internal && !v2.internal && !v3.internal)
           continue;
         float v1v2 = v1.add(v2.negate()).magnitude();
         float v1v3 = v1.add(v3.negate()).magnitude();
         float v2v3 = v2.add(v3.negate()).magnitude();
         float perimeter = v1v2 + v1v3 + v2v3;
         
         float ocx = (v1.x*v2v3 + v2.x*v1v3 + v3.x*v1v2)/perimeter;
         float ocy = (v1.y*v2v3 + v2.y*v1v3 + v3.y*v1v2)/perimeter;
         
         float s = perimeter/2;
         
         float ocr = sqrt(s*(s-v1v2)*(s-v1v3)*(s-v2v3))/s;
         
         pushStyle();
         noStroke();
         fill(0,0, 0, 60);
         ellipse(ocx, ocy, 2*ocr, 2*ocr);
         popStyle();
         
         ae.put(he, true);
      }
    }
  }
  void drawOrthocircles()
  {
    HashMap<HalfEdge, Boolean> ae = new HashMap<HalfEdge, Boolean>();
         G.dual = new Complex();

    for(Edge e: G.edges)
    {
      HalfEdge tc[] = {e.h1, e.h2};
      Vertex dualTwins[] = new Vertex[2];
      
      for(int i= 0; i < 2; i++)
      {
         HalfEdge he = tc[i];
         if(ae.containsKey(he) || ae.containsKey(he.next) || ae.containsKey(he.prev))
           continue;
           
         Vertex v1 = he.v, v2 = he.next.v, v3 = he.prev.v;
         
         if(!v1.internal && !v2.internal && !v3.internal)
           continue;
         float v1h = v1.getZ();
         float v2h = v2.getZ();
         float v3h = v3.getZ();
      
         float ach = v1h - v3h;
         float bch = v2h - v3h;
          
         float acx = v1.x - v3.x;
         float acy = v1.y - v3.y;
          
         float bcx = v2.x - v3.x;
         float bcy = v2.y - v3.y;
          
         float det1 = acx*bcy - acy*bcx;
         float det2 = ach*bcy - acy*bch;
         float det3 = acx*bch - ach*bcx;
         float det4 = v1h*(v2.x*v3.y - v2.y*v3.x) - v1.x*(v2h*v3.y - v2.y*v3h) + v1.y*(v2h*v3.x - v2.x*v3h);
          
         float cx = det2/(2*det1);
         float cy = det3/(2*det1);
         float r = sqrt(cx*cx + cy*cy + det4/det1);
         
         pushStyle();
         //noStroke();
         //fill(0,100, 0);
         noFill();
         stroke(200,0,0);
         strokeWeight(5);
         ellipse(cx, cy, 2*r, 2*r);
         popStyle();
         
         dualTwins[i] = new Vertex(cx, cy, 0, r);
      }
      //fix this up so it just calculates the whole dual
      pushStyle();
      stroke(100,100,100);
      
      if(dualTwins[1]!=null)
       line(dualTwins[0].x, dualTwins[0].y, dualTwins[1].x, dualTwins[1].y);
        
      popStyle();
      
      G.dual.verts.add(dualTwins[0]);
      G.dual.verts.add(dualTwins[1]);
    }
    drawDualPSLG();
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
    for(int i =0; i < 100; i++)
    {
       for(Edge e : G.edges)
       {
         double vx = (e.v1.x - e.v2.x)*e.stress/100000;
         double vy = (e.v1.y - e.v2.y)*e.stress/100000;
          
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
     for(Edge e : G.edges)
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
    if(G.verts.size()==0)
      return;
    //layout algorithm, gives correct embedding given good radii
    G.verts.get(0).x = 0;
    G.verts.get(0).y = 0;
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