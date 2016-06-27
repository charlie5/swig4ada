/* File : example.i */


%module string_example


%{
#include "example.h"
%}


//%include "std_string.i"

%include "example.h";

