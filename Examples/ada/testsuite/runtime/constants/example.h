/* Constants and enumerations of every kind. */

#define COUNT       12
#define SCALE       2.5
#define NAME        "constants"
#define LETTER      'x'
#define FLAGS       (0x10 | 0x03)
#define SHIFTED     (1 << 6)
#define NEGATIVE    (-7)
#define DERIVED     (COUNT * 2 + 1)

const int      limit   = 100;
const double   epsilon = 0.25;

enum Level        { Low = -1, Middle, High = 10, Top };
enum              { anonymous_one = 1, anonymous_five = 5 };
enum Flags        { None = 0, Read = 1, Write = 2, Execute = 4, All = Read | Write | Execute };
enum class Mode   { Off, On, Automatic = 7 };
enum Small : unsigned char  { Tiny = 1, Huge = 200 };

struct Limits {
  enum Kind { Soft, Hard = 3 };
  static const int maximum = 64;
  static int    clamp (int value)        { return value > maximum ? maximum : value; }
  static Kind   kind_of (int value)      { return value > maximum ? Hard : Soft; }
};

/* An enumeration of one byte, as a member. */
struct Packet { Small first;  Small second;  int length; };

inline int   packet_sum   (Packet* p)       { return (int) p->first + (int) p->second + p->length; }
inline void  packet_fill  (Packet* p)       { p->first = Huge;  p->second = Tiny;  p->length = 5; }

inline int   level_number (Level l)         { return (int) l; }
inline Level raise_level  (Level l)         { return l == Low ? Middle : l == Middle ? High : Top; }
inline bool  can          (Flags f, Flags wanted)   { return (f & wanted) == wanted; }
inline int   mode_number  (Mode m)          { return (int) m; }
inline Mode  next_mode    (Mode m)          { return m == Mode::Off ? Mode::On : Mode::Automatic; }
inline int   small_number (Small s)         { return (int) s; }
inline void  set_level    (Level* l, Level to)   { *l = to; }
inline void  top_level    (Level& l)        { l = Top; }
inline int   kind_number  (Limits::Kind k)  { return (int) k; }
