import java.util.Random;

final int NUM_OUTER_VERTS = 3;
final int INF = 1<<30;
final int orthoSphereR = 200;

boolean drawing = false;
boolean in = true;

float ax = 0, ay=0, az=0;
float tx = 0, ty=0, tz=1;
int sx, sy;

Packing CPack;
Vertex planeNormal = new Vertex(0,0,10);

void setup() 
{
  size(1024, 768, P3D);
  background(255);
  fill(0, 0);
  CPack = new Packing(NUM_OUTER_VERTS);
}

void draw() 
{
  translate(width/2, height/2, 0);  
  translate(tx, ty, tz);

  rotateX(ax);
  rotateZ(az);
  background(255);
  CPack.draw();
  noStroke();

  fill(200);

  if(mousePressed) 
    mousePressedCall();
   if(keyPressed)
    keyPressedCall();
    
  planeNormal.draw();

}

void mousePressedCall() 
{
  if (CPack.mobius) 
  {
    if(in)
    {
      //handle rotations
      float dxt = sx - mouseX, dyt = sy - mouseY;
      CPack.rot('y', dxt/70);
      CPack.rot('x', dyt/70);  
    }
    else
      in = true;
    sx = mouseX;
    sy = mouseY;
  } 
  else if (!drawing) 
  {
    drawing = true;
    sx = mouseX;
    sy = mouseY;
  } 
  else if (drawing) 
  {
    float x = (sx - tx - width/2) / tz;
    float y = (sy - ty - height/2) / tz;
    float r = sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy));
    ellipse(x,y,2*r,2*r);
  }
}

void keyReleased()
{
  switch(key)
  {
    case '1':
      CPack.drawOrtho = !CPack.drawOrtho;
      break;
    case '2':
      CPack.drawDualEdge = !CPack.drawDualEdge;
    case '7':
      CPack.drawKoebe = !CPack.drawKoebe;
      break;
  }
}

void keyPressedCall()
{
  switch(key)
  {
    case '5':
      CPack.test();
      break;
    case '6':
      CPack.computePacking();
      CPack.layout();
      break;
    case '\\':
      Random rand = new Random();
      int x = rand.nextInt(width) - width/2, y = rand.nextInt(height)-height/2;
      CPack.addVertex(new Vertex(x, y, 0, 10));//varRadii[x][y]));
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
    case '=':
      tz += 10;
      break;
    case '-':
      tz -= 10;
      break;
  }
  switch (keyCode) 
  {
    case UP:
      ax+=0.01;
      planeNormal.rotate('x', 0.01);
      break;
    case DOWN:
      ax-=0.01;
      planeNormal.rotate('x', -0.01);
      break;
    case LEFT:
      az+=0.01;
      planeNormal.rotate('z', 0.01);
      break;
    case RIGHT:
      az-=0.01;
     planeNormal.rotate('z', -0.01);
      break;
    case ENTER:
      CPack.mobius = true;
      break;
  }
}

void mouseReleased() 
{
  //float ixnZ = -(planeNormal.x*mouseX + planeNormal.y*mouseY)/planeNormal.z;
  //Vertex test = new Vertex(mouseX-width/2, mouseY-height/2, ixnZ,0);
  //test.draw();
  //noLoop();

  in = false;
  drawing = false;
  float x = (sx - tx - width/2) / tz;
  float y = (sy - ty - height/2) /tz;
  CPack.addVertex(new Vertex(x, y, 0, sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy))));
  //CPack.computeSprings();
}