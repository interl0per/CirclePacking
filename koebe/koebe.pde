
class Vertex {
  float x, y;
  float r;
  ArrayList<Vertex> n;
  boolean bdy;

  Vertex() {
    r = 80;
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
    strokeWeight(1);
    ellipse(x, y, 4, 4);
    noFill();    
    ellipse(x, y, r, r);
    for (Vertex v : n) {
      line(x,y,v.x,v.y); 
    }
  }
}

//int[][] he = {
//  {0,1,3,2}, 
//  {1,0,2,3},
//  {2,0,3,1},
//  {3,0,1,2},
//};
//int[] bdy = {1,2,3};

//two points in a triangle
int[][] he = {
  {0,1,2,3,4}, 
  {1,4,2,0},
  {2,0,1,4,3},
  {3,0,2,4},
  {4,0,3,2,1}
};
int[] bdy = {0,1,4};

// one point in a square
//int[][] he = {
//  {0,1,2,3}, 
//  {1,4,2,0},
//  {2,0,1,4,3},
//  {3,0,2,4},
//  {4,3,2,1}
//};
//int[] bdy = {0,1,3,4};

// one point in a pentagon
//int[][] he = {
//  {0,1,2,3}, 
//  {1,5,2,0},
//  {2,0,1,5,4,3},
//  {3,0,2,4},
//  {4,3,2,5},
//  {5,4,2,1}
//};
//int[] bdy = {0,1,3,4,5};

// nested pentagons
//int[][] he = {
//  {0,1,2,3,4}, 
//  {1,8,9,2,0},
//  {2,0,1,9,3},
//  {3,0,2,9,5,4},
//  {4,0,3,5,6},
//  {5,4,3,9,7,6},
//  {6,4,5,7,8}, 
//  {7,6,5,9,8},
//  {8,6,7,9,1},
//  {9,8,7,5,3,2,1}
//};
//int[] bdy = {0,1,4,6,8};


int numVertices = he.length;
int numBdyVertices = bdy.length;
Vertex[] v = new Vertex[numVertices];
float R = 200;
float phi = sin(PI / numBdyVertices);
//float phi = sin(PI / 3);
float r = R * phi / (1 + phi);
float startX = 350, startY = 350-R+r;
float theta = PI * (1/2 + 1/ ((float)numBdyVertices));
//float theta = PI * (1/2.0 + 1/3.0);

void setup() {
  size(700, 700);
  smooth(4);
  ellipseMode(RADIUS);
  noFill();

  for (int i=0;i<numVertices;++i) { v[i] = new Vertex(); }  
  for (int i : bdy) { v[i].bdy = true; }

  Vertex a = new Vertex();
  Vertex b = new Vertex();
  Vertex c = new Vertex();
  Vertex d = new Vertex();
  a.r = -100;
  b.r = 12;
  c.r = 12;
  d.r = 25;
  a.setPosition(100,100);
  b.setPosition(100,b.r);
  c.n.add(b);
  c.n.add(a);
  c.place();
  d.n.add(b);
  d.n.add(c);
  d.place();
//  a.draw();
//  b.draw();
//  c.draw();
//  d.draw();
//
//  print(angle(b,a,c)/(2*PI) * 360);


  v[0].r = -200;
  v[1].r = r;
  float l = v[0].r + v[1].r;
  v[0].setPosition(startX, startY);
//  v[1].setPosition(startX, startY - 200 + r);
  v[1].setPosition(startX + (l * cos(theta)), startY - (l * sin(theta)));
  for (int[] nbrs : he) {
    for (int nbr: nbrs) {
      newHalfEdge(nbrs[0], nbr);        
    }
  }
}

void draw() {
//  noLoop();
  background(255);  

  for (int i = 2;i<numVertices;++i) {
    float targetAngle = (v[i].bdy) ? (PI - (2 * PI / numBdyVertices)) : 2 * PI;
//    float targetAngle = 2 * PI;
    float radiusAdjustment = (angleSum(v[i]) > targetAngle) ? 0.03 : -0.03;
    v[i].r += radiusAdjustment;
  }
  float l = v[0].r + v[1].r;
  v[1].setPosition(startX + (l * cos(theta)), startY + (l * sin(theta)));
//  v[1].setPosition(startX, startY - 200 + v[1].r);
  
  for (int i=2;i<numVertices;++i) { v[i].place(); }
  for (int i=0;i<numVertices;++i) { v[i].draw(); }
}

float angleSum(Vertex i) {
  Vertex j = i.n.get(i.n.size() - 1);  // last nieghbor of i
  Vertex k = i.n.get(0);  //first neighbor of i
  float currentAngle = i.bdy ? (2.0 * PI) - angle(i,j,k) : angle(i,j,k);
  for (int a = 1; a < i.n.size(); ++a) {
    j=k;
    k=i.n.get(a);
    currentAngle += angle(i,j,k);  
  }
  return currentAngle;
}

void keyPressed() {
  for(Vertex i : v) { i.r = r; }
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
