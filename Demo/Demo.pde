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

boolean first = true;
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
      curr.G.comp2();
       for(Vertex v : curr.G.verts)
       {
        v.ap.rotate('x', dxc);
        v.ap.rotate('y', dyc);
        v.bp.rotate('x', dxc);
        v.bp.rotate('y', dyc);
        v.cp.rotate('x', dxc);
        v.cp.rotate('y', dyc);
       }
       for(Vertex v : curr.G.outerVerts)
       {
        v.ap.rotate('x', dxc);
        v.ap.rotate('y', dyc);
        v.bp.rotate('x', dxc);
        v.bp.rotate('y', dyc);
        v.cp.rotate('x', dxc);
        v.cp.rotate('y', dyc);
       }
    }
  }

  if (drawing) 
  {
    float dx = mouseX - sx, dy = mouseY - sy, r = sqrt(dx*dx + dy*dy);
    noStroke();
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
    if(first)
    {
      dyt = 2;
      dxt = 2;
    }
    for(Vertex vv : curr.G.verts)
    {
      vv.ap.rotate('x', -dxt/70);
      vv.ap.rotate('y', dyt/70);
      vv.bp.rotate('x', -dxt/70);
      vv.bp.rotate('y', dyt/70);
      vv.cp.rotate('x', -dxt/70);
      vv.cp.rotate('y', dyt/70);
    }
    for(Vertex vv : curr.G.outerVerts)
    {
      vv.ap.rotate('x', -dxt/70);
      vv.ap.rotate('y', dyt/70);
      vv.bp.rotate('x', -dxt/70);
      vv.bp.rotate('y', dyt/70);
      vv.cp.rotate('x', -dxt/70);
      vv.cp.rotate('y', dyt/70);
    }
    curr.G.down2();
    
    curr.G.fancyDraw(drawKoebe);

    sx = mouseX; 
    sy = mouseY;
    first = false;
  }
  
  fill(230);
  if(showHelp)
  {
   stroke(100);
   rect(-200,-200, 500, 300);
   fill(0);
   text("Help", -200, -200);
   fill(0);
   text("-Press 'h' to toggle help menu", -150, -170);
  }
  fill(230);
}

void mousePressed() {
  if (mouseButton == LEFT && !rotating) {
    sx = mouseX; 
    sy = mouseY;
    drawing = true;
  } 
}

void mouseReleased() {
  if (mouseButton == LEFT && !rotating) {
    float dx = mouseX - sx, dy = mouseY - sy;
    curr.addVertex(sx-width/2, sy-height/2, sqrt(dx*dx + dy*dy));
    drawing = false;
  } 
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
      curr.G.comp2();
      first = true;
      rotating = true;
    }
    else if(mode==3)
    {
      sx = mouseX; 
      sy = mouseY;
      curr.G.comp2();
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