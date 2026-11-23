/* A binding to C which uses the further library files. */

%module library_c

%include <typemaps.i>
%include <cdata.i>
%include <argcargv.i>
%include <file.i>

%apply double        *INPUT  { double *a, double *b };
%apply unsigned char *INPUT  { unsigned char *flag };
%apply int           *OUTPUT { int *whole };
%apply double        *OUTPUT { double *part };
%apply int           *INOUT  { int *x };
%apply short         *INOUT  { short *s };
%apply unsigned long *INOUT  { unsigned long *u };
%apply float         *INOUT  { float *f };
%apply long          *INPUT  { long * };     // Every pointer to a 'long', that of a result among them.

%cdata (int);

%{
#include "example.h"
%}

%include "example.h"
