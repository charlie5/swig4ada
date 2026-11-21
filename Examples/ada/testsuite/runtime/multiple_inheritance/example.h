/* Classes with more than one base class. */

struct Position {                 // No virtual function.
  int x, y;
  Position () : x (1), y (2)   {}
  int  manhattan ()            { return x + y; }
};

struct Named {                    // No virtual function.
  int name_code;
  Named () : name_code (77)    {}
  int  code ()                 { return name_code; }
};

class Drawable {                  // Virtual.
public:
  int layer;
  Drawable () : layer (3)      {}
  virtual ~Drawable ()         {}
  virtual int draw ()          { return 10; }
};

class Clickable {                 // Virtual too.
public:
  int clicks;
  Clickable () : clicks (0)    {}
  virtual ~Clickable ()        {}
  virtual int click ()         { return ++clicks; }
};

/* Two bases with no virtual function. */
struct Label : Position, Named {
  int size;
  Label () : size (12)         {}
  int total ()                 { return x + y + name_code + size; }
};

/* A virtual base and one which is not. */
class Sprite : public Drawable, public Position {
public:
  int frame;
  Sprite () : frame (5)        {}
  virtual int draw ()          { return 20 + frame; }
  int  where ()                { return x * 10 + y; }
};

/* Two virtual bases: only the first is kept in the Ada binding. */
class Button : public Drawable, public Clickable {
public:
  int id;
  Button () : id (9)           {}
  virtual int draw ()          { return 30; }
  virtual int click ()         { return clicks += 2; }
  int  get_id ()               { return id; }
};

inline int draw_it  (Drawable*  d)   { return d->draw ();  }
inline int click_it (Clickable* c)   { return c->click (); }
inline int label_code (Named* n)     { return n->code (); }
