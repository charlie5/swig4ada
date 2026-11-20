/* The module which is imported. */

#ifndef BASE_H
#define BASE_H

enum Colour { Red, Green, Blue };

struct Vec { double x; double y; };

inline double dot (Vec a, Vec b)   { return a.x * b.x + a.y * b.y; }

class Animal {
public:
  int legs;
  Animal (int l) : legs (l)   {}
  virtual ~Animal ()          {}
  virtual int  speed ()       { return legs; }
  int          get_legs ()    { return legs; }
};

class Tag {
public:
  int id;
  Tag ()       : id (0)  {}
  Tag (int i)  : id (i)  {}
  ~Tag ()      {}
};

#endif
