final int NUM_OUTER_VERTS = 3;
final int INF = 1<<30;
final float orthoSphereR = 200.0;

float sx, sy, dyc, dxc;
boolean drawing, rotating, drawKoebe, showHelp = true, first = true;
int mode;

EnrichedEmbedding curr, temp; 

void setup() 
{
  size(1433, 900, P3D);
  background(255);
  
  curr = new EnrichedEmbedding(NUM_OUTER_VERTS);
  temp = new EnrichedEmbedding(NUM_OUTER_VERTS);
  
  drawing = false;
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
  noStroke();

  if (!rotating) 
  {
    if(mode==1)
    {
      curr.G.drawDual();
    }
    else
    {
      curr.drawPSLG();
      curr.drawRadii();
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
       curr.G.updateStereo();
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
    fill(176, 196, 250);
    ellipse(sx-width/2, sy-height/2, 2*r, 2*r);
  }

  if (rotating)
  {
    float dyt = (sx - mouseX)/70, dxt = -(sy - mouseY)/70;
    dyc += dyt;
    dxc += dxt;
    if(first)
    {
      dyt = 2;
      dxt = 2;
    }
    for(Vertex vv : curr.G.verts)
    {
      vv.ap.rotate('x', dxt);
      vv.ap.rotate('y', dyt);
      vv.bp.rotate('x', dxt);
      vv.bp.rotate('y', dyt);
      vv.cp.rotate('x', dxt);
      vv.cp.rotate('y', dyt);
    }
    for(Vertex vv : curr.G.outerVerts)
    {
      vv.ap.rotate('x', dxt);
      vv.ap.rotate('y', dyt);
      vv.bp.rotate('x', dxt);
      vv.bp.rotate('y', dyt);
      vv.cp.rotate('x', dxt);
      vv.cp.rotate('y', dyt);
    }
    curr.G.upateFromStereo();
    
    curr.G.fancyDraw(drawKoebe);

    sx = mouseX; 
    sy = mouseY;
    first = false;
  }
  
  String status = "";
  fill(0);

  switch(mode)
  {
    case 0:  status = "Primal graph (editable)"; 
             break;

    case 1:  status = "Dual graph (editable)";  
             break;

    case 2:  status = "Mobius transformations (view only)";  
             break;

    case 3:  status = "Koebe polyhedron (view only)";
             break;
             
    default: status = "error";
             break;
  }
  
  text("Mode: " + status, -width/2, -height/2 + 20);

  if(showHelp)
  {
   stroke(100);
   fill(230);

   rect(-200,-200, 500, 300);
   fill(0);
   text("Instructions", -200, -210);
   //Add weighted points to the triangulation by clicking and dragging left mouse.
   //Press left arrow to run the radii-update algorithm, or right arrow to run the spring algorithm.
   //Press space to change modes. To restart press 'c'.
   text("Press 'h' to toggle instructions", -150, -170);
   text("Press SPACE to change modes", -150, -150);
   text("Press LEFT to run the radii-update algorithm", -150, -130);
   text("Press RIGHT to run the spring algorithm", -150, -110);
   text("Press 'c' to restart", -150, -70);
   text("Press ',' to save the current embedding", -150, -50);
   text("Press '.' to load the saved embedding", -150, -30);
  }
  fill(230);
}

void mousePressed() 
{
  if (mouseButton == LEFT && !rotating) 
  {
    sx = mouseX; 
    sy = mouseY;
    drawing = true;
  } 
}

void mouseReleased() 
{
  if (mouseButton == LEFT && !rotating) 
  {
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
  
  if(key ==  ',' && mode <= 1)
  {
    temp = new EnrichedEmbedding(curr);
  }
  else if(key == '.' && mode <= 1)
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
      curr.G.updateStereo();
      first = true;
      rotating = true;
    }
    else if(mode==3)
    {
      sx = mouseX; 
      sy = mouseY;
      curr.G.updateStereo();
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