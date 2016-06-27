/* File : example.i */
%module example

%{
//#include "example.h"
%}



//%include "example.h"
//%include "vector.h"
%include /usr/local/share/swig/1.3.36/gnat/std_vector.i

%template(int_vector) std::vector<int>;

