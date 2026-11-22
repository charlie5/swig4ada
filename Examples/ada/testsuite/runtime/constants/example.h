/* Constants and enumerations of every kind. */

#define COUNT       12
#define SCALE       2.5
#define NAME        "constants"
#define LETTER      'x'
#define FLAGS       (0x10 | 0x03)
#define SHIFTED     (1 << 6)
#define NEGATIVE    (-7)
#define DERIVED     (COUNT * 2 + 1)
#define QUOTED      "a \"quoted\" word"
#define TABBED      "one\ttwo"
#define BINARY      0b1010
#define PACKED      (('a' << 8) | 'b')
#define LETTER_SUM  ('A' + 2)
#define COMPARED    (COUNT > 10)
#define REMAINDER   (COUNT % 5)
#define IN_ORDER    (10 - 4 + 3)
#define SUM_SHIFTED (1 + 2 << 3)
#define AND_THEN_OR (6 & 3 | 8)
#define TWICE_MINUS (- - 5)
#define OCTAL       0755
#define OCTAL_SUM   (010 + 1)

const int      limit   = 100;
const double   epsilon = 0.25;

enum Level        { Low = -1, Middle, High = 10, Top };
enum              { anonymous_one = 1, anonymous_five = 5 };
enum Flags        { None = 0, Read = 1, Write = 2, Execute = 4, All = Read | Write | Execute };
enum class Mode   { Off, On, Automatic = 7 };
enum Small : unsigned char  { Tiny = 1, Huge = 200 };
enum Octals       { Eighth = 010, Ninth, Sixteenth = 020 };                                           // values which are octal
enum Marks        { Comma = ',', Newline = '\n', Capital = 'A', After, Escaped = '\x43' + 1 };     // values which are characters

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
inline int   mark_number  (Marks m)         { return (int) m; }
inline Marks mark_of      (char c)          { return (Marks) c; }
inline int   c_in_order ()                  { return IN_ORDER; }
inline int   c_sum_shifted ()               { return SUM_SHIFTED; }
inline int   c_and_then_or ()               { return AND_THEN_OR; }
inline int   c_twice_minus ()               { return TWICE_MINUS; }
inline int   c_octal ()                     { return OCTAL; }
inline int   c_octal_sum ()                 { return OCTAL_SUM; }
inline int   octal_mark ()                  { return (int) Eighth; }
inline const char* quoted_text ()           { return QUOTED; }
inline const char* tabbed_text ()           { return TABBED; }
