final int NUM_OUTER_VERTS = 6;
Triangulation tri;
boolean drawOrtho = false;
boolean drawDualEdge = false;
final boolean FAKE = true;
int sx, sy;

void setup()
{
  size(2048, 1024, P3D);
  background(255);
  fill(0,0);
  tri = new Triangulation(NUM_OUTER_VERTS, 5000, 800);
}

boolean d = true, e= true;
ArrayList<Float> oldr;

void draw()
{
  if(keyPressed)
  {
    switch (key)
    {
      case '1':
        drawOrtho = true;
        break;
      case '2':
        drawOrtho = false;
        break;
      case '3':
        drawDualEdge = true;
        break;
      case '4':
        drawDualEdge = false;
        break;
      case '5':
        if(tri.verticies.size() > 0)
          simulate(tri);
        break;
     case '6':
        computePacking(tri);
        break;
     case '7':
       if(e)
       {
         oldr =  new ArrayList<Float>();

         for(int i =0; i < tri.verticies.size(); i++)
           oldr.add(i, tri.verticies.get(i).weight);
  
         Edge nxt = edges.get(20);
         attach(nxt.h2.prev.v, nxt.h1.prev.v);
         nxt.h1.detach();
         e = false;
       }
       break;
    case '9':
      int x = (int)random(width-100), y = (int)random(height-100);
      tri.addVertex(new Vertex(x, y, 10));
      break;
     case 'g':
       for(int i =0; i < tri.verticies.size(); i++)
       {
           tri.verticies.get(i).shade = (int)min(255, 10*(abs(oldr.get(i) - tri.verticies.get(i).weight)));
           println(tri.verticies.get(i).shade);
       }
       break;
     case '8':
        for(Edge e : edges)
        {
          float sign = random(0,1);
          float off = random(0,1);
          if(sign < 0.5)
            e.spring+=off*10;
      
          else
            e.spring-=off*10;
        }
        break;
      
      case 'c':
        translate(0,0,0);
        break;
      case 'w':
        ty+=20;
        break;
      case 'a':
        tx+=20;
        break;
      case 's':
        ty-=20;
        break;
      case 'd':
        tx-=20;
        break;
      case 'q':
        tz+=20;
        break;
      case 'z':
        tz-=20;
        break;
    }
  }
    ///////////////////draw
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
  tri.addVertex(new Vertex(sx, sy, sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy))));
}


float CORRECTION = 0.05, SPRING = 0.01;

void computeSprings(Triangulation t)
{
  JQueue<HalfEdge> q = new JQueue<HalfEdge>();
  q.add(t.verticies.get(0).h);
  while(!q.isEmpty())
  {
    HalfEdge he = q.remove();

    if(visited.containsKey(he))  
      continue;
      
    Point grad1 = new Point(he.ocx, he.ocy, 0);
    Point grad2 = new Point(he.twin.ocx, he.twin.ocy, 0);
    
    Point force = new Point(grad1.x - grad2.x, grad1.y - grad2.y, 0);
    
    float magnitude = sqrt(force.x*force.x + force.y*force.y);
    float disp = sqrt((he.v.x-he.next.v.x)*(he.v.x-he.next.v.x) + (he.v.y-he.next.v.y)*(he.v.y-he.next.v.y));
    
    hetoe.get(he).spring = magnitude/disp;
    visited.put(he, true);
    q.add(he.next);
    q.add(he.twin);
  }
  visited.clear();
}

void updateStress(Triangulation t)
{
  for(Edge e : edges)
  {
    if(!(e.h1.v.internal && e.h2.v.internal)) 
    {
      e.spring = 200;
      continue;
    }
    float target = sqrt((e.h1.v.x-e.h2.v.x)*(e.h1.v.x-e.h2.v.x) + (e.h1.v.y-e.h2.v.y)*(e.h1.v.y-e.h2.v.y));

    if (e.h2.v == t.imaginary)
    {
      if(-e.h1.v.weight + e.h2.v.weight < target)
      {      //increase the stress on this edge
        e.spring += CORRECTION;
        e.h1.v.weight -= CORRECTION*10; 
      }
      else 
      {
         if(e.spring > 0) 
           e.spring -= CORRECTION;//decrease stress
         e.h1.v.weight += CORRECTION*10; 
      }
    }
    else
    {
      if(e.h1.v.weight + e.h2.v.weight < target)
      {      //increase the stress on this edge
       e.spring += CORRECTION;
       e.h1.v.weight += CORRECTION*10; 
       e.h2.v.weight += CORRECTION*10; 
      }
      else
      {
        if(e.spring > 0)
          e.spring -= CORRECTION;//decrease stress
        e.h1.v.weight -= CORRECTION*10; 
        e.h2.v.weight -= CORRECTION*10; 
      }
    }
  }
}


void simulate(Triangulation t)
{
//  for(Edge e: edges)
//        e.spring = 0;
 for(int i =0; i < 100; i++)
 {
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(t.verticies.get(0).h);
    while(!q.isEmpty())
    {
      HalfEdge he = q.remove();
      if(visited.containsKey(he))// || !he.next.v.internal)  
        continue;
        
      float vx = (he.v.x - he.next.v.x)*hetoe.get(he).spring/100000;
      float vy = (he.v.y - he.next.v.y)*hetoe.get(he).spring/100000;

      if(!he.next.v.internal)// || he.next.v == t.imaginary)
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
    visited.clear();
    updateStress(t);
  }
}

float angleSum(Vertex v)
{
  float res = 0;
  ArrayList<Vertex> adjacent = v.degree();
  float x = v.weight;
  for(int i = 1; i < adjacent.size()+1; i++)
  {
    Vertex v1 = adjacent.get(i-1);
    Vertex v2 = adjacent.get(i%adjacent.size());
//    if(!v1.internal)  v1 = tri.imaginary;
//    if(!v2.internal)  v2 = tri.imaginary;
    float y = v1.weight;
    float z = v2.weight;
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

//thurston algorithm
void computePacking(Triangulation t)
{
  for(Vertex v : t.outerVerts)
    v.placed = false;
  for(int i = 0; i < t.verticies.size(); i++)
  {
    if(t.verticies.get(i).h==null)
    {
      t.verticies.remove( t.verticies.get(i));
      i--;
      continue;
    }
    t.verticies.get(i).placed = false;
    t.verticies.get(i).processed = false;
  }
  //compute radii to some threshhold
  for(int i= 0; i < 100; i++)
  {
    for(int j = 0; j <  t.verticies.size(); j++)
    {
      float csum = angleSum( t.verticies.get(j));
      if(csum < 2*PI)
         t.verticies.get(j).weight -= 0.01;
      else if(csum > 2*PI)
         t.verticies.get(j).weight += 0.01;  
    }
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

    ArrayList<Vertex> adjacent = iv.degree();//ordered neighbors
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




//HalfEdge data structure, and a stack and queue implementation.
//Also there are some methods to use on the HalfEdge data structure.

HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
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
      if(turn(h.v, temp.v, this))
        return false;
      h = h.next;
      temp = temp.next;
    }
    return true;
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
    if(d.inFace(he))
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

void attach(Vertex s, Vertex t) 
{
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
class Point
{
  float x, y, z;
  public Point(float _x, float _y, float _z)
  {
    x = _x;
    y = _y;
    z = _z;
  }
  float magnitude()
  {
    return(sqrt(x*x + y*y + z*z));
  }
  void normalize(float target)
  {
    float c = target/z;
    x*=c;
    y*=c;
    z = target;
  }
  Point crossp(Point b)
  {
     return(new Point(y*b.z - z*b.y, z*b.x - x*b.z, x*b.y - y*b.x));
  }
}

HashMap<HalfEdge, Edge> hetoe = new HashMap<HalfEdge, Edge>();
ArrayList<Edge> edges = new ArrayList<Edge>();
boolean drawing = false;
float tx = 0, ty=0, tz=0;

class Triangulation
{
  Vertex imaginary = new Vertex(1024, 512, 800);
  ArrayList<Vertex> verticies = new ArrayList<Vertex>();//internal verticies
  ArrayList<Vertex> outerVerts = new ArrayList<Vertex>();
  
  //Triangulation([Number of outer verticies] [boundary spacing] [boundary radii])
  public Triangulation(int n, int rCent, int rBound)
  {
    imaginary.shade = color(255,255,255,0);
    //create outer face
    Vertex center = new Vertex(width/2, height/2, rCent);
    float step = 2*PI/n;
    //place the verticies on the outer face
    for(int i = 0; i < n; i++)
    {
      Vertex bv = new Vertex(-100,-100,rBound);
      bv.internal = false;
      placeVertex(bv, i*step, center);
      outerVerts.add(bv);
    }
    for(int i =1; i <= n; i++)
      attach(outerVerts.get(i%n), outerVerts.get(i-1)); 
  }
  
  void draw()
  {//draw the triangulation
    background(255);
    imaginary.shade = color(255,255,255,0);
    translate(tx,ty,tz);
  
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(outerVerts.get(0).h);
    while(!q.isEmpty())
    {
      HalfEdge he = q.remove();
      
      if(visited.containsKey(he))  continue;
      
      if(!drawDualEdge && he.v != imaginary && he.next.v != imaginary)
        line(he.v.x, he.v.y, he.next.v.x, he.next.v.y);
      he.v.draw();
      he.drawOrthocircle();

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
  
  boolean addVertex(Vertex v)  //add vertex to the delaunay triangulation
  {
    drawing = false;
    if(FAKE)
    {
      HalfEdge he = this.imaginary.h;
      if(he!=null)  
      {  
        ArrayList<Vertex> dg = imaginary.degree();
        for(int i= 0;i < dg.size(); i++)
        {
          HalfEdge nxt = he.twin.next; 
          he.detach();
          he = nxt;
        }
      }
    }
    
    if(v.weight < EPSILON)  
      v.weight = 5;
      
    verticies.add(v);
    HalfEdge face = findHE(outerVerts.get(0).h, v);    //the face this new vertex sits in
    
    if(face==null)  return false;

    triangulate(face, v);
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
      if(nxt.h2.inOrthocircle(nxt.h1.prev.v) || nxt.h1.inOrthocircle(nxt.h2.prev.v))
      {//edge is not ld
        if(turn(nxt.h2.prev.v, nxt.h1.next.v, nxt.h1.prev.v))
        {//concave case 1
          if(nxt.h1.next.v.degree().size()==3)
          {//flippable
            attach(nxt.h2.prev.v,nxt.h1.prev.v);
            Edge ei[] = {hetoe.get(nxt.h1.next.twin.prev), hetoe.get(nxt.h1.prev), hetoe.get(nxt.h2.next)};
            for(int i= 0;i < 3; i++)
            {
              if(inStack.get(ei[i]) == null || !inStack.get(ei[i]))
              {
                edgesToCheck.push(ei[i]);
                inStack.put(ei[i], true);
              }
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
            attach(nxt.h2.prev.v,nxt.h1.prev.v);

            Edge ei[] = {hetoe.get(nxt.h1.prev.twin.next), hetoe.get(nxt.h1.next), hetoe.get(nxt.h2.prev)};
            for(int i= 0;i < 3; i++)
            {
              if(inStack.get(ei[i]) == null || !inStack.get(ei[i]))
              {
                edgesToCheck.push(ei[i]);
                inStack.put(ei[i], true);
              }
            }
            nxt.h1.prev.detach();
            nxt.h2.next.detach();
            nxt.h1.detach();
          }
        }
        else 
        {//2-2 flip
          Edge ei[] = {hetoe.get(nxt.h1.next), hetoe.get(nxt.h1.prev), hetoe.get(nxt.h2.next), hetoe.get(nxt.h2.prev)};
          for(int i =0; i < 4; i++)
          {
            if(inStack.get(ei[i]) == null || !inStack.get(ei[i]))
            {
              edgesToCheck.push(ei[i]);
              inStack.put(ei[i], true);
            }
          }
          attach(nxt.h2.prev.v, nxt.h1.prev.v);
          nxt.h1.detach();
        }
      }
    } 
  if(FAKE)
  {
    for(Vertex vv : verticies)
    {
      ArrayList<Vertex> adj = vv.degree();
      vv.almostOuter = false;
      for(Vertex vvv : adj)
      {
        if(!vvv.internal)
          vv.almostOuter = true;
          //break;
      }
      if(vv.almostOuter)
      {
        attach(vv,imaginary);
        vv.shade = color(100, 0, 0);
      }
      else
        vv.shade = 50;
    }
  }
  computeSprings(this);
  return true;  
  }
}



