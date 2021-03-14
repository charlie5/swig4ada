


#include <string>
#include <iostream>



int
std_string_Size()
{
  std::string    a_String;

  return sizeof (a_String);
}





void
foo (std::string   a_String)
{
  std::cout << "foo std::string is: '" << a_String << "'" << '\n';
}


void
fooey (std::string&   a_String)
{
  std::cout << "foo std::string is: '" << a_String << "'" << '\n';
}



class aaa
{
   int           Rank;
   std::string   Name;
   int           Age;
};
