/* Directives which change a binding: names, what is bound, and how parameters are passed. */

%module directives

%{
#include "example.h"
%}

%rename (new_name)       old_name;
%rename (sample)         Sensor::read;
%rename (less_than)      Sensor::operator<;
%rename (element)        Sensor::operator[];
%rename (negated)        Sensor::operator-;

%ignore                  not_wanted;
%ignore                  Sensor::secret;
%ignore                  Sensor::internal_state;
%ignore                  Reading::hidden_detail;
%ignore                  HIDDEN_LIMIT;

%immutable               Reading::raw;

%apply char * { const unsigned char * };

%inline %{
  inline int added_here (int a)   { return a + 100; }
%}

%constant int ANSWER = 42;

%include "example.h"
