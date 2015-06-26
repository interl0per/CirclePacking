HashMap<HalfEdge, Edge> hetoe = new HashMap<HalfEdge, Edge>();
ArrayList<Edge> edges = new ArrayList<Edge>();

class Triangulation
{
  ArrayList<Vertex> verticies = new ArrayList<Vertex>();//internal verticies
  ArrayList<Vertex> outerVerts = new ArrayList<Vertex>();

  public Triangulation(int n)
  {
    //create outer face
    Vertex center = new Vertex(512, 256);
    center.weight = 1000;
    float step = 2*PI/n;//angle between adjacent verticies
    //place the verticies on the outer face
    for(int i = 0; i < n; i++)
    {
      Vertex bv = new Vertex(-100,-100);
      bv.weight = 700;
      bv.internal = false;
      placeVertex(bv, i*step, center);
      outerVerts.add(bv);
    }
    center.weight = 0;
    for(int i =1; i < n+1; i++)
      attach(outerVerts.get(i%n), outerVerts.get(i-1)); 
  }
  
  void draw()
  {//draw the graph, and its lifting
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(outerVerts.get(0).h);
    while(!q.isEmpty())
    {
      HalfEdge he = q.remove();
      if(visited.containsKey(he))  continue;
      //if(he.v.internal && he.next.v.internal)  
        line(he.v.x, he.v.y, he.next.v.x, he.next.v.y);
       if(he.v.internal && he.next.v.internal)  
        line(he.v.x, he.v.y, he.v.z, 
             he.next.v.x, he.next.v.y, he.next.v.z);
      //if(he.v.internal)
        he.v.draw();
      if(showCircles)
      {
        Vertex v1 = new Vertex(he.v.x, he.v.y);
        v1.weight = he.v.weight;
        Vertex v2 = new Vertex(he.next.v.x, he.next.v.y);
        v2.weight = he.next.v.weight;
        Vertex v3 = new Vertex(he.prev.v.x, he.prev.v.y);
        v3.weight = he.prev.v.weight;
        
        float v1h = v1.x*v1.x + v1.y*v1.y - v1.weight*v1.weight;
        float v2h = v2.x*v2.x + v2.y*v2.y - v2.weight*v2.weight;
        float v3h = v3.x*v3.x + v3.y*v3.y - v3.weight*v3.weight;

        float ach = v1h - v3h;
        float bch = v2h - v3h;
        
        float acx = v1.x - v3.x;
        float acy = v1.y - v3.y;
        
        float bcx = v2.x - v3.x;
        float bcy = v2.y - v3.y;
        
        
        float det2 = acx*bch - ach*bcx;
        float det3 = ach*bcy - acy*bch;
        float det4 = acx*bcy - acy*bcx;
        
        float det1 = 1*(v1h*(v2.x*v3.y - v2.y*v3.x) - v1.x*(v2h*v3.y - v2.y*v3h) + v1.y*(v2h*v3.x - v2.x*v3h));
        
        float cx = det3/(2*det4);
        float cy = det2/(2*det4);
        println(det1/det4);
        float r = sqrt(cx*cx + cy*cy + det1/det4);
        println(cx + " " +cy + " " + r);
        ellipse(cx, cy, r/2, r/2);
      }
      visited.put(he, true);
      q.add(he.next);
      q.add(he.twin);
    }
    visited.clear();
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
      attach(v, h.v);
      h = h.next;
    }
  }
  void addVertex(int x, int y, float r)
  {
    Vertex v = new Vertex(x, y);
    v.weight = r;
    if(r < EPSILON)  v.weight = 2;
    verticies.add(v);
    HalfEdge tri = findHE(outerVerts.get(0).h, v);    //the face this new vertex sits in
  
    if(tri!=null)
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
  
        if(hetoe.get(nxt.h1)==null)  continue; //removed edge
        if(inOrthocircle(nxt.h2.v, nxt.h2.next.v, nxt.h2.prev.v, nxt.h1.prev.v) || inOrthocircle(nxt.h1.v, nxt.h1.next.v, nxt.h1.prev.v, nxt.h2.prev.v))
        {//edge is not ld
          //ld = false;
          if(turn(nxt.h2.prev.v, nxt.h1.next.v, nxt.h1.prev.v))
          {//concave case 1
            if(degree(nxt.h1.next.v).size()==3)
            {//flippable
              attach(nxt.h2.prev.v,nxt.h1.prev.v);
  
              Edge e1 = hetoe.get(nxt.h1.next.twin.prev);//new edge
              Edge e2 = hetoe.get(nxt.h1.prev);
              Edge e3 = hetoe.get(nxt.h2.next);
              
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
            if(degree(nxt.h1.v).size()==3)//nxt.h1.v.degree <= 3)//flippable
            {
              attach(nxt.h2.prev.v,nxt.h1.prev.v);
  
              Edge e1 = hetoe.get(nxt.h1.prev.twin.next);
              Edge e2 = hetoe.get(nxt.h1.next);
              Edge e3 = hetoe.get(nxt.h2.prev);
              
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
            Edge e1 = hetoe.get(nxt.h1.next);
            Edge e2 = hetoe.get(nxt.h1.prev);
            Edge e3 = hetoe.get(nxt.h2.next);
            Edge e4 = hetoe.get(nxt.h2.prev);
            
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
            attach(nxt.h2.prev.v, nxt.h1.prev.v);
            nxt.h1.detach();
          }
        }
      }
    }
  }
}


