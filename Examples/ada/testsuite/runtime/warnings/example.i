/* The warnings of the Ada module: each has a number, names the line of its declaration, and may be turned off. */

%module warnings

%warnfilter (SWIGWARN_ADA_NOT_BOUND) quiet;     // One declaration is silenced by name.

%{
#include "example.h"
Box<int>  make_box ()         { return Box<int> (); }
int       take  (Box<int> b)  { return b.item; }
int       quiet (Box<int> b)  { return b.item; }
%}

%include "example.h"
