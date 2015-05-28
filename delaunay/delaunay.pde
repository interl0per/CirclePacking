import java.util.*;
/*******************************************************************************/
/**************************     Data structures     ****************************/

class Edge {
  HalfEdge h1, h2;
  public Edge(HalfEdge _h1, HalfEdge _h2) {  h1 = _h1; h2 = _h2;  }
}

class HalfEdge {
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
    for(int i = 0; i < edges.size(); i++)
    {
      if(edges.get(i).h1 == this || edges.get(i).h1==this.twin)
      {
        edges.remove(i);
        return;
      }
    }
  }
}

class Vertex {
  HalfEdge h;
  float x, y;
  Vertex(float _x, float _y) {
    x = _x; y = _y;
    h = null;
  }
  
  void draw(){
    fill(0);
    noStroke();
    ellipse(x, y,2,2);
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

void attach(Vertex s, Vertex t) {
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
}

/**************************************************************************/
/**************************     Algorithms     ****************************/

boolean showCircles = false;
HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
ArrayList<Edge> edges = new ArrayList<Edge>();
ArrayList<Vertex> verticies = new ArrayList<Vertex>();

//bounding triangle
Vertex a = new Vertex(-100,-100);
Vertex b = new Vertex(1200, -100);
Vertex c = new Vertex(512, 5000);

void setup()
{
  size(1024, 512);
  background(255);
  fill(0,0);
  attach(a,b);
  attach(b,c);
  attach(c,a);
  verticies.add(a);  verticies.add(b);  verticies.add(c);
}

void draw()
{
  visited.clear();
  background(255);
  drawBFS(a.h);
  visited.clear();
  if(keyPressed && key == '1')
    showCircles = true;
  else if(keyPressed && key=='2')
    showCircles = false;
}

void mouseReleased()
{
  Vertex v = new Vertex(mouseX, mouseY);
  verticies.add(v);
  HalfEdge tri = findHE(a.h, v);    //the face this new vertex sits in

  if(tri!=null)
  {
    triangulate(tri, v);
    Stack<Edge> edgesToCheck = new Stack<Edge>();
    HashMap<Edge, Boolean> inStack = new HashMap<Edge, Boolean>();
    println(edges.size());
    for(Edge e : edges)
    {
      edgesToCheck.push(e);
      inStack.put(e, true);
    } 
    while(!edgesToCheck.isEmpty())
    {
      Edge nxt = edgesToCheck.pop();
      if(!inCircumcircle(nxt.h1.v, nxt.h1.next.v, nxt.h1.next.next.v, nxt.h2.prev.v) || !inCircumcircle(nxt.h2.v, nxt.h2.next.v, nxt.h2.next.next.v, nxt.h1.prev.v))
      {
        attach(nxt.h2.prev.v, nxt.h1.prev.v);
        nxt.h1.detach();
      }
      inStack.put(nxt, false);
    }
  }
}

HalfEdge findHE(HalfEdge curr, Vertex d)//bfs the faces
{
  Queue<HalfEdge> q = new LinkedList<HalfEdge>();
  q.add(curr);
  while(!q.isEmpty())
  {
    HalfEdge he = q.remove();
    println(he);
    if(visited.containsKey(he))  continue;
    if(inFace(he,d))  return he;
    visited.put(he, true);
    q.add(he.next);
    q.add(he.twin);
  }
  println("it seems that the point is not inside any triangle");
  return null;
}

void drawBFS(HalfEdge curr)
{
  Queue<HalfEdge> q = new LinkedList<HalfEdge>();
  q.add(curr);
  while(!q.isEmpty())
  {
    HalfEdge he = q.remove();
    if(visited.containsKey(he))  continue;
    line(he.v.x, he.v.y, he.next.v.x, he.next.v.y);
    if(showCircles)
      drawCircumcircle(he.v, he.next.v, he.next.next.v);
    visited.put(he, true);
    q.add(he.next);
    q.add(he.twin);
  }
}

void drawCircumcircle(Vertex a, Vertex b, Vertex c)
{
  float mr = (b.y-a.y) / (b.x-a.x);
  float mt = (c.y-b.y) / (c.x-b.x);
  float x = (mr*mt*(c.y-a.y) + mr*(b.x+c.x) - mt*(a.x+b.x)) / (2*(mr-mt));
  float y = (a.y+b.y)/2 - (x - (a.x+b.x)/2) / mr;
  float r = sqrt(((b.x-x)*(b.x-x) +  (b.y-y)*(b.y-y)));
  ellipse(x, y,2*r, 2*r);
}

void triangulate(HalfEdge h, Vertex v)
{
  for(int i = 0; i < 3; i++)
  {
    println("connecting to " + h);
    attach(v, h.v);
    h = h.next;
  }
}

boolean turn(Vertex p, Vertex q, Vertex r)
{//returns true if no turn/right turn is formed by p q r
  return((q.x - p.x)*(r.y - p.y) - (r.x - p.x)*(q.y - p.y)>=0);
}

boolean inFace(HalfEdge h, Vertex d)
{//is d in the face defined by h?
  return!((turn(h.v,h.next.v, d) || turn(h.next.v,h.next.next.v, d) || turn(h.next.next.v,h.v, d)));
}

boolean inCircumcircle(Vertex a, Vertex b, Vertex c, Vertex d)
{//a,b,c should be in ccw order from following the half edges. I just copied this from http://algs4.cs.princeton.edu/91primitives/ to save a headache...
  float adx = a.x - d.x;
  float ady = a.y - d.y;
  float bdx = b.x - d.x;
  float bdy = b.y - d.y;
  float cdx = c.x - d.x;
  float cdy = c.y - d.y;

  float abdet = adx * bdy - bdx * ady;
  float bcdet = bdx * cdy - cdx * bdy;
  float cadet = cdx * ady - adx * cdy;
  float alift = adx * adx + ady * ady;
  float blift = bdx * bdx + bdy * bdy;
  float clift = cdx * cdx + cdy * cdy;
  return alift * bcdet + blift * cadet + clift * abdet >= 0;
}
