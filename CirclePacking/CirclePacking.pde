
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
   // println(force.x + " " + force.y + " " + (he.v.x-he.next.v.x) + " " + (he.v.y-he.next.v.y));
    float magnitude = sqrt(force.x*force.x + force.y*force.y);
    //hetoe.get(he).spring = force.x/(he.v.x-he.next.v.x);
    float disp = sqrt((he.v.x-he.next.v.x)*(he.v.x-he.next.v.x) + (he.v.y-he.next.v.y)*(he.v.y-he.next.v.y));
    hetoe.get(he).spring = magnitude/disp;
    println(magnitude);
    visited.put(he, true);
    q.add(he.next);
    q.add(he.twin);
  }
  visited.clear();
}

float CORRECTION = 0.001;

void updateStress(Triangulation t)
{
  for(Edge e : edges)
  {
    if(!(e.h1.v.internal && e.h2.v.internal)) continue;
    float target = sqrt((e.h1.v.x-e.h2.v.x)*(e.h1.v.x-e.h2.v.x) + (e.h1.v.y-e.h2.v.y)*(e.h1.v.y-e.h2.v.y));
    if(e.h1.v.weight + e.h2.v.weight < target)
    {      //increase the stress on this edge
     e.spring += CORRECTION;
     e.h1.v.weight += CORRECTION*10; 
     e.h2.v.weight+= CORRECTION*10;
    }
    else
    {
      if(e.spring > 0)
        e.spring -= CORRECTION;//decrease stress
      e.h1.v.weight -= CORRECTION*10; 
      e.h2.v.weight-= CORRECTION*10;
    }
  }
}
void updateStress2(Triangulation t)
{
  for(Edge e : edges)
  {
    float target = sqrt((e.h1.v.x-e.h2.v.x)*(e.h1.v.x-e.h2.v.x) + (e.h1.v.y-e.h2.v.y)*(e.h1.v.y-e.h2.v.y));
    if(e.h1.v.weight + e.h2.v.weight < target)
    {      //increase the stress on this edge
     e.spring += CORRECTION;
    }
    else
    {
      if(e.spring > 0)
        e.spring -= CORRECTION;//decrease stress
    }
  }
}
final float SPRING = 0.01;
void test(Triangulation t)
{
 for(int i =0; i < 100; i++)
 {
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(t.verticies.get(0).h);
    while(!q.isEmpty())
    {
      HalfEdge he = q.remove();
      if(visited.containsKey(he))// || !he.next.v.internal)  
        continue;
        
      float vx = (he.v.x - he.next.v.x)*hetoe.get(he).spring/1000;
      float vy = (he.v.y - he.next.v.y)*hetoe.get(he).spring/1000;
      
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
    visited.clear();
  }
  updateStress2(t);
  HalfEdge he = edges.get(0).h1;
  he.v.weight = he.v.x*he.v.x + he.v.y*he.v.y;
  he.next.v.weight = he.next.v.x*he.next.v.x + he.next.v.y*he.next.v.y;
  he.prev.v.weight = he.prev.v.x*he.prev.v.x + he.prev.v.y*he.prev.v.y;
  for(Vertex v : tri.verticies)
    v.weight = -1;
  JQueue<HalfEdge> q = new JQueue<HalfEdge>();
  q.add(he);
  while(!q.isEmpty())
  {
    HalfEdge he2 = q.remove();
    if(visited.containsKey(he2))// || !he.next.v.internal)  
      continue;
    
    if(he.twin.v.weight<0)
    {
      
    }

    visited.put(he, true);
    q.add(he.next);
    q.add(he.twin);
  }
  visited.clear();
  
}
void simulate(Triangulation t)
{
 for(int i =0; i < 100; i++)
 {
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(t.verticies.get(0).h);
    while(!q.isEmpty())
    {
      HalfEdge he = q.remove();
      if(visited.containsKey(he))// || !he.next.v.internal)  
        continue;
        
      float vx = (he.v.x - he.next.v.x)*hetoe.get(he).spring/10000;
      float vy = (he.v.y - he.next.v.y)*hetoe.get(he).spring/10000;

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
    updateStress(t);
    visited.clear();
  }
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

//stephenson/collin's algorithm
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
