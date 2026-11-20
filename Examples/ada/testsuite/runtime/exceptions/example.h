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
