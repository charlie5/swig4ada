/* A smart pointer: the functions of the class it points to are reached through it. */

%module smart_pointers

%{
#include "example.h"
int Engine::alive = 0;
%}

%include "example.h"
