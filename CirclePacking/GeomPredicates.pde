boolean turn(Vertex p, Vertex q, Vertex r)
{//returns true if no turn/right turn is formed by p q r
  return((q.x - p.x)*(r.y - p.y) - (r.x - p.x)*(q.y - p.y)>=0);
}

boolean inFace(HalfEdge h, Vertex d)
{//is d in the face defined by h?
  HalfEdge start = h;
  HalfEdge temp = h.next;
  boolean first = true;
  while(first || h!=start)
  {
    first = false;
    if(turn(h.v, temp.v, d))
      return false;
    h = h.next;
    temp = temp.next;
  }
  return true;
}

boolean inOrthocircle(Vertex a, Vertex b, Vertex c, Vertex d)//is d in the circumcircle of a,b,c?
{//a,b,c should be in ccw order from following the half edges. 
//from http://algs4.cs.princeton.edu/91primitives/
  float adx = a.x - d.x;
  float ady = a.y - d.y;
  float bdx = b.x - d.x;
  float bdy = b.y - d.y;
  float cdx = c.x - d.x;
  float cdy = c.y - d.y;

  float abdet = adx * bdy - bdx * ady;
  float bcdet = bdx * cdy - cdx * bdy;
  float cadet = cdx * ady - adx * cdy;
  float alift = adx * adx + ady * ady - d.weight*d.weight - a.weight*a.weight;
  float blift = bdx * bdx + bdy * bdy - d.weight*d.weight - b.weight*b.weight;
  float clift = cdx * cdx + cdy * cdy - d.weight*d.weight - c.weight*c.weight;
  return alift * bcdet + blift * cadet + clift * abdet < 0;
}

