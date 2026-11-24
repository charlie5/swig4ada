/* Directors: virtual functions which Ada cannot call through the vtable (they return, by value, a class which
   C++ constructs, or take a plain structure by value), overridden in Ada through the director of their class,
   and called by C++. */

#include <string>

struct Point { int x; int y; };                     /* A plain structure. */

class Label                                         /* A class which C++ constructs. */
{
public:
  Label ()                       : text ("none") {}
  Label (const std::string& t)   : text (t)      {}
  Label (const Label& other)     : text (other.text) {}
  ~Label ()                                      {}
  std::string text;
};

class Fixed                                         /* A class which has no constructor that takes nothing. */
{
public:
  Fixed (int v) : value (v) {}
  ~Fixed ()                 {}
  int value;
};

class Speaker
{
public:
  Speaker ()        : volume (1) {}
  Speaker (int v)   : volume (v) {}
  virtual ~Speaker () {}

  virtual int          level () const                  { return volume; }
  virtual std::string  speak (const std::string& word) { return word + "!"; }
  virtual std::string  speak (int times)               { return std::string (times, 'a'); }
  virtual Label        label () const                  { return Label ("speaker"); }
  virtual int          sum   (Point p)                 { return p.x + p.y; }
  virtual Fixed        fixed ()                        { return Fixed (7); }

  std::string reveal () { return secret (); }
  int volume;

protected:
  virtual std::string  secret ()                       { return "hidden"; }
};

inline std::string say      (Speaker* s, const std::string& w) { return s->speak (w); }
inline std::string say_n    (Speaker* s, int n)                { return s->speak (n); }
inline std::string label_of (Speaker* s)                       { return s->label ().text; }
inline int         sum_of   (Speaker* s, int x, int y)         { Point p = {x, y};  return s->sum (p); }
inline int         level_of (Speaker* s)                       { return s->level (); }
inline int         fixed_of (Speaker* s)                       { return s->fixed ().value; }

class Voice                                         /* An abstract class. */
{
public:
  virtual ~Voice () {}
  virtual std::string name  () const = 0;
  virtual int         pitch () const = 0;
};

inline std::string introduce (Voice* v) { return "I am " + v->name (); }
inline int         pitch_of  (Voice* v) { return v->pitch (); }

/* A class derived from one with a director, which has a director of its own: its director lets Ada override the
   functions which it inherits, as well as its own. */
class Talker : public Speaker
{
public:
  Talker () : Speaker (3) {}
  virtual std::string accent () { return "plain"; }
};

inline std::string accent_of (Talker* t) { return t->accent (); }
