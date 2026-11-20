/* A class which is used through a smart pointer. */

class Engine {
public:
  int power;
  static int alive;

  Engine (int p) : power (p)   { alive++; }
  ~Engine ()                   { alive--; }

  int  get_power ()            { return power; }
  void boost (int amount)      { power += amount; }
  int  scaled (int factor)     { return power * factor; }
};

/* A pointer which owns its engine, and counts the pointers which share it. */
class EnginePtr {
  Engine* engine;
  int*    count;
public:
  EnginePtr (int power)          : engine (new Engine (power)), count (new int (1))  {}
  EnginePtr (const EnginePtr& o) : engine (o.engine), count (o.count)                { ++*count; }
  ~EnginePtr ()                  { if (--*count == 0) { delete engine;  delete count; } }

  Engine* operator-> ()          { return engine; }
  int     use_count ()           { return *count; }
};

inline int       engines_alive ()               { return Engine::alive; }
inline int       power_of      (EnginePtr p)    { return p->get_power (); }     // the pointer is passed by value
inline EnginePtr make_engine   (int power)      { return EnginePtr (power); }   // and returned by value
