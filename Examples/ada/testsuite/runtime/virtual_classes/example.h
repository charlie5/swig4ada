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

/* A base class which the interface file ignores. A class which is derived from it has its members and its
   virtual functions all the same. */

class Hidden {
public:
  int    secret;
  double weight;
  Hidden () : secret (41), weight (2.5) {}
  virtual ~Hidden () {}
  virtual int first  ()   { return 1; }
  virtual int second ()   { return 2; }
  int plain ()            { return 99; }
};

class Shown : public Hidden {
public:
  int mine;
  Shown () : mine (7) {}
  virtual int second ()   { return 20; }
  virtual int third  ()   { return 30; }
};

inline int call_second (Shown* s)   { return s->second (); }
inline int call_third  (Shown* s)   { return s->third (); }
inline int secret_of   (Shown* s)   { return s->secret; }
inline int mine_of     (Shown* s)   { return s->mine; }

/* A virtual function which a derived class overloads, beside a 'using' declaration of the one of its base.
   The overload has a place of its own, after those of the destructor, and the function after it follows. */

class Named {
public:
  virtual int label (int i)      { return i; }
  virtual ~Named ()              {}
};

class Renamed : public Named {
public:
  virtual int label (int i)      { return i + 10; }
  virtual ~Renamed ()            {}
};

class Worded : public Renamed {
public:
  virtual ~Worded ()             {}
  using Renamed::label;
  virtual int label (double d)   { return 1000; }
  virtual int tail  ()           { return 5; }
};

class Longer : public Worded {
public:
  virtual int label (int i)      { return i + 20; }
  virtual int label (double d)   { return 2000; }
  virtual int tail  ()           { return 50; }
};

inline Worded* new_longer  ()            { return new Longer; }
inline void    drop_worded (Worded* w)   { delete w; }
inline int     call_label  (Worded* w)   { return w->label (1.5); }
inline int     call_tail   (Worded* w)   { return w->tail (); }

/* Private virtual functions. None is bound, and each has its place among the others: one which overrides
   nothing a place of its own, and one which overrides the place of the function which it overrides. */

typedef int Count;

class Vault {
public:
  virtual ~Vault ()                    {}
  virtual int open  (const Count& c)   { return c + 1; }
  virtual int shown ()                 { return 10; }
  int through_hidden ()                { return hidden (); }
private:
  virtual int hidden ()                { return 20; }
public:
  virtual int last  ()                 { return 30; }
};

class Keeper : public Vault {
public:
  virtual int open  (const int& c)     { return c + 100; }     /* The parameter is written otherwise, and is the same. */
  virtual int last  ()                 { return 300; }
  virtual int more  ()                 { return 400; }
private:
  virtual int shown  ()                { return 1000; }
  virtual int hidden ()                { return 2000; }
};

inline int call_open (Vault*  v)   { return v->open (5); }
inline int call_last (Vault*  v)   { return v->last (); }
inline int call_more (Keeper* k)   { return k->more (); }

/* An abstract class with a pure virtual function of its own and one of its base class. */

class Source {
public:
  virtual ~Source ()        {}
  virtual int produce ()    = 0;
};

class Filter : public Source {
public:
  virtual int refine ()     = 0;
};

inline int call_produce (Source* s)   { return s->produce (); }
inline int call_refine  (Filter* f)   { return f->refine (); }
