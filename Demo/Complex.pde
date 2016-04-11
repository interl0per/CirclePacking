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
  void drawDual()
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
      
     noFill();
     stroke(0);
      ellipse(he.ocx, he.ocy, 2*he.ocr, 2*he.ocr);

      q.add(he.next);
      q.add(he.twin);
    }
  }
  void placeVertex(Vertex targ, float theta, Vertex ref) {
    targ.x = (ref.r + targ.r)*cos(theta) + ref.x;
    targ.y = (ref.r + targ.r)*sin(theta) + ref.y;
  }

  void drawComplex() {
    stroke(100, 100, 100, 50);
    for (Edge e : edges) {
      line(e.v1.x, e.v1.y, e.v2.x, e.v2.y);
    }
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
  
  void comp2()
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
  }
  
  void down2()
  {
    for(Vertex v : verts)
    {
      v.a = stereoProjI(v.ap);
      v.b = stereoProjI(v.bp);
      v.c = stereoProjI(v.cp);
    }
  }

  void fancyDraw(boolean d3) {
    strokeWeight(2);
    stroke(0);

    for(Vertex v : verts)
    {
      fill(176, 196, 222);
      if(d3)
      {
        drawCircumcircle3D(v.ap, v.bp, v.cp);
      }
      else
      {
        if(verts.size() > 2 && ccInside(verts.get(0), v) && ccInside(verts.get(1), v))
        {
          fill(176, 196, 222, 90);
        }
        drawCircumcircle2D(v.a, v.b, v.c);
      }
    }
  }
}