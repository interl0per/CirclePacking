import java.util.*;
boolean packing = false;
boolean showCircles = false;
boolean showWeights = true;
HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
ArrayList<Edge> edges = new ArrayList<Edge>();
ArrayList<Vertex> verts = new ArrayList<Vertex>();//internal verticies
HashMap<HalfEdge, Edge> hetoe = new HashMap<HalfEdge, Edge>();

//bounding triangle
Vertex a = new Vertex(-100,-100);
Vertex b = new Vertex(2000, -100);
Vertex c = new Vertex(512, 5000);
//Vertex d = new Vertex(2000, 500);



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
  boolean inc = false;
  boolean internal = true;
  boolean processed = false;
  boolean placed = false;
  boolean f = false;
  float r = 20;
  float weight;
  HalfEdge h;
  float x, y;
  Vertex(float _x, float _y) {
    x = _x; y = _y;
    h = null;
  }
  
  void draw(){
    if(inc) fill(204, 102, 0);
    if(f) fill(0);
    if(!packing)  ellipse(x, y,2*weight,2*weight);
    else     ellipse(x, y,2*r,2*r);
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

class Vertex2 {
  float x, y, r;
  ArrayList<Integer> neighbors = new ArrayList<Integer>();
}


HalfEdge findHE(HalfEdge curr, Vertex d)//bfs the faces
{
  Queue<HalfEdge> q = new LinkedList<HalfEdge>();
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
  Queue<HalfEdge> q = new LinkedList<HalfEdge>();
  q.add(curr);
  while(!q.isEmpty())
  {
    HalfEdge he = q.remove();
    if(visited.containsKey(he))  continue;
    //if(he.v!=a && he.next.v!=a && he.v!=b && he.next.v!=b && he.v!=c && he.next.v!=c)  
      line(he.v.x, he.v.y, he.next.v.x, he.next.v.y);
    if(showWeights)
      he.v.draw();
    if(showCircles)  
      drawCircumcircle(he.v, he.next.v, he.next.next.v);
    visited.put(he, true);
    q.add(he.next);
    q.add(he.twin);
  }
  visited.clear();
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
//  HalfEdge temp = h.next;
//  while(temp!=h)
//  {
//    attach(v, temp.v);
//    temp = temp.next;
//  }
  for(int i = 0; i < 3; i++)
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
  verts.add(v);
  HalfEdge tri = findHE(a.h, v);    //the face this new vertex sits in

  if(tri!=null)
  {
    triangulate(tri, v);

    Stack<Edge> edgesToCheck = new Stack<Edge>();
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
  attach(a,b);
  attach(b,c);
  attach(c,a);
  //attach(a,c);
  a.weight = b.weight = c.weight = 0;// = d.weight = 0;
  a.internal = b.internal = c.internal = false;//= d.internal = false;
  a.r = b.r = c.r = 500;// d.r = 50;
}

boolean drawing = false;
int sx, sy;
int SCALE = 50;

int avgColor(int x, int y, int w)
{
  int sum = 0;
  
  for(int i = x; i < x+SCALE; i++)
    for(int j = y; j < y+SCALE; j++)
      sum+=get(i,j);
 
  return sum/(SCALE*SCALE);
}

void draw()
{
  background(255);
  drawBFS(a.h);
  if(keyPressed && key == '1')
    showCircles = true;
  else if(keyPressed && key == '2')
    showCircles = false;
 else if(keyPressed && key=='3')
    showWeights = true;
  else if(keyPressed && key=='4')
    showWeights = false;
  else if(keyPressed && key=='5')
  {
    PImage img = loadImage("test.jpg");
    image(img, 0, 0);

    for(int i =0 ; i < img.width; i+= SCALE)
      for(int j = 0; j < img.height; j+= SCALE)
      {
        float weight = brightness(avgColor(i,j,img.width));
        addVertex(i,j, weight/(10));
      }
  }
  else if(keyPressed && key=='6')
  {
    packing = true;
    computePacking();
  }
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

/**************************************************************************/
float angleSum(Vertex v)
{
  float res = 0;
  ArrayList<Vertex> adjacent = degree(v);
  //adjacent.remove(a);  adjacent.remove(b);  adjacent.remove(c);
  float x = v.r;

  for(int i = 1; i < adjacent.size()+1; i++)
  {
    float y = adjacent.get(i-1).r;
    float z = adjacent.get(i%adjacent.size()).r;
    res += Math.acos(((x+y)*(x+y) + (x+z)*(x+z) - (y+z)*(y+z))/(2*(x+y)*(x+z)));
  }
  return res;
}
void placeVertex(Vertex targ, float theta,  Vertex ref)
{
  targ.x = (ref.r + targ.r)*cos(theta) + ref.x;
  targ.y = (ref.r + targ.r)*sin(theta) + ref.y;
  targ.placed = true;
}
void computePacking()
{
  a.placed = b.placed = c.placed = false;
  for(Vertex v : verts)
  {
    v.placed = false;
    v.processed = false;
  }
  //compute radii to some threshhold
  float error = 100;
  while(error>1)
  {
    error = 0;
    for(int j = 0; j < verts.size(); j++)
    {
      float csum = angleSum(verts.get(j));
      //println(csum);
      error+=abs(csum-2*PI);
      if(csum < 2*PI)
      {
        verts.get(j).r -= 0.05;
        verts.get(j).inc = false;
      }
      else if(csum > 2*PI)
      {
        verts.get(j).r +=0.05;  
        verts.get(j).inc = true;
      }
    }
  }
  
  //fix an arbitrary internal vertex
  verts.get(0).x = 512; 
  verts.get(0).y = 256;
  verts.get(0).placed = true;

  Queue<Vertex> q = new LinkedList<Vertex>();

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
      placeVertex(adjacent.get(i), lastAngle, iv);
      if(adjacent.get(i).internal)  
        q.add(adjacent.get(i));
    }

    j = i;
    while(++j % adjacent.size() != i)
    {
      Vertex v = adjacent.get(j % adjacent.size());
      //println(j);

      if(!v.placed)
      {
        Vertex lastKnown = adjacent.get((j-1)%adjacent.size());
        atan2(0.1, 0.2);
        lastAngle = atan2(lastKnown.y-iv.y,lastKnown.x-iv.x);
        if(j==4)
        {
          //lastKnown.f = true;
        }
        float x = iv.r;
        float y = lastKnown.r;
        float z = v.r;
        float theta = (float)Math.acos(((x+y)*(x+y) + (x+z)*(x+z) - (y+z)*(y+z))/(2*(x+y)*(x+z)));

       // println(j + " " + lastAngle);
        if(cnt==1&&j==4) 
        {
          //iv.f = true;
          //v.f = true;
          println(lastAngle + " " + theta);
          
        }

        placeVertex(v, theta+lastAngle, iv);
      }
      if(!v.processed && v.internal)
        q.add(v);
    }
    iv.processed = true;
  }
}
