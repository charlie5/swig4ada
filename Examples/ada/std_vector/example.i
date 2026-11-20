/* File : example.i */
%module example

%{
//#include "example.h"
%}



//%include "example.h"
//%include "vector.h"
%include <std_vector.i>

%template(int_vector) std::vector<int>;

