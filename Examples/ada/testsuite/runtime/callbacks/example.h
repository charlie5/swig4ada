/* Functions of Ada which C++ calls: through pointer types, structure members and classes. */

struct Sample { int id;  double value; };

class Listener {
public:
  int heard;
  Listener () : heard (0) {}
  virtual ~Listener () {}
  virtual void hear (int what)   { heard += what; }
};

typedef double (*Measure)   (const Sample* sample);
typedef void   (*Visitor)   (int value, void* context);
typedef int    (*Namer)     (const char* name);
typedef Sample (*Maker)     (int id);
typedef void   (*Notifier)  (Listener* listener, int what);
typedef void   (*Updater)   (Sample& sample);

/* A structure which holds functions. */
struct Handlers {
  Measure measure;
  Namer   namer;
};

inline double measure_all (Measure m, Sample* samples, int count)  { double s = 0;  for (int i = 0; i < count; i++) s += m (&samples [i]);  return s; }
inline void   visit_range (Visitor v, int first, int last, void* context)  { for (int i = first; i <= last; i++) v (i, context); }
inline int    name_it     (Namer n)                         { return n ("callback"); }
inline double made_value  (Maker m, int id)                 { Sample s = m (id);  return s.value + s.id; }
inline void   notify      (Notifier n, Listener* l, int w)  { n (l, w); }
inline void   update      (Updater u, Sample& s)            { u (s); }
inline double use_handlers (Handlers* h, Sample* s)         { return h->measure (s) + h->namer ("four"); }

/* C++ functions which are given back as pointers. */
inline double twice_value (const Sample* s)                 { return s->value * 2; }
inline Measure doubler ()                                   { return twice_value; }

/* A class which keeps a function, and calls it later. */
class Button {
public:
  Button () : on_press (0), context (0), presses (0) {}
  void connect (Visitor v, void* c)   { on_press = v;  context = c; }
  void press   ()                     { presses++;  if (on_press) on_press (presses, context); }
  int  presses;
private:
  Visitor on_press;
  void*   context;
};

/* Pointers to class members: one to a member variable, which is its offset, and one to a member function, which is
   two words. Ada takes them from C++ and gives them back. */
struct Pair {
  int first;
  int second;
  int sum () const   { return first + second; }
};

typedef int Pair::* PairMember;

inline PairMember pick      (bool second)                { return second ? &Pair::second : &Pair::first; }
inline int        read      (const Pair* p, PairMember m) { return p->*m; }
inline int        (Pair::*  summer ()) () const           { return &Pair::sum; }
inline int        call_on   (const Pair* p, int (Pair::*f) () const)   { return (p->*f) (); }

/* A virtual function which takes a pointer to a class member, which C++ takes by value: Ada calls it through its
   function of the wrapper, as it cannot through the vtable. */
class Reader {
public:
  virtual ~Reader () {}
  virtual int apply (const Pair* p, PairMember m)   { return (p->*m) * 10; }
};
