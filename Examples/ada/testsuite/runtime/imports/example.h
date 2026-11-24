/* The module which imports: it uses the types of the other module, and derives from one of its classes. */

#include "base.h"

class Horse : public Animal {
public:
  Colour coat;
  Tag    tag;
  Horse (Colour c) : Animal (4), coat (c), tag (17)   {}
  virtual int speed ()        { return 60; }
  virtual int stride (const int& p)   { return p * 2; }     /* The parameter is written otherwise than in the base, and is the same. */
  virtual Horse* self ()      { return this; }              /* The result is of the derived class, which C++ allows. */
  Colour      get_coat ()     { return coat; }
};

/* A plain structure which is derived from one of the imported module. */
struct Vec3 : Vec { double z; };

inline void   fill3      (Vec3* v)           { v->x = 1.0;  v->y = 2.0;  v->z = 3.0; }
inline double sum3       (Vec3* v)           { return v->x + v->y + v->z; }

inline Vec    scaled     (Vec v, double k)   { Vec r;  r.x = v.x * k;  r.y = v.y * k;  return r; }
inline Colour brightest  (Colour a, Colour b)  { return a > b ? a : b; }
inline int    speed_of   (Animal* a)         { return a->speed (); }
inline int    id_of      (Tag t)             { return t.id; }
inline Tag    make_tag   (int id)            { return Tag (id); }

/* A class which is derived from a class of the imported module whose tail it uses: 'd' is at 5, not at 8. */
struct More : Odd {
  char d;
  More () : d ('z')   {}
};

inline int  size_of_more ()          { return (int) sizeof (More); }
inline char d_of         (More* m)   { return m->d; }
inline int  i_of         (More* m)   { return m->i; }

/* A structure with a member of a structure of the imported module, which has bit-fields. */
struct Panel {
  char  kind;
  Flags flags;
  int   after;
};

inline void fill_panel  (Panel* p)   { p->kind = 'p';  p->flags.ready = 1;  p->flags.level = 9;  p->flags.count = 44;  p->after = 55; }
inline int  after_of    (Panel* p)   { return p->after; }

inline int stride_of (Animal* a)   { return a->stride (3); }
inline int legs_of_self (Animal* a)   { return a->self ()->legs; }

/* A class which is derived from one of the imported module with a pointer and an array: 'extra' is at 22. */
struct Wider : Mixed {
  char extra;
  Wider () : extra ('w')   {}
};

inline int  size_of_wider ()           { return (int) sizeof (Wider); }
inline char extra_of      (Wider* w)   { return w->extra; }
inline int  codes_of      (Wider* w)   { return w->codes [0] + w->codes [1] + w->codes [2]; }

/* A class derived from one of the imported module which has no virtual function: the functions which its 'using'
   declarations name are functions of this class, as C++ has them, beside one which it adds. */
class Tally : public Counter {
public:
  using Counter::add;
  using Counter::total;
  int add (double d)   { n += (int) (d * 10);  return n; }
};
