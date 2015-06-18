int NUM_OUTER_VERTS = 3;
boolean showCircles = false;
HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
ArrayList<Edge> edges = new ArrayList<Edge>();
ArrayList<Vertex> verts = new ArrayList<Vertex>();//internal verticies
HashMap<HalfEdge, Edge> hetoe = new HashMap<HalfEdge, Edge>();

ArrayList<Vertex> outerVerts = new ArrayList<Vertex>();

/*******************************************************************************/
/**************************     Data structures     ****************************/
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
    hetoe.remove(this);
    hetoe.remove(twin);
    for(int i = 0; i < edges.size(); i++)
    {//not efficent
      if(edges.get(i).h1 == this || edges.get(i).h1 == twin)
      {
        edges.remove(i);
        i--;
      }
    }
  }
}

class Vertex {
  boolean internal = true;
  boolean processed = false;
  boolean placed = false;
  boolean f = false;//fill this vertex
  float weight;
  HalfEdge h;
  float x, y;
  Vertex(float _x, float _y) {
    x = _x; y = _y;
    h = null;
  }
  
  void draw(){
    if(f)  fill(0);
    ellipse(x, y,2*weight,2*weight);
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

void drawBFS(HalfEdge curr)
{
  JQueue<HalfEdge> q = new JQueue<HalfEdge>();
  q.add(curr);
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
//Vertex getPt(float x, float dx, float y, float dy)
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
  //return!((turn(h.v,h.next.v, d) || turn(h.next.v,h.next.next.v, d) || turn(h.next.next.v,h.v, d)));
}

boolean inCircumcircle(Vertex a, Vertex b, Vertex c, Vertex d)
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

void addVertex(int x, int y, float r)
{
  Vertex v = new Vertex(x, y);
  v.weight = r;
  if(r < EPSILON)  v.weight = 10;
  verts.add(v);
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
/**************************************************************************/
/**************************  Processing events ****************************/
void setup()
{
  size(1024, 512);
  background(255);
  fill(0,0);
  //create outer face
  Vertex center = new Vertex(512, 256);
  center.weight = 10000;
  float step = 2*PI/NUM_OUTER_VERTS;//angle between adjacent verticies
  //place the verticies on the outer face
  for(int i = 0; i < NUM_OUTER_VERTS; i++)
  {
    Vertex bv = new Vertex(-100,-100);
    bv.weight = 700;
    bv.internal = false;
    placeVertex(bv, i*step, center);
    outerVerts.add(bv);
  }
  center.weight = 0;
  for(int i =1; i < NUM_OUTER_VERTS+1; i++)
    attach(outerVerts.get(i%NUM_OUTER_VERTS), outerVerts.get(i-1)); 
}

boolean drawing = false;
int sx, sy;

void draw()
{
  background(255);
  drawBFS(outerVerts.get(0).h);
  if(keyPressed && key == '1')
    showCircles = true;
  else if(keyPressed && key == '2')
    showCircles = false;
  
  else if(keyPressed && key=='6')
    computePacking();
    
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
  addVertex(sx, sy, sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy)));
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

void computePacking()
{
  for(Vertex v : outerVerts)
    v.placed = false;
  for(int i = 0; i < verts.size(); i++)
  {
    if(verts.get(i).h==null)
    {
      verts.remove(verts.get(i));
      i--;
      continue;
    }
    verts.get(i).placed = false;
    verts.get(i).processed = false;
  }
  //compute radii to some threshhold
  float error = 10;
  while(error>0.005)
  {
    error = 0;
    for(int j = 0; j < verts.size(); j++)
    {
      float csum = angleSum(verts.get(j));
      //println(csum);
      error+=abs(csum-2*PI);
      if(csum < 2*PI)
        verts.get(j).weight -= 0.01;
      else if(csum > 2*PI)
        verts.get(j).weight +=0.01;  
    }
    error/=verts.size();
  }
  
  //fix an arbitrary internal vertex
  verts.get(0).placed = true;

  JQueue<Vertex> q = new JQueue<Vertex>();

  q.add(verts.get(0));
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
