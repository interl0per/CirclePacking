final int NUM_OUTER_VERTS = 3;
Triangulation tri = new Triangulation(NUM_OUTER_VERTS);

boolean showCircles = false;


void setup()
{
  size(1024, 512);
  background(255);
  fill(0,0);
}
boolean drawing = false;
int sx, sy;

void draw()
{
  background(255);
  tri.draw();
  if(keyPressed && key == '1')
    showCircles = true;
  else if(keyPressed && key == '2')
    showCircles = false;
  
  else if(keyPressed && key=='6')
    computePacking(tri);
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
  tri.addVertex(sx, sy, sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy)));
}


