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
float tx = 0, ty=0, tz=0;
int sx, sy;

ArrayList<Point> stereoUp = new ArrayList<Point>();

void settings() {
  fullScreen(P3D);
  //size(displayWidth, displayHeight, P3D);
}

void setup() {
  //fullScreen(P3D);
  //size(width, height, P3D);
  background(255);
  fill(0, 0);
  CPack = new Packing(NUM_OUTER_VERTS);
}

void draw() {
  translate(width/2, height/2, 0);  
  keyPressedCall();

  translate(tx, ty, tz);
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
    float r = sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy));
    ellipse(sx - tx - width/2, sy - ty - height/2, 2*r, 2*r);
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
      tz+=10;
      break;
    case '-':
      tz-=10;
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
    CPack.addVertex(new Vertex(sx - tx - width/2, sy - ty-height/2, sqrt((mouseX-sx)*(mouseX-sx) + (mouseY-sy)*(mouseY-sy))));
    CPack.computeSprings();
  }
}