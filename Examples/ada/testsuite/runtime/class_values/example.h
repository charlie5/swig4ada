#include <string>
class Buffer {
public:
  int*        items;
  int         count;
  std::string label;
  Buffer ()                : items (new int [1]), count (1), label ("default") { items [0] = 0; }
  Buffer (int n)           : items (new int [n]), count (n), label ("sized")   { for (int i = 0; i < n; i++) items [i] = i; }
  Buffer (const Buffer& o) : items (new int [o.count]), count (o.count), label (o.label + " (copy)") { for (int i = 0; i < count; i++) items [i] = o.items [i]; }
  ~Buffer ()               { delete [] items; }
  Buffer& operator= (const Buffer& o) { if (this != &o) { delete [] items; items = new int [o.count]; count = o.count; label = o.label + " (assigned)"; for (int i = 0; i < count; i++) items [i] = o.items [i]; } return *this; }
  int    sum ()            { int s = 0; for (int i = 0; i < count; i++) s += items [i]; return s; }
  Buffer doubled ()        { Buffer r (count * 2); r.label = "doubled"; return r; }      // a member which returns its class by value
};
inline Buffer make_buffer (int n)        { Buffer b (n); b.label = "made"; return b; }   // a function which returns the class by value
inline int    total       (Buffer b)     { return b.sum (); }                             // a function which takes the class by value


/* A class which manages a resource through its copy constructor and destructor alone. It declares no
   assignment, so that which the compiler generates would share the resource between two objects. */
class Token {
public:
  int* value;
  Token ()               : value (new int (0))          {}
  Token (int v)          : value (new int (v))          {}
  Token (const Token& o) : value (new int (*o.value))   {}
  ~Token ()              { delete value; }
  int   get ()           { return *value; }
  Token next ()          { return Token (*value + 1); }     // a member which returns its class by value
};
inline Token make_token (int v)   { return Token (v); }     // a function which returns the class by value
