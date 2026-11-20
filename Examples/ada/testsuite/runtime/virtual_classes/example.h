/* A small class hierarchy with virtual functions. */

class Shape {
public:
  double x, y;
  static int count;

  Shape () : x (0), y (0)  { count++; }
  virtual ~Shape ()        { count--; }

  void           move (double dx, double dy)  { x += dx;  y += dy; }
  virtual double area ()      = 0;
  virtual int    sides ()     { return 0; }
};

class Circle : public Shape {
public:
  double radius;
  Circle (double r) : radius (r) {}
  virtual double area ()      { return 3.0 * radius * radius; }
};

class Square : public Shape {
public:
  double width;
  Square (double w) : width (w) {}
  virtual double area ()      { return width * width; }
  virtual int    sides ()     { return 4; }
};

/* C++ calls the virtual functions of an object which Ada gives it. */
inline double area_of  (Shape* s)  { return s->area ();  }
inline int    sides_of (Shape* s)  { return s->sides (); }

/* C++ makes an object, which Ada uses and then deletes. */
inline Shape* new_square (double w)  { return new Square (w); }
inline void   dispose    (Shape* s)  { delete s; }

inline int    shape_count ()         { return Shape::count; }
