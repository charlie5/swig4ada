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
