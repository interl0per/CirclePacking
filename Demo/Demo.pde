import java.util.Random;

final int NUM_OUTER_VERTS = 3;
final int INF = 1<<30;
final float orthoSphereR = 200.0;

float sx, sy, dyc, dxc;
boolean drawing, drawOrtho, rotating, drawKoebe, showHelp = true;
int mode;
EnrichedEmbedding curr, temp; 


void setup() {
  size(1433, 900, P3D);
  background(255);
  fill(0, 0);
  
  curr = new EnrichedEmbedding(NUM_OUTER_VERTS);
  temp = new EnrichedEmbedding(NUM_OUTER_VERTS);
  
  drawing = false;
  drawOrtho = false;
  rotating = false;
  drawKoebe = false;
  mode = 0;
  dyc = dxc = 0;
  
  textFont(createFont("Arial",20));
}


void draw() 
{
  background(255);
  translate(width/2, height/2, 0);  
  
  fill(100);
  noStroke();
  

  if (!rotating) 
  {
    curr.drawPSLG();
    curr.drawRadii();
    if(mode==1)
    {
      curr.G.drawDual();
    }
  }

  if (keyPressed) 
  {
    
    if (keyCode==LEFT) 
    {
      radii_update(curr);
    } 
    else if (keyCode==RIGHT) 
    {
      stress_update(curr);
    }
    if(keyCode == RIGHT || keyCode == LEFT)
    {
       curr.G.computeIxn();
       HashMap<HalfEdge, Boolean> done = new HashMap<HalfEdge, Boolean>();
  
       for (int i= 0; i < curr.G.edges.size(); i++) {
       if (done.containsKey(curr.G.edges.get(i).h1)) {
         continue;
       }
       done.put(curr.G.edges.get(i).h1, true);
  
       Vertex v = curr.G.edges.get(i).h1.ixnp;
  
       v.rotate('x', dxc);
       v.rotate('y', dyc);
  
       curr.G.edges.get(i).h1.ixnp = v;
     }
    }
  }

  if (drawing) 
  {
    float dx = mouseX - sx, dy = mouseY - sy, r = sqrt(dx*dx + dy*dy);

    noStroke();
  //  fill(185, 205, 240);
    ellipse(sx-width/2, sy-height/2, 2*r, 2*r);
  }

  if (!rotating && drawOrtho) 
  {
    curr.drawOrthocircles();
  }
  if (rotating)
  {
    float dyt = sx - mouseX, dxt = sy - mouseY;
    
    dyc += dyt/70;
    dxc += -dxt/70;
    
    HashMap<HalfEdge, Boolean> done = new HashMap<HalfEdge, Boolean>();

    for (int i= 0; i < curr.G.edges.size(); i++) {
      if (done.containsKey(curr.G.edges.get(i).h1)) {
        continue;
      }
      done.put(curr.G.edges.get(i).h1, true);

      Vertex v = curr.G.edges.get(i).h1.ixnp;

      v.rotate('x', -dxt/70);
      v.rotate('y', dyt/70);

      curr.G.edges.get(i).h1.ixnp = v;
    }
    curr.G.down();
    curr.G.fancyDraw(drawKoebe);

    sx = mouseX; 
    sy = mouseY;
  }
  fill(230);
  if(showHelp)
  {
    stroke(100);
   rect(-200,-200, 500, 300);
   fill(0);
   text("Help", -200, -200);
      fill(0);

   text("-Press 'h' to toggle off center help menu", -150, -170);

  }
  
  fill(230);
}

void mousePressed() {
  if (mouseButton == LEFT && !rotating) {
    sx = mouseX; 
    sy = mouseY;
    drawing = true;
  } 
//  else if (mouseButton == RIGHT/* && curr.isPacking()*/) 
//  {
//    curr.G.computeIxn();
//    sx = mouseX; 
//    sy = mouseY;
//    rotating = true;
//  }
}

void mouseReleased() {
  if (mouseButton == LEFT && !rotating) {
    float dx = mouseX - sx, dy = mouseY - sy;
    curr.addVertex(sx-width/2, sy-height/2, sqrt(dx*dx + dy*dy));
    drawing = false;
  } 
  //else if (mouseButton == RIGHT) {
//    rotating = false;
  //}
}

void keyPressed() 
{
  if(key == 'h')
  {
    showHelp = !showHelp;
  }
  if (key == 'c') 
  {
    setup();
  }
  else if (key=='d') {
    drawOrtho = !drawOrtho;
  }
  else if (key == 'k') {
    drawKoebe = !drawKoebe;
  }
  
  if(key ==  ',')
  {
    temp = new EnrichedEmbedding(curr);
  }
  else if(key == '.')
  {
    curr = new EnrichedEmbedding(temp);
  }
  else if(key == ' ')
  {
    mode = (mode+1)%4;
    if(mode == 2)
    {
      sx = mouseX; 
      sy = mouseY;
      curr.G.computeIxn();
      rotating = true;
    }
    else if(mode==3)
    {
      sx = mouseX; 
      sy = mouseY;
      curr.G.computeIxn();
      rotating = true;
      drawKoebe = true;
    }
    else
    {
      rotating = false;
      drawKoebe = false;
    }
  }
}