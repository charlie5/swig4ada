/* Arrays and pointers, as parameters, results, members and variables. */

struct Vec3  { double v [3]; };
struct Grid  { int cells [2][3];  char label [8];  Vec3 corners [2]; };

inline int    sum3        (int values [3])                  { return values [0] + values [1] + values [2]; }
inline double total       (const double* values, int count) { double s = 0;  for (int i = 0; i < count; i++) s += values [i];  return s; }
inline void   scale       (double* values, int count, double by)   { for (int i = 0; i < count; i++) values [i] *= by; }
inline double length2     (Vec3 a)                          { return a.v [0] * a.v [0] + a.v [1] * a.v [1] + a.v [2] * a.v [2]; }
inline Vec3   unit        (int axis)                        { Vec3 r;  r.v [0] = r.v [1] = r.v [2] = 0;  r.v [axis] = 1;  return r; }
inline int    grid_sum    (const Grid& g)                   { int s = 0;  for (int i = 0; i < 2; i++) for (int j = 0; j < 3; j++) s += g.cells [i][j];  return s; }
inline void   grid_fill   (Grid* g, int v)                  { for (int i = 0; i < 2; i++) for (int j = 0; j < 3; j++) g->cells [i][j] = v + i * 3 + j;  g->label [0] = 'g';  g->label [1] = 0;  g->corners [1].v [2] = 9; }
inline double sum_vecs    (Vec3* vecs, int count)           { double s = 0;  for (int i = 0; i < count; i++) s += vecs [i].v [0];  return s; }

/* Results through pointers to pointers, and references to pointers. */
int           table [4] = { 2, 4, 6, 8 };
inline void   get_table   (int** values, int* count)        { *values = table;  *count = 4; }
inline int*   table_start ()                                { return table; }
inline void   next_entry  (int*& entry)                     { entry++; }
inline void   get_name    (const char** name)               { *name = "table"; }

/* Text in a buffer of the caller. */
inline int    write_text  (char* buffer, int size)          { const char* t = "written";  int i = 0;  for (; t [i] && i < size - 1; i++) buffer [i] = t [i];  buffer [i] = 0;  return i; }
inline int    count_char  (const char* text, char c)        { int n = 0;  for (; *text; text++) if (*text == c) n++;  return n; }

/* The other standard types. */
inline bool               negate   (bool b)                 { return !b; }
inline long long          big      (long long a)            { return a * 1000000000LL; }
inline unsigned char      high_bit (unsigned char c)        { return c | 0x80; }
inline float              half     (float f)                { return f / 2; }
inline short              shorten  (int i)                  { return (short) i; }
inline unsigned long      mask     (unsigned long a, unsigned long b)   { return a & b; }
inline void               toggle   (bool& b)                { b = !b; }
inline void               halve    (float* f)               { *f /= 2; }

/* Variables. */
int          limit       = 10;
double       weights [3] = { 0.5, 1.5, 2.5 };
Vec3         origin      = { { 1, 2, 3 } };
const int    fixed       = 42;
const char*  title       = "arrays";
int*         cursor      = table;
int          range       = 3;          /* A name which is a reserved word of Ada. */

inline int    read_limit  ()                                { return limit; }
inline int    read_range  ()                                { return range; }
inline double read_weight (int i)                           { return weights [i]; }
