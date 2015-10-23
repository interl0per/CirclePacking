boolean turn(Point p, Point q, Point r)
{//returns true if no turn/right turn is formed by p q r
 return((q.x - p.x)*(r.y - p.y) - (r.x - p.x)*(q.y - p.y)>=0);
}

boolean inFace(HalfEdge h, Point d)
{//is d in the face defined by h?
 HalfEdge start = h;
 HalfEdge temp = h.next;
 boolean first = true;
 while(first || h!=start)
 {
   first = false;
   if(turn(h.v.loc, temp.v.loc, d))
     return false;
   h = h.next;
   temp = temp.next;
 }
 return true;
}

boolean inOrthocircle(Vertex a, Vertex b, Vertex c, Vertex d)//is d in the circumcircle of a,b,c?
{//a,b,c should be in ccw order from following the half edges. 
 float adx = a.loc.x - d.loc.x;
 float ady = a.loc.y - d.loc.y;
 float bdx = b.loc.x - d.loc.x;
 float bdy = b.loc.y - d.loc.y;
 float cdx = c.loc.x - d.loc.x;
 float cdy = c.loc.y - d.loc.y;

 float abdet = adx * bdy - bdx * ady;
 float bcdet = bdx * cdy - cdx * bdy;
 float cadet = cdx * ady - adx * cdy;
 float alift = adx * adx + ady * ady - d.weight*d.weight - a.weight*a.weight;
 float blift = bdx * bdx + bdy * bdy - d.weight*d.weight - b.weight*b.weight;
 float clift = cdx * cdx + cdy * cdy - d.weight*d.weight - c.weight*c.weight;
 return alift * bcdet + blift * cadet + clift * abdet < 0;
}

void drawCircumcircle(Point a, Point b, Point c)
{
 float mr = (b.y-a.y) / (b.x-a.x);
 float mt = (c.y-b.y) / (c.x-b.x);
 float x = (mr*mt*(c.y-a.y) + mr*(b.x+c.x) - mt*(a.x+b.x)) / (2*(mr-mt));
 float y = (a.y+b.y)/2 - (x - (a.x+b.x)/2) / mr;
 float r = sqrt(((b.x-x)*(b.x-x) +  (b.y-y)*(b.y-y)));
 //stroke(255, 0, 0);
 ellipse(x, y,2*r, 2*r);
 //stroke(0);
}
//Point calcIncircle(Point a, Point b, Point c)
//{
//  //returns a point (the incircle pos) whos weight is the radius
//}
Point project(Point init)
{
  float x = init.x/orthoSphereR, y = init.y/orthoSphereR;
  float denom = (x*x + y*y +1);
  return new Point(orthoSphereR*2*x/denom, orthoSphereR*2*y/denom, orthoSphereR*(x*x + y*y -1)/denom);
}

Point project2(Point init)
{
  return new Point(init.x*orthoSphereR/(orthoSphereR-init.z), init.y*orthoSphereR/(orthoSphereR-init.z), 0);
}
float det(float[][] m)
{
  return m[0][0]*m[1][1] - m[0][1]*m[1][0];
}