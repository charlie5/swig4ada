/* A class which is derived from an instance of a template, and functions which use that instance. */

#include "example.h"

class Counter : public Source<int> {
public:
  int value;
  Counter () : value (0)        {}
  virtual int next ()           { return ++value; }
};

inline int drain  (Source<int>* s, int count)   { int total = 0;  for (int i = 0; i < count; i++) total += s->next ();  return total; }
inline int sources_alive ()                     { return Source<int>::alive; }
