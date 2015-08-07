//HalfEdge data structure, and a stack and queue implementation.
//Also there are some methods to use on the HalfEdge data structure.

class HalfEdge
{
  HalfEdge prev;
  HalfEdge next;
  HalfEdge twin;
  Vertex v;
  float ocx=-9999999, ocy=-9999999;//orthocenter of this face
  
  HalfEdge(Vertex vv) 
  {
    v =vv;
  }
  
  void connectTo(HalfEdge h) 
  {
    next = h;
    h.prev = this;
  }
  // Disconnect both a halfedge and its twin.
  void detach() 
  {
    if (v.isLeaf()) 
    { 
      v.h = null;
    } 
    else 
    {
      prev.connectTo(twin.next);
      v.h = twin.next;
    }
    if (twin.v.isLeaf()) 
    { 
      twin.v.h = null; 
    }
    else 
    {
      twin.prev.connectTo(next);
      twin.v.h = next;
    }
    hetoe.remove(this);
    hetoe.remove(twin);
    for(int i = 0; i < edges.size(); i++)
    {
      if(edges.get(i).h1 == this || edges.get(i).h1 == twin)
      {
        edges.remove(i);
        i--;
      }
    }
  }
  void drawCircumcircle()
  {
    Vertex a = v, b = next.v, c = prev.v;
    float mr = (b.y-a.y) / (b.x-a.x);
    float mt = (c.y-b.y) / (c.x-b.x);
    float x = (mr*mt*(c.y-a.y) + mr*(b.x+c.x) - mt*(a.x+b.x)) / (2*(mr-mt));
    float y = (a.y+b.y)/2 - (x - (a.x+b.x)/2) / mr;
    float r = sqrt(((b.x-x)*(b.x-x) +  (b.y-y)*(b.y-y)));
    stroke(255, 0, 0);
    ellipse(x, y,2*r, 2*r);
    stroke(0);
  }
  void drawOrthocircle()
  {
    Vertex v1 = v, v2 = next.v, v3 = prev.v;
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
    ocx = cx;
    ocy = cy;
    stroke(20,20,20);
    if(drawDualEdge && twin.v.internal && twin.ocx>-999999)
      line(ocx, ocy, twin.ocx, twin.ocy);
    stroke(255,0,0);
    if(drawOrtho)
    {
      noFill();
      ellipse(cx, cy, 2*r, 2*r);
      fill(50);
    }
    stroke(0,0,0);
  }
  boolean inOrthocircle(Vertex d)//is d in the circumcircle of the triangle defined by this halfedge?
  {//a,b,c should be in ccw order from following the half edges. 
  //from http://algs4.cs.princeton.edu/91primitives/
    Vertex a = v, b = next.v, c = prev.v;
    float adx = a.x - d.x;
    float ady = a.y - d.y;
    float bdx = b.x - d.x;
    float bdy = b.y - d.y;
    float cdx = c.x - d.x;
    float cdy = c.y - d.y;
  
    float abdet = adx * bdy - bdx * ady;
    float bcdet = bdx * cdy - cdx * bdy;
    float cadet = cdx * ady - adx * cdy;
    float alift = adx * adx + ady * ady - d.weight*d.weight - a.weight*a.weight;
    float blift = bdx * bdx + bdy * bdy - d.weight*d.weight - b.weight*b.weight;
    float clift = cdx * cdx + cdy * cdy - d.weight*d.weight - c.weight*c.weight;
    return alift * bcdet + blift * cadet + clift * abdet < 0;
  }
}

class JStack<T>
{
  ArrayList<T> container = new ArrayList<T>();
  void push(T e)
  {
    container.add(e);
  }
  T pop()
  {
    return container.remove(container.size()-1);
  }
  boolean isEmpty()
  {
    return(container.size()==0);
  }
}

class JQueue<T>
{
  ArrayList<T> container = new ArrayList<T>();
  void add(T e)
  {
    container.add(e);
  }
  T remove()
  {
    return container.remove(0);
  }
  boolean isEmpty()
  {
    return(container.size()==0);
  }
}

class Edge {
  HalfEdge h1, h2;
  float spring;
  public Edge(HalfEdge _h1, HalfEdge _h2) 
  {  
    h1 = _h1; 
    h2 = _h2;  
  }
}

class Vertex 
{
  boolean almostOuter = false;
  color shade = 50;
  boolean internal = true, processed = false, placed = false, f = false;
  HalfEdge h;
  float x, y, z, weight; // z = f(x,y,weight)
  Vertex(float _x, float _y, float _w) {
    x = _x; y = _y; weight = _w;
    h = null;
  }
  void draw()
  {
    if(this==tri.imaginary)
      shade = color(225, 225, 225, 0);
    fill(shade);
    ellipse(x, y,2*weight,2*weight);
    fill(0);
  }
  float getZ() 
  {//get the height of this vertex in the parabolic lifting
    return (x*x+y*y-weight*weight);
  }
  HalfEdge handle(Vertex u) 
  {
    if (isIsolated() || isLeaf()) { return h; }
    HalfEdge h1 = h, h2 = h.prev.twin;
    while (!ordered(h1.twin.v, u, h2.twin.v)) 
    {
      h1 = h2;
      h2 = h1.prev.twin;      
    }
    return h1;
  }
  
  boolean isIsolated() 
  {
    return (h == null);
  }
  
  boolean isLeaf()     
  {
    return (!isIsolated()) && (h.twin == h.prev);
  }
  
  boolean ccw(Vertex a, Vertex b) 
  {
    return ((a.y-y) * (b.x-x) - (a.x-x) * (b.y-y) >= 0);
  }
  
  boolean ordered(Vertex a, Vertex b, Vertex c) 
  {
    boolean I   = ccw(a,b);
    boolean II  = ccw(b,c);
    boolean III = ccw(c,a);
    return ((I && (II || III)) || (II && III)); // at least two must be true
  } 
  ArrayList<Vertex> degree()//returns neighbors in ccw order
  {
    ArrayList<Vertex> neighbors = new ArrayList<Vertex>();
    try
    {
      neighbors.add(this.h.next.v);
      HalfEdge test = this.h.prev.twin;
      while(test != this.h)
      {
        neighbors.add(test.next.v);
        test = test.prev.twin;
      }
      return neighbors;
    }
    catch(Exception ex)
    {
      return(new ArrayList<Vertex>());
    }
  }
  
  boolean inFace(HalfEdge h)
  {//is d in the face defined by h?
    HalfEdge start = h;
    HalfEdge temp = h.next;
    boolean first = true;
    while(first || h!=start)
    {
      first = false;
      if(h.v.turn(temp.v, this))
        return false;
      h = h.next;
      temp = temp.next;
    }
    return true;
  }
  
  boolean turn(Vertex q, Vertex r)
  {//returns true if no turn/right turn is formed by p q r
    return((q.x - x)*(r.y - y) - (r.x - x)*(q.y - y)>=0);
  }
  
  void attach(Vertex t) 
  {
    //don't connect verticies that are already connected
    Vertex s = this;
    if(s.h!=null&&s.h.next!=null && s.h.next.v == t)
      return;
      
    HalfEdge test = null;
    
    if(s.h!=null&&s.h.prev!=null)
      test = s.h.prev.twin;
      
    while(test!=null&&test!=s.h)
    {
      if(test.next.v==t)  
        return;
      test = test.prev.twin;
    }
  
    HalfEdge h1 = new HalfEdge(s);
    HalfEdge h2 = new HalfEdge(t);
    h1.twin = h2;
    h2.twin = h1;
    if (s.h == null) {
      h2.connectTo(h1);
      s.h = h1;
    }
    if (t.h == null) {
      h1.connectTo(h2);
      t.h = h2;    
    }
  
    HalfEdge sh = s.handle(t);
    HalfEdge th = t.handle(s);
    sh.prev.connectTo(h1);
    th.prev.connectTo(h2);
    h2.connectTo(sh);
    h1.connectTo(th);
  
    edges.add(new Edge(h1, h2));
    hetoe.put(h1, edges.get(edges.size()-1));
    hetoe.put(h2, edges.get(edges.size()-1));
  }
}



