/* Classes derived from classes with no virtual functions, whose members C++ may place in the unused tail of the base. */

/* A base which C++ may add to: it has a constructor, and three unused bytes at its end. */
class Base {
public:
  int  i;
  char c;
  Base () : i (1), c ('c')   {}
};

/* A base which C++ does not add to: a plain structure, though it has the same members. */
struct Plain { int i;  char c; };

class Derived : public Base {
public:
  char  d;                   /* In the tail of the base. */
  short s;
  int   e;
  Derived () : d ('d'), s (7), e (9)   {}
  int sum () const           { return i + s + e + (c == 'c' ? 100 : 0) + (d == 'd' ? 1000 : 0); }
};

struct PlainDerived : Plain {
  char d;                    /* After the whole of the base. */
  int  e;
};

/* A further level, and the tail of a derived class. */
class Further : public Derived {
public:
  char f;
  char g;
  Further () : f ('f'), g ('g')   {}
  int sum () const           { return Derived::sum () + (f == 'f' ? 10000 : 0) + (g == 'g' ? 20000 : 0); }
};

/* Bit-fields which begin in the tail of the base. */
class Flagged : public Base {
public:
  unsigned on    : 1;
  unsigned level : 4;
  int      after;
  Flagged () : on (1), level (9), after (33)   {}
  int sum () const           { return i + on + level + after; }
};

/* An ignored member, in the tail of the base. */
class Hiding : public Base {
public:
  char secret;
  char shown;
  int  last;
  Hiding () : secret ('s'), shown ('v'), last (5)   {}
  int sum () const           { return last + (shown == 'w' ? 100 : 0) + (secret == 's' ? 1000 : 0); }
};

/* Two bases. */
class Other {
public:
  short o;
  char  p;
  Other () : o (3), p ('p')  {}
};

class Both : public Base, public Other {
public:
  char  q;
  int   r;
  Both () : q ('q'), r (4)   {}
  int sum () const           { return i + o + r + (p == 'p' ? 100 : 0) + (q == 'q' ? 1000 : 0); }
};

/* Other things which let C++ use the tail of a base: a member which is not public, a destructor, and a copy constructor. */
class Guarded   { public: int i;  Guarded () = default;  int get () const { return k; }  void set (char v) { k = v; }  private: char k; };
class Ended     { public: int i;  char c;  ~Ended () {} };
class Copied    { public: int i;  char c;  Copied () = default;  Copied (const Copied& o) : i (o.i), c (o.c) {} };

struct OnGuarded : Guarded  { char d;  int e; };
struct OnEnded   : Ended    { char d;  int e; };
struct OnCopied  : Copied   { char d;  int e; };

inline int  guarded_d (OnGuarded* o)          { return o->d + o->e; }
inline int  ended_d   (OnEnded*   o)          { return o->d + o->e; }
inline int  copied_d  (OnCopied*  o)          { return o->d + o->e; }

/* A base with no members takes no room, and a base which is itself derived. */
struct Empty    {};
struct OnEmpty  : Empty     { int i;  char c; };
struct OnOnEmpty : OnEmpty  { char d; };

inline int  empty_sum (OnOnEmpty* o)          { return o->i + o->c + o->d; }

inline int  size_of_on_guarded ()             { return (int) sizeof (OnGuarded); }
inline int  size_of_on_ended   ()             { return (int) sizeof (OnEnded); }
inline int  size_of_on_copied  ()             { return (int) sizeof (OnCopied); }
inline int  size_of_on_empty   ()             { return (int) sizeof (OnEmpty); }
inline int  size_of_on_on_empty ()            { return (int) sizeof (OnOnEmpty); }

inline void fill_plain (PlainDerived* p)      { p->i = 1;  p->c = 'c';  p->d = 'd';  p->e = 9; }
inline int  plain_sum  (const PlainDerived& p)   { return p.i + p.e + (p.c == 'c' ? 100 : 0) + (p.d == 'x' ? 1000 : 0); }

inline int  base_value   (Base*  b)           { return b->i; }
inline int  other_value  (Other* o)           { return o->o; }

inline int  size_of_derived ()                { return (int) sizeof (Derived); }
inline int  size_of_plain   ()                { return (int) sizeof (PlainDerived); }
inline int  size_of_further ()                { return (int) sizeof (Further); }
inline int  size_of_flagged ()                { return (int) sizeof (Flagged); }
inline int  size_of_hiding  ()                { return (int) sizeof (Hiding); }
inline int  size_of_both    ()                { return (int) sizeof (Both); }
