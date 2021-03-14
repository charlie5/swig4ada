/* File : example.i */

/* This file has a few "typical" uses of C++ references. */

// - adapted to cater for Gnat (ie %include of "example.h")
// - non-default constructors are not yet implemeneted in Gnat, so the
//   example uses a modified default constructor which has preset values.


%module ref_example

%{
#include "example.h"
%}

/*
class Vector {
public:
    Vector(double x, double y, double z);
   ~Vector();
    char *print();
};
*/

%include "example.h"

/* This helper function calls an overloaded operator */
%inline %{
Vector addv(Vector &a, Vector &b) {
  return a+b;
}
%}

/* Wrapper around an array of vectors class */
/*
class VectorArray {
public:
  VectorArray(int maxsize);
  ~VectorArray();
  int size();
  
  // This wrapper provides an alternative to the [] operator 
  %extend {
    Vector &get(int index) {
      return (*self)[index];
    }
    void set(int index, Vector &a) {
      (*self)[index] = a;
    }
  }
};
*/

%extend VectorArray 
{
    Vector&
    get (int   index) 
    {
      return (*self)[index];
    }

    
    void
    set (int         index, 
         Vector&     a) 
    {
      (*self)[index] = a;
    }
}


