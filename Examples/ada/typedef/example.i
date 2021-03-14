/* File : example.i */


%module example



/*
class Inner {
  public:
    int var;
    Inner(int v = 0) : var(v) {}
};
*/


%{
//#include <exception>
//#include <stdexcept>
#include "example.h"
%}

//%import "std_vector.i"

//%template(vector_int)    std::vector<int>;



//struct foo;


//%rename(bar) foo;

//%rename(bar) SDL_SysWMEvent;


//%import "/usr/gnat/include/c++/4.3.4/bits/stl_vector.h"
//#include "/usr/gnat/include/c++/4.3.4/bits/stl_vector.h"




/*
namespace std
{
  template<typename _Tp>
  class vector
  {
    void*   _M_impl;
  };
};


//%import <std_vector.i>


%template(int_Vector) std::vector<int>;

*/




%include "example.h";


/*
%{
// SWIG thinks that Inner is a global class, so we need to trick the C++
// compiler into understanding this so called global type.
typedef Outer::Inner Inner;
%}
*/
