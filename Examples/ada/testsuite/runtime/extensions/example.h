/* Classes which the interface file extends, and a function with an '%exception'. */

#include <stdexcept>

struct Vec {
  double x, y;
};

class Stack {
  int  items [8];
  int  count;
public:
  Stack () : count (0)   {}
  void push (int v)      { items [count++] = v; }
  int  pop ()            { return items [--count]; }
  int  size () const     { return count; }
};

namespace shapes {
  class Circle {
  public:
    double radius;
    Circle (double r) : radius (r)  {}
  };
}

/* A class which manages a resource through its copy constructor and destructor alone. */
class Token {
public:
  int* value;
  Token ()               : value (new int (0))          {}
  Token (int v)          : value (new int (v))          {}
  Token (const Token& o) : value (new int (*o.value))   {}
  ~Token ()              { delete value; }
  int get ()             { return *value; }
};

inline Token checked_token (int v)
{
  if (v < 0)  throw std::runtime_error ("a token cannot be negative");
  return Token (v);
}
