//

class Complex
{
    public ArrayList<Vertex> verts = new ArrayList<Vertex>();//internal verticies
    public ArrayList<Vertex> outerVerts = new ArrayList<Vertex>();
    public ArrayList<Edge> edges = new ArrayList<Edge>();
    
    Complex dual;
    
    public Complex(){}
    
    public Complex(int n)
    {
     //create outer face (a regular n-gon)
     Vertex center = new Vertex(width/2, height/2, 0, 700, this);
     float step = 2*PI/n;
     //place the verticies on the outer face
      
     for(int i = 0; i < n; i++)
     {
       Vertex bv = new Vertex(-100,-100, 0, 700, this);
       bv.internal = false;
       placeVertex(bv, i*step, center);
       outerVerts.add(bv);
     }

     for(int i =1; i < n+1; i++)
       outerVerts.get(i%n).attach(outerVerts.get(i-1)); 
     
    }
    
    void placeVertex(Vertex targ, float theta,  Vertex ref)
    {
     targ.x = (ref.r + targ.r)*cos(theta) + ref.x;
     targ.y = (ref.r + targ.r)*sin(theta) + ref.y;
     targ.placed = true;
    }
    
    void draw()
    {
      pushStyle();
      stroke(100,100,100);
      for(Edge e : edges)
      {
          line(e.v1.x, e.v1.y, e.v2.x, e.v2.y);
      }
      popStyle();
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
      //add a vertex to the complex (delaunay triangulation)
     if(v.r < EPSILON)  
       v.r = 10;
       
     verts.add(v);
     
     HalfEdge tri = outerVerts.get(0).h.findFace(v);    //the face this new vertex sits in
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
    
         if(nxt.h1.e==null)  continue; //already removed edge
         
         if(inOrthocircle(nxt.h2.v, nxt.h2.next.v, nxt.h2.prev.v, nxt.h1.prev.v) || inOrthocircle(nxt.h1.v, nxt.h1.next.v, nxt.h1.prev.v, nxt.h2.prev.v))
         {//edge is not ld
           if(turn(nxt.h2.prev.v, nxt.h1.next.v, nxt.h1.prev.v))
           {//concave case 1
             if(nxt.h1.next.v.neighbors().size()==3)
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
             if(nxt.h1.v.neighbors().size()==3)//nxt.h1.v.degree <= 3)//flippable
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
 {//delaunay Complex helper
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