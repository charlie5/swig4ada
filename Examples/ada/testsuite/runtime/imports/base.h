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

/* A class whose unused tail a class which is derived from it uses: it is no plain structure, as it has a constructor. */
struct Odd {
  int  i;
  char c;
  Odd () : i (7), c ('a')   {}
};

/* A structure with bit-fields, which another module has as a member. */
struct Flags {
  unsigned ready : 1;
  unsigned level : 4;
  int      count;
};

#endif
