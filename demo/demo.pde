final int NUM_OUTER_VERTS = 6;
Triangulation tri;
boolean drawOrtho = false;
boolean drawDualEdge = false;
final boolean FAKE = true;
int sx, sy;

void setup()
{
  size(2048, 1024, P3D);
  background(255);
  fill(0,0);
  tri = new Triangulation(NUM_OUTER_VERTS, 5000, 800);
}

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
        drawDualEdge = true;
        break;
      case '4':
        drawDualEdge = false;
        break;
      case '5':
        if(tri.verticies.size() > 0)
          tri.simulate();
        break;
     case '6':
        computePacking(tri);
        break;
     case '7':
       if(e)
       {
         oldr =  new ArrayList<Float>();

         for(int i =0; i < tri.verticies.size(); i++)
           oldr.add(i, tri.verticies.get(i).weight);
  
//         Edge nxt = edges.get(20);
//         attach(nxt.h2.prev.v, nxt.h1.prev.v);
//         nxt.h1.detach();
//         e = false;
       }
       break;
    case '9':
      int x = (int)random(width-100), y = (int)random(height-100);
      tri.addVertex(new Vertex(x, y, 10));
      break;
     case 'g':
       for(int i =0; i < tri.verticies.size(); i++)
       {
           tri.verticies.get(i).shade = (int)min(255, 10*(abs(oldr.get(i) - tri.verticies.get(i).weight)));
           println(tri.verticies.get(i).shade);
       }
       break;
      case 'c':
        translate(0,0,0);
        break;
      case 'w':
        ty+=20;
        break;
      case 'a':
        tx+=20;
        break;
      case 's':
        ty-=20;
        break;
      case 'd':
        tx-=20;
        break;
      case 'q':
        tz+=20;
        break;
      case 'z':
        tz-=20;
        break;
    }
  }
    ///////////////////draw
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
  tri.addVertex(new Vertex(sx, sy, sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy))));
}


