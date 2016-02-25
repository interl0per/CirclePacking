import java.util.Random;

final int NUM_OUTER_VERTS = 3;
final int INF = 1<<30;
final float orthoSphereR = 200.0;
float sx, sy;
boolean drawing = false;
boolean drawOrtho = false;
boolean rotating = false;
boolean drawKoebe = false;

EnrichedEmbedding test; 

void setup() 
{
  size(1024, 768, P3D);
  background(255);
  fill(0, 0);
  test = new EnrichedEmbedding(NUM_OUTER_VERTS);
}

void draw()
{
  translate(width/2, height/2, 0);  
  background(255);

  if(!rotating)
  {
    test.drawPSLG();
    test.drawRadii();
  }
  
  if(keyPressed)
  {
    if(keyCode==LEFT)
    {
      radii_update(test);
    }
    else if(keyCode==RIGHT)
    {
      stress_update(test);
    }
  }

   if(keyPressed && key=='r')
   {
      Random rand = new Random();
      test.addVertex(rand.nextInt(width)-width/2, rand.nextInt(height)-height/2, rand.nextInt(70));
   }
   if(drawing)
   {
    float dx = mouseX - sx, dy = mouseY - sy, r = sqrt(dx*dx + dy*dy);
     
     pushStyle();
     
     noStroke();
     fill(185,205,240);
     ellipse(sx-width/2, sy-height/2, 2*r, 2*r);
     popStyle();
   }
   
   if(!rotating && drawOrtho)
     test.drawOrthocircles();
   if(rotating)
   {
    test.G.fancy(drawKoebe);
    
    HashMap<HalfEdge, Boolean> done = new HashMap<HalfEdge, Boolean>();
    float dyt = sx - mouseX, dxt = sy - mouseY;

    for(int i= 0; i < test.G.edges.size(); i++)
    {
      if(done.containsKey(test.G.edges.get(i).h1)) continue;
      done.put(test.G.edges.get(i).h1, true);
      
      Vertex v = test.G.edges.get(i).h1.ixnp;
      
      v.rotate('x', -dxt/70);
      v.rotate('x', -dxt/70);
      v.rotate('y', dyt/70);
      v.rotate('y', dyt/70);
      
      test.G.edges.get(i).h1.ixnp = v;
      test.G.edges.get(i).h2.ixnp = v;
    }
      sx = mouseX; sy = mouseY;
   }
}

void mousePressed()
{
  if(mouseButton == LEFT)
  {
    sx = mouseX; sy = mouseY;
    drawing = true;

  }
  else if(mouseButton == RIGHT)
  {
    sx = mouseX; sy = mouseY;
    rotating = true;
  }
}
void mouseReleased()
{
  if(mouseButton == LEFT)
  {
    float dx = mouseX - sx, dy = mouseY - sy;
    test.addVertex(sx-width/2, sy-height/2, sqrt(dx*dx + dy*dy));
    drawing = false;
  }
  else if(mouseButton == RIGHT)
  {
    rotating = false;
  }
}
void keyPressed()
{
  if(key == 'c')
  {
    setup();
  }
  else if(key=='d')
    drawOrtho = !drawOrtho;
  else if(key == 'k')
  {
    drawKoebe = !drawKoebe;
  }
}