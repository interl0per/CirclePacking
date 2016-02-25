class Vertex
{
 color shade = 200;
 float x, y, z, r;
 boolean internal = true, f = false;
 HalfEdge h;
 Complex parent;//Complex this vertex belongs to 
 
 public Vertex(float _x, float _y, float _z, float _w, Complex _p)
 {
   x = _x; y = _y; z = _z; r = _w; parent = _p;
 }
  public Vertex(float _x, float _y, float _z, float _w)
 {
   x = _x; y = _y; z = _z; r = _w;
 }
 public Vertex(float _x, float _y, float _z)
 {
   x = _x; y = _y; z = _z;
 }
 ///////////////////////////////////////////////////////
 float magnitude()
 {
   return sqrt(x*x + y*y + z*z);
 }
 void updateZ()
 {
   z = (x*x + y*y - r*r);
 } 

 void normalize()
 {
   float c = 1/magnitude();
   x*=c;
   y*=c;
   z *=c;
 }
 Vertex scale(float s)
 {
   return new Vertex(x*s, y*s, z*s, r);
 }
 Vertex cross(Vertex b)
 {
    return(new Vertex(y*b.z - z*b.y, z*b.x - x*b.z, x*b.y - y*b.x, r));
 }
 Vertex negate()
 {
   return new Vertex(-x, -y, -z, r);
 }
 Vertex add(Vertex b)
 {
   return new Vertex(x+b.x, y+b.y, z+b.z, r);
 }
 float dot(Vertex b)
 {
   return x*b.x + y*b.y + z*b.z;
 }
 void rotate(char dir, float theta)
 {
   float cost = cos(theta), sint = sin(theta);
   if(dir=='z')
   {
       float xi =x;
       x = x*cost-y*sint;
       y = xi*sint+y*cost;
   }
   else if(dir=='y')
   {
       float xi= x;
       x = x*cost+z*sint;
       z = -xi*sint+z*cost;
   }
   else if(dir=='x')
   {      
       float yi = y;
       y = y*cost-z*sint;
       z = yi*sint+z*cost;
   }
 }
 void draw()
 {
 //   pushStyle();
    
    noStroke();
    fill(176,196,222);
    ellipse(x, y,2*r,2*r);
    
 //   popStyle();
 }
 
  float getZ()
  {
    return (x*x + y*y - r*r);
  }
  
   float angleSum()
   {
     float res = 0;
     ArrayList<Vertex> adjacent = neighbors();
  
     for(int i = 1; i <= adjacent.size(); i++)
     {
        float y = adjacent.get(i-1).r;
        float z = adjacent.get(i%adjacent.size()).r;
        res += Math.acos(((r+y)*(r+y) + (r+z)*(r+z) +- (y+z)*(y+z))/(2*(r+y)*(r+z)));
     }
     return res;
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
  
  void attach(Vertex t) 
  {
    //don't connect verticies that are already connected or not in same Complex
    if(t.parent != parent || this.h!=null&&this.h.next!=null && this.h.next.v == t)
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
    
    parent.edges.add(new Edge(h1, h2));
    h1.e = parent.edges.get(parent.edges.size()-1);
    h2.e = parent.edges.get(parent.edges.size()-1);
  }
  
  ArrayList<Vertex> neighbors()//returns neighbors in ccw order
  {
    ArrayList<Vertex> adj = new ArrayList<Vertex>();
    adj.add(h.next.v);
    HalfEdge test = h.prev.twin;
    while(test != h)
    {
      adj.add(test.next.v);
      test = test.prev.twin;
    }
    return adj;
  }
  
  void print()
  {
    println(x, y, z);
  }
}
