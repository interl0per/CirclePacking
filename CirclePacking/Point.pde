class Point
{
  float x, y, z;
  public Point(float _x, float _y, float _z)
  {
    x = _x;
    y = _y;
    z = _z;
  }
  float magnitude()
  {
    return(sqrt(x*x + y*y + z*z));
  }
  void normalize(float target)
  {
    float norm = magnitude();
    x = x*target/norm;
    y = y*target/norm;
    z = z*target/norm;
  }
  Point crossp(Point b)
  {
     return(new Point(y*b.z - z*b.y, z*b.x - x*b.z, x*b.y - y*b.x));
  }
}

