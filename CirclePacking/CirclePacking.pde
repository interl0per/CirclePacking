public class Packing extends Triangulation
{
  final float SPRING = 0.01;
  final float CORRECTION = 0.01;

  public Packing(int n) 
  {
    super(n);
  }
  
  void computeSprings()
  {
    HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
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
      he.e.spring = magnitude/disp;

      visited.put(he, true);
      q.add(he.next);
      q.add(he.twin);
    }
  }
  
  void updateStress()
  {
    for(Edge e : edges)
    {
      float target = sqrt((e.h1.v.x-e.h2.v.x)*(e.h1.v.x-e.h2.v.x) + (e.h1.v.y-e.h2.v.y)*(e.h1.v.y-e.h2.v.y));
      
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
  void test()
  {
    simulate(); 
  }
  void simulate()
  {
  //  for(Edge e: edges)
  //        e.spring = 0;
   for(int i =0; i < 100; i++)
   {
     HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
      JQueue<HalfEdge> q = new JQueue<HalfEdge>();
      q.add(verticies.get(0).h);
      while(!q.isEmpty())
      {
        HalfEdge he = q.remove();
        if(visited.containsKey(he))// || !he.next.v.internal)  
          continue;
          
        float vx = (he.v.x - he.next.v.x)*he.e.spring/100000;
        float vy = (he.v.y - he.next.v.y)*he.e.spring/100000;

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
      updateStress();
    }
  }
  
  //Thurston's algorithm
  void computePacking()
  {
   for(Vertex v : outerVerts)
     v.placed = false;
   for(int i = 0; i < verticies.size(); i++)
   {
     //verticies.get(i).weight = 20;
     if(verticies.get(i).h==null)
     {
       verticies.remove(verticies.get(i));
       i--;
       continue;
     }
     verticies.get(i).placed = false;
     verticies.get(i).processed = false;
   }
   //compute radii to some threshhold
   float error = 10;
   //for(int ff = 0; ff < 100; ff++)//while(error > 9);
   {
    error = 0;
    for(int j = 0; j <  verticies.size(); j++)
    {
      float csum = verticies.get(j).angleSum();
      error+=abs(csum-2*PI);
      
      if(csum < 2*PI)
        verticies.get(j).weight -= 0.25;///(1+abs(verticies.get(j).weight - 20));
      
      else if(csum > 2*PI)
        verticies.get(j).weight += 0.25;///(1+abs(verticies.get(j).weight - 20));  
    }
     error/= verticies.size();
   }
   //fix an arbitrary internal vertex
   verticies.get(0).placed = true;
  
   JQueue<Vertex> q = new JQueue<Vertex>();
  
   q.add(verticies.get(0));
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
}