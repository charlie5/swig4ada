/* A class which is not trivial, as a value: constructed, returned and passed by value. */

%module class_values

%include <std_string.i>

%{
#include "example.h"
%}

%include "example.h"
