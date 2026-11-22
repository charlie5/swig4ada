/* Templates which the library defines: functions, a structure, a class with a default argument, and a virtual class. */

%module templates

%{
#include "derived.h"
%}

%include "example.h"

%template (largest_int)    largest<int>;
%template (largest_double) largest<double>;

%template (int_Pair)       Pair<int>;
%template (double_Pair)    Pair<double>;

%template (int_Ring)       Ring<int>;
%template (long_Ring_8)    Ring<long, 8>;

%template (int_Source)     Source<int>;

%template (whole_Tracked)  Tracked<Whole>;

%include "derived.h"     // After the instance of the template which it uses as a base class.
