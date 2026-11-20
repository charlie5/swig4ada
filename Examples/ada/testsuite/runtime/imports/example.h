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

inline Vec    scaled     (Vec v, double k)   { Vec r;  r.x = v.x * k;  r.y = v.y * k;  return r; }
inline Colour brightest  (Colour a, Colour b)  { return a > b ? a : b; }
inline int    speed_of   (Animal* a)         { return a->speed (); }
inline int    id_of      (Tag t)             { return t.id; }
inline Tag    make_tag   (int id)            { return Tag (id); }
