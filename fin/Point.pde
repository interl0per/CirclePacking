class Point
{
 float x, y, z, w;
 public Point(float _x, float _y, float _z)
 {
   x = _x; y = _y;z = _z;
 }
 float magnitude()
 {
   return(sqrt(x*x + y*y + z*z));
 }
 void normalize(float target)
 {
   float c = target/z;
   x*=c;
   y*=c;
   z = target;
 }
 Point crossp(Point b)
 {
    return(new Point(y*b.z - z*b.y, z*b.x - x*b.z, x*b.y - y*b.x));
 }
 Point negate()
 {
   return new Point(-x, -y, -z);
 }
 Point add(Point b)
 {
   return new Point(x+b.x, y+b.y, z+b.z);
 }
 void rotate(char dir, float theta)
 {
   float cost = cos(theta), sint = sin(theta);
   if(dir=='z')
   {
       float xi =x;
       x = x*cost-y*sint;
       y = xi*sint+y*cost;
   }
   else if(dir=='y')
   {
       float xi= x;
       x = x*cost-z*sint;
       z = xi*sint+z*cost;
   }
   else if(dir=='x')
   {      
       float yi = y;
       y = y*cost-z*sint;
       z = yi*sint+z*cost;
   }
 }
}