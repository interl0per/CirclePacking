float CORRECTION = 0.05, SPRING = 0.01;

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

