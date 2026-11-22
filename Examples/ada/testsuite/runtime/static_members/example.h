/* Static member variables of classes. */

struct Point { int x;  int y; };

class Counter {
public:
  enum Mode { Up, Down = 5 };

  static int          total;
  static double       rate;
  static int          history [3];
  static const char*  label;
  static Point        origin;
  static Point*       target;
  static Mode         mode;
  static Counter*     first;                /* A pointer to the class itself. */

  static const int    limit      = 16;      /* Constants with a value need have no symbol. */
  static const long   big_limit  = 1L << 20;
  static const int    unset;                /* A constant whose value is given elsewhere. */
  static const Mode   start      = Down;    /* Of an enumeration, of a truth value and of a character, likewise. */
  static const bool   enabled    = true;
  static const char   mark       = 'M';

  int id;
  Counter () : id (++total)       {}

  static void adopt (Counter* c)  { first = c; }

  static int  read_total ()       { return total; }
  static int  read_history (int i)   { return history [i]; }
  static int  mode_number ()      { return (int) mode; }
};

int          Counter::total   = 0;
double       Counter::rate    = 1.5;
int          Counter::history [3] = { 7, 8, 9 };
const char*  Counter::label   = "counter";
Point        Counter::origin  = { 3, 4 };
Point*       Counter::target  = &Counter::origin;
Counter::Mode Counter::mode   = Counter::Down;
Counter*     Counter::first   = 0;
const int    Counter::unset   = 99;

/* In a class with virtual functions, and in a class derived from it. */
class Widget {
public:
  static int made;
  Widget ()                       { made++; }
  virtual ~Widget ()              {}
  virtual int kind ()             { return 1; }
};

class Dial : public Widget {
public:
  static int dials;
  Dial ()                         { dials++; }
  virtual int kind ()             { return 2; }
};

int Widget::made = 0;
int Dial::dials  = 0;

/* In a class of a namespace, and in a template instance. */
namespace store {
  class Shelf {
  public:
    static int capacity;
    static int read_capacity ()   { return capacity; }
  };
}

int store::Shelf::capacity = 40;

template <typename T>
class Pool {
public:
  static int size;
  static int read_size ()         { return size; }
};

template <typename T> int Pool<T>::size = 11;
