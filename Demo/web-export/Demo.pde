import java.util.Random;

final int NUM_OUTER_VERTS = 3;
final int INF = 1<<30;
final float orthoSphereR = 200.0;
float sx, sy;
boolean drawing = false;
boolean drawOrtho = false;
boolean rotating = false;
boolean drawKoebe = false;
boolean mode2 = false;

EnrichedEmbedding test; 

void setup() {
  size(1024, 768, P3D);
  background(255);
  fill(0, 0);
  test = new EnrichedEmbedding(NUM_OUTER_VERTS);
  textFont(createFont("Arial",32));
}

void draw() {
  background(255);
  
  translate(width/2, height/2, 0);  
  
  fill(100);
  noStroke();
  rect(-500,-height/2, 1000, 50);

  if (!rotating) {
    test.drawPSLG();
    test.drawRadii();
  }

  if (keyPressed) {
    if (keyCode==LEFT) {
      radii_update(test);
    } else if (keyCode==RIGHT) {
      stress_update(test);
    }
  }

  if (keyPressed && key=='r') {
    Random rand = new Random();
    test.addVertex(rand.nextInt(width)-width/2, rand.nextInt(height)-height/2, rand.nextInt(70));
  }
  if (drawing) {
    float dx = mouseX - sx, dy = mouseY - sy, r = sqrt(dx*dx + dy*dy);

    noStroke();
    fill(185, 205, 240);
    ellipse(sx-width/2, sy-height/2, 2*r, 2*r);
  }

  if (!rotating && drawOrtho) {
    test.drawOrthocircles();
  }
  if (rotating && test.isPacking())
  {
    float dyt = sx - mouseX, dxt = sy - mouseY;

    HashMap<HalfEdge, Boolean> done = new HashMap<HalfEdge, Boolean>();

    for (int i= 0; i < test.G.edges.size(); i++) {
      if (done.containsKey(test.G.edges.get(i).h1)) {
        continue;
      }
      done.put(test.G.edges.get(i).h1, true);

      Vertex v = test.G.edges.get(i).h1.ixnp;

      v.rotate('x', -dxt/70);
      v.rotate('x', -dxt/70);
      v.rotate('y', dyt/70);
      v.rotate('y', dyt/70);

      test.G.edges.get(i).h1.ixnp = v;
    }
    test.G.down();
    test.G.fancyDraw(drawKoebe);

    sx = mouseX; 
    sy = mouseY;
  }
      fill(100);

    rect(-500,-height/2, 1000, 50);
  fill(230);

  if(test.G.verts.size()==0)
  {
    text("Click and drag to add weighted points to the triangulation", -450, -height/2+30);
  }
  else if(!test.isPacking())
  {
    text("When finished, press 'LEFT' to run the radii update algorithm or 'RIGHT' to run the force directed algorithm", -450, -height/2+30);
  }
  else
  {
    text("Click and drag right mouse to view mobius transformations. Press K to toggle koebe view, and 'C' to restart.", -450, -height/2+30);
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    sx = mouseX; 
    sy = mouseY;
    drawing = true;
  } else if (mouseButton == RIGHT && test.isPacking()) {
    test.G.computeIxn();
    sx = mouseX; 
    sy = mouseY;
    rotating = true;
    mode2 = true;
  }
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    float dx = mouseX - sx, dy = mouseY - sy;
    test.addVertex(sx-width/2, sy-height/2, sqrt(dx*dx + dy*dy));
    drawing = false;
  } else if (mouseButton == RIGHT) {
    rotating = false;
  }
}

void keyPressed() {
  if (key == 'c') {
    mode2 = false;
    setup();
  } else if (key=='d') {
    drawOrtho = !drawOrtho;
  }
  else if (key == 'k') {
    drawKoebe = !drawKoebe;
  }
}
final float KCORRECTION = 0.01;
final float RCORRECTION = 0.005;

void stress_update(EnrichedEmbedding ebd) {
  ebd.cEmbedding_stress();
}

void radii_update(EnrichedEmbedding t) {
  for (int i =0; i <  100; i++) {
    for (Vertex v : t.G.verts) {
      if (v.angleSum() > 2*PI) {
        v.r += RCORRECTION;
      } else {
        v.r -= RCORRECTION;
      }
    }
    t.cEmbedding_radii();
  }
}
class Complex
{
  public ArrayList<Vertex> verts = new ArrayList<Vertex>();//internal verticies
  public ArrayList<Vertex> outerVerts = new ArrayList<Vertex>();
  public ArrayList<Edge> edges = new ArrayList<Edge>();

  Complex dual;

  public Complex() {
  }

  public Complex(int n) {
    //create outer face (a regular n-gon)
    Vertex center = new Vertex(0, 0, 0, 1000, this);
    float step = 2*PI/n;
    //place the verticies on the outer face

    for (int i = 0; i < n; i++) {
      Vertex bv = new Vertex(-100, -100, 0, 800, this);
      bv.internal = false;
      placeVertex(bv, i*step, center);
      outerVerts.add(bv);
    }

    for (int i =1; i < n+1; i++) {
      outerVerts.get(i%n).attach(outerVerts.get(i-1));
    }
  }

  void placeVertex(Vertex targ, float theta, Vertex ref) {
    targ.x = (ref.r + targ.r)*cos(theta) + ref.x;
    targ.y = (ref.r + targ.r)*sin(theta) + ref.y;
    //targ.placed = true;
  }

  void drawComplex() {
   // pushStyle();
    stroke(100, 100, 100, 50);
    for (Edge e : edges) {
      line(e.v1.x, e.v1.y, e.v2.x, e.v2.y);
    }
  //  popStyle();
  }  

  void triangulate(HalfEdge h, Vertex v) {
    int sides = 1;
    HalfEdge temp = h.next;
    while (temp!=h) {
      sides++;
      temp = temp.next;
    }

    for (int i = 0; i < sides; i++) {
      v.attach(h.v);
      h = h.next;
    }
  }

  boolean addVertex(Vertex v) {
    //add a vertex to the complex (delaunay triangulation)
    if (v.r < EPSILON)  
      v.r = 10;

    HalfEdge tri = outerVerts.get(0).h.findFace(v);    //the face this new vertex sits in
    if (tri==null) {
      println("The input vertex does not lie in any face");
      return false;
    } else {
      triangulate(tri, v);

      JStack<Edge> edgesToCheck = new JStack<Edge>();
      HashMap<Edge, Boolean> inStack = new HashMap<Edge, Boolean>();
      for (Edge e : edges) {
        edgesToCheck.push(e);
        inStack.put(e, true);
      } 

      while (!edgesToCheck.isEmpty()) {
        Edge nxt = edgesToCheck.pop();
        inStack.put(nxt, false);//mark as out of the stack

        if (nxt.h1.e==null) {
          continue; //already removed edge
        }
        if (inOrthocircle(nxt.h2.v, nxt.h2.next.v, nxt.h2.prev.v, nxt.h1.prev.v) ||
            inOrthocircle(nxt.h1.v, nxt.h1.next.v, nxt.h1.prev.v, nxt.h2.prev.v)) { //edge is not ld
          if (turn(nxt.h2.prev.v, nxt.h1.next.v, nxt.h1.prev.v)) { //concave case 1
            if (nxt.h1.next.v.neighbors().size()==3) {  //flippable
              nxt.h2.prev.v.attach(nxt.h1.prev.v);
              Edge [] checkEdge = {nxt.h1.next.twin.prev.e, nxt.h1.prev.e, nxt.h2.next.e};
              checkEdges(checkEdge, inStack, edgesToCheck);
              nxt.h1.next.detach();
              nxt.h2.prev.detach();
              nxt.h1.detach();
            }
          } else if (!turn(nxt.h2.prev.v, nxt.h1.v, nxt.h1.prev.v)) { //concave case 2
            if (nxt.h1.v.neighbors().size()==3) { //nxt.h1.v.degree <= 3) //flippable
              nxt.h2.prev.v.attach(nxt.h1.prev.v);

              Edge [] checkEdge = {nxt.h1.prev.twin.next.e, nxt.h1.next.e, nxt.h2.prev.e};
              checkEdges(checkEdge, inStack, edgesToCheck);

              nxt.h1.prev.detach();
              nxt.h2.next.detach();
              nxt.h1.detach();
            }
          } else { //2-2 flip
            Edge [] checkEdge = { nxt.h1.next.e, nxt.h1.prev.e, nxt.h2.next.e, nxt.h2.prev.e};
            checkEdges(checkEdge, inStack, edgesToCheck);

            nxt.h2.prev.v.attach(nxt.h1.prev.v);
            nxt.h1.detach();
          }
        }
      }
      verts.add(v);
      for (int i = 0; i < verts.size(); i++) {
        if (verts.get(i).isIsolated()) {
          verts.remove(i);
          i--;
        }
      }
      return true;
    }
  }

  void checkEdges(Edge[] checkEdge, HashMap<Edge, Boolean> inStack, JStack<Edge> edgesToCheck) { //delaunay Complex helper
    for (Edge e : checkEdge) {
      if (inStack.get(e) == null || !inStack.get(e)) {
        edgesToCheck.push(e);
        inStack.put(e, true);
      }
    }
  }

  void computeIxn() {
    HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(outerVerts.get(0).h);

    while (!q.isEmpty()) {
      HalfEdge he = q.remove();

      if (he == null || visited.containsKey(he)) {
        continue;
      }
      visited.put(he, true);
      //////////////////////////////
      //draw orthocircle of internal triangles
      //calculate the incenter and incircle radius.
      //assuming we're given a packing, it's a dual packing.

      Vertex p1 = new Vertex(he.v.x, he.v.y, 0, 0);
      Vertex p2 = new Vertex(he.next.v.x, he.next.v.y, 0, 0);
      Vertex p3 = new Vertex(he.prev.v.x, he.prev.v.y, 0, 0);
      float p1p2 = p1.add(p2.negate()).magnitude();
      float p1p3 = p1.add(p3.negate()).magnitude();
      float p2p3 = p2.add(p3.negate()).magnitude();
      float perimeter = p1p2 + p1p3 + p2p3;
      he.ocx = (p1.x*p2p3 + p2.x*p1p3 + p3.x*p1p2)/perimeter;
      he.ocy = (p1.y*p2p3 + p2.y*p1p3 + p3.y*p1p2)/perimeter;
      float s = perimeter/2;
      he.ocr = sqrt(s*(s-p1p2)*(s-p1p3)*(s-p2p3))/s;

      //update radii
      float x1 = he.ocx, y1 = he.ocy;
      float x2 = he.twin.ocx, y2 = he.twin.ocy;

      float x3 = he.v.x, y3 = he.v.y;
      float x4 = he.next.v.x, y4 = he.next.v.y;

      float m1 = (y1-y2)/(x1-x2);
      float m2 = (y3-y4)/(x3-x4);
      float b1 = y1-m1*x1;
      float b2 = y3-m2*x3;

      float ix = (b2 - b1)/(m1 - m2);
      float iy = (b2*m1 - b1*m2)/(m1 - m2);

      he.ixn = new Vertex(ix, iy, 0, 0);
      he.ixnp = stereoProj(he.ixn);
      he.twin.ixnp = he.ixnp;

      q.add(he.next);
      q.add(he.twin);
    }
  }
  void down() {
    HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(outerVerts.get(0).h);

    while (!q.isEmpty()) {
      HalfEdge he = q.remove();
      if (visited.containsKey(he))  continue;
      visited.put(he, true);

      he.ixn = stereoProjI(he.ixnp);
      q.add(he.next);
      q.add(he.twin);
    }
  }
  void fancyDraw(boolean d3) {//this should not be here...
     //d3: draw polyhedra
    HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(outerVerts.get(0).h);

    while (!q.isEmpty()) {
      HalfEdge he = q.remove();

      if (he == null || visited.containsKey(he)) {
        continue;
      }
      visited.put(he, true);

      if (d3) {
        Vertex a2 = new Vertex(he.ixnp.x, he.ixnp.y, he.ixnp.z, 0), 
          b2 = new Vertex(he.next.ixnp.x, he.next.ixnp.y, he.next.ixnp.z, 0), 
          c2 = new Vertex(he.next.next.ixnp.x, he.next.next.ixnp.y, he.next.next.ixnp.z, 0);

     //   pushStyle();
        strokeWeight(2);
        stroke(0);
        drawCircumcircle3D(a2, b2, c2);
      //  popStyle();
      } else {
    //    pushStyle();
        strokeWeight(2);
        stroke(0);
        drawCircumcircle2D(he.ixn, he.next.ixn, he.next.twin.next.ixn);
     //   popStyle();
      }

      q.add(he.next);
      q.add(he.twin);
    }
  }
}
class EnrichedEmbedding {
  Complex G;

  public EnrichedEmbedding(int n) {
    G = new Complex(n);
  }

  void drawCircumcircles() {
    HashMap<HalfEdge, Boolean> ae = new HashMap<HalfEdge, Boolean>();

    for (Edge e : G.edges) {
      HalfEdge tc[] = {e.h1, e.h2};
      for (HalfEdge he : tc) {
        if (ae.containsKey(he) || ae.containsKey(he.next) || ae.containsKey(he.prev)) {
          continue;
        }
        Vertex v1 = he.v, v2 = he.next.v, v3 = he.prev.v;

        if (!v1.internal && !v2.internal && !v3.internal) {
          continue;
        }
        float v1v2 = v1.add(v2.negate()).magnitude();
        float v1v3 = v1.add(v3.negate()).magnitude();
        float v2v3 = v2.add(v3.negate()).magnitude();
        float perimeter = v1v2 + v1v3 + v2v3;

        float ocx = (v1.x*v2v3 + v2.x*v1v3 + v3.x*v1v2)/perimeter;
        float ocy = (v1.y*v2v3 + v2.y*v1v3 + v3.y*v1v2)/perimeter;

        float s = perimeter/2;

        float ocr = sqrt(s*(s-v1v2)*(s-v1v3)*(s-v2v3))/s;

      //  pushStyle();
        noStroke();
        fill(0, 0, 0, 60);
        ellipse(ocx, ocy, 2*ocr, 2*ocr);
      //  popStyle();

        ae.put(he, true);
      }
    }
  }
  void drawOrthocircles() {
    HashMap<HalfEdge, Boolean> ae = new HashMap<HalfEdge, Boolean>();
    G.dual = new Complex();

    for (Edge e : G.edges) {
      HalfEdge tc[] = {e.h1, e.h2};
      Vertex dualTwins[] = new Vertex[2];

      for (int i= 0; i < 2; i++) {
        HalfEdge he = tc[i];
        if (ae.containsKey(he) || ae.containsKey(he.next) || ae.containsKey(he.prev)) {
          continue;
        }
        Vertex v1 = he.v, v2 = he.next.v, v3 = he.prev.v;

        if (!v1.internal && !v2.internal && !v3.internal) {
          continue;
        }
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

      //  pushStyle();
        //noStroke();
        //fill(0,100, 0);
        noFill();
        stroke  (255, 160, 122);
        strokeWeight(2);
        ellipse(cx, cy, 2*r, 2*r);
      //  popStyle();

        dualTwins[i] = new Vertex(cx, cy, 0, r);
      }
      //fix this up so it just calculates the whole dual
    //  pushStyle();
      stroke  (100, 100, 100);

      if (dualTwins[1]!=null) {
        line(dualTwins[0].x, dualTwins[0].y, dualTwins[1].x, dualTwins[1].y);
      }
    //  popStyle();
    }
  }
  /////////////////
  //Drawing methods
  /////////////////
  void drawPSLG() {
    G.drawComplex();
  }
  void drawDualPSLG() {
    G.dual.drawComplex();
  }
  void drawRadii() {
    for (Vertex v : G.verts) {
      v.drawVertex();
    }
    for (Vertex v : G.outerVerts) {
      v.drawVertex();
    }
  }
  void drawDualRadii() {
    for (Vertex v : G.dual.verts) {
      v.drawVertex();
    }
    for (Vertex v : G.dual.outerVerts) {
      v.drawVertex();
    }
  }
  void drawKoebe() {
  }
  //////////////////////
  //Data transformations
  //////////////////////
  void cDual_primal() {
    //construct new dual embedding
  }
  void cPrimal_dual() {
    //construct new primal embedding
  }

  void cEmbedding_stress() {
    for (int i =0; i < 100; i++) {
      for (Edge e : G.edges) {
        double vx = (e.v1.x - e.v2.x)*e.stress/100000;
        double vy = (e.v1.y - e.v2.y)*e.stress/100000;

        if (e.v2.internal) {
          e.v2.x+=vx;
          e.v2.y+=vy;
        }

        if (e.v1.internal) {
          e.v1.x-=vx;
          e.v1.y-=vy;
        }
      }
      for (Edge e : G.edges) {
        float target = sqrt((((e.v1.x-e.v2.x)*(e.v1.x-e.v2.x) + (e.v1.y-e.v2.y)*(e.v1.y-e.v2.y))));

        if (e.v1.r + e.v2.r < target) {
          //increase the stress on this edge
          e.stress += KCORRECTION;
          e.h1.v.r += KCORRECTION*10; 
          e.h2.v.r += KCORRECTION*10;
        } else {
          if (e.stress > 0) {
            //decrease stress
            e.stress -= KCORRECTION;
          }
          e.h1.v.r -= KCORRECTION*10; 
          e.h2.v.r -= KCORRECTION*10;
        }
      }
    }
  }

  void cStress_embedding() {
    //maxwell
    for (Edge e : G.edges) {
      Vertex grad1 = grad(e.h1);
      Vertex grad2 = grad(e.h2);

      e.stress = grad1.add(grad2.negate()).magnitude()/distv(e.h1.v, e.h2.v);

      if (e.h1.v.internal || e.h2.v.internal) {
        println(e.stress);
      }
    }
    println();
    println();
  }

  void cStress_radii() {
    //calculate stress from dual+primal radii, assuming packing
    for (Edge e : G.edges) {
      e.stress = (e.dual.v1.r + e.dual.v2.r) / (e.v1.r + e.v2.r);
    }
  }

  void cEmbedding_radii() {
    if (G.verts.size()==0) {
      return;
    }
    //layout algorithm, gives correct embedding given good radii
    G.verts.get(0).x = 0;
    G.verts.get(0).y = 0;
    HashMap placed = new HashMap();
    HashMap processed = new HashMap();

    placed.put(G.verts.get(0), true);

    placed.put(G.verts.get(0), true);

    JQueue<Vertex> q = new JQueue<Vertex>();
    q.add(G.verts.get(0));

    while (!q.isEmpty()) {
      Vertex iv = q.remove();
      ArrayList<Vertex> adjacent = iv.neighbors();//ordered neighbors

      int i, j;
      for (i = 0; i < adjacent.size() && !placed.containsKey(adjacent.get(i)); i++) {}
      //find a placed petal, if there is one
      float lastAngle = 0;

      if (i==adjacent.size() && !placed.containsKey(adjacent.get(i-1))) {
        //initialization
        i--; 
        lastAngle = atan2((float)(adjacent.get(i).y-iv.y), (float)(adjacent.get(i).x-iv.x));
        G.placeVertex(adjacent.get(i), lastAngle, iv);
        placed.put(adjacent.get(i), true);

        if (adjacent.get(i).internal) {  
          q.add(adjacent.get(i));
        }
      }

      j = i;

      while (++j % adjacent.size() != i) {
        Vertex v = adjacent.get(j % adjacent.size());
        if (!placed.containsKey(v)) {
          Vertex lastKnown = adjacent.get((j-1)%adjacent.size());
          lastAngle = atan2((float)(lastKnown.y-iv.y), (float)(lastKnown.x-iv.x));

          float x = iv.r;
          float y = lastKnown.r;
          float z = v.r;

          float theta = (float)Math.acos(((x+y)*(x+y) + (x+z)*(x+z) - (y+z)*(y+z))/(2*(x+y)*(x+z)));
          G.placeVertex(v, lastAngle-theta, iv);
          placed.put(v, true);
        }
        if (!processed.containsKey(v) && v.internal) {
          q.add(v);
        }
      }
      processed.put(iv, true);
    }
  }

  void cDualRadii_embedding() { 
    //Calculate dual radii as incircles of faces of embedding
    for (Vertex v : G.dual.verts) {}
  }
  void cDualRadii_radii() {
    //Calculate dual radii as orthocircles of radii in embedding.
  }
  void cRadii_dualRadii() {
  }


  //Auxillary methods
  boolean isPacking()
  {
    float error = 0;
    for (Vertex v : G.verts)
      error += abs(v.angleSum() - 2*PI);

    error/=G.verts.size();
    if (error > 0.05)
      return false;
    return true;
  }
  void addVertex(float x, float y, float r)
  {
    G.addVertex(new Vertex(x, y, 0, r, G));
  }
}
//HalfEdge data structure, and a stack and queue implementation.
//Also there are some methods to use on the HalfEdge data structure.
class HalfEdge {
  HalfEdge prev;
  HalfEdge next;
  HalfEdge twin;
  Edge e;
  Vertex v;
  Vertex ixn, ixnp;

  float ocx=-INF, ocy=-INF, ocr = 1;//orthocenter of this face

  public HalfEdge(Vertex _v) {
    v = _v;
  }

  void connectTo(HalfEdge h) {
    next = h;
    h.prev = this;
  }

  void detach() {
    // Disconnect both a halfedge and its twin.
    if (v.isLeaf())
      v.h = null;
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
    this.e = null;
    twin.e = null;

    for (int i = 0; i < v.parent.edges.size(); i++) {
      if (v.parent.edges.get(i).h1 == this || v.parent.edges.get(i).h1 == twin) {
        v.parent.edges.remove(i);
        i--;
      }
    }
  }

  HalfEdge findFace(Vertex d) { 
    //find the face containing this vertex
    HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(this);
    while (!q.isEmpty()) {
      HalfEdge he = q.remove();
      if (visited.containsKey(he))  continue;
      if (inFace(he, d)) {
        return he;
      }
      visited.put(he, true);
      q.add(he.next);
      q.add(he.twin);
    }
    return null;
  }
}

class JStack<T> {
  ArrayList<T> container = new ArrayList<T>();
  void push(T e) {
    container.add(e);
  }
  T pop() {
    return container.remove(container.size()-1);
  }
  boolean isEmpty() {
    return(container.size()==0);
  }
}

class JQueue<T> {
  ArrayList<T> container = new ArrayList<T>();
  void add(T e) {
    container.add(e);
  }
  T remove() {
    return container.remove(0);
  }
  boolean isEmpty() {
    return(container.size()==0);
  }
}

class Edge {
  HalfEdge h1, h2;
  Vertex v1, v2;
  float stress = 1;
  Edge dual;
  public Edge(HalfEdge _h1, HalfEdge _h2) {  
    h1 = _h1; 
    h2 = _h2;
    v1 = h1.v;
    v2 = h2.v;
  }
}
boolean turn(Vertex p, Vertex q, Vertex r) {
  //returns true if no turn/right turn is formed by p q r
  return((q.x - p.x)*(r.y - p.y) - (r.x - p.x)*(q.y - p.y)>=0);
}

boolean inFace(HalfEdge h, Vertex d) {
  //is d in the face defined by h?
  HalfEdge start = h;
  HalfEdge temp = h.next;
  boolean first = true;
  while (first || h!=start) {
    first = false;
    if (turn(h.v, temp.v, d)) {
      return false;
    }
    h = h.next;
    temp = temp.next;
  }
  return true;
}

boolean inOrthocircle(Vertex a, Vertex b, Vertex c, Vertex d) {
  //is d in the circumcircle of a,b,c?
  //a,b,c should be in ccw order from following the half edges. 
  float adx = a.x - d.x;
  float ady = a.y - d.y;
  float bdx = b.x - d.x;
  float bdy = b.y - d.y;
  float cdx = c.x - d.x;
  float cdy = c.y - d.y;

  float abdet = adx * bdy - bdx * ady;
  float bcdet = bdx * cdy - cdx * bdy;
  float cadet = cdx * ady - adx * cdy;
  float alift = adx * adx + ady * ady - d.r*d.r - a.r*a.r;
  float blift = bdx * bdx + bdy * bdy - d.r*d.r - b.r*b.r;
  float clift = cdx * cdx + cdy * cdy - d.r*d.r - c.r*c.r;
  return alift * bcdet + blift * cadet + clift * abdet < 0;
}

void drawCircumcircle2D(Vertex a, Vertex b, Vertex c) {
  float mr = (b.y-a.y) / (b.x-a.x);
  float mt = (c.y-b.y) / (c.x-b.x);
  float x = (mr*mt*(c.y-a.y) + mr*(b.x+c.x) - mt*(a.x+b.x)) / (2*(mr-mt));
  float y = (a.y+b.y)/2 - (x - (a.x+b.x)/2) / mr;
  float r = sqrt(((b.x-x)*(b.x-x) +  (b.y-y)*(b.y-y)));
  ellipse(x, y, 2*r, 2*r);
}

void drawCircumcircle3D(Vertex a, Vertex b, Vertex c) { 
  Vertex ct = c;
  a = a.add(c.negate());
  b = b.add(c.negate());
  c = new Vertex(0, 0, 0, 0);
  //b.drw();

  float rx, ry, rz;
  ry = atan2(a.z, a.x);
  //rotate a so it's z is 0:
  a.rotate('y', ry);
  b.rotate('y', ry);
  //now need to rotate so a's y is 0:
  rz = -atan2(a.y, a.x);
  a.rotate('z', rz);
  b.rotate('z', rz);
  //now rotate so b's z is 0:
  rx = PI/2 - atan2(b.y, -b.z);
  a.rotate('x', rx);
  b.rotate('x', rx);

  pushMatrix();

  translate(ct.x, ct.y, ct.z);
  rotateY(-ry);
  rotateZ(-rz);
  rotateX(-rx);
  drawCircumcircle2D(a, b, c);

  popMatrix();
}

Vertex stereoProj(Vertex init) {
  float x = init.x/orthoSphereR, y = init.y/orthoSphereR;
  float denom = (x*x + y*y +1);
  return new Vertex(orthoSphereR*2*x/denom, orthoSphereR*2*y/denom, orthoSphereR*(x*x + y*y -1)/denom, 0);
}

Vertex stereoProjI(Vertex init) {
  return new Vertex(init.x*orthoSphereR/(orthoSphereR-init.z), init.y*orthoSphereR/(orthoSphereR-init.z), 0, 0);
}

Vertex grad(HalfEdge f) {
  f.v.updateZ();
  f.next.v.updateZ();
  f.next.next.v.updateZ();

  Vertex p = f.v, q = f.next.v, r = f.next.next.v;

  Vertex pq = q.add(p.negate());
  Vertex pr = r.add(p.negate());
  Vertex ansT = pq.cross(pr);
  return pq.cross(pr);
}

float distv(Vertex p, Vertex q) {
  float dx = p.x - q.x;
  float dy = p.y - q.y;
  float dz = p.z - q.z;

  return sqrt(dx*dx + dy*dy + dz*dz);
}
class Vertex {
  color shade = 200;
  float x, y, z, r;
  boolean internal = true, f = false;
  HalfEdge h;
  Complex parent;//Complex this vertex belongs to 

  public Vertex(float _x, float _y, float _z, float _w, Complex _p) {
    x = _x; 
    y = _y; 
    z = _z; 
    r = _w; 
    parent = _p;
  }
  public Vertex(float _x, float _y, float _z, float _w) {
    x = _x; 
    y = _y; 
    z = _z; 
    r = _w;
  }
  public Vertex(float _x, float _y, float _z) {
    x = _x; 
    y = _y; 
    z = _z;
  }
  ///////////////////////////////////////////////////////
  float magnitude() {
    return sqrt(x*x + y*y + z*z);
  }
  void updateZ() {
    z = (x*x + y*y - r*r);
  } 

  void normalize() {
    float c = 1/magnitude();
    x*=c;
    y*=c;
    z *=c;
  }
  Vertex scale(float s) {
    return new Vertex(x*s, y*s, z*s, r);
  }
  Vertex cross(Vertex b) {
    return(new Vertex(y*b.z - z*b.y, z*b.x - x*b.z, x*b.y - y*b.x, r));
  }
  Vertex negate() {
    return new Vertex(-x, -y, -z, r);
  }
  Vertex add(Vertex b) {
    return new Vertex(x+b.x, y+b.y, z+b.z, r);
  }
  float dot(Vertex b) {
    return x*b.x + y*b.y + z*b.z;
  }
  void rotate(char dir, float theta) {
    float cost = cos(theta), sint = sin(theta);
    if (dir=='z') {
      float xi =x;
      x = x*cost-y*sint;
      y = xi*sint+y*cost;
    } else if (dir=='y') {
      float xi= x;
      x = x*cost+z*sint;
      z = -xi*sint+z*cost;
    } else if (dir=='x') {      
      float yi = y;
      y = y*cost-z*sint;
      z = yi*sint+z*cost;
    }
  }
  void drawVertex() {
    //   pushStyle();

   // noStroke();
    fill(176, 196, 222);
    ellipse(x, y, 2*r, 2*r);

    //   popStyle();
  }

  float getZ() {
    return (x*x + y*y - r*r);
  }

  float angleSum() {
    float res = 0;
    ArrayList<Vertex> adjacent = neighbors();

    for (int i = 1; i <= adjacent.size(); i++) {
      float y = adjacent.get(i-1).r;
      float z = adjacent.get(i%adjacent.size()).r;
      res += Math.acos(((r+y)*(r+y) + (r+z)*(r+z) +- (y+z)*(y+z))/(2*(r+y)*(r+z)));
    }
    return res;
  }

  HalfEdge handle(Vertex u) {
    if (isIsolated() || isLeaf()) return h;
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
    boolean I   = ccw(a, b);
    boolean II  = ccw(b, c);
    boolean III = ccw(c, a);
    return ((I && (II || III)) || (II && III)); // at least two must be true
  }

  void attach(Vertex t) {
    //don't connect verticies that are already connected or not in same Complex
    if (t.parent != parent || this.h!=null&&this.h.next!=null && this.h.next.v == t)
      return;

    HalfEdge test = null;

    if (this.h!=null&&this.h.prev!=null)
      test = this.h.prev.twin;

    while (test!=null&&test!=this.h) {
      if (test.next.v==t)  
        return;
      test = test.prev.twin;
    }

    HalfEdge h1 = new HalfEdge(this);
    HalfEdge h2 = new HalfEdge(t);
    h1.twin = h2;
    h2.twin = h1;
    if (this.h == null) {
      h2.connectTo(h1);
      this.h = h1;
    }
    if (t.h == null) {
      h1.connectTo(h2);
      t.h = h2;
    }

    HalfEdge sh = this.handle(t);
    HalfEdge th = t.handle(this);
    sh.prev.connectTo(h1);
    th.prev.connectTo(h2);
    h2.connectTo(sh);
    h1.connectTo(th);

    parent.edges.add(new Edge(h1, h2));
    h1.e = parent.edges.get(parent.edges.size()-1);
    h2.e = parent.edges.get(parent.edges.size()-1);
  }

  ArrayList<Vertex> neighbors() {//returns neighbors in ccw order
    ArrayList<Vertex> adj = new ArrayList<Vertex>();
    adj.add(h.next.v);
    HalfEdge test = h.prev.twin;
    while (test != h) {
      adj.add(test.next.v);
      test = test.prev.twin;
    }
    return adj;
  }

  void print() {
    println(x, y, z);
  }
}

