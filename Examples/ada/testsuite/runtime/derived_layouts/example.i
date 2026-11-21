/* Classes derived from classes with no virtual functions. */

%module derived_layouts

%{
#include "example.h"
%}

%ignore Hiding::secret;

%include "example.h"
