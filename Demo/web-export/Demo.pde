final int NUM_OUTER_VERTS = 3;
final int INF = 1<<30;
final float orthoSphereR = 200.0;

float sx, sy, dyc, dxc;
boolean drawing, rotating, drawKoebe, showHelp = true, first = true;
int mode;

EnrichedEmbedding curr, temp; 

void setup() 
{
  size(1433, 900, P3D);
  background(255);
  
  curr = new EnrichedEmbedding(NUM_OUTER_VERTS);
  temp = new EnrichedEmbedding(NUM_OUTER_VERTS);
  
  drawing = false;
  rotating = false;
  drawKoebe = false;
  mode = 0;
  dyc = dxc = 0;
  
  textFont(createFont("Arial",15));
}

void draw() 
{
  background(255);
  translate(width/2, height/2, 0);  
  noStroke();

  if (!rotating) 
  {
    if(mode==1)
    {
      curr.G.drawDual();
    }
    else
    {
      curr.G.sctr();
      curr.drawPSLG();
      curr.drawRadii();
    }
  }

  if (keyPressed) 
  {
    if (keyCode==LEFT) 
    {
      radii_update(curr);
    } 
    else if (keyCode==RIGHT) 
    {
      stress_update(curr);
    }
    //else if(key == 'j')
    //      curr.fancyDraw(drawKoebe);

    //else if(key == 'k')
    //{
    //  curr.G.dual = new Complex(curr.G);
    //  curr.cStress_radii();
    //}
    if(keyCode == RIGHT || keyCode == LEFT)
    {
       curr.G.updateStereo();
       for(Vertex v : curr.G.verts)
       {
        v.ap.rotate('x', dxc);
        v.ap.rotate('y', dyc);
        v.bp.rotate('x', dxc);
        v.bp.rotate('y', dyc);
        v.cp.rotate('x', dxc);
        v.cp.rotate('y', dyc);
       }
       for(Vertex v : curr.G.outerVerts)
       {
        v.ap.rotate('x', dxc);
        v.ap.rotate('y', dyc);
        v.bp.rotate('x', dxc);
        v.bp.rotate('y', dyc);
        v.cp.rotate('x', dxc);
        v.cp.rotate('y', dyc);
       }
    }
  }

  if (drawing) 
  {
    float dx = mouseX - sx, dy = mouseY - sy, r = sqrt(dx*dx + dy*dy);
    fill(176, 196, 250);
    ellipse(sx-width/2, sy-height/2, 2*r, 2*r);
  }

  if (rotating)
  {
    float dyt = (sx - mouseX)/70, dxt = -(sy - mouseY)/70;
    if(first)
    {//necessary to fix some very, very strange bug with processing that leads to circumcircles not being drawn
      dyt += 0.001;
      dxt += 0.001;
    }
    dyc += dyt;
    dxc += dxt;

    for(Vertex vv : curr.G.verts)
    {
    vv.ap.rotate('x', dxt);
    vv.ap.rotate('y', dyt);
    vv.bp.rotate('x', dxt);
    vv.bp.rotate('y', dyt);
    vv.cp.rotate('x', dxt);
    vv.cp.rotate('y', dyt);
    }
    for(Vertex vv : curr.G.outerVerts)
    {
    vv.ap.rotate('x', dxt);
    vv.ap.rotate('y', dyt);
    vv.bp.rotate('x', dxt);
    vv.bp.rotate('y', dyt);
    vv.cp.rotate('x', dxt);
    vv.cp.rotate('y', dyt);
    }
    
    curr.fancyDraw(drawKoebe);

    sx = mouseX; 
    sy = mouseY;
    first = false;
  }
  
  String status = "";
  fill(0);

  switch(mode)
  {
    case 0:  status = "Primal graph (editable)"; 
             break;

    case 1:  status = "Dual graph (editable)";  
             break;

    case 2:  status = "Mobius transformations (view only)";  
             break;

    case 3:  status = "Koebe polyhedron (view only)";
             break;
             
    default: status = "error";
             break;
  }
  
  text("Mode: " + status, -width/2, -height/2 + 20);

  if(showHelp)
  {
   stroke(100);
   fill(230,200,200);
   translate(0,0,250);
   rect(-200,-200, 500, 300);

   fill(0);
   text("Instructions", -200, -210);
   text(" -Add weighted points to the triangulation by clicking \n and dragging left mouse. \n "+
       " -Press left arrow to run the radii-update algorithm, or \n right arrow to run the spring algorithm. \n "
       + " -Press space to change modes. \n "
       + " -Press , to save the current embedding, and . to load \n a saved embedding. \n "
       + " -To restart, press c. \n" 
       + "-Press h to toggle this menu.", -180, -170);
   translate(0,0,-250);
  }
  fill(230);
}

void mousePressed() 
{
  if (mouseButton == LEFT && !rotating) 
  {
    sx = mouseX; 
    sy = mouseY;
    drawing = true;
  }
}

void mouseReleased() 
{
  if (mouseButton == LEFT && !rotating) 
  {
    float dx = mouseX - sx, dy = mouseY - sy;
    curr.addVertex(sx-width/2, sy-height/2, sqrt(dx*dx + dy*dy));
    drawing = false;
  } 
}

void keyPressed() 
{
  if(key == 'h')
  {
    showHelp = !showHelp;
  }
  else if (key == 'c') 
  {
    setup();
  }
  else if(key ==  ',' && mode <= 1)
  {
    temp = new EnrichedEmbedding(curr);
  }
  else if(key == '.' && mode <= 1)
  {
    curr = new EnrichedEmbedding(temp);
  }
  
  else if(key == ' ')
  {
    mode = (mode+1)%4;
    if(mode == 2)
    {
      sx = mouseX; 
      sy = mouseY;
      curr.G.updateStereo();
      rotating = true;
      first = true;
    }
    else if(mode==3)
    {
      sx = mouseX; 
      sy = mouseY;
      curr.G.updateStereo();
      rotating = true;
      drawKoebe = true;
    }
    else
    {
      rotating = false;
      drawKoebe = false;
    }
  }
}
final float KCORRECTION = 0.005;
final float RCORRECTION = 0.005;

void stress_update(EnrichedEmbedding ebd) 
{
  ebd.cEmbedding_stress();
}

void radii_update(EnrichedEmbedding t) 
{
  for (int i =0; i <  100; i++) 
  {
    for (Vertex v : t.G.verts) 
    {
      if (v.angleSum() > 2*PI) 
      {
        v.r += RCORRECTION;
      }
      else 
      {
        v.r -= RCORRECTION;
      }
    }
    t.cEmbedding_radii();
  }
}

void test(EnrichedEmbedding t)
{
  for(int i= 0; i < 100; i++)
  {
    t.cEmbedding_stress_f();
  }
  curr.cStress_radii();
}
class Complex
{
  public ArrayList<Vertex> verts = new ArrayList<Vertex>();//internal verticies
  public ArrayList<Vertex> outerVerts = new ArrayList<Vertex>();
  public ArrayList<Edge> edges = new ArrayList<Edge>();

  Complex dual;

  public Complex(Complex d) {
    dual = d;
    
    HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(dual.outerVerts.get(0).h);

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

      fill(176, 196, 222);
      stroke(0);
      
      //verts.add(new Vertex(he.ocx, he.ocy, he.ocr));
      q.add(he.next);
      q.add(he.twin);
    }
    
    for(Edge e : d.edges)
    {
      e.dual = new Edge();
      e.dual.v1 = new Vertex(e.h1.ocx, e.h1.ocy, 0, e.h1.ocr);
      e.dual.v2 = new Vertex(e.h2.ocx, e.h2.ocy, 0, e.h2.ocr);
    }
  }
  
  public Complex(int n) 
  {
    //create outer face (a regular n-gon)
    Vertex center = new Vertex(0, 0, 0, 1000, this);
    center.special = true;
    float step = 2*PI/n;
    //place the verticies on the outer face

    for (int i = 0; i < n; i++) 
    {
      Vertex bv = new Vertex(-100, -100, 0, 800, this);
      bv.internal = false;
      placeVertex(bv, i*step, center);
      outerVerts.add(bv);
    }

    for (int i =1; i < n+1; i++) 
    {
      outerVerts.get(i%n).attach(outerVerts.get(i-1));
    }
    
    dual = new Complex(this);
  }
  
  void sctr()
  {//center complex in window
    float minx = 99999, miny = 999999;
    int itx = 0, ity = 0;
    for(int i =0;i < outerVerts.size(); i++)
    {
      if(outerVerts.get(i).x < minx)
      {
        minx = outerVerts.get(i).x;
        itx = i;
      }
      if(outerVerts.get(i).y < miny)
      {
        miny = outerVerts.get(i).y;
        ity = i;
      }
    }

    float diffx = -width/2 -outerVerts.get(itx).r/4 - outerVerts.get(itx).x;
    float diffy = -height/2 - outerVerts.get(ity).y;
    
    for(Vertex v : outerVerts)
    {
     v.x += diffx;
    //v.y += diffy;
    }
    for(Vertex v : verts)
    {
     v.x += diffx;  
     //v.y += diffy;
    }
  }
  
  void drawDual()//this should be obsolete soon!
  {
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

      fill(176, 196, 222);
      stroke(0);
      
      if(he.v.internal || he.next.v.internal || he.prev.v.internal)
        ellipse(he.ocx, he.ocy, 2*he.ocr, 2*he.ocr);

      q.add(he.next);
      q.add(he.twin);
      
      
    }
    for(Edge e : edges)
    {
      if(e.v1.internal || e.v2.internal)
        line(e.h1.ocx, e.h1.ocy, e.h2.ocx, e.h2.ocy);
    }
  }
  void placeVertex(Vertex targ, float theta, Vertex ref) 
  {
    targ.x = (ref.r + targ.r)*cos(theta) + ref.x;
    targ.y = (ref.r + targ.r)*sin(theta) + ref.y;
  }

  void drawComplex() 
  {
    stroke(50);
    strokeWeight(1.5);
    for (Edge e : edges) 
    {
      line(e.v1.x, e.v1.y, e.v2.x, e.v2.y);
    }
  }  

  void triangulate(HalfEdge h, Vertex v) 
  {
    int sides = 1;
    HalfEdge temp = h.next;
    while (temp!=h) 
    {
      sides++;
      temp = temp.next;
    }

    for (int i = 0; i < sides; i++) 
    {
      v.attach(h.v);
      h = h.next;
    }
  }

  boolean addVertex(Vertex v) 
  {
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
      for (int i = 0; i < verts.size(); i++) 
      {
        if (verts.get(i).isIsolated()) 
        {
          verts.remove(i);
          i--;
        }
      }
      return true;
    }
  }

  void checkEdges(Edge[] checkEdge, HashMap<Edge, Boolean> inStack, JStack<Edge> edgesToCheck) 
  { //delaunay Complex helper
    for (Edge e : checkEdge) 
    {
      if (inStack.get(e) == null || !inStack.get(e)) 
      {
        edgesToCheck.push(e);
        inStack.put(e, true);
      }
    }
  }
  
  void updateStereo()
  {
    for(Vertex v : verts)
    {
     v.a = new Vertex(v.x + v.r, v.y, 0); 
     v.b = new Vertex(v.x - v.r, v.y, 0); 
     v.c = new Vertex(v.x, v.y + v.r, 0);
     v.ap = stereoProj(v.a);
     v.bp = stereoProj(v.b);
     v.cp = stereoProj(v.c);
    }
    for(Vertex v : outerVerts)
    {
     v.a = new Vertex(v.x + v.r, v.y, 0);
     v.b = new Vertex(v.x - v.r, v.y, 0);
     v.c = new Vertex(v.x, v.y + v.r, 0);
     v.ap = stereoProj(v.a);
     v.bp = stereoProj(v.b);
     v.cp = stereoProj(v.c);
    }
  }
  
  void upateFromStereo()
  {
    for(Vertex v : verts)
    {
      v.a = stereoProjI(v.ap);
      v.b = stereoProjI(v.bp);
      v.c = stereoProjI(v.cp);
  //    println(v.a.x, v.a.y, v.b.x, v.b.y, v.c.x, v.c.y);
    }
    for(Vertex v : outerVerts)
    {
      v.a = stereoProjI(v.ap);
      v.b = stereoProjI(v.bp);
      v.c = stereoProjI(v.cp);
    }
  }
}
class EnrichedEmbedding {
  Complex G;

  public EnrichedEmbedding(int n) {
    G = new Complex(n);
  }
  public EnrichedEmbedding(EnrichedEmbedding s)
  {
    G = new Complex(3);
    for(Vertex v : s.G.verts)
    {
      addVertex(v.x, v.y, v.r);
    }
    
    for(int i= 0; i < 3; i++)
    {
      G.outerVerts.get(i).x = s.G.outerVerts.get(i).x;
      G.outerVerts.get(i).y = s.G.outerVerts.get(i).y;
      G.outerVerts.get(i).r = s.G.outerVerts.get(i).r;
    }
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

        noStroke();
        fill(0, 0, 0, 60);
        ellipse(ocx, ocy, 2*ocr, 2*ocr);

        ae.put(he, true);
      }
    }
  }
  void drawOrthocircles() {
    HashMap<HalfEdge, Boolean> ae = new HashMap<HalfEdge, Boolean>();
    //G.dual = new Complex();

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

        noFill();
        stroke  (255, 160, 122);
        strokeWeight(2);
        ellipse(cx, cy, 2*r, 2*r);

        dualTwins[i] = new Vertex(cx, cy, 0, r);
      }
      //fix this up so it just calculates the whole dual
      stroke  (100, 100, 100);

      if (dualTwins[1]!=null) {
        line(dualTwins[0].x, dualTwins[0].y, dualTwins[1].x, dualTwins[1].y);
      }
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

void fancyDraw(boolean koebe)
  {
    strokeWeight(2);
    stroke(0);
    for(Vertex v : G.verts)
    {
      fill(176, 196, 222);
      if(koebe)
      {
        drawCircumcircle3D(v.ap, v.bp, v.cp);
      }
      else
      {
        if(G.verts.size() > 2 && ccInside(G.verts.get(0), v) && ccInside(G.verts.get(1), v))
        {
          fill(176, 196, 222, 90);
        }
        Vertex a = stereoProjI(v.ap), b = stereoProjI(v.bp), c = stereoProjI(v.cp);
        drawCircumcircle3D(a, b, c);
      }
    }
    
    for(Vertex v : G.outerVerts)
    {
      fill(176, 196, 222);
      if(koebe)
      {
        drawCircumcircle3D(v.ap, v.bp, v.cp);
      }
      else
      {
        if(G.verts.size() > 2 && ccInside(G.verts.get(0), v) && ccInside(G.verts.get(1), v))
        {
          fill(176, 196, 222, 90);
        }
        Vertex a = stereoProjI(v.ap), b = stereoProjI(v.bp), c = stereoProjI(v.cp);
        drawCircumcircle3D(a, b, c);
      }
    }
  }
  //////////////////////
  //Data transformations
  //////////////////////
  void cDual_primal() 
  {
    //construct new dual embedding
  }
  void cPrimal_dual() 
  {
    //construct new primal embedding
  }
  void cEmbedding_stress_f() {
      for (int i =0; i < 100; i++) {
        for (Edge e : G.edges) {//use leapfrog integration maybe?
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
      }
  }
  
  void cEmbedding_stress() {
    for (int i =0; i < 100; i++) {
      for (Edge e : G.edges) {//use leapfrog integration maybe?
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

  void cStress_embedding() 
  {
    for (Edge e : G.edges) {
      
    }
  }

  void cStress_radii() {
    G.dual = new Complex(G);
    for (Edge e : G.edges) {
      e.stress = (e.dual.v1.r + e.dual.v2.r) / (e.v1.r + e.v2.r);
      println(e.stress);
    }
  }

  void cEmbedding_radii() {
    if (G.verts.size()==0) {
      return;
    }
    //gives packing given good radii
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

  void cDualRadii_embedding() 
  { 
    //Calculate dual radii as incircles of faces of embedding ....
    for (Vertex v : G.dual.verts) {}
  }
  void cDualRadii_radii() {
    //Calculate dual radii as orthocircles of radii in embedding.
  }
  void cRadii_dualRadii() 
  {
  
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
  public Edge()
  {
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
boolean turn(Vertex p, Vertex q, Vertex r) {
  //returns true if no turn/right turn is formed by p q r
  return((q.x - p.x)*(r.y - p.y) - (r.x - p.x)*(q.y - p.y)>=0);
}

boolean inFace(HalfEdge h, Vertex d) 
{
  //is d in the face defined by h?
  HalfEdge start = h;
  HalfEdge temp = h.next;
  boolean first = true;
  while (first || h!=start) 
  {
    first = false;
    if (turn(h.v, temp.v, d)) 
    {
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

boolean ccInside(Vertex a0, Vertex b0)
{//is 1's circumcircle contained in 2's? 
  Vertex a = a0.a, b = a0.b, c = a0.c;
  
  float mr = (b.y-a.y) / (b.x-a.x);
  float mt = (c.y-b.y) / (c.x-b.x);
  float x = (mr*mt*(c.y-a.y) + mr*(b.x+c.x) - mt*(a.x+b.x)) / (2*(mr-mt));
  float y = (a.y+b.y)/2 - (x - (a.x+b.x)/2) / mr;
  
  a = b0.a;
  b = b0.b;
  c = b0.c;
    
  float mr2 = (b.y-a.y) / (b.x-a.x);
  float mt2 = (c.y-b.y) / (c.x-b.x);
  float x2 = (mr2*mt2*(c.y-a.y) + mr2*(b.x+c.x) - mt2*(a.x+b.x)) / (2*(mr2-mt2));
  float y2 = (a.y+b.y)/2 - (x2 - (a.x+b.x)/2) / mr2;
  float r2 = sqrt(((b.x-x2)*(b.x-x2) +  (b.y-y2)*(b.y-y2)));
  
  if(sqrt((x-x2)*(x-x2) + (y-y2)*(y-y2)) < r2)
    return true;
    
  return false;
}

void drawCircumcircle3D(Vertex a, Vertex b, Vertex c) { 
  Vertex ct = c;
  a = a.add(c.negate());
  b = b.add(c.negate());
  c = new Vertex(0, 0, 0, 0);

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

Vertex stereoProjI(Vertex init) {//inverse
  return new Vertex(init.x*orthoSphereR/(orthoSphereR-init.z), init.y*orthoSphereR/(orthoSphereR-init.z), 0, 0);
}

Vertex grad(HalfEdge f) {
  f.v.updateZ();
  f.next.v.updateZ();
  f.next.next.v.updateZ();

  Vertex p = f.v, q = f.next.v, r = f.next.next.v;

  Vertex pq = q.add(p.negate());
  Vertex pr = r.add(p.negate());
  //Vertex ansT = pq.cross(pr);
  return pq.cross(pr);
}

float distv(Vertex p, Vertex q) 
{
  float dx = p.x - q.x;
  float dy = p.y - q.y;
  float dz = p.z - q.z;
  return sqrt(dx*dx + dy*dy + dz*dz);
}
class Vertex {
  color shade = 200;
  float x, y, z, r;
  boolean internal = true, f = false;
  boolean special = false;
  HalfEdge h;
  Complex parent;//Complex this vertex belongs to 
  Vertex a,b,c;//points on boundary
  Vertex ap, bp, cp;
  
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
    fill(176, 196, 222);
    ellipse(x, y, 2*r, 2*r);
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

