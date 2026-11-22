/* A small class hierarchy with virtual functions. */

class Shape {
public:
  double x, y;
  static int count;

  Shape () : x (0), y (0)  { count++; }
  virtual ~Shape ()        { count--; }

  void           move (double dx, double dy)  { x += dx;  y += dy; }
  virtual double area ()      = 0;
  virtual int    sides ()     { return 0; }
};

class Circle : public Shape {
public:
  double radius;
  Circle (double r) : radius (r) {}
  virtual double area ()      { return 3.0 * radius * radius; }
};

class Square : public Shape {
public:
  double width;
  Square (double w) : width (w) {}
  virtual double area ()      { return width * width; }
  virtual int    sides ()     { return 4; }
};

/* A derived class with members of several kinds, the first of which fits in the unused tail of its base class. */
class Grid : public Shape {
public:
  char     kind;
  int      cells [3];
  unsigned visible : 1;
  unsigned depth   : 4;
  double   scale;

  Grid () : kind ('g'), visible (1), depth (9), scale (1.5), hidden (77)   { cells [0] = 10;  cells [1] = 20;  cells [2] = 30; }
  virtual double area ()   { return 0; }

  int  cell_sum ()         { return cells [0] + cells [1] + cells [2]; }
  int  get_depth ()        { return depth; }
  int  get_hidden ()       { return hidden; }
  char get_kind ()         { return kind; }

protected:
  int      hidden;
};

/* C++ calls the virtual functions of an object which Ada gives it. */
inline double area_of  (Shape* s)  { return s->area ();  }
inline int    sides_of (Shape* s)  { return s->sides (); }

/* C++ makes an object, which Ada uses and then deletes. */
inline Shape* new_square (double w)  { return new Square (w); }
inline void   dispose    (Shape* s)  { delete s; }

inline int    shape_count ()         { return Shape::count; }

/* Virtual functions with a default argument. C++ has one virtual function of each, of all its arguments. */

class Scaler {
public:
  virtual ~Scaler () {}
  virtual int scaled (int a, int factor = 2)   { return a * factor; }
  virtual int after  ()                        { return 7; }
  virtual int offset (int a = 1) = 0;
  virtual int last   ()                        { return 9; }
};

class Tripler : public Scaler {
public:
  virtual int scaled (int a, int factor = 2)   { return a * factor + 1; }
  virtual int after  ()                        { return 70; }
  virtual int offset (int a = 1)               { return a + 100; }
  virtual int last   ()                        { return 90; }
};

inline int call_scaled (Scaler* s)   { return s->scaled (5); }
inline int call_after  (Scaler* s)   { return s->after (); }
inline int call_offset (Scaler* s)   { return s->offset (); }
inline int call_last   (Scaler* s)   { return s->last (); }

/* A virtual function which the interface file ignores, and a virtual destructor which is not public.
   Each has its place in the vtable, though neither is bound. */

class Guarded {
public:
  virtual int first  ()   { return 1; }
  virtual int hidden ()   { return 2; }
  virtual int third  ()   { return 3; }
protected:
  virtual ~Guarded ()     {}
};

class Opened : public Guarded {
public:
  virtual int first  ()   { return 10; }
  virtual int hidden ()   { return 20; }
  virtual int third  ()   { return 30; }
  virtual int fourth ()   { return 40; }
  virtual ~Opened ()      {}
};

inline Guarded* new_opened   ()             { return new Opened; }
inline void     drop_opened  (Guarded* g)   { delete static_cast <Opened*> (g); }
inline int      call_first   (Guarded* g)   { return g->first (); }
inline int      call_third   (Guarded* g)   { return g->third (); }
inline int      call_fourth  (Opened*  o)   { return o->fourth (); }
