/* Classes with virtual functions: dispatching in both directions, and the lifetime of objects. */

%module virtual_classes

%{
#include "example.h"
int Shape::count = 0;
%}

%include "example.h"
