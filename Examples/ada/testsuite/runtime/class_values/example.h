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
