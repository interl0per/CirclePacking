ArrayList<Edge> edges = new ArrayList<Edge>();

class Triangulation
{
  //HalfEdge data structure, and a stack and queue implementation.
  //Also there are some methods to use on the HalfEdge data structure.
    public ArrayList<Vertex> verticies = new ArrayList<Vertex>();//internal verticies
    public ArrayList<Vertex> outerVerts = new ArrayList<Vertex>();

    public Triangulation(){}
    public Triangulation(int n)
    {
     //create outer face (a regular n-gon)
     Vertex center = new Vertex(0, 0, 0, 700);
     float step = 2*PI/n;
     //place the verticies on the outer face
      
     for(int i = 0; i < n; i++)
     {
       Vertex bv = new Vertex(-100,-100, 0, 700);
       bv.internal = false;
       placeVertex(bv, i*step, center);
       outerVerts.add(bv);
     }

     for(int i =1; i < n+1; i++)
       outerVerts.get(i%n).attach(outerVerts.get(i-1)); 
    }
    
    void placeVertex(Vertex targ, float theta,  Vertex ref)
    {
     targ.x = (ref.weight + targ.weight)*cos(theta) + ref.x;
     targ.y = (ref.weight + targ.weight)*sin(theta) + ref.y;
     targ.placed = true;
    }
    
    void rot(char dir, float theta)
    {
     HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
     JQueue<HalfEdge> q = new JQueue<HalfEdge>();
     q.add(outerVerts.get(0).h);

     while(!q.isEmpty())
     {
       HalfEdge he = q.remove();

       if(visited.containsKey(he))  continue;
       he.ixnp.rotate(dir, theta);
       visited.put(he, true);
       q.add(he.next);
       q.add(he.twin);
     }
    }
    
    void draw()
    {
     HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
     JQueue<HalfEdge> q = new JQueue<HalfEdge>();
     q.add(outerVerts.get(0).h);

     while(!q.isEmpty())
     {
       HalfEdge he = q.remove();

       if(visited.containsKey(he))  continue;        
       
       line(he.v.x, he.v.y, he.next.v.x, he.next.v.y);
     }
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
    
    boolean addVertex(Vertex v)
    {
     if(v.weight < EPSILON)  
       v.weight = 2;
     verticies.add(v);
     HalfEdge tri = outerVerts.get(0).h.findHE(v);    //the face this new vertex sits in
     if(tri==null)
       return false;
     else
     {
       triangulate(tri, v);
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
    
         if(nxt.h1.e==null)  continue; //removed edge
         if(inOrthocircle(nxt.h2.v, nxt.h2.next.v, nxt.h2.prev.v, nxt.h1.prev.v) || inOrthocircle(nxt.h1.v, nxt.h1.next.v, nxt.h1.prev.v, nxt.h2.prev.v))
         {//edge is not ld
           if(turn(nxt.h2.prev.v, nxt.h1.next.v, nxt.h1.prev.v))
           {//concave case 1
             if(nxt.h1.next.v.degree().size()==3)
             {//flippable
               nxt.h2.prev.v.attach(nxt.h1.prev.v);
               
               Edge [] checkEdge = {nxt.h1.next.twin.prev.e, nxt.h1.prev.e, nxt.h2.next.e};
               checkEdges(checkEdge, inStack, edgesToCheck);
               
               nxt.h1.next.detach();
               nxt.h2.prev.detach();
               nxt.h1.detach();
             }
           }
           else if(!turn(nxt.h2.prev.v, nxt.h1.v, nxt.h1.prev.v))
           {//concave case 2
             if(nxt.h1.v.degree().size()==3)//nxt.h1.v.degree <= 3)//flippable
             {
               nxt.h2.prev.v.attach(nxt.h1.prev.v);
    
               Edge [] checkEdge = {nxt.h1.prev.twin.next.e, nxt.h1.next.e, nxt.h2.prev.e};
               checkEdges(checkEdge, inStack, edgesToCheck);

               nxt.h1.prev.detach();
               nxt.h2.next.detach();
               nxt.h1.detach();
             }
           }
           else 
           {//2-2 flip
             Edge [] checkEdge = { nxt.h1.next.e, nxt.h1.prev.e, nxt.h2.next.e, nxt.h2.prev.e};
             checkEdges(checkEdge, inStack, edgesToCheck);

             nxt.h2.prev.v.attach(nxt.h1.prev.v);
             nxt.h1.detach();
           }
         }
       }
     return true;  
    }
 }
 
 void checkEdges(Edge[] checkEdge, HashMap<Edge, Boolean> inStack, JStack<Edge> edgesToCheck)
 {//delaunay triangulation helper
    for(Edge e : checkEdge)
    {
       if(inStack.get(e) == null || !inStack.get(e))
       {
         edgesToCheck.push(e);
         inStack.put(e, true);
       }
    }
 }
}