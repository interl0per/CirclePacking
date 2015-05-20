import java.util.*;

class Point { int x,y; public Point(int _x,int _y) { x = _x; y = _y; } }

class Vertex
{
  Point loc;
  ArrayList<Integer> neighbors = new ArrayList();
  public Vertex(int x, int y) { loc = new Point(x,y); }
}

ArrayList<Vertex> graph = new ArrayList<Vertex>();
int[][] vertexRegions = new int[1050][540];

void saveGraph()//save to text file
{//format: nverts, followed by an edge list
    PrintWriter output = createWriter("graph.txt"); 
    output.println(graph.size()-1);
    for(int i = 1; i < graph.size(); i++)
      for(int j : graph.get(i).neighbors)
        output.println(i + "  " + j);
    output.flush();
    output.close();
}
void loadGraph()//load from text, in the future this will not need x,y coords
{
  
}

void setRegion(int x, int y, int vertRef)
{//square 'hitbox' of width 40
  for(int i = x-20; i < x+20; i++)
    for(int j = y-20; j < y+20; j++)
      vertexRegions[i][j] = vertRef;
}
int getRegion(int x, int y)
{
  //System.out.println(x + "  " + y + "  " + vertexRegions[x][y]);
  return(vertexRegions[x][y]-1);
}

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
      text(Integer.toString(graph.size()-1),mouseX, mouseY);
      fill(255);
      System.out.println("Drawn " + Integer.toString(graph.size()-1) );
    }
  
  if(mousePressed && mouseButton == RIGHT && (getRegion(mouseX, mouseY)!= 0) && !connecting)
  {
        from = getRegion(mouseX, mouseY);
        connecting = true;
        System.out.println("Connecting verticies... ");
  }
  //else  connecting = false;
  if(keyPressed && key == 'x')
    saveGraph();
}
void mouseReleased()
{
  int to = getRegion(mouseX, mouseY);
  if(connecting && to != 0 && to != from)
  {//no self loops
      graph.get(from).neighbors.add(to);
      graph.get(to).neighbors.add(from);
      line(graph.get(from).loc.x, graph.get(from).loc.y, graph.get(to).loc.x, graph.get(to).loc.y);
      System.out.println("Connected " + from + " " + to);
      connecting = false;
  }
}
