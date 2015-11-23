
import java.util.Random;

final int NUM_OUTER_VERTS = 3;
final int INF = 1<<30;
Packing CPack;

boolean drawSphere = false;
boolean drawOrtho = false;
boolean drawing = false;
boolean drawDualEdge = false;
boolean drawBack = true;
boolean d = true, e= true;
boolean in = false;  
boolean TEST = false;
boolean circleDrawn = true;//false;
boolean DEBUG1 = false;
boolean cool_stuff = false;

float ax = 0, ay=0, az=0;
float tx = 0, ty=0, tz=1;
float fov = PI/3.0;
float eyeX, eyeY, eyeZ;
float eyeZStart = 800; // approximate value for now ;//(height/2.0)/tan(PI*30.0 / 180.0);
int sx, sy;
int orthoSphereR = 200;

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
Matrix calculateTransitionMatrix(float x, float y) {
    double[][] tempVector = new double[3][1];
    tempVector[0][0] = x;
    tempVector[1][0] = y;
    tempVector[2][0] = 0;
    Matrix pointMatrix = new Matrix(tempVector);
    double[][] tempTransitionX = new double[3][3];
    double[][] tempTransitionZ = new double[3][3];
    tempTransitionX[0][0] =  1;
    tempTransitionX[0][1] =  0;
    tempTransitionX[0][2] =  0;
    tempTransitionX[1][0] =  0;
    tempTransitionX[1][1] =  cos(-ax);
    tempTransitionX[1][2] =  -sin(-ax);
    tempTransitionX[2][0] =  0;
    tempTransitionX[2][1] =  sin(-ax);
    tempTransitionX[2][2] =  cos(-ax);
    Matrix transitionX = new Matrix(tempTransitionX);
    
    tempTransitionZ[0][0] =  cos(-az);
    tempTransitionZ[0][1] =  -sin(-az);
    tempTransitionZ[0][2] =  0;
    tempTransitionZ[1][0] =  sin(-az);
    tempTransitionZ[1][1] =  cos(-az);
    tempTransitionZ[1][2] =  0;
    tempTransitionZ[2][0] =  0;
    tempTransitionZ[2][1] =  0;
    tempTransitionZ[2][2] =  1;
    Matrix transitionZ = new Matrix(tempTransitionZ);
    
    MatrixMathematics matrixMath = new MatrixMathematics();
    Matrix transition = matrixMath.multiply(transitionX, transitionZ);
    Matrix newPoints = matrixMath.multiply(transition, pointMatrix);
    return newPoints;
}
void mousePressedCall() {
  if (TEST) 
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

  } else if (!drawing) {
    drawing = true;
    sx = mouseX;
    sy = mouseY;
  } else if (drawing) {
    //float x = modelX(mouseX, mouseY,0);
    //float y = modelY(mouseX,mouseY,0);
    float x = (sx - tx - width/2) / tz; 
    float y = (sy - ty - height/2) / tz;
    Matrix newPoints = calculateTransitionMatrix(x,y);
    float xe = (float) newPoints.getValueAt(0,0);
    float ye = (float) newPoints.getValueAt(1,0);
    
    float r = sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy))/tz;
    ellipse(xe,ye,2*r,2*r);
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
      cool_stuff = !cool_stuff;
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
    Matrix newPoints = calculateTransitionMatrix(x,y);
    float xe = (float) newPoints.getValueAt(0,0);
    float ye = (float) newPoints.getValueAt(1,0);
    float r = sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy))/tz;
    System.out.println("X: " + x + " Y: " + y);
    CPack.addVertex(new Vertex(xe, ye, r));
    //CPack.addVertex(new Vertex(sx - tx - width/2, sy - ty-height/2, sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy))));
    CPack.computeSprings();
  }
}