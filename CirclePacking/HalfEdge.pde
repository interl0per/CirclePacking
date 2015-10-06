//HalfEdge data structure, and a stack and queue implementation.
//Also there are some methods to use on the HalfEdge data structure.
class HalfEdge extends Triangulation
{
 HalfEdge prev;
 HalfEdge next;
 HalfEdge twin;
 Edge e;
  
 Vertex v;
 float ocx=-INF, ocy=-INF;//orthocenter of this face
  
 HalfEdge(Vertex vv) 
 {
   v =vv;
 }
  
 void connectTo(HalfEdge h) 
 {
   next = h;
   h.prev = this;
 }
 // Disconnect both a halfedge and its twin.
 void detach() 
 {
   if (v.isLeaf())  
     v.h = null;
   else 
   {
     prev.connectTo(twin.next);
     v.h = twin.next;
   }
   if (twin.v.isLeaf())  
     twin.v.h = null; 
   else 
   {
     twin.prev.connectTo(next);
     twin.v.h = next;
   }
   this.e = null;
   twin.e = null;
   for(int i = 0; i < edges.size(); i++)
   {
     if(edges.get(i).h1 == this || edges.get(i).h1 == twin)
     {
       edges.remove(i);
       i--;
     }
   }
 }
 
 HalfEdge findHE(Vertex d)//bfs the faces
 {
   HashMap<HalfEdge, Boolean> visited = new HashMap<HalfEdge, Boolean>();
   JQueue<HalfEdge> q = new JQueue<HalfEdge>();
   q.add(this);
   while(!q.isEmpty())
   {
     HalfEdge he = q.remove();
     if(visited.containsKey(he))  continue;
     if(inFace(he,d))
     {
       return he;
     }
     visited.put(he, true);
     q.add(he.next);
     q.add(he.twin);
   }
   println("it seems that the point is not inside any triangle");
   return null;
 }
}

class JStack<T>
{
 ArrayList<T> container = new ArrayList<T>();
 void push(T e)
 {
   container.add(e);
 }
 T pop()
 {
   return container.remove(container.size()-1);
 }
 boolean isEmpty()
 {
   return(container.size()==0);
 }
}

class JQueue<T>
{
 ArrayList<T> container = new ArrayList<T>();
 void add(T e)
 {
   container.add(e);
 }
 T remove()
 {
   return container.remove(0);
 }
 boolean isEmpty()
 {
   return(container.size()==0);
 }
}

class Edge 
{
 HalfEdge h1, h2;
 float spring;
 public Edge(HalfEdge _h1, HalfEdge _h2) 
 {  
   h1 = _h1; 
   h2 = _h2;  
 }
}

class Vertex extends Triangulation
{
   color shade = 200;
   boolean internal = true, processed = false, placed = false, f = false;
   boolean fake = false, fixed = false, almostOuter = false;
   HalfEdge h;
   float x, y, z, weight; // z = f(x,y,weight) //<>//
  
   Vertex(float _x, float _y, float _w) 
   {
     x = _x; 
     y = _y; 
     weight = _w;
     //h = null;
     //Random rand = new Random();
     //z = rand.nextInt(20);
   }

 void draw()
 {
   if(x > 0 && x < width && y > 0 && y < height)
   {
     fill(shade);
   }
   ellipse(x, y,2*weight,2*weight);
 }
  
 float getZ()
 {
   return (x*x+y*y-weight*weight);
 }
  
 HalfEdge handle(Vertex u) 
 {
   if (isIsolated() || isLeaf()) return h;
   HalfEdge h1 = h, h2 = h.prev.twin;
   while (!ordered(h1.twin.v, u, h2.twin.v)) 
   {
     h1 = h2;
     h2 = h1.prev.twin;      
   }
   return h1;
 }
  
 boolean isIsolated() 
 {
   return (h == null);
 }
  
 boolean isLeaf() 
 {
   return (!isIsolated()) && (h.twin == h.prev);
 }
  
 boolean ccw(Vertex a, Vertex b) 
 {
   return ((a.y-y) * (b.x-x) - (a.x-x) * (b.y-y) >= 0);
 }
  
 boolean ordered(Vertex a, Vertex b, Vertex c) 
 {
   boolean I   = ccw(a,b);
   boolean II  = ccw(b,c);
   boolean III = ccw(c,a);
   return ((I && (II || III)) || (II && III)); // at least two must be true
 }
 ArrayList<Vertex> degree()//returns neighbors in ccw order
 {
   ArrayList<Vertex> neighbors = new ArrayList<Vertex>();
   neighbors.add(h.next.v);
   HalfEdge test = h.prev.twin;
   while(test != h)
   {
     neighbors.add(test.next.v);
     test = test.prev.twin;
   }
   return neighbors;
 }
 void detach()//returns neighbors in ccw order
 {
   //if(h == null || h.prev == null)
   //  return;
   HalfEdge test = h;
   ArrayList<Vertex> num = degree();
   //for(int i=0; i< num.size(); i++)
   //{
     h.detach();
     //h = h.prev.twin;
   //}
 }
 void attach(Vertex t) 
 {
   //don't connect verticies that are already connected
   if(this.h!=null&&this.h.next!=null && this.h.next.v == t)
     return;
      
   HalfEdge test = null;
    
   if(this.h!=null&&this.h.prev!=null)
     test = this.h.prev.twin;
      
   while(test!=null&&test!=this.h)
   {
     if(test.next.v==t)  
       return;
     test = test.prev.twin;
   }
  
   HalfEdge h1 = new HalfEdge(this);
   HalfEdge h2 = new HalfEdge(t);
   h1.twin = h2;
   h2.twin = h1;
   if (this.h == null) 
   {
     h2.connectTo(h1);
     this.h = h1;
   }
   if (t.h == null) 
   {
     h1.connectTo(h2);
     t.h = h2;    
   }
  
   HalfEdge sh = this.handle(t);
   HalfEdge th = t.handle(this);
   sh.prev.connectTo(h1);
   th.prev.connectTo(h2);
   h2.connectTo(sh);
   h1.connectTo(th);
  
   edges.add(new Edge(h1, h2));
   h1.e = edges.get(edges.size()-1);
   h2.e = edges.get(edges.size()-1);
 }
 
  float angleSum()
  {
    float res = 0;
    ArrayList<Vertex> adjacent = degree();
    for(int i= 0; i < adjacent.size(); i++)
    {
      if(!adjacent.get(i).internal)
      {
        adjacent.remove(i);
        i--;
      }
    }
    
    int cnt = 0;
    float x = weight;

    for(int i = 1; i <= adjacent.size(); i++)
    {
       float y = adjacent.get(i-1).weight;
       float z = adjacent.get(i%adjacent.size()).weight;
       if(z < 0 || y < 0)
       {
         res += PI - Math.acos(((x+y)*(x+y) + (x+z)*(x+z) - (y+z)*(y+z))/abs(2*(x+y)*(x+z)));
       }
       else
         res += Math.acos(((x+y)*(x+y) + (x+z)*(x+z) +- (y+z)*(y+z))/(2*(x+y)*(x+z)));
       cnt++;
    }
    println(res);
    return res;
  }
}