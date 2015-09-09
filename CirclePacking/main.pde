import java.util.Random;

final int NUM_OUTER_VERTS = 4;
final int INF = 1<<30;

Packing CPack;

boolean drawOrtho = false;
boolean drawing = false;
boolean drawDualEdge = false;
boolean drawBack = true;
boolean d = true, e= true;

float ax = 0, ay=0, az=0;
float tx = 0, ty=0, tz=0;

int sx, sy;

void setup()
{
  //fullScreen();
  //size(400, 400, P3D);
  surface.setSize(1000, 800);
  background(255);
  fill(0,0);
  CPack = new Packing(NUM_OUTER_VERTS);
}

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
        CPack.simulate();
        break;
     case '6':
        CPack.computePacking();
        break;
        
      case 'w':
        ty+=10;
        break;
      case 'a':
        tx+=10;
        break;
      case 's':
        ty-=10;
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

  translate(tx,ty);
  background(255);
  CPack.draw();

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
  CPack.addVertex(new Vertex(sx, sy, sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy))));
  CPack.computeSprings();
}