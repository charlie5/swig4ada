/* Mutually dependent classes. */

%module mutual_classes

%{
#include "example.h"
%}

%include "example.h"
