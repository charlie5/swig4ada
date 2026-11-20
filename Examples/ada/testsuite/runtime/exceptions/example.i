/* C++ exceptions, which a wrapper catches and records. */

%module exceptions

%{
#include "example.h"
%}

%catches (std::runtime_error) checked_divide;
%catches (int)                require_positive;

%include "example.h"
