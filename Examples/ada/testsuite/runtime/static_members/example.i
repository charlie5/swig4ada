/* Static member variables: of each kind of type, constants, and in classes of several kinds. */

%module static_members

%{
#include "example.h"
%}

%include "example.h"

%template (int_Pool) Pool<int>;
