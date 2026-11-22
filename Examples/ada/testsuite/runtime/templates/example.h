/* Templates which the library defines itself. */

template <class T> T largest (T a, T b)   { return a > b ? a : b; }

template <class T> struct Pair {
  T first;
  T second;
  T    sum  () const   { return first + second; }
  void swap ()         { T t = first;  first = second;  second = t; }
};

template <class T, int Size = 4> class Ring {
  T   items [Size];
  int next;
public:
  typedef T value_type;

  Ring () : next (0)            { for (int i = 0; i < Size; i++) items [i] = T (); }
  void put (const T& v)         { items [next] = v;  next = (next + 1) % Size; }
  T    get (int index) const    { return items [index]; }
  int  capacity () const        { return Size; }
};

/* A template with virtual functions, and a class which is derived from an instance of it. */
template <class T> class Source {
public:
  static int alive;
  Source ()                     { alive++; }
  virtual ~Source ()            { alive--; }
  virtual T next ()             { return T (); }
  T twice ()                    { return next () + next (); }
};

template <class T> int Source<T>::alive = 0;

/* A virtual template whose instance is not named as C++ names it: it has a default argument, and an argument which is a typedef. */
typedef int Whole;

inline int& tracked_alive ()   { static int alive = 0;  return alive; }
inline int  tracked_count ()   { return tracked_alive (); }

template <class T, class Extra = long> class Tracked {
public:
  T value;
  Tracked (T v) : value (v)    { tracked_alive ()++; }
  virtual ~Tracked ()          { tracked_alive ()--; }
  virtual T get ()             { return value; }
};

/* Functions which use instances ahead of the '%template' lines which name them, as a header does. */
inline Tracked<Whole>* new_tracked (int v)                  { return new Tracked<Whole> (v); }     // Made by C++, and freed by the destructor which Ada calls.
inline Pair<int>       pair_of     (int a, int b)           { Pair<int> p;  p.first = a;  p.second = b;  return p; }
inline int             difference  (const Pair<int>& p)     { return p.first - p.second; }
inline long            first_of    (Ring<long, 8>* r)       { return r->get (0); }
