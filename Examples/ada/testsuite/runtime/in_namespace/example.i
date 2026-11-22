/* A binding whose packages are within another package: it is generated with '-namespace outer'. */

%module in_namespace

%{
#include "example.h"
%}

%include "example.h"
