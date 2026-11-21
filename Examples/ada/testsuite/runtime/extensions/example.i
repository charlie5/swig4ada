/* Members which the interface file adds to a class with '%extend', and a function with an '%exception'. */

%module extensions

%include <std_except.i>

%{
#include "example.h"
%}

%exception checked_token {
  try {
    $action
  } catch (std::runtime_error& e) {
    SWIG_exception (SWIG_RuntimeError, e.what ());
  }
}

%include "example.h"

%extend Vec {
  Vec (double x, double y)       { Vec* v = new Vec;  v->x = x;  v->y = y;  return v; }
  double dot (const Vec& other)  { return self->x * other.x + self->y * other.y; }
  Vec    scaled (double k)       { Vec r;  r.x = self->x * k;  r.y = self->y * k;  return r; }
  static Vec unit_x ()           { Vec r;  r.x = 1;  r.y = 0;  return r; }
}

%extend Stack {
  int  top ()                    { int v = self->pop ();  self->push (v);  return v; }
  bool is_empty ()               { return self->size () == 0; }
  void push_twice (int v)        { self->push (v);  self->push (v); }
}

%extend shapes::Circle {
  double area ()                 { return 3.0 * self->radius * self->radius; }
  double area (double scale)     { return 3.0 * self->radius * self->radius * scale; }
}
