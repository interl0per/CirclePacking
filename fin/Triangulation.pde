ArrayList<Edge> edges = new ArrayList<Edge>();

class Triangulation
{
    boolean drawKoebe = false;
    boolean mobius = false;
    boolean drawOrtho = false;
    boolean drawDualEdge = false;

  //HalfEdge data structure, and a stack and queue implementation.
  //Also there are some methods to use on the HalfEdge data structure.
    public ArrayList<Vertex> verticies = new ArrayList<Vertex>();//internal verticies
    public ArrayList<Vertex> outerVerts = new ArrayList<Vertex>();

    public Triangulation(){}
    public Triangulation(int n)
    {
     //create outer face (a regular n-gon)
     Vertex center = new Vertex(0, 0, 0, 700);
     float step = 2*PI/n;
     //place the verticies on the outer face
      
     for(int i = 0; i < n; i++)
     {
       Vertex bv = new Vertex(-100,-100, 0, 700);
       bv.internal = false;
       placeVertex(bv, i*step, center);
       outerVerts.add(bv);
     }

     for(int i =1; i < n+1; i++)
       outerVerts.get(i%n).attach(outerVerts.get(i-1)); 
    }
    
    void placeVertex(Vertex targ, float theta,  Vertex ref)
    {
     targ.x = (ref.weight + targ.weight)*cos(theta) + ref.x;
     targ.y = (ref.weight + targ.weight)*sin(theta) + ref.y;
     targ.placed = true;
    }
    
    void rot(char dir, float theta)
    {
     HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
     JQueue<HalfEdge> q = new JQueue<HalfEdge>();
     q.add(outerVerts.get(0).h);

     while(!q.isEmpty())
     {
       HalfEdge he = q.remove();

       if(visited.containsKey(he))  continue;
       he.ixnp.rotate(dir, theta);
       visited.put(he, true);
       q.add(he.next);
       q.add(he.twin);
     }
    }
    
    void draw()
    {
     if(!mobius)
     {
       for(Vertex v : verticies)
         v.draw();
       for(Vertex v : outerVerts)
        v.draw();
     }
     
     HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
     JQueue<HalfEdge> q = new JQueue<HalfEdge>();
     q.add(outerVerts.get(0).h);

     while(!q.isEmpty())
     {
       HalfEdge he = q.remove();

       if(visited.containsKey(he))  continue;
       //if(he.v.internal && he.next.v.internal)  
         if(!drawDualEdge && !mobius)
         {
           line(he.v.x, he.v.y, he.next.v.x, he.next.v.y);
         }
        if(drawKoebe)
        {
          if(he.ixnp!=null && he.next.ixnp != null && he.next.twin.next.ixnp != null)
          {
            line(he.ixnp.x, he.ixnp.y, he.ixnp.z, he.next.ixnp.x, he.next.ixnp.y, he.next.ixnp.z);
            line(he.ixnp.x, he.ixnp.y, he.ixnp.z, he.next.next.ixnp.x, he.next.next.ixnp.y, he.next.next.ixnp.z);
            line(he.next.ixnp.x, he.next.ixnp.y, he.next.ixnp.z, he.next.next.ixnp.x, he.next.next.ixnp.y, he.next.next.ixnp.z);
            
            Vertex a2 = new Vertex(he.ixnp.x, he.ixnp.y, he.ixnp.z, 0), 
                  b2 = new Vertex(he.next.ixnp.x, he.next.ixnp.y, he.next.ixnp.z, 0), 
                  c2 = new Vertex(he.next.next.ixnp.x, he.next.next.ixnp.y, he.next.next.ixnp.z, 0);
                  
            drawCircumcircle3D(a2, b2, c2);
          }
        }
        
        else
        {
          if(he.ixn!=null && he.next.ixn != null && he.next.twin.next.ixn != null)
          {
            stroke(0);
            drawCircumcircle2D(he.ixn, he.next.ixn, he.next.twin.next.ixn);
            stroke(255,0,0);
          }
        }
        
        //////////////////////////////
        //draw orthocircle of internal triangles
        
       if(!mobius)
       {
         Vertex v1 = new Vertex(he.v.x, he.v.y, 0, he.v.weight);
         Vertex v2 = new Vertex(he.next.v.x, he.next.v.y,0, he.next.v.weight);
         Vertex v3 = new Vertex(he.prev.v.x, he.prev.v.y,0, he.prev.v.weight);
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
         he.ocx = cx;
         he.ocy = cy;
         he.ocr = r;
       }
       else
       {
         //calculate the incenter and incircle radius.
         //assuming we're given a packing, it's a dual packing.
         Vertex p1 = new Vertex(he.v.x, he.v.y, 0, 0);
         Vertex p2 = new Vertex(he.next.v.x, he.next.v.y,0, 0);
         Vertex p3 = new Vertex(he.prev.v.x, he.prev.v.y, 0, 0);
         float p1p2 = p1.add(p2.negate()).magnitude();
         float p1p3 = p1.add(p3.negate()).magnitude();
         float p2p3 = p2.add(p3.negate()).magnitude();
         float perimeter = p1p2 + p1p3 + p2p3;
         he.ocx = (p1.x*p2p3 + p2.x*p1p3 + p3.x*p1p2)/perimeter;
         he.ocy = (p1.y*p2p3 + p2.y*p1p3 + p3.y*p1p2)/perimeter;
         float s = perimeter/2;
         he.ocr = sqrt(s*(s-p1p2)*(s-p1p3)*(s-p2p3))/s;
         
         //update radii
         float x1 = he.ocx, y1 = he.ocy;
         float x2 = he.twin.ocx, y2 = he.twin.ocy;
         
         float x3 = he.v.x, y3 = he.v.y;
         float x4 = he.next.v.x, y4 = he.next.v.y;
         
         float m1 = (y1-y2)/(x1-x2);
         float m2 = (y3-y4)/(x3-x4);
         float b1 = y1-m1*x1;
         float b2 = y3-m2*x3;
         
         float ix = (b2 - b1)/(m1 - m2);
         float iy = (b2*m1 - b1*m2)/(m1 - m2);
         
         Vertex drA = new Vertex(he.v.x - ix, he.v.y - iy, 0, 0);
         Vertex drB = new Vertex(he.next.v.x - ix, he.next.v.y - iy, 0, 0);
         
         he.v.weight = drA.magnitude();
         he.next.v.weight = drB.magnitude();

        if(he.ixn == null)
        {
           he.ixn = new Vertex(ix,iy,0,0);
           he.ixnp = stereoProj(he.ixn);
           he.twin.ixnp = he.ixnp;
        }
        if(he.ixnp != null && he.next.ixnp != null && he.next.next.ixnp != null)
        {
           he.ixn = stereoProjI(he.ixnp);
           he.next.ixn = stereoProjI(he.next.ixnp);
           he.next.next.ixn = stereoProjI(he.next.next.ixnp);
        }
       }
       
       stroke(20,20,20);
       if(drawDualEdge && he.twin.v.internal && he.twin.ocx>-INF)
       {
         line(he.ocx, he.ocy, he.twin.ocx, he.twin.ocy);
       }

       if(drawOrtho)
       {           
         stroke(255,0,0);
         if(mobius)
         {
           drawCircumcircle2D(he.ixn, he.next.ixn, he.next.next.ixn);
         }
         else
         {
           ellipse(he.ocx, he.ocy, 2*he.ocr, 2*he.ocr);
         }
       }
       stroke(0,0,0);
       visited.put(he, true);
       q.add(he.next);
       q.add(he.twin);
     }
    }  
    
    void triangulate(HalfEdge h, Vertex v)
    {
     int sides = 1;
     HalfEdge temp = h.next;
     while(temp!=h)
     {
       sides++;
       temp = temp.next;
     }
    
     for(int i = 0; i < sides; i++)
     {
       v.attach(h.v);
       h = h.next;
     }
    }
    
    boolean addVertex(Vertex v)
    {
     if(mobius)  return false;
     if(v.weight < EPSILON)  
       v.weight = 2;
     verticies.add(v);
     HalfEdge tri = outerVerts.get(0).h.findHE(v);    //the face this new vertex sits in
     if(tri==null)
       return false;
     else
     {
       triangulate(tri, v);
       JStack<Edge> edgesToCheck = new JStack<Edge>();
       HashMap<Edge, Boolean> inStack = new HashMap<Edge, Boolean>();
       for(Edge e : edges)
       {
         edgesToCheck.push(e);
         inStack.put(e, true);
       } 
        
       while(!edgesToCheck.isEmpty())
       {
         Edge nxt = edgesToCheck.pop();
         inStack.put(nxt, false);//mark as out of the stack
    
         if(nxt.h1.e==null)  continue; //removed edge
         if(inOrthocircle(nxt.h2.v, nxt.h2.next.v, nxt.h2.prev.v, nxt.h1.prev.v) || inOrthocircle(nxt.h1.v, nxt.h1.next.v, nxt.h1.prev.v, nxt.h2.prev.v))
         {//edge is not ld
           if(turn(nxt.h2.prev.v, nxt.h1.next.v, nxt.h1.prev.v))
           {//concave case 1
             if(nxt.h1.next.v.degree().size()==3)
             {//flippable
               nxt.h2.prev.v.attach(nxt.h1.prev.v);
               
               Edge [] checkEdge = {nxt.h1.next.twin.prev.e, nxt.h1.prev.e, nxt.h2.next.e};
               checkEdges(checkEdge, inStack, edgesToCheck);
               
               nxt.h1.next.detach();
               nxt.h2.prev.detach();
               nxt.h1.detach();
             }
           }
           else if(!turn(nxt.h2.prev.v, nxt.h1.v, nxt.h1.prev.v))
           {//concave case 2
             if(nxt.h1.v.degree().size()==3)//nxt.h1.v.degree <= 3)//flippable
             {
               nxt.h2.prev.v.attach(nxt.h1.prev.v);
    
               Edge [] checkEdge = {nxt.h1.prev.twin.next.e, nxt.h1.next.e, nxt.h2.prev.e};
               checkEdges(checkEdge, inStack, edgesToCheck);

               nxt.h1.prev.detach();
               nxt.h2.next.detach();
               nxt.h1.detach();
             }
           }
           else 
           {//2-2 flip
             Edge [] checkEdge = { nxt.h1.next.e, nxt.h1.prev.e, nxt.h2.next.e, nxt.h2.prev.e};
             checkEdges(checkEdge, inStack, edgesToCheck);

             nxt.h2.prev.v.attach(nxt.h1.prev.v);
             nxt.h1.detach();
           }
         }
       }
     return true;  
    }
 }
 
 void checkEdges(Edge[] checkEdge, HashMap<Edge, Boolean> inStack, JStack<Edge> edgesToCheck)
 {//delaunay triangulation helper
    for(Edge e : checkEdge)
    {
       if(inStack.get(e) == null || !inStack.get(e))
       {
         edgesToCheck.push(e);
         inStack.put(e, true);
       }
    }
 }
}