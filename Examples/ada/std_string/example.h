/* File : example.h */

#include <string>
#include <iostream>


/* The size which C++ gives a string, for comparison with that of the Ada type. */
inline int
std_string_Size()
{
  return sizeof (std::string);
}


/* A string passed by value. */
inline void
foo (std::string   a_String)
{
  std::cout << "foo:    '" << a_String << "'" << std::endl;
}


/* A string passed by reference, and changed. */
inline void
fooey (std::string&   a_String)
{
  a_String += " (changed by fooey)";
}


/* A string returned by value, long enough not to fit in the string's own buffer. */
inline std::string
greeting (std::string   Name)
{
  return "Hello " + Name + ", and welcome to a string which is returned by value.";
}


/* A class with a string as a member. */
class aaa
{
public:
   int           Rank;
   std::string   Name;
   int           Age;

   aaa() : Rank (1), Name ("a name given by the constructor"), Age (42) {}
};
