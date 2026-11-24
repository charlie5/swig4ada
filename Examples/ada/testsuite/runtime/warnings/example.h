/* Declarations which the Ada module warns of. */

struct Hidden;

template <class T> struct Box { T item; };

struct Base    { int b; };
struct Poly    { virtual ~Poly () {} };
struct Derived : Poly, virtual Base { int d; };            // 864: a parent of the tagged type, and a virtual base

enum Marks { One = sizeof (Hidden*) * 99 % 7 ? 1 : 2 };    // 863: a value which is not worked out

#define ODD (1 ? 2 : 3)                                    // 861: a value which Ada cannot state

Box<int>  make_box ();                                     // 861: a type which is not known ...
int       take     (Box<int> b);                           //      ... and the functions which use it
int       quiet    (Box<int> b);                           //      (this one is turned off in the interface file)

inline int kept (int x)   { return x + 1; }                // A function with nothing to warn of.

struct Boxed  { Box<int> box;  int n; };                   // 862: a member of a type which is not known, and the kind of the class a guess
struct Holder : Box<int> { int h; };                       // 862: a base class which is not known, likewise
struct Owner  { Box<int> box;  ~Owner () {} };             // 862: its destructor says that C++ constructs it, so nothing is a guess
