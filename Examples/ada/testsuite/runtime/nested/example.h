/* Declarations which are nested in a class. */

class Engine {
public:
  enum State { Off, Idle = 3, Running };

  typedef int   Speed;
  typedef State Mode;

  static const int Cylinders = 4;

  /* The structure needs the package of the class, for the enumeration, and the class that of the structure, for 'read'. */
  struct Reading {
    Speed speed;
    State state;
  };

  class Gauge {
  public:
    int value;
    Gauge () : value (50)         {}
    int doubled ()                { return value * 2; }
  };

  State   state;
  Speed   speed;
  Gauge   gauge;
  Reading last;                   /* The class holds the structure, which holds an enumeration of the class. */
  union { int raw;  float scaled; }  sensor;      /* A member whose type has no name, where nested classes are flattened. */
  struct { short low;  short high; } range_of;

  Engine () : state (Off), speed (0)   { sensor.raw = 77;  range_of.low = -5;  range_of.high = 5; }

  int     span ()                 { return range_of.high - range_of.low + sensor.raw; }

  void    start ()                { state = Idle; }
  void    run (Speed s)           { state = Running;  speed = s; }
  Mode    mode ()                 { return state; }
  Reading read ()                 { Reading r;  r.speed = speed;  r.state = state;  last = r;  return r; }
  Gauge*  get_gauge ()            { return &gauge; }
};

inline int  as_number (Engine::State s)     { return (int) s; }
inline int  reading_total (Engine::Reading r)  { return r.speed + (int) r.state; }
inline int  gauge_value (Engine::Gauge* g)  { return g->value; }

/* A second class has a nested class of the same name as that of the first, which cannot be the same package. */

class Pump {
public:
  struct Gauge { double pressure;  Gauge () : pressure (2.5) {} };

  Gauge gauge;
  Gauge read_gauge ()            { return gauge; }
};

inline double pressure_of (Pump::Gauge* g)   { return g->pressure; }

/* Nested declarations which are private, and are the types of members: an enumeration, and a structure which a member
   of an anonymous union names by its plain name. The core binds neither, and the records lost those members. */

class Lexeme {
public:
  Lexeme () : kind (word), length (3) {}
  int  size () const    { return length; }
  int  kind_of () const { return (int) kind; }
  void make_number ()   { kind = number; }
private:
  enum Kind { word, number, symbol };
  Kind kind;
  int  length;
};

class Holder {
public:
  Holder () : count (9) { storage.policy = 4;  storage.length = 6; }
  int policy () const { return (int) storage.policy; }
  int count_of () const { return count; }
private:
  struct Storage { unsigned policy; unsigned length; };
  union {
    Storage  storage;
    unsigned index;
  };
  int count;
};

inline int size_of_lexeme ()   { return sizeof (Lexeme); }
inline int size_of_holder ()   { return sizeof (Holder); }
