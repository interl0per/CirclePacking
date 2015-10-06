    ArrayList<Edge> edges = new ArrayList<Edge>();

class Triangulation
{
  //HalfEdge data structure, and a stack and queue implementation.
  //Also there are some methods to use on the HalfEdge data structure.
    public ArrayList<Vertex> verticies = new ArrayList<Vertex>();//internal verticies
    public ArrayList<Vertex> outerVerts = new ArrayList<Vertex>();
    Vertex imaginary;// = new Vertex(512, 512, 100);
    public Triangulation(){}
    public Triangulation(int n)
    {
      imaginary = new Vertex(width/2, height/2, -400);
      imaginary.fake = true;
      //create outer face (a regular n-gon)
      Vertex center = new Vertex(width/2, height/2, 1000);
      float step = 2*PI/n;//angle between adjacent verticies
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
      targ.x = (ref.weight + targ.weight)*cos(theta) + ref.x;
      targ.y = (ref.weight + targ.weight)*sin(theta) + ref.y;
      targ.placed = true;
    }
    
    void draw()
    {
      imaginary.draw();
      for(Vertex v : verticies)
        v.draw();
      //for(Vertex v : outerVerts)
      //  v.draw();
        
      HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
      JQueue<HalfEdge> q = new JQueue<HalfEdge>();
      q.add(outerVerts.get(0).h);
      //outerVerts.get(0).draw();
      while(!q.isEmpty())
      {
        HalfEdge he = q.remove();
        
        if(visited.containsKey(he))  continue;
        if(he.v.internal && he.next.v.internal && !he.v.fake && !he.next.v.fake)  
          if(!drawDualEdge)
            line(he.v.x, he.v.y, he.next.v.x, he.next.v.y);
          
  //       if(he.v.internal && he.next.v.internal)  
  //        line(he.v.x, he.v.y, he.v.z, 
  //             he.next.v.x, he.next.v.y, he.next.v.z);
          
        //draw orthocircle of internal triangles
        Vertex v1 = new Vertex(he.v.x, he.v.y, he.v.weight);
        Vertex v2 = new Vertex(he.next.v.x, he.next.v.y,he.next.v.weight);
        Vertex v3 = new Vertex(he.prev.v.x, he.prev.v.y,he.prev.v.weight);
        
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
        stroke(20,20,20);
        if(drawDualEdge && he.twin.v.internal && he.twin.ocx>-INF)
          line(he.ocx, he.ocy, he.twin.ocx, he.twin.ocy);
        //noStroke();
        if(drawOrtho)
        {
          stroke(255,0,0);
          noFill();
          ellipse(cx, cy, 2*r, 2*r);
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
            else if(!turn(nxt.h2.prev.v, nxt.h1.v, nxt.h1.prev.v))
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
  void test2()
  {
       //ArrayList<Vertex> prevOuter = imaginary.degree();
       //for(Vertex vv : prevOuter)
        // imaginary.detach();
      //imaginary = new Vertex(width/2, height/2, 400);

     int count = 0;
      for(Vertex vv : outerVerts)
      {
        ArrayList<Vertex> adj = vv.degree();
        for(Vertex uv : adj)
        {
          if(uv.internal)
          {
            if(count < 2)
              uv.fixed = true;
            imaginary.attach(uv);
            count++;
            uv.almostOuter = true;
          }
        }
       // println(imaginary.degree().size());
      }
      //for(Vertex vv : outerVerts)
      //  vv.detach();
  }
}