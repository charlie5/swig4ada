/* A binding to C: structures, a union, arrays, strings, callbacks and variables. */

%module c_library

%{
#include "example.h"
%}

%include "example.h"
