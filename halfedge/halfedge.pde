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
  }
  
  void draw() {
    strokeWeight(2);
    stroke(100,100,200);
    Vertex u = twin.v;
    float x1 = v.x;
    float x2 = u.x;
    float y1 = v.y;
    float y2 = u.y;
    float dx = x2 - x1;
    float dy = y2 - y1;
    float d = sqrt(dx * dx + dy * dy);
    float offset = 4;
    float t = 0.75;
    line(x1 + offset*(dx+dy)/d, y1 + offset*(dy-dx)/d, x1 + offset*dy/d + t*dx, y1 + t*dy - offset*dx/d);
  }  
}

class Vertex {
  float x,y;
  HalfEdge h;
  
  Vertex(float xx, float yy) {
    x = xx;
    y = yy;
    h = null;
  }
  
  void draw(){
    fill(0);
    noStroke();
    ellipse(x,y,2,2);
  }

  HalfEdge handle(Vertex u) {
    if (isIsolated() || isLeaf()) { return h; }
    HalfEdge h1 = h, h2 = h.prev.twin;
    while (!ordered(h1.twin.v,u,h2.twin.v)) {
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
  
  void reconnect() {
    ArrayList<Vertex> nbrs = new ArrayList<Vertex>();
    while(!isIsolated()) {
      nbrs.add(h.twin.v);
      h.detach();
    }
    for (Vertex n : nbrs) { attach(this, n); }
  }
}

class Edge {
  Vertex s,t;
  
  Edge(Vertex ss, Vertex tt) {
    s = ss;
    t = tt;
  }
  
  void draw() {
    strokeWeight(2);
    stroke(256,150,150);
    line(s.x, s.y, t.x, t.y);
  }
  
}

ArrayList<Vertex> vertex = new ArrayList<Vertex>();  
ArrayList<Edge> edge = new ArrayList<Edge>();
boolean draggingVertex = false;
boolean edgeStarted = false;
HalfEdge activeHalfEdge;
Vertex activeVertex;
float xOffset;
float yOffset;

void setup() {
  size(800, 800);
  smooth();
  ellipseMode(RADIUS);
  
  Vertex u = newVertex(100, 100);
  Vertex v = newVertex(200,300);
  newEdge(u,v);
  activeHalfEdge = u.h;
}

void draw() {
  background(255);
  for(Edge e :edge) {
    e.draw();
  }
  for(Vertex v : vertex) {
    v.draw();
  }
  
  activeHalfEdge.draw();
  
  Vertex v = whichVertex(mouseX, mouseY);
  if(v != null) {
    strokeWeight(2);
    noFill();
    stroke(150,150,256);
    ellipse(v.x,v.y,5,5);
//    Vertex u = activeHalfEdge.v;
//    HalfEdge h = v.handle(u);
//    if (h != null) { h.draw(); }
//    h = u.handle(v);
//    if (h != null) { h.draw(); }
  } 
  if(edgeStarted) {
    strokeWeight(2);
    noFill();
    stroke(150,150,256);
    line(activeVertex.x, activeVertex.y, mouseX, mouseY);
  }
}

Vertex newVertex(float x, float y) {
  Vertex v = new Vertex(x,y);
  vertex.add(v);
  return v;
}

Edge newEdge(Vertex s, Vertex t) {
  // todo: check if edge already exists.
  Edge e = new Edge(s, t);
  edge.add(e);
  attach(s,t);
  return e;
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
}

Vertex whichVertex(float x, float y) {
  if(vertex.isEmpty()) { return null; }
  Vertex nearest = null;
  float d_min = 50;
  float d; 
  for(Vertex v: vertex) {
    d = squaredDistance(v.x, v.y, x,y);
    if(d < d_min) {
      d_min = d;
      nearest = v;
    } 
  }
  return nearest;
}

void keyPressed() {
  if(key == 'p') { activeHalfEdge = activeHalfEdge.prev; } 
  if(key == 'n') { activeHalfEdge = activeHalfEdge.next; } 
  if(key == 't') { activeHalfEdge = activeHalfEdge.twin; } 
}

void mousePressed() {
  Vertex v = whichVertex(mouseX,mouseY);
  if(v == null) { 
    v = newVertex(mouseX, mouseY);
    if (edgeStarted) {
      newEdge(activeVertex, v);
      edgeStarted = false;
    }
  }  
  else {
    if (edgeStarted) {
      newEdge(activeVertex, v);
      edgeStarted = false;
    }
    else {
      edgeStarted = true;
      draggingVertex = true;
      activeVertex = v;
      xOffset = v.x - mouseX;
      yOffset = v.y - mouseY;
    }
  } 
}

void mouseDragged () {
  edgeStarted = false;
  if(draggingVertex) {
    activeVertex.x = mouseX + xOffset;
    activeVertex.y = mouseY + yOffset; 
    activeVertex.reconnect(); 

  }
}

void mouseReleased() {
  if(draggingVertex) { 
    draggingVertex = false;
  }
}

float squaredDistance(float x1, float y1, float x2, float y2) {
  return squaredNorm(x1-x2, y1-y2);
}

float squaredNorm(float x, float y) {
  return x*x + y*y;
}
