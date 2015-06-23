class Point
{
  float x, y, z;
  public Point(float _x, float _y, float _z)
  {
    x = _x;
    y = _y;
    z = _z;
  }
}
Point normalize(Point a)
{
  float norm = magnitude(a);
  a.x/=norm;
  a.y/=norm;
  a.z/=norm;
  return a;
}
float magnitude(Point a)
{
  return(sqrt(a.x*a.x + a.y*a.y + a.z*a.z));
}
Point crossp(Point a, Point b)
{
  return(new Point(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x));
}
void computeSprings(Triangulation t)
{
  JQueue<HalfEdge> q = new JQueue<HalfEdge>();
  q.add(t.verticies.get(0).h);
  while(!q.isEmpty())
  {
    HalfEdge he = q.remove();
    if(visited.containsKey(he))  
      continue;
    Point vec1 = new Point(he.v.x - he.next.v.x, he.v.y - he.next.v.y, he.v.z - he.next.v.z);
    //vec1 = normalize(vec1);
    Point vec2 = new Point(he.v.x - he.prev.v.x, he.v.y - he.prev.v.y, he.v.z - he.prev.v.z);
    //vec2 = normalize(vec2);
    Point norm1 = crossp(vec1, vec2);
    norm1 = normalize(norm1);
    
    Point vec3 = new Point (he.twin.v.x - he.twin.next.v.x, he.twin.v.y - he.twin.next.v.y, he.twin.v.z - he.twin.next.v.z);
    Point vec4 = new Point(he.twin.v.x - he.twin.prev.v.x, he.twin.v.y - he.twin.prev.v.y, he.twin.v.z - he.twin.prev.v.z);
    Point norm2 = crossp(vec3, vec4);
    norm2 = normalize(norm2);

    Point force = crossp(norm1, norm2);

    float magnitude = sqrt(force.x*force.x + force.y*force.y + force.z*force.z);
   // println(force.x);
    hetoe.get(he).spring = magnitude / sqrt((he.v.x-he.next.v.x)*(he.v.x-he.next.v.x) + (he.v.y-he.next.v.y)*(he.v.y-he.next.v.y) + (he.v.z-he.next.v.z)*(he.v.z-he.next.v.z));
    
    visited.put(he, true);
    q.add(he.next);
    q.add(he.twin);
  }
  visited.clear();
}
void updateStress(Triangulation t)
{
  float CORRECTION = 1;
  for(Edge e : edges)
  {
    float target = sqrt((e.h1.v.x-e.h2.v.x)*(e.h1.v.x-e.h2.v.x) + (e.h1.v.x-e.h2.v.x)*(e.h1.v.x-e.h2.v.x));
    if(e.h1.v.weight + e.h2.v.weight < target)
    {
      e.spring += CORRECTION;
      //increase the stress on this edge
    }
    else if (e.h1.v.weight + e.h2.v.weight > target)
       e.spring -= CORRECTION;//decrease stress
  }
}
final float SPRING = 0.01;

void simulate(Triangulation t)
{
  computeSprings(t);
//  for(int i =0; i < 100; i++)
//  {
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(t.verticies.get(0).h);
    while(!q.isEmpty())
    {
      HalfEdge he = q.remove();
      if(visited.containsKey(he))// || !he.next.v.internal)  
        continue;
      float vx = (he.v.x - he.next.v.x)*SPRING;//*hetoe.get(he).spring;
      
      float vy = (he.v.y - he.next.v.y)*SPRING;//*hetoe.get(he).spring;
      if(!he.next.v.internal)
      {
        vx = 0;
        vy = 0;
      }
      he.next.v.x += vx;
      he.next.v.y += vy;
      visited.put(he, true);
      q.add(he.next);
      q.add(he.twin);
    }
  //}
  updateStress(t);
  visited.clear();
}

float angleSum(Vertex v)
{
  float res = 0;
  ArrayList<Vertex> adjacent = degree(v);
  float x = v.weight;
  for(int i = 1; i < adjacent.size()+1; i++)
  {
    float y = adjacent.get(i-1).weight;
    float z = adjacent.get(i%adjacent.size()).weight;
    res += Math.acos(((x+y)*(x+y) + (x+z)*(x+z) - (y+z)*(y+z))/(2*(x+y)*(x+z)));
  }
  return res;
}

void placeVertex(Vertex targ, float theta,  Vertex ref)
{
  targ.x = (ref.weight + targ.weight)*cos(theta) + ref.x;
  targ.y = (ref.weight + targ.weight)*sin(theta) + ref.y;
  targ.placed = true;
}

void computePacking(Triangulation t)
{
  for(Vertex v : t.outerVerts)
    v.placed = false;
  for(int i = 0; i < t.verticies.size(); i++)
  {
    if( t.verticies.get(i).h==null)
    {
       t.verticies.remove( t.verticies.get(i));
      i--;
      continue;
    }
     t.verticies.get(i).placed = false;
     t.verticies.get(i).processed = false;
  }
  //compute radii to some threshhold
  float error = 10;
  while(error>0.005)
  {
    error = 0;
    for(int j = 0; j <  t.verticies.size(); j++)
    {
      float csum = angleSum( t.verticies.get(j));
      //println(csum);
      error+=abs(csum-2*PI);
      if(csum < 2*PI)
         t.verticies.get(j).weight -= 0.01;
      else if(csum > 2*PI)
         t.verticies.get(j).weight +=0.01;  
    }
    error/= t.verticies.size();
  }
  
  //fix an arbitrary internal vertex
   t.verticies.get(0).placed = true;

  JQueue<Vertex> q = new JQueue<Vertex>();

  q.add(t.verticies.get(0));
  int cnt = 0;
  while(!q.isEmpty())
  {
    cnt++;
    Vertex iv = q.remove();
    
    ArrayList<Vertex> adjacent = degree(iv);//ordered neighbors
    int i,j;
    for(i = 0; i < adjacent.size() && !adjacent.get(i).placed; i++);
    //find a placed petal, if there is one
    float lastAngle = 0;
    
    if(i==adjacent.size() && !adjacent.get(i-1).placed)  
    {//initialization
      i--; 
      lastAngle = atan2(adjacent.get(i).y-iv.y,adjacent.get(i).x-iv.x);
      placeVertex(adjacent.get(i), lastAngle, iv);
      if(adjacent.get(i).internal)  
        q.add(adjacent.get(i));
    }

    j = i;
    while(++j % adjacent.size() != i)
    {
      Vertex v = adjacent.get(j % adjacent.size());
      if(!v.placed)
      {
        Vertex lastKnown = adjacent.get((j-1)%adjacent.size());
        lastAngle = atan2(lastKnown.y-iv.y,lastKnown.x-iv.x);

        float x = iv.weight;
        float y = lastKnown.weight;
        float z = v.weight;
        float theta = (float)Math.acos(((x+y)*(x+y) + (x+z)*(x+z) - (y+z)*(y+z))/(2*(x+y)*(x+z)));
        placeVertex(v, lastAngle-theta, iv);
      }
      if(!v.processed && v.internal)
        q.add(v);
    }
    iv.processed = true;
  }
}
boolean turn(Vertex p, Vertex q, Vertex r)
{//returns true if no turn/right turn is formed by p q r
  return((q.x - p.x)*(r.y - p.y) - (r.x - p.x)*(q.y - p.y)>=0);
}

boolean inFace(HalfEdge h, Vertex d)
{//is d in the face defined by h?
  HalfEdge start = h;
  HalfEdge temp = h.next;
  boolean first = true;
  while(first || h!=start)
  {
    first = false;
    if(turn(h.v, temp.v, d))
      return false;
    h = h.next;
    temp = temp.next;
  }
  return true;
}

boolean inOrthocircle(Vertex a, Vertex b, Vertex c, Vertex d)//is d in the circumcircle of a,b,c?
{//a,b,c should be in ccw order from following the half edges. 
//stolen from http://algs4.cs.princeton.edu/91primitives/
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
    float x2 = x-512; float y2 = y-256;
    z = (x*x+y*y-weight*weight)/1000;
    translate(x, y, z); 
    sphereDetail(6);
    sphere(10);
    translate(-x, -y, -z); 
    fill(255,0);
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

final int NUM_OUTER_VERTS = 3;
Triangulation tri = new Triangulation(NUM_OUTER_VERTS);
boolean showCircles = false;
boolean drawing = false;
int sx, sy;

void setup()
{
  size(1024, 512, P3D);
  background(255);
  fill(0,0);
}
float ax = 0, ay=0, az=0;
float tx = 0, ty=0, tz=0;
void draw()
{
  if(keyPressed && key == '1')
    showCircles = true;
  else if(keyPressed && key == '2')
    showCircles = false;
  else if(keyPressed && key=='3')
    computePacking(tri);
  else if(keyPressed && key=='4')
    computeSprings(tri);
  else if(keyPressed && key=='5')
    simulate(tri);
 else if(keyPressed && key=='c')
 {
   translate(0,0,0);
   rotate(0,0,0,0);
   ax = ay = az = tx = ty = tz = 0;
 }
  else if(keyPressed && keyCode==UP)
  {
      ax+=0.01;
  }
  else if(keyPressed && keyCode==DOWN)
  {
      ax-=0.01;  
  }
  else if(keyPressed && keyCode==LEFT)
  {
      az+=0.01;
  }
    else if(keyPressed && keyCode==RIGHT)
  {
      az-=0.01;
  }
  else if(keyPressed && key=='w')
    tz+=10;
  else if(keyPressed && key=='s')
    tz-=10;
  else if(keyPressed && key=='a')
    tx+=10;
  else if(keyPressed && key=='d')
    tx-=10;
  rotateX(ax);
  rotateY(ay);
  rotateZ(az);
  translate(tx,ty,tz);
      background(255);
  tri.draw();
  if(mousePressed && !drawing)
  {
    drawing = true;
    sx = mouseX;
    sy = mouseY;
  }
  else if(mousePressed && drawing)
  {
    float r = sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy));
    ellipse(sx, sy, 2*r,2*r);
  }

    

}

void mouseReleased()
{
  drawing = false;
  tri.addVertex(sx, sy, sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy)));
}


