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
