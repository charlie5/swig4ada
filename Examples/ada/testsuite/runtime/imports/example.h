/* The module which imports: it uses the types of the other module, and derives from one of its classes. */

#include "base.h"

class Horse : public Animal {
public:
  Colour coat;
  Tag    tag;
  Horse (Colour c) : Animal (4), coat (c), tag (17)   {}
  virtual int speed ()        { return 60; }
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
