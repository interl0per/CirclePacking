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
 float adx = a.x - d.x;
 float ady = a.y - d.y;
 float bdx = b.x - d.x;
 float bdy = b.y - d.y;
 float cdx = c.x - d.x;
 float cdy = c.y - d.y;

 float abdet = adx * bdy - bdx * ady;
 float bcdet = bdx * cdy - cdx * bdy;
 float cadet = cdx * ady - adx * cdy;
 float alift = adx * adx + ady * ady - d.r*d.r - a.r*a.r;
 float blift = bdx * bdx + bdy * bdy - d.r*d.r - b.r*b.r;
 float clift = cdx * cdx + cdy * cdy - d.r*d.r - c.r*c.r;
 return alift * bcdet + blift * cadet + clift * abdet < 0;
}

void drawCircumcircle2D(Vertex a, Vertex b, Vertex c)
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
void drawCircumcircle3D(Vertex a, Vertex b, Vertex c)
{ 
   Vertex ct = c;
   a = a.add(c.negate());
   b = b.add(c.negate());
   c = new Vertex(0,0,0,0);
   //b.drw();
   
   float rx,ry,rz;
   ry = atan2(a.z, a.x);
   //rotate a so it's z is 0:
   a.rotate('y', ry);
   b.rotate('y', ry);
   //now need to rotate so a's y is 0:
   rz = -atan2(a.y, a.x);
   a.rotate('z', rz);
   b.rotate('z', rz);
   //now rotate so b's z is 0:
   rx = PI/2 - atan2(b.y, -b.z);
   a.rotate('x', rx);
   b.rotate('x', rx);

   pushMatrix();
   
   translate(ct.x, ct.y, ct.z);
   rotateY(-ry);
   rotateZ(-rz);
   rotateX(-rx);
   drawCircumcircle2D(a,b,c);
   
   popMatrix();
}

Vertex stereoProj(Vertex init)
{
  float x = init.x/orthoSphereR, y = init.y/orthoSphereR;
  float denom = (x*x + y*y +1);
  return new Vertex(orthoSphereR*2*x/denom, orthoSphereR*2*y/denom, orthoSphereR*(x*x + y*y -1)/denom, 0);
}

Vertex stereoProjI(Vertex init)
{
  return new Vertex(init.x*orthoSphereR/(orthoSphereR-init.z), init.y*orthoSphereR/(orthoSphereR-init.z), 0, 0);
}

Vertex grad(HalfEdge f)
{
  f.v.updateZ();
  f.next.v.updateZ();
  f.next.next.v.updateZ();
  
  Vertex p = f.v, q = f.next.v, r = f.next.next.v;
  
  Vertex pq = q.add(p.negate());
  Vertex pr = r.add(p.negate());
  return pq.cross(pr);
}

float distv(Vertex p, Vertex q)
{
  float dx = p.x - q.x;
  float dy = p.y - q.y;
  float dz = p.z - q.z;

  return sqrt(dx*dx + dy*dy + dz*dz);
}