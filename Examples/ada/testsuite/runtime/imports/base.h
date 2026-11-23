/* The module which is imported. */

#ifndef BASE_H
#define BASE_H

enum Colour { Red, Green, Blue };

struct Vec { double x; double y; };

inline double dot (Vec a, Vec b)   { return a.x * b.x + a.y * b.y; }

typedef int Paces;

class Animal {
public:
  int legs;
  Animal (int l) : legs (l)   {}
  virtual ~Animal ()          {}
  virtual int  speed ()       { return legs; }
  virtual int  stride (const Paces& p)   { return p; }
  virtual Animal* self ()     { return this; }
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

/* A class with a member which is a pointer and one which is an array, and a tail of two bytes. */
struct Mixed {
  char  tag;
  int*  link;
  short codes [3];
  Mixed () : tag ('m'), link (0)   { codes [0] = 1;  codes [1] = 2;  codes [2] = 3; }
};

#endif
