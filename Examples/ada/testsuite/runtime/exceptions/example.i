/* C++ exceptions, which a wrapper catches and records. */

%module exceptions

%include <std_except.i>     // Records a standard exception by its kind and its own message.

%{
#include "example.h"
%}

%catches (std::runtime_error) checked_divide;
%catches (std::out_of_range)  element;
%catches (int)                require_positive;

%include "example.h"
