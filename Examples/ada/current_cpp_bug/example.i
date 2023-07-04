%module example

%{
#include "example.h"
%}

%ignore foo;
%include "example.h";
