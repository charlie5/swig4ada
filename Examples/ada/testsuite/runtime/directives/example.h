/* A library whose binding the interface file changes with directives. */

struct Reading { int raw;  int hidden_detail;  double value; };

class Sensor {
public:
  int    id;
  int    internal_state;
  Sensor (int i) : id (i), internal_state (0), last (0)  {}

  int    read         ()                 { return last = id * 10; }
  int    read_raw     (int scale)        { return id * scale; }
  void   secret       ()                 { internal_state = 99; }
  int    begin        ()                 { return 1; }            /* A reserved word of Ada. */
  int    type         ()                 { return 2; }            /* Another. */
  int    get_Last     ()                 { return last; }
  bool   operator<    (const Sensor& o) const   { return id < o.id; }
  int    operator[]   (int i) const      { return id + i; }
  Sensor operator-    () const           { return Sensor (-id); }

private:
  int    last;
};

inline int   old_name       (int a)                      { return a + 1; }
inline int   not_wanted     (int a)                      { return a; }
inline void  output_pair    (int in, int* sum, int* product)   { *sum = in + in;  *product = in * in; }
inline int   sum_bytes      (const unsigned char* data, int count)   { int s = 0;  for (int i = 0; i < count; i++) s += data [i];  return s; }
inline int   end            (int a)                      { return a * 2; }       /* A reserved word of Ada. */
inline int   _leading       (int a)                      { return a * 3; }       /* Not an identifier of Ada. */
inline int   trailing_      (int a)                      { return a * 4; }
inline int   double__under  (int a)                      { return a * 5; }
inline int   checked        (int a)                      { return a; }

#define      HIDDEN_LIMIT   5
#define      SHOWN_LIMIT    6
