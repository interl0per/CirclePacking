final int NUM_OUTER_VERTS = 3;
Triangulation tri = new Triangulation(NUM_OUTER_VERTS);
boolean drawOrtho = false;
boolean drawing = false;
boolean drawDualEdge = false;

int sx, sy;

void setup()
{
  size(1024, 512, P3D);
  background(255);
  fill(0,0);
}
float ax = 0, ay=0, az=0;
float tx = 0, ty=0, tz=0;
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
        simulate(tri);
        break;
     case '6':
        computePacking(tri);
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
  tri.addVertex(sx, sy, sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy)));
   computeSprings(tri);

}

