/* File : example.i */
%module class_example

%{
#include "example.h"
%}

/* Let's just grab the original header file here */
%include "example.h"

