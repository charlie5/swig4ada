/* Overloading, default arguments and operators. */

%module overloads

%{
#include "example.h"
%}

%rename (plus)      Money::operator+;
%rename (equals)    Money::operator==;
%rename (less_than) Money::operator<;

%include "example.h"
