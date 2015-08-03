import java.util.Random;

final int NUM_OUTER_VERTS = 4;
Triangulation tri;
boolean drawOrtho = false;
boolean drawing = false;
boolean drawDualEdge = false;

int sx, sy;
color cpts[][];
float varRadii[][];
void appolonian_gasket()
{
  JQueue<HalfEdge> q = new JQueue<HalfEdge>();
  q.add(tri.outerVerts.get(0).h);
  while(!q.isEmpty())
  {
    HalfEdge he = q.remove();

    if(visited.containsKey(he))  
      continue;
    
    Vertex v1 = he.v;
    Vertex v2 = he.next.v;
    Vertex v3 = he.prev.v;
    float x = (1.1*v1.x + v2.x + v3.x)/3;
    float y = (1.1*v1.y + v2.y + v3.y)/3;
    //println(x + " " + y);
    Vertex v = new Vertex((int)x, (int)y, 20);
    if(tri.addVertex(v))
    {
//      visited.put(v.h,true);
//      visited.put(v.h.prev,true);
//      
//      visited.put(v.h.twin,true);
//      visited.put(v.h.twin.next,true);
//      
//      visited.put(v.h.prev.twin,true);
//      visited.put(v.h.twin.next.twin,true);
    }
    

    visited.put(he, true);
    q.add(he.next);
    q.add(he.twin);
  }
  visited.clear();
}


void setup()
{
  size(2048, 1024, P3D);
  background(255);
  img = loadImage("test9.jpg");  
  image(img, 0, 0);
  loadPixels();
  
  cpts = new color[width][height];
  varRadii = new float[width][height];
  
  for(int i =0; i < height; i++)
    for(int j = 0; j < width; j++)
      cpts[j][i] = pixels[j+width*i];
  
  for(int i =0; i < width; i+= width/10)
  {
    for(int j = 0; j < height; j+= height/10)
    {
      //calculate variance of this region
      float avg = 0,variance = 0;
      for(int k= i; k < i+width/10 && k < width; k++)
        for(int l = j; l < j+height/10 && l < height; l++)
          avg+=brightness(pixels[k+l*width]);

      avg/=(width*height/100);
      
      for(int k= i; k < i+width/10 && k < width; k++)
        for(int l = j; l < j+height/10 && l < height; l++)
          variance += (avg - brightness(pixels[k+l*width]))*(avg - brightness(pixels[k+l*width]));

      variance /= 1000000;
      for(int k= i; k < i+width/10 && k < width; k++)
        for(int l = j; l < j+height/10 && l < height; l++)
           varRadii[k][l] = 100/variance;
    }
  }
  fill(0,0);
  tri = new Triangulation(NUM_OUTER_VERTS);
}

float ax = 0, ay=0, az=0;
float tx = 0, ty=0, tz=0;
PImage img;
boolean drawBack = true;
boolean d = true, e= true;
ArrayList<Float> oldr;
void draw()
{
  if(keyPressed)
  {
    switch (key)
    {
      case '1':
        drawOrtho = true;
        break;
      case '2':
        drawOrtho = false;
        break;
      case '3':
      drawBack = false;
        drawDualEdge = true;
        break;
      case '4':
        drawDualEdge = false;
        break;
      case '5':
        simulate(tri);
        break;
     case '6':
        computePacking(tri);
        break;
     case '7':
       if(e)
       {
        oldr =  new ArrayList<Float>();

       for(int i =0; i < tri.verticies.size(); i++)
       {
           oldr.add(i, tri.verticies.get(i).weight);
       }
        Edge nxt = edges.get(20);
            attach(nxt.h2.prev.v, nxt.h1.prev.v);
            nxt.h1.detach();
            e = false;
       }
        break;

     case 'g':
     for(int i =0; i < tri.verticies.size(); i++)
     {
         tri.verticies.get(i).shade = (int)min(255, 10*(abs(oldr.get(i) - tri.verticies.get(i).weight)));
         println(tri.verticies.get(i).shade);
     }
     break;
     case '8':
         Random rand = new Random();
        for(Edge e : edges)
        {
          float sign = rand.nextFloat();
          float off = rand.nextFloat();
          if(sign < 0.5)
          {
            e.spring+=off*10;
          }
          else
          {
            e.spring-=off*10;
          }
        }
        break;
      case '9':
        rand = new Random();
        int x = rand.nextInt(img.width-100), y = rand.nextInt(img.height-100);
        tri.addVertex(new Vertex(x, y, 10));//varRadii[x][y]));
        break;
      case '0':
        //appolonian_gasket();
        for(Vertex v : tri.verticies)
        {
          float red = 0, green = 0, blue = 0;
          for(float i= v.x - v.weight/2;i < v.x + v.weight/2; i++)
          {
           for(float j= v.y - v.weight/2; j < v.y + v.weight/2; j++)
           {
             if (i > 0 && i < width && j > 0 && j < height) 
             {
               green+= green(cpts[(int)i][(int)j]);
               blue+= blue(cpts[(int)i][(int)j]);
               red+= red(cpts[(int)i][(int)j]);
             }
           } 
          } 
          red/= v.weight*v.weight;
          green/= v.weight*v.weight;
          blue/= v.weight*v.weight;

          v.shade = color(red, green, blue);
        }
        break;
        
      case 'c':
        translate(0,0,0);
        rotate(0,0,0,0);
        ax = ay = az = tx = ty = tz = 0;
        break;
      case 'w':
        tz+=10;
        break;
      case 'a':
        tx+=10;
        break;
      case 's':
        tz-=10;
        break;
      case 'd':
        tx-=10;
        break;
    }
    switch (keyCode)
    {
      case UP:
        ax+=0.01;
        break;
      case DOWN:
        ax-=0.01;  
        break;
      case LEFT:
        az+=0.01;
        break;
      case RIGHT:
        az-=0.01;
        break;
    }
  }
  
  rotateX(ax);
  rotateY(ay);
  rotateZ(az);
  translate(tx,ty,tz);
  background(255);
  ///if(img!=null && drawBack)
  //      image(img, 0, 0);
  tri.draw();


  if(mousePressed && !drawing)
  {
    drawing = true;
    sx = mouseX;
    sy = mouseY;
  }
  else if(mousePressed && drawing)
  {
    float r = sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy));
    ellipse(sx, sy, 2*r,2*r);
  }
}

void mouseReleased()
{
  drawing = false;
//  for(int i =0; i < 50; i++)
//  {
//    Random rand = new Random();
//    int r = rand.nextInt(20);
//    int mx = rand.nextInt(1024);
//    int my = rand.nextInt(512);
//    tri.addVertex(mx, my,r);
//  }
  //tri.addVertex(20, 20, 20);
   // computeSprings(tri);
  tri.addVertex(new Vertex(sx, sy, sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy))));
  computeSprings(tri);
}

