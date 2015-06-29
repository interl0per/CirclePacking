
void computeSprings(Triangulation t)
{
  JQueue<HalfEdge> q = new JQueue<HalfEdge>();
  q.add(t.verticies.get(0).h);
  float i = 0.01;
  while(!q.isEmpty())
  {
    HalfEdge he = q.remove();

    if(visited.containsKey(he))  
      continue;
    Point vec1 = new Point(he.v.x - he.next.v.x, he.v.y - he.next.v.y, he.v.z - he.next.v.z);
    //vec1 = normalize(vec1);
    Point vec2 = new Point(he.v.x - he.prev.v.x, he.v.y - he.prev.v.y, he.v.z - he.prev.v.z);
    //vec2 = normalize(vec2);
    Point norm1 = vec1.crossp(vec2);
    norm1.normalize(-1/2);
    
    Point vec3 = new Point (he.twin.v.x - he.twin.next.v.x, he.twin.v.y - he.twin.next.v.y, he.twin.v.z - he.twin.next.v.z);
    Point vec4 = new Point(he.twin.v.x - he.twin.prev.v.x, he.twin.v.y - he.twin.prev.v.y, he.twin.v.z - he.twin.prev.v.z);
    Point norm2 = vec3.crossp(vec4);
    norm2.normalize(-1/2);
    
    Point force = new Point(norm1.x-norm2.x, norm1.y - norm2.y, 0);//crossp(norm1, norm2);
    
    float magnitude = sqrt(force.x*force.x + force.y*force.y);
    hetoe.get(he).spring = magnitude/sqrt((he.v.x-he.next.v.x)*(he.v.x-he.next.v.x) + (he.v.y-he.next.v.y)*(he.v.y-he.next.v.y));
    visited.put(he, true);
    q.add(he.next);
    q.add(he.twin);
  }
  visited.clear();
}

float CORRECTION = 0.00001;

void updateStress(Triangulation t)
{
  for(Edge e : edges)
  {
    if(!(e.h1.v.internal && e.h2.v.internal)) continue;
    float target = sqrt((e.h1.v.x-e.h2.v.x)*(e.h1.v.x-e.h2.v.x) + (e.h1.v.y-e.h2.v.y)*(e.h1.v.y-e.h2.v.y));
    if(e.h1.v.weight + e.h2.v.weight < target)
    {
     e.spring += CORRECTION;
     e.h1.v.weight += CORRECTION*1000; 
     e.h2.v.weight+= CORRECTION*1000;
      //increase the stress on this edge
    }
    else
    {
      e.spring -= CORRECTION;//decrease stress
      e.h1.v.weight -= CORRECTION*1000; 
      e.h2.v.weight-= CORRECTION*1000;
    }
  }
}
final float SPRING = 0.01;
void simulate(Triangulation t)
{
 computeSprings(t);//error accumulates with simulation, have to recompute
 for(int i =0; i < 100; i++)// while(dx/edges.size() > 0.26 + edges.size()/100)
 {
    JQueue<HalfEdge> q = new JQueue<HalfEdge>();
    q.add(t.verticies.get(0).h);
    while(!q.isEmpty())
    {
      HalfEdge he = q.remove();
      if(visited.containsKey(he))// || !he.next.v.internal)  
        continue;
        
      float vx = (he.v.x - he.next.v.x)*hetoe.get(he).spring;
      float vy = (he.v.y - he.next.v.y)*hetoe.get(he).spring;
      float vz = (he.v.getZ() - he.next.v.getZ())*hetoe.get(he).spring;

      if(!he.next.v.internal)
      {
        vx = 0;
        vy = 0;
        vz = 0;
      }

      he.next.v.x += vx;
      he.next.v.y += vy;
      //he.next.v.setPos(vz);
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
