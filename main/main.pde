import java.util.Random;

final int NUM_OUTER_VERTS = 4;
final int INF = 1<<30;
Packing CPack;

boolean drawSphere = true;
boolean drawOrtho = false;
boolean drawing = false;
boolean drawDualEdge = false;
boolean drawBack = true;
boolean d = true, e= true;
boolean in = false;  
boolean TEST = false;
boolean circleDrawn = false;
boolean DEBUG1 = false;

float ax = 0, ay=0, az=0;
float tx = 0, ty=0, tz=1;
float fov = PI/3.0;
float eyeX, eyeY, eyeZ;
float eyeZStart = 800; // approximate value for now ;//(height/2.0)/tan(PI*30.0 / 180.0);
int sx, sy;

ArrayList<Point> stereoUp = new ArrayList<Point>();

void settings() {
  fullScreen(P3D);
  //size(displayWidth, displayHeight, P3D);
}

void setup() {
  //fullScreen(P3D);
  //size(width, height, P3D);
  eyeX = width/2;
  eyeY = height/2;
  eyeZ = eyeZStart;
  background(255);
  fill(0, 0);
  CPack = new Packing(NUM_OUTER_VERTS);
}

void draw() {
   // CAMERA:
  /*if (eyeZ<0) {
    camera(eyeX, eyeY, eyeZ, 
    width/2, height/2, 0, 
    0, -1, 0);
  }
  else {
    camera(eyeX, eyeY, eyeZ, 
    width/2, height/2, 0, 
    0, 1, 0);
  }*/
  translate(width/2, height/2, 0);  
  keyPressedCall();
  //scale(tz);
  //float cameraZ = (height/2.0) / tan(fov/2.0);
  //perspective(fov - tz, float(width)/float(height), 
  //          cameraZ/10.0, cameraZ*10.0);
  translate(tx, ty, 0);
  scale(tz);
  rotateX(ax);
  rotateZ(az);
  background(255);
  CPack.draw();
  fill(0, 0, 255, 40);
  noStroke();

  if (drawSphere) {
    sphere(100);
  }
  fill(200);
  if(mousePressed) {
    mousePressedCall();
  }
}

void mousePressedCall() {
  if (TEST) {
    if (in) {
      //handle rotations
      float dxt = sx - mouseX, dyt = sy - mouseY;

      for (Vertex v : CPack.verticies) {
        v.stereoUp.rotate('y', dxt/700);
        v.stereoUp.rotate('x', dyt/700);
        //v.weight = 10;
      }
      for (Vertex v : CPack.outerVerts) {
        v.stereoUp.rotate('y', dxt/700);
        v.stereoUp.rotate('x', dyt/700);
      }
    } else
      in = true;
      sx = mouseX;
      sy = mouseY;
  } else if (!drawing) {
    drawing = true;
    sx = mouseX;
    sy = mouseY;
  } else if (drawing) {
    //float x = modelX(mouseX, mouseY,0);
    //float y = modelY(mouseX,mouseY,0);
    float x = (sx - tx - width/2) / tz;
    float y = (sy - ty - height/2) / tz;
    float r = sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy));
    ellipse(x,y,2*r,2*r);
    //ellipse(sx - tx - width/2, sy - ty - height/2, 2*r, 2*r);
  }
}
void keyPressedCall() {
  if (keyPressed) {
    switch (key) {
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
      if (circleDrawn) {
        CPack.test();
      }
      break;
    case '6':
      if (circleDrawn) {
        CPack.computePacking();
        CPack.layout();
      }
      break;
    case '7':
      //CPack.test2();
      break;
    case '8':
      if (circleDrawn) {
        CPack.layout();
      }
      break;
    case '9':    // reset display to original position
      ty = 0;
      tx = 0;
      az = 0;
      ax = 0;
      tz = 0;
      break;
    case '\\':
      Random rand = new Random();
      int x = rand.nextInt(width) - width/2, y = rand.nextInt(height)-height/2;
      CPack.addVertex(new Vertex(x, y, 10));//varRadii[x][y]));
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
      tz += .01;
      //tz+= 10;
      break;
    case '-':
      //tz-= 10;
      tz -= .01;
      break;
    case 'v':
      drawSphere = !drawSphere;
      break;
    case 'x':
      for (Vertex v : CPack.verticies) {
        v.stereoUp.rotate('y', 0.01);
        v.stereoUp.rotate('x', 0.01);
      }
      break;
    case 'z':
      for (Vertex v : CPack.verticies) {
        v.stereoUp.rotate('z', 0.01);
      }
      break;
    case 'f':
      DEBUG1 = !DEBUG1;
      break;
    }
    switch (keyCode) {
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
    case ENTER:
      TEST = true;
      break;
    }
  }
}
void mouseReleased() {
  circleDrawn = true;
  in = false;
  if (!TEST) {
    drawing = false;
    System.out.println("mouseX: " + sx + " mouseY: " + sy);
    float x = (sx - tx - width/2) / tz;
    float y = (sy - ty - height/2) /tz;
    System.out.println("X: " + x + " Y: " + y);
    CPack.addVertex(new Vertex(x, y, sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy))));
    //CPack.addVertex(new Vertex(sx - tx - width/2, sy - ty-height/2, sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy))));
    CPack.computeSprings();
  }
}