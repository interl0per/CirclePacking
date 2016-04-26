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