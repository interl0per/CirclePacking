//HalfEdge data structure, and a stack and queue implementation.
//Also there are some methods to use on the HalfEdge data structure.

HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();


class HalfEdge {

  //public HalfEdge(){}
  HalfEdge prev;
  HalfEdge next;
  HalfEdge twin;
  Vertex v;
  
  HalfEdge(Vertex vv) {
    v =vv;
  }
  
  void connectTo(HalfEdge h) {
    next = h;
    h.prev = this;
  }
  // Disconnect both a halfedge and its twin.
  void detach() {
    if (v.isLeaf()) { 
      v.h = null;
    } 
    else {
      prev.connectTo(twin.next);
      v.h = twin.next;
    }
    if (twin.v.isLeaf()) { 
      twin.v.h = null; 
    }
    else {
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

class Vertex {
  boolean internal = true, processed = false, placed = false, f = false;
  HalfEdge h;
  float x, y, z, weight; // z = f(x,y,weight)
  Vertex(float _x, float _y) {
    x = _x; y = _y; weight = 0;
    h = null;
  }
  void draw(){
    if(f)  fill(0);
    ellipse(x, y,2*weight,2*weight);
    z = getZ();
    translate(x, y, z); 
    sphereDetail(6);
    sphere(10);
    translate(-x, -y, -z); 
    fill(255,0);
  }
  float getZ()
  {
    return (x*x+y*y-weight*weight)/1000;
  }
  void setPos(float dz)
  {
    z = getZ();
    //println(dz);
    z+=dz/1000;
    weight = sqrt(x*x + y*y - z*1000); 
  }
  HalfEdge handle(Vertex u) {
    if (isIsolated() || isLeaf()) { return h; }
    HalfEdge h1 = h, h2 = h.prev.twin;
    while (!ordered(h1.twin.v, u, h2.twin.v)) {
      h1 = h2;
      h2 = h1.prev.twin;      
    }
    return h1;
  }
  
  boolean isIsolated() {
    return (h == null);
  }
  
  boolean isLeaf() {
    return (!isIsolated()) && (h.twin == h.prev);
  }
  
  boolean ccw(Vertex a, Vertex b) {
    return ((a.y-y) * (b.x-x) - (a.x-x) * (b.y-y) >= 0);
  }
  
  boolean ordered(Vertex a, Vertex b, Vertex c) {
    boolean I   = ccw(a,b);
    boolean II  = ccw(b,c);
    boolean III = ccw(c,a);
    return ((I && (II || III)) || (II && III)); // at least two must be true
  } 
}

HalfEdge findHE(HalfEdge curr, Vertex d)//bfs the faces
{
  JQueue<HalfEdge> q = new JQueue<HalfEdge>();
  q.add(curr);
  while(!q.isEmpty())
  {
    HalfEdge he = q.remove();
    if(visited.containsKey(he))  continue;
    if(inFace(he,d))
    {
      visited.clear();
      return he;
    }
    visited.put(he, true);
    q.add(he.next);
    q.add(he.twin);
  }
  println("it seems that the point is not inside any triangle");
  visited.clear();
  return null;
}

ArrayList<Vertex> degree(Vertex v)//returns neighbors in ccw order
{
  ArrayList<Vertex> neighbors = new ArrayList<Vertex>();
  neighbors.add(v.h.next.v);
  HalfEdge test = v.h.prev.twin;
  while(test != v.h)
  {
    neighbors.add(test.next.v);
    test = test.prev.twin;
  }
  return neighbors;
}

void attach(Vertex s, Vertex t) {
  //don't connect verticies that are already connected
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

void drawCircumcircle(Vertex a, Vertex b, Vertex c)
{
  float mr = (b.y-a.y) / (b.x-a.x);
  float mt = (c.y-b.y) / (c.x-b.x);
  float x = (mr*mt*(c.y-a.y) + mr*(b.x+c.x) - mt*(a.x+b.x)) / (2*(mr-mt));
  float y = (a.y+b.y)/2 - (x - (a.x+b.x)/2) / mr;
  float r = sqrt(((b.x-x)*(b.x-x) +  (b.y-y)*(b.y-y)));
  stroke(255, 0, 0);
  ellipse(x, y,2*r, 2*r);
  stroke(0);
}


