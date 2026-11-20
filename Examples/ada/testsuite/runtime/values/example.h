/* References, pointers, enumerations, plain structures and callbacks. */

enum Colour { Red, Green = 5, Blue };

struct Point { int x; int y; };

inline void          increment (int& value)                 { value++; }
inline int           twice     (const int& value)           { return value * 2; }
inline const double& largest   (const double& a, const double& b)  { return a > b ? a : b; }
inline void          swap_ints (int* a, int* b)             { int t = *a;  *a = *b;  *b = t; }

inline Colour        next      (Colour c)                   { return c == Red ? Green : c == Green ? Blue : Red; }
inline int           value_of  (Colour c)                   { return (int) c; }

inline Point         make_point (int x, int y)              { Point p;  p.x = x;  p.y = y;  return p; }
inline int           manhattan  (Point p)                   { return p.x + p.y; }
inline void          shift      (Point* p, int dx, int dy)  { p->x += dx;  p->y += dy; }

typedef int (*Operation) (int, int);

inline int           add        (int a, int b)              { return a + b; }
inline int           apply      (Operation op, int a, int b)       { return op (a, b); }
inline int           apply_raw  (int (*op) (int, int), int a, int b)  { return op (a, b); }
