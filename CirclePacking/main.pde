final int NUM_OUTER_VERTS = 3;
Triangulation tri = new Triangulation(NUM_OUTER_VERTS);
boolean showCircles = false;
boolean drawing = false;
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
  if(keyPressed && key == '1')
    showCircles = true;
  else if(keyPressed && key == '2')
    showCircles = false;
  else if(keyPressed && key=='3')
    computePacking(tri);
  else if(keyPressed && key=='4')
    computeSprings(tri);
  else if(keyPressed && key=='5')
    simulate(tri);
 else if(keyPressed && key=='c')
 {
   translate(0,0,0);
   rotate(0,0,0,0);
   ax = ay = az = tx = ty = tz = 0;
 }
  else if(keyPressed && keyCode==UP)
  {
      ax+=0.01;
  }
  else if(keyPressed && keyCode==DOWN)
  {
      ax-=0.01;  
  }
  else if(keyPressed && keyCode==LEFT)
  {
      az+=0.01;
  }
    else if(keyPressed && keyCode==RIGHT)
  {
      az-=0.01;
  }
  else if(keyPressed && key=='w')
    tz+=10;
  else if(keyPressed && key=='s')
    tz-=10;
  else if(keyPressed && key=='a')
    tx+=10;
  else if(keyPressed && key=='d')
    tx-=10;
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
}

