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
    center.weight = 10000;
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
  {//draw the graph
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(outerVerts.get(0).h);
    while(!q.isEmpty())
    {
      HalfEdge he = q.remove();
      if(visited.containsKey(he))  continue;
      //if(he.v.internal && he.next.v.internal)  
        line(he.v.x, he.v.y, he.next.v.x, he.next.v.y);
      //if(he.v.internal)
        he.v.draw();
      if(showCircles)
      {
        Vertex v1, v2, v3;
        float sign1 = (he.next.v.x-he.v.x) / abs(he.next.v.x-he.v.x);
        float m1 = (he.v.y - he.next.v.y)/ (he.v.x - he.next.v.x);//take he.v as origin
        float x1 = sqrt(he.v.weight*he.v.weight / (m1*m1+1));
        float y1 = m1*x1;
        v1 = new Vertex(he.v.x + sign1*x1, he.v.y + sign1*y1);
        
        float sign2 = (he.next.next.v.x-he.next.v.x) / abs(he.next.next.v.x-he.next.v.x);
        float m2 = (he.next.v.y - he.next.next.v.y)/ (he.next.v.x - he.next.next.v.x);
        float x2 = sqrt(he.next.v.weight*he.next.v.weight / (m2*m2+1));
        float y2 = m2*x2;
        v2 = new Vertex(he.next.v.x + sign2*x2, he.next.v.y + sign2*y2);
        
        float sign3 = (he.next.next.next.v.x-he.next.next.v.x) / abs(he.next.next.next.v.x-he.next.next.v.x);
        float m3 = (he.next.next.v.y - he.next.next.next.v.y)/ (he.next.next.v.x - he.next.next.next.v.x);
        float x3 = sqrt(he.next.next.v.weight*he.next.next.v.weight / (m3*m3+1));
        float y3 = m3*x3;
        v3 = new Vertex(he.next.next.v.x + sign3*x3, he.next.next.v.y + sign3*y3);
     
        drawCircumcircle(v1, v2, v3);
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
        if(inCircumcircle(nxt.h2.v, nxt.h2.next.v, nxt.h2.prev.v, nxt.h1.prev.v) || inCircumcircle(nxt.h1.v, nxt.h1.next.v, nxt.h1.prev.v, nxt.h2.prev.v))
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

