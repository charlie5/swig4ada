/* A module which imports another: it uses its types, and derives from one of its classes. */

%module imports

%import "base.i"

%{
#include "example.h"
%}

%include "example.h"
