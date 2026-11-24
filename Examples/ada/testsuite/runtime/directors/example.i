/* Directors: virtual functions which Ada cannot call through the vtable, overridden in Ada. */

%module directors

%include <std_string.i>

%feature ("director") Speaker;
%feature ("director") Voice;

%{
#include "example.h"
%}

%include "example.h"
