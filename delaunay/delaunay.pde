import java.util.*;
class Point { float x, y; public Point(float xx, float yy) { x = xx; y = yy; } } ;

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
    stroke(255);
    strokeWeight(5);
    line(v.loc.x, v.loc.y, next.v.loc.x, next.v.loc.y);
    stroke(0);
    strokeWeight(1);
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
  }
}
class Vertex {
  Point loc;
  HalfEdge h;
  
  Vertex(Point p) {
    loc = p;
    h = null;
  }
  
  void draw(){
    fill(0);
    noStroke();
    ellipse(loc.x, loc.y,2,2);
  }

  HalfEdge handle(Vertex u) {
    if (isIsolated() || isLeaf()) { return h; }
    HalfEdge h1 = h, h2 = h.prev.twin;
    while (!ordered(h1.twin.v.loc, u.loc, h2.twin.v.loc)) {
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
  
  boolean ccw(Point a, Point b) {
    return ((a.y-loc.y) * (b.x-loc.x) - (a.x-loc.x) * (b.y-loc.y) >= 0);
  }
  
  boolean ordered(Point a, Point b, Point c) {
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
  if(s!=a && t!=a && s!=b && t!=b && s!=c && t!=c)    
    line(s.loc.x, s.loc.y, t.loc.x, t.loc.y);
}

HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();

HalfEdge dualBFS(HalfEdge curr, Point d)//walk along all the faces
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

/**************************************************************************/
/************************** Processing events *****************************/
//bounding triangle
Vertex a = new Vertex(new Point(-100,-100));
Vertex b = new Vertex(new Point(1200,-100));
Vertex c = new Vertex(new Point(512, 5000));

ArrayList<Vertex> verticies = new ArrayList<Vertex>();

void draw(){  }

void setup()
{
  size(1024, 512);
  background(255);
  attach(a,b);
  attach(b,c);
  attach(c,a);
  //println(inCircumcircle( new Point(500,500),  new Point(500, 600), new Point(550, 550), new Point(498, 550)));
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
boolean turn(Point p, Point q, Point r)
{//returns true if no turn/right turn is formed by p q r
  return((q.x - p.x)*(r.y - p.y) - (r.x - p.x)*(q.y - p.y)>=0);
}

boolean inFace(HalfEdge h, Point d)
{//is d in the face defined by h?
  return!((turn(h.v.loc,h.next.v.loc, d) || turn(h.next.v.loc,h.next.next.v.loc, d) || turn(h.next.next.v.loc,h.v.loc, d)));
}

boolean inCircumcircle(Point a, Point b, Point c, Point d)
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

void mouseReleased()
{
  Vertex v = new Vertex(new Point(mouseX, mouseY));
  verticies.add(v);
  HalfEdge tri = dualBFS(a.h, v.loc);    //the face this new vertex sits in
  if(tri!=null)
  {
    triangulate(tri, v);
    boolean isDelaunay = false;
    while(!isDelaunay)
    {
      isDelaunay = true;
      for(Vertex vv : verticies)
      {
        /*if(i==2) 
        {
          ellipse(vv.loc.x, vv.loc.y, 10, 10);
          ellipse(vv.h.twin.prev.v.loc.x, vv.h.twin.prev.v.loc.y, 20,20);
          ellipse(vv.h.next.v.loc.x, vv.h.next.v.loc.y, 30,30);
          ellipse(vv.h.twin.prev.twin.next.next.v.loc.x, vv.h.twin.prev.twin.next.next.v.loc.y, 40,40);
        }*/
        if(!inCircumcircle(vv.loc, vv.h.next.v.loc, vv.h.next.next.v.loc, vv.h.twin.prev.v.loc))
        {
          println("c1");
          attach(vv.h.twin.prev.v, vv.h.next.next.v);
          vv.h.detach();  
          isDelaunay = false;
        }
         /*else if(!inCircumcircle(vv.loc, vv.h.next.next.v.loc, vv.h.twin.prev.v.loc, vv.h.next.v.loc))
        {
          int x = 2/0;
          println("c2");
          attach(vv.h.next.v, vv.h.twin.prev.v);
          vv.h.next.detach();  
          isDelaunay = false;
        }*/
         else if(!inCircumcircle(vv.loc, vv.h.twin.prev.v.loc,vv.h.next.v.loc, vv.h.twin.prev.twin.next.next.v.loc))
        {
          println("c3");
          attach(vv,  vv.h.twin.prev.twin.next.next.v);
          vv.h.twin.prev.twin.detach();  
          isDelaunay = false;
        }
      }
    }
  }
  visited.clear();
}

