/* Classes with no virtual function which inherit a base class virtually: C++ lays each virtual base out after all
   of the rest of the object, once, and reaches it through a pointer to a table which the object holds. */

struct V  { int  v;   V () : v (10)  {} };
struct W  : virtual V { int  w;   W () : w (20)  {} };          /* 'V' in the tail of 'W'. */
struct X  : virtual V { char x;   X () : x ('x') {} };
struct Y  : W, X      { int  y;   Y () : y (40)  {} };          /* A diamond: one 'V', which 'W' and 'X' share. */
struct Z  : W         { short z;  Z () : z (5)   {} };          /* The part of 'W' which is not 'V', and then 'V'. */
struct U  : virtual W { int  u;   U () : u (6)   {} };          /* 'W', and then 'V', after 'u'. */

inline int size_of_w () { return sizeof (W); }
inline int size_of_y () { return sizeof (Y); }
inline int size_of_z () { return sizeof (Z); }
inline int size_of_u () { return sizeof (U); }

inline int  w_of        (W* p)          { return p->w; }
inline int  v_of        (W* p)          { return p->v; }
inline int  v_through_x (Y* p)          { return static_cast<X*> (p)->v; }
inline int  v_through_w (Y* p)          { return static_cast<W*> (p)->v; }
inline void set_v       (V* p, int n)   { p->v = n; }
inline int  w_of_u      (U* p)          { return p->w; }
inline int  v_of_u      (U* p)          { return p->v; }
inline int  z_of        (Z* p)          { return p->z; }

/* A virtual base which has nothing but its pointer to the table (one which is 'nearly empty'): the class which
   inherits it virtually, with no other base, shares that pointer with it at the start of the object. */
struct N  : virtual V {};
struct M  : virtual N { int m;  M () : m (7) {} };

inline int size_of_m () { return sizeof (M); }
inline int m_of      (M* p) { return p->m; }
inline int v_of_m    (M* p) { return p->v; }

/* Classes with virtual functions which inherit a base class virtually. One with no other base: its tagged type has
   no parent, and its virtual base is last, as for a class with no virtual function. Its own table lists its own
   virtual functions, one of which overrides that of the virtual base. */
struct Shape {
  int sides;
  Shape () : sides (3) {}
  virtual ~Shape () {}
  virtual int area () { return 1; }
};
struct Square : virtual Shape {
  int side;
  Square () : side (4) { sides = 4; }
  virtual int area ()   { return side * side; }      /* Overrides that of the virtual base. */
  virtual int corners () { return 4; }
};

/* And one whose virtual base has nothing but its pointer: that base is its parent, and shares the pointer. */
struct Named { virtual ~Named () {}  virtual int name () { return 7; } };
struct Label : virtual Named { int label;  Label () : label (8) {}  virtual int text () { return 9; } };

inline int sides_of       (Square* s)   { return s->sides; }      /* Through the offset of the virtual base, in the table. */
inline int area_of        (Square* s)   { return s->area (); }
inline int area_of_shape  (Shape* s)    { return s->area (); }
inline int corners_of     (Square* s)   { return s->corners (); }
inline int name_of        (Label* l)    { return l->name (); }
inline int text_of        (Label* l)    { return l->text (); }

/* A class with virtual functions whose parent is a base which it does not inherit virtually, and which has a
   virtual base too. GNAT lays its record out, as a type extension, so the virtual base is storage, which is no
   smaller than C++ takes for it, and is reached by 'as_Port'. */
struct Port  { int port;   Port  () : port (10)  {}  virtual ~Port  () {}  virtual int open  () { return 1; } };
struct Plug  { int plug;   Plug  () : plug (20)  {}  virtual ~Plug  () {}  virtual int fit   () { return 2; } };
struct Cable : Plug, virtual Port {
  int length;
  Cable () : length (30) {}
  virtual int open   () { return 11; }      /* Overrides that of the virtual base, and has a place of its own. */
  virtual int fit    () { return 22; }      /* Overrides that of the parent. */
  virtual int signal () { return 33; }
};

inline int port_of   (Cable* c)  { return c->port; }
inline int length_of (Cable* c)  { return c->length; }
inline int open_of   (Cable* c)  { return c->open (); }
inline int fit_of    (Plug*  p)  { return p->fit (); }
inline int open_port (Port*  p)  { return p->open (); }
