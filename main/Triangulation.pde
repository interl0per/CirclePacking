ArrayList<Edge> edges = new ArrayList<Edge>();
boolean flag = true;
class Triangulation
{
  ////HalfEdge data structure, and a stack and queue implementation.
  //Also there are some methods to use on the HalfEdge data structure.
    public ArrayList<Vertex> verticies = new ArrayList<Vertex>();//internal verticies
    public ArrayList<Vertex> outerVerts = new ArrayList<Vertex>();

    public Triangulation(){}
    public Triangulation(int n)
    {
     //create outer face (a regular n-gon)
     Vertex center = new Vertex(0, 0, 1300);
     float step = 2*PI/n;
     //place the verticies on the outer face
      
     for(int i = 0; i < n; i++)
     {
       Vertex bv = new Vertex(-100,-100,700);
       bv.internal = false;
       placeVertex(bv, i*step, center);
       outerVerts.add(bv);
     }

     for(int i =1; i < n+1; i++)
       outerVerts.get(i%n).attach(outerVerts.get(i-1)); 
    }
    
    void placeVertex(Vertex targ, float theta,  Vertex ref)
    {
     targ.loc.x = (ref.weight + targ.weight)*cos(theta) + ref.loc.x;
     targ.loc.y = (ref.weight + targ.weight)*sin(theta) + ref.loc.y;
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
     if(!TEST)
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
         if(!drawDualEdge && !TEST)
         {
           line(he.v.loc.x, he.v.loc.y, he.next.v.loc.x, he.next.v.loc.y);
           //line(he.v.stereoUp.x, he.v.stereoUp.y, he.v.stereoUp.z, he.next.v.stereoUp.x, he.next.v.stereoUp.y, he.next.v.stereoUp.z);
           //shows that stereographic projection works..
           //line(0,0,orthoSphereR, he.v.loc.x, he.v.loc.y, he.v.loc.z);
         }
        if(cool_stuff)
        {
          if(he.ixnp!=null && he.next.ixnp != null && he.next.twin.next.ixnp != null)
          {
            //stroke(0);
            line(he.ixnp.x, he.ixnp.y, he.ixnp.z, he.next.ixnp.x, he.next.ixnp.y, he.next.ixnp.z);
            line(he.ixnp.x, he.ixnp.y, he.ixnp.z, he.next.next.ixnp.x, he.next.next.ixnp.y, he.next.next.ixnp.z);
            line(he.next.ixnp.x, he.next.ixnp.y, he.next.ixnp.z, he.next.next.ixnp.x, he.next.next.ixnp.y, he.next.next.ixnp.z);
            Point a2 = new Point(he.ixnp.x, he.ixnp.y, he.ixnp.z), 
                  b2 = new Point(he.next.ixnp.x, he.next.ixnp.y, he.next.ixnp.z), 
                  c2 = new Point(he.next.next.ixnp.x, he.next.next.ixnp.y, he.next.next.ixnp.z);
            drawCircumcircle3D(a2, b2, c2);
          }
        }
        
        else
        {
          if(he.ixn!=null && he.next.ixn != null && he.next.twin.next.ixn != null)
          {
            stroke(0);
            drawCircumcircle(he.ixn, he.next.ixn, he.next.twin.next.ixn);
            stroke(255,0,0);
          }
        }
        
        if(!flag)
        {
          //he.ixnp = project2(
        }
        //////////////////////////////
        //draw orthocircle of internal triangles
        
       if(!TEST)
       {
         Vertex v1 = new Vertex(he.v.loc.x, he.v.loc.y, he.v.weight);
         Vertex v2 = new Vertex(he.next.v.loc.x, he.next.v.loc.y,he.next.v.weight);
         Vertex v3 = new Vertex(he.prev.v.loc.x, he.prev.v.loc.y,he.prev.v.weight);
         float v1h = v1.getZ();
         float v2h = v2.getZ();
         float v3h = v3.getZ();
  
         float ach = v1h - v3h;
         float bch = v2h - v3h;
          
         float acx = v1.loc.x - v3.loc.x;
         float acy = v1.loc.y - v3.loc.y;
          
         float bcx = v2.loc.x - v3.loc.x;
         float bcy = v2.loc.y - v3.loc.y;
          
         float det1 = acx*bcy - acy*bcx;
         float det2 = ach*bcy - acy*bch;
         float det3 = acx*bch - ach*bcx;
         float det4 = v1h*(v2.loc.x*v3.loc.y - v2.loc.y*v3.loc.x) - v1.loc.x*(v2h*v3.loc.y - v2.loc.y*v3h) + v1.loc.y*(v2h*v3.loc.x - v2.loc.x*v3h);
          
         float cx = det2/(2*det1);
         float cy = det3/(2*det1);
         float r = sqrt(cx*cx + cy*cy + det4/det1);
         he.ocx = cx;
         he.ocy = cy;
         he.ocr = r;
       }
       else if (TEST) //if(he.v.internal && he.next.v.internal)
       {
         //calculate the incenter and incircle radius.
         //assuming we're given a packing, it's a dual packing.
         Point p1 = new Point(he.v.loc.x, he.v.loc.y, 0);
         Point p2 = new Point(he.next.v.loc.x, he.next.v.loc.y,0);
         Point p3 = new Point(he.prev.v.loc.x, he.prev.v.loc.y, 0);
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
         
         float x3 = he.v.loc.x, y3 = he.v.loc.y;
         float x4 = he.next.v.loc.x, y4 = he.next.v.loc.y;
         
         float m1 = (y1-y2)/(x1-x2);
         float m2 = (y3-y4)/(x3-x4);
         float b1 = y1-m1*x1;
         float b2 = y3-m2*x3;
         
         float ix = (b2 - b1)/(m1 - m2);
         float iy = (b2*m1 - b1*m2)/(m1 - m2);
         
         Point drA = new Point(he.v.loc.x - ix, he.v.loc.y - iy, 0);
         Point drB = new Point(he.next.v.loc.x - ix, he.next.v.loc.y - iy, 0);
         
         he.v.weight = drA.magnitude();
         he.next.v.weight = drB.magnitude();
         //ellipse(ix,iy,10,10);
        // println("here");
        if(he.ixn == null)
        {
           he.ixn = new Point(ix,iy,0);
           he.ixnp = project(he.ixn);
           he.twin.ixnp = he.ixnp;
        }
        if(he.ixnp != null && he.next.ixnp != null && he.next.next.ixnp != null)
        {
           he.ixn = project2(he.ixnp);
           he.next.ixn = project2(he.next.ixnp);
           he.next.next.ixn = project2(he.next.next.ixnp);
        }
       }
       
       stroke(20,20,20);
       if(drawDualEdge && he.twin.v.internal && he.twin.ocx>-INF)
       {
         line(he.ocx, he.ocy, he.twin.ocx, he.twin.ocy);
       }

       if(drawOrtho)//&& he.v.internal && he.next.v.internal)
       {           stroke(255,0,0);

         if(TEST)
         {

           drawCircumcircle(he.ixn, he.next.ixn, he.next.next.ixn);
           //ellipse(he.ixn.x, he.ixn.y, 10, 10);
           //ellipse(he.next.ixn.x, he.next.ixn.y, 10, 10);
           //ellipse(he.next.next.ixn.x, he.next.next.ixn.y, 10, 10);
         }
         else
         {
           //noFill();
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
     if(v.weight < 2*EPSILON)  
       v.weight = 2;
     verticies.add(v);
     HalfEdge tri = outerVerts.get(0).h.findHE(v.loc);    //the face this new vertex sits in
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
           if(turn(nxt.h2.prev.v.loc, nxt.h1.next.v.loc, nxt.h1.prev.v.loc))
           {//concave case 1
             if(nxt.h1.next.v.degree().size()==3)
             {//flippable
               nxt.h2.prev.v.attach(nxt.h1.prev.v);
    
               Edge e1 = nxt.h1.next.twin.prev.e;//new edge
               Edge e2 = nxt.h1.prev.e;
               Edge e3 = nxt.h2.next.e;
                
               if(inStack.get(e1) == null || !inStack.get(e1))
               {
                 edgesToCheck.push(e1);
                 inStack.put(e1, true);
               }
               if(inStack.get(e2) == null || !inStack.get(e2))
               {
                 edgesToCheck.push(e2);
                 inStack.put(e2, true);
               }
               if(inStack.get(e3) == null || !inStack.get(e3))
               {
                 edgesToCheck.push(e3);
                 inStack.put(e3, true);
               }
               nxt.h1.next.detach();
               nxt.h2.prev.detach();
               nxt.h1.detach();
             }
           }
           else if(!turn(nxt.h2.prev.v.loc, nxt.h1.v.loc, nxt.h1.prev.v.loc))
           {//concave case 2
             if(nxt.h1.v.degree().size()==3)//nxt.h1.v.degree <= 3)//flippable
             {
               nxt.h2.prev.v.attach(nxt.h1.prev.v);
    
               Edge e1 = nxt.h1.prev.twin.next.e;
               Edge e2 = nxt.h1.next.e;
               Edge e3 = nxt.h2.prev.e;
                
               if(inStack.get(e1) == null || !inStack.get(e1))
               {
                 edgesToCheck.push(e1);
                 inStack.put(e1, true);
               }
               if(inStack.get(e2) == null || !inStack.get(e2))
               {
                 edgesToCheck.push(e2);
                 inStack.put(e2, true);
               }
               if(inStack.get(e3) == null || !inStack.get(e3))
               {
                 edgesToCheck.push(e3);
                 inStack.put(e3, true);
               }
               nxt.h1.prev.detach();
               nxt.h2.next.detach();
               nxt.h1.detach();
             }
           }
           else 
           {//2-2 flip
             Edge e1 = nxt.h1.next.e;
             Edge e2 = nxt.h1.prev.e;
             Edge e3 = nxt.h2.next.e;
             Edge e4 = nxt.h2.prev.e;
              
             if(inStack.get(e1) == null || !inStack.get(e1))
             {
               edgesToCheck.push(e1);
               inStack.put(e1, true);
             }
             if(inStack.get(e2) == null || !inStack.get(e2))
             {
               edgesToCheck.push(e2);
               inStack.put(e2, true);
             }
             if(inStack.get(e3) == null || !inStack.get(e3))
             {
               edgesToCheck.push(e3);
               inStack.put(e3, true);
             }
             if(inStack.get(e4) == null || !inStack.get(e4))
             {
               edgesToCheck.push(e4);
               inStack.put(e4, true);
             }
             nxt.h2.prev.v.attach(nxt.h1.prev.v);
             nxt.h1.detach();
           }
         }
       }
     return true;  
    }
 }
}