/* Declarations in namespaces: functions, a structure, an enumeration, and classes with and without virtual functions. */

%module namespaces

%{
#include "example.h"
int geometry::Figure::alive = 0;
%}

%include "example.h"
