/* Declarations in namespaces, one of them nested. */

namespace geometry {

  const int Dimensions = 2;

  enum Axis { Horizontal, Vertical };

  struct Size { int width; int height; };

  inline int area (Size s)  { return s.width * s.height; }

  class Counter {
  public:
    int total;
    Counter ()         : total (0)  {}
    ~Counter ()        {}
    void add (int n)   { total += n; }
    int  get ()        { return total; }
  };

  class Figure {
  public:
    static int alive;
    Figure ()                   { alive++; }
    virtual ~Figure ()          { alive--; }
    virtual int corners ()      { return 0; }
  };

  namespace solid {

    class Box : public Figure {
    public:
      int side;
      Box (int s) : side (s)    {}
      virtual int corners ()    { return 8; }
      int volume ()             { return side * side * side; }
    };

    inline int twice (int value)   { return value * 2; }
  }

  inline int corners_of (Figure* f)   { return f->corners (); }
  inline int figures_alive ()         { return Figure::alive; }
}
