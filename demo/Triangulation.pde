
boolean drawing = false;
float tx = 0, ty=0, tz=0;
  HashMap<HalfEdge, Edge> hetoe = new HashMap<HalfEdge, Edge>();
  ArrayList<Edge> edges = new ArrayList<Edge>();

class Triangulation
{
  Vertex imaginary = new Vertex(1024, 512, 800);
  ArrayList<Vertex> verticies = new ArrayList<Vertex>();//internal verticies
  ArrayList<Vertex> outerVerts = new ArrayList<Vertex>();
  HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();

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
      outerVerts.get(i%n).attach(outerVerts.get(i-1)); 
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
      v.attach(h.v);
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
    HalfEdge face = findHE(v);    //the face this new vertex sits in
    
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
        if(nxt.h2.prev.v.turn(nxt.h1.next.v, nxt.h1.prev.v))
        {//concave case 1
          if(nxt.h1.next.v.degree().size()==3)
          {//flippable
            nxt.h2.prev.v.attach(nxt.h1.prev.v);
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
        else if(!nxt.h2.prev.v.turn(nxt.h1.v, nxt.h1.prev.v))
        {//concave case 2
          if(nxt.h1.v.degree().size()==3)//nxt.h1.v.degree <= 3)//flippable
          {
            nxt.h2.prev.v.attach(nxt.h1.prev.v);

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
          nxt.h2.prev.v.attach(nxt.h1.prev.v);
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
        vv.attach(imaginary);
        vv.shade = color(100, 0, 0);
      }
      else
        vv.shade = 50;
    }
  }
  computeSprings();
  return true;  
  }
  void computeSprings()
  {
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(verticies.get(0).h);
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
  
  void updateStress()
  {
    for(Edge e : edges)
    {
      if(!(e.h1.v.internal && e.h2.v.internal)) 
      {
        e.spring = 200;
        continue;
      }
      float target = sqrt((e.h1.v.x-e.h2.v.x)*(e.h1.v.x-e.h2.v.x) + (e.h1.v.y-e.h2.v.y)*(e.h1.v.y-e.h2.v.y));
  
      if (e.h2.v == imaginary)
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
  
  void simulate()
  {
   for(int i =0; i < 100; i++)
   {
      JQueue<HalfEdge> q = new JQueue<HalfEdge>();
      q.add(verticies.get(0).h);
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
      updateStress();
    }
  }
  HalfEdge findHE(Vertex d)//bfs the faces
  {
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(outerVerts.get(0).h);
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
}


