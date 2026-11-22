/* Declarations which are nested in a class: an enumeration, typedefs, a constant, a structure and a class. */

%module nested

%{
#include "example.h"
%}

// A nested class is bound as a class of the module, beside the class which holds it. Nothing asks for that here.

%include "example.h"
