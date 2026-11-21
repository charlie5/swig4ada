/* Unions, bit-fields and structures within structures, whose layout Ada must match. */

#include <stddef.h>

union Value {
  int    as_int;
  float  as_float;
  char   as_bytes [4];
};

struct Flags {
  unsigned ready   : 1;
  unsigned mode    : 3;
  unsigned level   : 4;
  int      offset  : 6;          /* Signed. */
  unsigned         : 2;          /* Padding with no name. */
  unsigned wide    : 16;
  int      after;
};

/* Bit-fields which do not simply follow one another. */
enum Shade { Dark, Medium, Light };

struct Cross {
  char     x;
  unsigned a : 28;               /* Does not fit in what is left of its unit, so it begins the next. */
  unsigned b : 10;               /* Nor does this. */
  char     c;                    /* A member which is not a bit-field, among them. */
  unsigned d : 3;
  unsigned   : 0;                /* Ends the unit. */
  unsigned e : 5;
  bool     on    : 1;
  Shade    shade : 2;
  short    s;
};

struct Inner  { char tag;  double amount; };

/* Bit-fields which follow a structure, and in a class with virtual functions. */
struct Labelled {
  Inner    inner;
  unsigned low  : 4;
  unsigned high : 4;
  char     end_mark;
};

class Device {
public:
  unsigned enabled : 1;
  unsigned channel : 7;
  int      rate;
  Device () : enabled (1), channel (100), rate (9600)   {}
  virtual ~Device ()             {}
  virtual int describe ()        { return (int) (enabled * 1000 + channel); }
};

struct Outer {
  char        first;
  Inner       inner;
  short       middle;
  Value       value;
  Inner       pair [2];
  Inner*      link;
  char        last;
};

struct Mixed {
  char        c;
  long long   big;
  bool        flag;
  float       f;
  short       s;
  long double wide;
  void*       any;
  size_t      size;
};

/* Members whose types are nested and have no name, and an anonymous union. */
struct Variant {
  int kind;
  union  { long l;  double d;  char c; }  val;
  struct { short a;  short b; }           pair, pairs [2], *link;
  union  { int i;  float f; };                    /* Its members are members of the structure, in C++. */
  struct { int depth;  union { char tag;  int code; } inner; }  deep;
  int last;
};

inline void   fill_variant (Variant* v)          { v->kind = 1;  v->val.d = 2.5;  v->pair.a = 3;  v->pair.b = 4;  v->pairs [1].b = 5;  v->link = &v->pair;
                                                   v->i = 6;  v->deep.depth = 7;  v->deep.inner.code = 8;  v->last = 9; }
inline double variant_sum  (const Variant& v)    { return v.kind + v.val.d + v.pair.a + v.pair.b + v.pairs [1].b + v.i + v.deep.depth + v.deep.inner.code + v.last; }
inline int    size_of_variant ()                 { return (int) sizeof (Variant); }

inline int    value_int    (Value v)             { return v.as_int; }
inline Value  make_value   (int i)               { Value v;  v.as_int = i;  return v; }
inline void   set_float    (Value* v, float f)   { v->as_float = f; }

inline void   fill_flags   (Flags* f)            { f->ready = 1;  f->mode = 5;  f->level = 9;  f->offset = -7;  f->wide = 40000;  f->after = 123; }
inline int    flags_sum    (const Flags& f)      { return f.ready + f.mode + f.level + f.offset + f.wide + f.after; }

inline void   fill_outer   (Outer* o)            { o->first = 'a';  o->inner.tag = 'b';  o->inner.amount = 1.5;  o->middle = 7;  o->value.as_int = 9;
                                                   o->pair [0].amount = 2.5;  o->pair [1].tag = 'p';  o->pair [1].amount = 3.5;  o->link = &o->inner;  o->last = 'z'; }
inline double outer_sum    (const Outer& o)      { return o.inner.amount + o.middle + o.value.as_int + o.pair [0].amount + o.pair [1].amount + (o.last == 'y' ? 100 : 0); }

inline void   fill_mixed   (Mixed* m)            { m->c = 'm';  m->big = 5000000000LL;  m->flag = true;  m->f = 0.5f;  m->s = -3;  m->wide = 2.25L;  m->any = m;  m->size = 77; }
inline double mixed_sum    (const Mixed& m)      { return (double) m.big + m.f + m.s + (double) m.wide + (double) m.size + (m.flag ? 1 : 0); }

inline void   fill_cross   (Cross* c)            { c->x = 'x';  c->a = 0xABCDEF1;  c->b = 1000;  c->c = 'c';  c->d = 5;  c->e = 21;  c->on = true;  c->shade = Light;  c->s = -12; }
inline long   cross_sum    (const Cross& c)      { return (long) c.a + c.b + c.d + c.e + (c.on ? 1 : 0) + (int) c.shade + c.s + (c.c == 'k' ? 1000 : 0); }

inline void   fill_labelled  (Labelled* t)           { t->inner.amount = 4.5;  t->low = 9;  t->high = 6;  t->end_mark = 'e'; }
inline int    labelled_sum   (const Labelled& t)     { return (int) t.inner.amount + t.low + t.high + (t.end_mark == 'f' ? 100 : 0); }

inline int    describe     (Device* d)           { return d->describe () + d->rate; }

inline int    size_of_cross  ()                  { return (int) sizeof (Cross); }
inline int    size_of_labelled ()                  { return (int) sizeof (Labelled); }
inline int    size_of_device ()                  { return (int) sizeof (Device); }
inline int    size_of_flags ()                   { return (int) sizeof (Flags); }
inline int    size_of_outer ()                   { return (int) sizeof (Outer); }
inline int    size_of_mixed ()                   { return (int) sizeof (Mixed); }
inline int    size_of_value ()                   { return (int) sizeof (Value); }
