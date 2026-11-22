/* Classes with virtual functions: dispatching in both directions, and the lifetime of objects. */

%module virtual_classes

%{
#include "example.h"
int Shape::count = 0;
%}

%ignore Guarded::hidden;     // A virtual function which is not bound keeps its place among the others.

%include "example.h"
