
class Vertex {
  float x, y;
  float r;
  ArrayList<Vertex> n;
  boolean bdy;

  Vertex() {
    r = 100;
    n = new ArrayList<Vertex>(0);
    bdy = false;
  }

  void setPosition(float xx, float yy) {
    x = xx;
    y = yy;
  }

  void place() {
    Vertex a = n.get(0);
    Vertex b = n.get(1);
    float r0 = (a.r + r) * (a.r + r);
    float r1 = (b.r + r) * (b.r + r);
    float dx = b.x - a.x;
    float dy = b.y - a.y;
    float d = a.r + b.r;
    float t = (r0 - r1 + (d*d)) / (2.0 * d) ;
    float x2 = a.x + (dx * t/d);
    float y2 = a.y + (dy * t/d);
    float h = sqrt(r0 - (t*t));
    x = x2 - dy * h/d;
    y = y2 + dx * h/d;
  }

  void draw() {
    stroke(0);
    fill(0);
    ellipse(x, y, 4, 4);
    noFill();    
    ellipse(x, y, r, r);
    for (Vertex v : n) {
      line(x,y,v.x,v.y); 
    }
  }
}

int numVertices = 5;
int numBdyVertices = 3;
Vertex[] v = new Vertex[numVertices];
float startX = 350, startY = 350;
float theta=1;

void setup() {
  size(700, 700);
  ellipseMode(RADIUS);
  noFill();

  for (int i=0;i<numVertices;++i) {
    v[i] = new Vertex();
  }  

  float l = v[0].r + v[1].r;
  v[0].setPosition(startX, startY);
  v[1].setPosition(startX + (l * cos(theta)), startY + (l * sin(theta)));
  int[][] he = {
    {0,1,2,3,4}, 
    {1,4,2,0},
    {2,0,1,4,3},
    {3,0,2,4},
    {4,0,3,2,1}
  };
  for (int[] nbrs : he) {
    for (int nbr: nbrs) {
      newHalfEdge(nbrs[0], nbr);        
    }
  }
  v[0].bdy = true;
  v[1].bdy = true;
  v[4].bdy = true;
}

void draw() {
  background(255);  

  for (int i = 1;i<numVertices;++i) {
    float targetAngle = (v[i].bdy) ? (PI - 2 * PI / numBdyVertices) : 2 * PI;
    float radiusAdjustment = (angleSum(v[i]) > targetAngle) ? 0.1 : -0.1;
    v[i].r += radiusAdjustment;
  }
  float l = v[0].r + v[1].r;
  v[1].setPosition(startX + (l * cos(theta)), startY + (l * sin(theta)));
  for (int i=2;i<numVertices;++i) { v[i].place(); }
  for (int i=0;i<numVertices;++i) { v[i].draw(); }
}

float angleSum(Vertex i) {
  Vertex j = i.n.get(i.n.size() - 1);  // last nieghbor of i
  Vertex k = i.n.get(0);  //first neighbor of i
  float currentAngle = i.bdy ? 0 : angle(i,j,k);
  for (int a = 1; a < i.n.size(); ++a) {
    j=k;
    k=i.n.get(a);
    currentAngle += angle(i,j,k);  
  }
  return currentAngle;
}

float angle(Vertex i, Vertex j, Vertex k) {
  float li = j.r + k.r;
  float lj = i.r + k.r;
  float lk = i.r + j.r; 
  // Use the law of cosines! 
  return acos((li*li - lj*lj - lk*lk)/(-2.0 * lj * lk));
}

void newHalfEdge(int i, int j) {
  if (i != j) { v[i].n.add(v[j]); }
}

