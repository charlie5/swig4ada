/* Overloaded functions, constructors and members, default arguments and operators. */

inline int    describe (int)             { return 1; }
inline int    describe (double)          { return 2; }
inline int    describe (const char*)     { return 3; }
inline int    describe (int, int)        { return 4; }

inline int    scale (int value, int factor = 10, int offset = 1)   { return value * factor + offset; }

class Money {
public:
  long cents;

  Money ()                          : cents (0)                       {}
  Money (long whole)                : cents (whole * 100)             {}
  Money (long whole, long part)     : cents (whole * 100 + part)      {}

  void add (long whole)             { cents += whole * 100; }
  void add (long whole, long part)  { cents += whole * 100 + part; }
  void add (const Money& other)     { cents += other.cents; }

  Money operator+ (const Money& other) const   { Money r;  r.cents = cents + other.cents;  return r; }
  bool  operator== (const Money& other) const  { return cents == other.cents; }
  bool  operator<  (const Money& other) const  { return cents <  other.cents; }

  static Money of_cents (long c)    { Money r;  r.cents = c;  return r; }
};
