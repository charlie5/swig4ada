/* Declarations which are nested in a class: an enumeration, typedefs, a constant, a structure and a class. */

%module nested

%{
#include "example.h"
%}

%feature ("flatnested");     // Bind a nested class as a class of the module.

%include "example.h"
