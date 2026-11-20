/* File : example.i */

%module string_example

%include <std_string.i>

%{
#include "example.h"
%}

%include "example.h"
