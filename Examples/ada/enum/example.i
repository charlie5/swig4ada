/* File : example.i */
%module enum_example

%{
#include "example.h"
%}

/* Let's just grab the original header file here */

%include "example.h"

