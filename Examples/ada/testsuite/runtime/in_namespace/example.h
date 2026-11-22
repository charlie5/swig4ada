/* A binding whose packages are within another package (the '-namespace' option). */

struct Flags { unsigned a : 3;  unsigned b : 5;  int c; };                // needs a representation clause

struct Base { int i;  char c;  Base () : i (1), c ('x') {} };
struct Derived : Base { char d;  Derived () : d ('y') {} };               // its member lies in the tail of its base

enum Colour { Red, Green = 5 };

class Shape {
public:
  int sides;
  Shape (int s) : sides (s)   {}
  virtual ~Shape ()           {}
  virtual int corners ()      { return sides; }
};

inline int    flags_sum (Flags* f)       { return (int) f->a + (int) f->b + f->c; }
inline void   flags_set (Flags* f)       { f->a = 5;  f->b = 17;  f->c = 100; }
inline char   derived_d (Derived* d)     { return d->d; }
inline int    base_i    (Derived* d)     { return d->i; }
inline Colour next      (Colour c)       { return c == Red ? Green : Red; }
inline int    corners_of (Shape* s)      { return s->corners (); }
