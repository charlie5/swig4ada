/* Declarations which the Ada module warns of. */

struct Hidden;

template <class T> struct Box { T item; };

struct Base    { int b; };
struct Derived : virtual Base { int d; };                  // 864: virtual inheritance

enum Marks { One = sizeof (Hidden*) * 99 % 7 ? 1 : 2 };    // 863: a value which is not worked out

#define ODD (1 ? 2 : 3)                                    // 861: a value which Ada cannot state

Box<int>  make_box ();                                     // 861: a type which is not known ...
int       take     (Box<int> b);                           //      ... and the functions which use it
int       quiet    (Box<int> b);                           //      (this one is turned off in the interface file)

inline int kept (int x)   { return x + 1; }                // A function with nothing to warn of.
