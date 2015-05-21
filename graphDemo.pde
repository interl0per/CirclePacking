import java.util.*;

class Point { int x,y; public Point(int _x,int _y) { x = _x; y = _y; } }

class Vertex
{
  Point loc;
  ArrayList<Integer> neighbors = new ArrayList(0);
  public Vertex(int x, int y) { loc = new Point(x,y); }
}

ArrayList<Vertex> graph = new ArrayList<Vertex>();
int[][] vertexRegions = new int[1060][550];

void saveGraph()//save to text file
{//format: nverts, followed by an edge list
    PrintWriter output = createWriter("graph.txt"); 
    output.println(graph.size()-1);
    for(int i = 1; i < graph.size(); i++)
      for(int j : graph.get(i).neighbors)
        output.println(i + " " + j);
        
    output.flush();
    output.close();
}
/**************************************************************************/
/************************** Draw planar graph *****************************/

void drawGraph()  //http://www-lp.fmf.uni-lj.si/plestenjak/Papers/schlegel.pdf
{    //model the graph as a system of springs
  //initialization: position on a circle of radius 200
  double c = Math.sqrt((graph.size()-1)/Math.PI);
  double placementAngle = 2*Math.PI/(graph.size()-1);
  for(int i = 0; i < graph.size()-1; i++)
    graph.get(i).loc = new Point(200+200*(int)Math.cos(i*placementAngle), 200+200*(int)Math.sin(i*placementAngle));
  
  float[] forces = new float[graph.size()-1];
  
  for(int i = 0; i < 20; i++)
  {
    for(int j = 0; j < graph.size()-1; j++)  forces[j] = 0;
      //calculate forces, update positions
  }
}

ArrayList<Point> convexHull()//I think this is needed to compute the circle packing using the algorithm in "a circle packing algorithm"
{//messed up: vertex 1 has to be in the middle, otherwise it stalls
  ArrayList<Point> hull = new ArrayList<Point>();
  hull.add(graph.get(1).loc);
  for(int i = 2; i < graph.size(); i++)
  {
    if(graph.get(i).loc.x < hull.get(0).x)
      hull.set(0, graph.get(i).loc);//last known point in the hull
  }
  do
  {
    Point candidate = graph.get(1).loc;  //not sure what point this should be
    for(int i = 1; i < graph.size(); i++)
    {//check angle formed by last vertex in the hull and every other point
        if(graph.get(i).loc!=hull.get(hull.size()-1))
        {
          if(turn(hull.get(hull.size()-1), candidate, graph.get(i).loc))
            candidate = graph.get(i).loc;
        }
    }
    hull.add(candidate);
    line(hull.get(hull.size()-1).x, hull.get(hull.size()-1).y,hull.get(hull.size()-2).x, hull.get(hull.size()-2).y);
  }while(hull.get(hull.size()-1)!=hull.get(0));
  return hull;
}

boolean turn(Point p, Point q, Point r)
{
  int val = (q.x - p.x)*(r.y - p.y) - (r.x - p.x)*(q.y - p.y);
  //print(val + " ");
  if(val>0)
    return true;
  return false;
}

void loadGraph()//load graph text (nothing drawn yet)
{
  setup();
  BufferedReader reader = createReader("graph.txt");
  try
  {
    int size = Integer.parseInt(reader.readLine());
    graph = new ArrayList<Vertex>(0);
    for(int i = 0; i < size+1; i++)
      graph.add(new Vertex(-1, -1));
      
    int vertA, vertB;
    String line;
    while(true)
    {
      line = reader.readLine();
      if(line==null)  
          break;
      String[] verts = split(line, " "); 
      //System.out.println(line);
      vertA = int(verts[0]);
      vertB = int(verts[1]);
      graph.get(vertA).neighbors.add(vertB);
      graph.get(vertB).neighbors.add(vertA);
    }
  }
  catch(IOException e)  {    }
}

void setRegion(int x, int y, int vertRef)
{//set square 'hitbox' of width 40
  for(int i = x-20; i < x+20; i++)
    for(int j = y-20; j < y+20; j++)
      if(i>-1 && j>-1 && i<1060 && j<550) vertexRegions[i][j] = vertRef;
}

int getRegion(int x, int y)
{
  //get which vertex occupies this part of the screen
  return(vertexRegions[x][y]-1);
}
/**************************************************************************/
/************************** Processing events *****************************/
void setup()
{
  for(int i = 0; i < 1050; i++)
    for(int j = 0; j < 540; j++)
      vertexRegions[i][j] = 1;
  size(1024, 512);
  background(123);
  graph.add(null);
}

boolean connecting = false;  int from;
void draw()
{
  if(mousePressed && mouseButton == LEFT)
    if(getRegion(mouseX, mouseY)==0)//there is no circle at this region
    {
      ellipse(mouseX, mouseY,20,20);
      graph.add(new Vertex(mouseX, mouseY));
      setRegion(mouseX, mouseY, graph.size());
      fill(0);
      text(graph.size()-1,mouseX, mouseY);
      fill(255);
      System.out.println("Drawn " + Integer.toString(graph.size()-1) );
    }
  
  if(mousePressed && mouseButton == RIGHT && getRegion(mouseX, mouseY) != 0 && !connecting)
  {
        from = getRegion(mouseX, mouseY);
        connecting = true;
        System.out.println("Release to connect verticies");
  }
  if(keyPressed)
  {
    switch(key)
    {
      case 's':
        saveGraph();
        break;
      case 'l': 
        loadGraph();
        break;
      case 'h':
        convexHull();
        break;
      case 'd':
        drawGraph();
        break;
    }
  }
}
void mouseReleased()
{
  int to = getRegion(mouseX, mouseY);
  if(connecting && to != 0 && to != from)
  {
      graph.get(from).neighbors.add(to);
      graph.get(to).neighbors.add(from);
      line(graph.get(from).loc.x, graph.get(from).loc.y, graph.get(to).loc.x, graph.get(to).loc.y);
      System.out.println("Connected " + from + " and " + to);
      connecting = false;
  }
}
