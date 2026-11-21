/* Declarations which are nested in a class. */

class Engine {
public:
  enum State { Off, Idle = 3, Running };

  typedef int   Speed;
  typedef State Mode;

  static const int Cylinders = 4;

  /* The structure has no member of the nested enumeration type: the package of the structure would then need that
     of the class, which needs that of the structure for 'read', and two Ada specifications cannot need each other. */
  struct Reading {
    Speed speed;
    int   state_number;
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

  Engine () : state (Off), speed (0)   {}

  void    start ()                { state = Idle; }
  void    run (Speed s)           { state = Running;  speed = s; }
  Mode    mode ()                 { return state; }
  Reading read ()                 { Reading r;  r.speed = speed;  r.state_number = (int) state;  return r; }
  Gauge*  get_gauge ()            { return &gauge; }
};

inline int  as_number (Engine::State s)     { return (int) s; }
inline int  gauge_value (Engine::Gauge* g)  { return g->value; }
