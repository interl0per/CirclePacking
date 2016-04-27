final int NUM_OUTER_VERTS = 3;
final int INF = 1<<30;
final float orthoSphereR = 200.0;

float sx, sy, dyc, dxc;
boolean drawing, rotating, drawKoebe, showHelp = true, first = true, helpNotClosed = true;
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
  
  textFont(createFont("Arial",18));
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
      curr.G.sctr();
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
    //else if(key == 'j')
    //      curr.fancyDraw(drawKoebe);

    //else if(key == 'k')
    //{
    //  curr.G.dual = new Complex(curr.G);
    //  curr.cStress_radii();
    //}
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
    if(first)
    {//necessary to fix some very, very strange bug with processing that leads to circumcircles not being drawn
      dyt += 0.001;
      dxt += 0.001;
    }
    dyc += dyt;
    dxc += dxt;

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
    
    curr.fancyDraw(drawKoebe);

    sx = mouseX; 
    sy = mouseY;
    first = false;
  }
  
  String status = "";
  fill(0);

  switch(mode)
  {
    case 0:  status = "1: Primal graph (editable)"; 
             break;

    case 1:  status = "2: Dual graph (editable)";  
             break;

    case 2:  status = "3: Möbius transformations";  
             break;

    case 3:  status = "4: Koebe polyhedron";
             break;
             
    default: status = "error";
             break;
  }
  
  text("Mode " + status, -width/2, -height/2 + 20);

  if(showHelp)
  {
   stroke(100);
   fill(230,200,200);
   translate(0,0,5);
   rect(-200,-400, 530, 310);

   fill(0);
   text("Instructions", 0, -380);
   text(" -Add weighted points to the triangulation by clicking \n and dragging left mouse in modes 1 and 2. \n"+
       " -Press left arrow to run the radii-update algorithm, or \n right arrow to run the spring algorithm (mode independent). \n"
       + " -Press space to change modes. \n" 
       + " -Move the mouse to explore transformations in modes 3 and 4. \n"
       + " -Press x to save the current embedding, and v to load \n a saved embedding in modes 1 and 2. \n"
       + " -To restart, press c. \n" 
       + " -Press h to toggle this menu.", -180, -350);
   translate(0,0,-5);
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
  if(showHelp && helpNotClosed)
  {
    showHelp = false;
  }
}

void keyPressed() 
{
  if(key == 'h')
  {
    showHelp = !showHelp;
    helpNotClosed = false;
  }
  else if (key == 'c') 
  {
    setup();
  }
  else if(key ==  'x' && mode <= 1)
  {
    temp = new EnrichedEmbedding(curr);
  }
  else if(key == 'v' && mode <= 1)
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
      rotating = true;
      first = true;
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