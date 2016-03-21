import java.util.Random;

final int NUM_OUTER_VERTS = 3;
final int INF = 1<<30;
final float orthoSphereR = 200.0;
float sx, sy;
boolean drawing = false;
boolean drawOrtho = false;
boolean rotating = false;
boolean drawKoebe = false;
boolean mode2 = false;

EnrichedEmbedding test; 

void setup() {
  size(1024, 768, P3D);
  background(255);
  fill(0, 0);
  test = new EnrichedEmbedding(NUM_OUTER_VERTS);
  textFont(createFont("Arial",20));
}

void draw() {
  background(255);
  
  translate(width/2, height/2, 0);  
  
  fill(100);
  noStroke();
  rect(-500,-height/2, 1000, 50);

  if (!rotating) {
    test.drawPSLG();
    test.drawRadii();
  }

  if (keyPressed) {
    if (keyCode==LEFT) {
      radii_update(test);
    } else if (keyCode==RIGHT) {
      stress_update(test);
    }
  }

  if (keyPressed && key=='r') {
    Random rand = new Random();
    test.addVertex(rand.nextInt(width)-width/2, rand.nextInt(height)-height/2, rand.nextInt(70));
  }
  if (drawing) {
    float dx = mouseX - sx, dy = mouseY - sy, r = sqrt(dx*dx + dy*dy);

    noStroke();
    fill(185, 205, 240);
    ellipse(sx-width/2, sy-height/2, 2*r, 2*r);
  }

  if (!rotating && drawOrtho) {
    test.drawOrthocircles();
  }
  if (rotating && test.isPacking())
  {
    float dyt = sx - mouseX, dxt = sy - mouseY;

    HashMap<HalfEdge, Boolean> done = new HashMap<HalfEdge, Boolean>();

    for (int i= 0; i < test.G.edges.size(); i++) {
      if (done.containsKey(test.G.edges.get(i).h1)) {
        continue;
      }
      done.put(test.G.edges.get(i).h1, true);

      Vertex v = test.G.edges.get(i).h1.ixnp;

      v.rotate('x', -dxt/70);
      v.rotate('x', -dxt/70);
      v.rotate('y', dyt/70);
      v.rotate('y', dyt/70);

      test.G.edges.get(i).h1.ixnp = v;
    }
    test.G.down();
    test.G.fancyDraw(drawKoebe);

    sx = mouseX; 
    sy = mouseY;
  }
      fill(100);

    rect(-500,-height/2, 1000, 50);
  fill(230);

  if(test.G.verts.size()==0)
  {
    text("Drag left mouse to add weighted points to the triangulation.", -490, -height/2+30);
  }
  else if(!test.isPacking())
  {
    text("When finished, press LEFT to run the radii update algorithm or RIGHT to run the force directed algorithm.", -490, -height/2+30);
  }
  else
  {
    text("Drag right mouse to view mobius transformations. Press K to toggle Koebe polyhedron view, and C to restart.", -490, -height/2+30);
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    sx = mouseX; 
    sy = mouseY;
    drawing = true;
  } else if (mouseButton == RIGHT && test.isPacking()) {
    test.G.computeIxn();
    sx = mouseX; 
    sy = mouseY;
    rotating = true;
    mode2 = true;
  }
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    float dx = mouseX - sx, dy = mouseY - sy;
    test.addVertex(sx-width/2, sy-height/2, sqrt(dx*dx + dy*dy));
    drawing = false;
  } else if (mouseButton == RIGHT) {
    rotating = false;
  }
}

void keyPressed() {
  if (key == 'c') {
    mode2 = false;
    setup();
  } else if (key=='d') {
    drawOrtho = !drawOrtho;
  }
  else if (key == 'k') {
    drawKoebe = !drawKoebe;
  }
}
