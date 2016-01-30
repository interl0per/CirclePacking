//HalfEdge data structure, and a stack and queue implementation.
//Also there are some methods to use on the HalfEdge data structure.
class HalfEdge
{
  HalfEdge prev;
  HalfEdge next;
  HalfEdge twin;
  Edge e;
  Vertex ixn, ixnp; 
  Vertex v;
  float ocx=-INF, ocy=-INF, ocr = 1;//orthocenter of this face
    
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
    if(v.isLeaf())
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
    println("it seems that the Vertex is not inside any triangle");
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