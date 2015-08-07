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
    float c = target/z;
    x*=c;
    y*=c;
    z = target;
  }
  Point crossp(Point b)
  {
     return(new Point(y*b.z - z*b.y, z*b.x - x*b.z, x*b.y - y*b.x));
  }
}

