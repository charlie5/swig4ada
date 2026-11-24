/* Functions which throw. */

#include <stdexcept>

inline int checked_divide (int a, int b)
{
  if (b == 0)  throw std::runtime_error ("division by zero");
  return a / b;
}

inline int require_positive (int value)
{
  if (value < 0)  throw value;
  return value;
}

inline int element (int index)
{
  static const int values [3] = { 10, 20, 30 };

  if (index < 0 || index > 2)  throw std::out_of_range ("index is out of range");
  return values [index];
}

/* Classes which are derived from the standard exceptions, as many libraries' are: their layout and their vtables are
   those of the classes of 'std_except.i', which have the shape of GNU libstdc++. */

class Failure : public std::runtime_error {
public:
  Failure (const char* why, int code) : std::runtime_error (why), code_ (code) {}
  int code () const          { return code_; }
  virtual int level () const { return 2; }
private:
  int code_;
};

class Plain : public std::exception {
public:
  int n = 7;
  const char* what () const noexcept override { return "plain"; }
};

inline const char* what_of (const std::exception& e)   { return e.what (); }
inline int         size_of_failure ()                  { return sizeof (Failure); }
inline int         size_of_plain ()                    { return sizeof (Plain); }
