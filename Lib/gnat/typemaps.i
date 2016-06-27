//
// SWIG Typemap library
// Ada implementation
//

// ------------------------------------------------------------------------
// Pointer and reference handling
//
// These mappings provide support for input/output arguments and common
// uses for C/C++ pointers and C++ references.
// ------------------------------------------------------------------------

/*
INPUT typemaps
--------------

These typemaps are used for pointer/reference parameters that are input only
are mapped to a Ada input parameter.

The following typemaps can be applied to turn a pointer or reference into a simple
input value.  That is, instead of passing a pointer or reference to an object,
you would use a real value instead.

        bool               *INPUT, bool               &INPUT
        signed char        *INPUT, signed char        &INPUT
        unsigned char      *INPUT, unsigned char      &INPUT
        short              *INPUT, short              &INPUT
        unsigned short     *INPUT, unsigned short     &INPUT
        int                *INPUT, int                &INPUT
        unsigned int       *INPUT, unsigned int       &INPUT
        long               *INPUT, long               &INPUT
        unsigned long      *INPUT, unsigned long      &INPUT
        long long          *INPUT, long long          &INPUT
        unsigned long long *INPUT, unsigned long long &INPUT
        float              *INPUT, float              &INPUT
        double             *INPUT, double             &INPUT
         
To use these, suppose you had a C function like this :

        double fadd(double *a, double *b) {
               return *a+*b;
        }

You could wrap it with SWIG as follows :
        
        %include "typemaps.i"
        double fadd(double *INPUT, double *INPUT);

or you can use the %apply directive :

        %include "typemaps.i"
        %apply double *INPUT { double *a, double *b };
        double fadd(double *a, double *b);

In Ada you could then use it like this:
        Answer : long_Float := modulename.fadd(10.0, 20.0);

*/



%define INPUT_TYPEMAP(TYPE, CTYPE, ADATYPE)

  %typemap (ctype)         TYPE  *INPUT,     TYPE  &INPUT               "CTYPE"
  %typemap (imtype)        TYPE  *INPUT,     TYPE  &INPUT               "ADATYPE"
  %typemap (adatype)       TYPE  *INPUT,     TYPE  &INPUT               "ADATYPE"
  %typemap (adain)         TYPE  *INPUT,     TYPE  &INPUT               "$adainput"

  %typemap (in)            TYPE  *INPUT,     TYPE  &INPUT               %{ $1 = ($1_ltype) &$input; %}

  %typemap (typecheck)     TYPE  *INPUT = TYPE;
  %typemap (typecheck)     TYPE  &INPUT = TYPE;

%enddef



INPUT_TYPEMAP (bool,               unsigned int,         swig.bool_Pointer)
//INPUT_TYPEMAP (char,               char,                 char)                          // tbd
INPUT_TYPEMAP (signed char,        signed char,          swig.signed_char_Pointer)
INPUT_TYPEMAP (unsigned char,      unsigned char,        swig.unsigned_char_Pointer)
INPUT_TYPEMAP (short,              short,                swig.short_Pointer)
INPUT_TYPEMAP (unsigned short,     unsigned short,       swig.unsigned_short_Pointer)
INPUT_TYPEMAP (int,                int,                  swig.int_Pointer)
INPUT_TYPEMAP (unsigned int,       unsigned int,         swig.unsigned_Pointer)
INPUT_TYPEMAP (long,               long,                 swig.long_Pointer)
INPUT_TYPEMAP (unsigned long,      unsigned long,        swig.unsigned_long_Pointer)
INPUT_TYPEMAP (long long,          long long,            swig.long_long_integer_Pointer)
INPUT_TYPEMAP (unsigned long long, unsigned long long,   swig.unsigned_long_long_Pointer)
INPUT_TYPEMAP (float,              float,                swig.float_Pointer)
INPUT_TYPEMAP (double,             double,               swig.double_Pointer)

#undef INPUT_TYPEMAP





/*
OUTPUT typemaps
---------------

These typemaps are used for pointer/reference parameters that are output only and
are mapped to a Ada output parameter.

The following typemaps can be applied to turn a pointer or reference into an "output"
value.  When calling a function, no input value would be given for
a parameter, but an output value would be returned. In Ada, the 'out' keyword is
used when passing the parameter to a function that takes an output parameter.

        bool               *OUTPUT, bool               &OUTPUT
        signed char        *OUTPUT, signed char        &OUTPUT
        unsigned char      *OUTPUT, unsigned char      &OUTPUT
        short              *OUTPUT, short              &OUTPUT
        unsigned short     *OUTPUT, unsigned short     &OUTPUT
        int                *OUTPUT, int                &OUTPUT
        unsigned int       *OUTPUT, unsigned int       &OUTPUT
        long               *OUTPUT, long               &OUTPUT
        unsigned long      *OUTPUT, unsigned long      &OUTPUT
        long long          *OUTPUT, long long          &OUTPUT
        unsigned long long *OUTPUT, unsigned long long &OUTPUT
        float              *OUTPUT, float              &OUTPUT
        double             *OUTPUT, double             &OUTPUT
         
For example, suppose you were trying to wrap the modf() function in the
C math library which splits x into integral and fractional parts (and
returns the integer part in one of its parameters):

        double modf(double x, double *ip);

You could wrap it with SWIG as follows :

        %include "typemaps.i"
        double modf(double x, double *OUTPUT);

or you can use the %apply directive :

        %include "typemaps.i"
        %apply double *OUTPUT { double *ip };
        double modf(double x, double *ip);

The Ada output of the function would be the function return value and the 
value returned in the second output parameter. In Ada you would use it like this:

    double dptr;
    double fraction = modulename.modf(5, out dptr);

*/


%define OUTPUT_TYPEMAP(TYPE, CTYPE, ADATYPE, TYPECHECKPRECEDENCE)

  %typemap (ctype)                TYPE  *OUTPUT,     TYPE  &OUTPUT                "CTYPE *"
  %typemap (imtype)               TYPE  *OUTPUT,     TYPE  &OUTPUT                "ADATYPE"
  %typemap (adatype)              TYPE  *OUTPUT,     TYPE  &OUTPUT                "ADATYPE"
  %typemap (adain)                TYPE  *OUTPUT,     TYPE  &OUTPUT                "$adainput"

  %typemap (in)                   TYPE  *OUTPUT,     TYPE  &OUTPUT                %{ $1 = ($1_ltype) $input; %}

  %typecheck (SWIG_TYPECHECK_##TYPECHECKPRECEDENCE)     
                                  TYPE  *OUTPUT,     TYPE  &OUTPUT                ""
%enddef


OUTPUT_TYPEMAP (bool,               unsigned int,         swig.bool_Pointer,               BOOL_PTR)
//OUTPUT_TYPEMAP(char,               char,                 char,     CHAR_PTR)                            // tbd
OUTPUT_TYPEMAP (signed char,        signed char,          swig.signed_char_Pointer,           INT8_PTR)
OUTPUT_TYPEMAP (unsigned char,      unsigned char,        swig.unsigned_char_Pointer,         UINT8_PTR)
OUTPUT_TYPEMAP (short,              short,                swig.short_Pointer,                 INT16_PTR)
OUTPUT_TYPEMAP (unsigned short,     unsigned short,       swig.unsigned_short_Pointer,        UINT16_PTR)
OUTPUT_TYPEMAP (int,                int,                  swig.int_Pointer,                   INT32_PTR)
OUTPUT_TYPEMAP (unsigned int,       unsigned int,         swig.unsigned_Pointer,              UINT32_PTR)
OUTPUT_TYPEMAP (long,               long,                 swig.long_Pointer,                  INT32_PTR)
OUTPUT_TYPEMAP (unsigned long,      unsigned long,        swig.unsigned_long_Pointer,         UINT32_PTR)
OUTPUT_TYPEMAP (long long,          long long,            swig.long_long_integer_Pointer,     INT64_PTR)
OUTPUT_TYPEMAP (unsigned long long, unsigned long long,   swig.unsigned_long_long_Pointer,     UINT64_PTR)
OUTPUT_TYPEMAP (float,              float,                swig.float_Pointer,                 FLOAT_PTR)
OUTPUT_TYPEMAP (double,             double,               swig.double_Pointer,            DOUBLE_PTR)


#undef OUTPUT_TYPEMAP





/*
INOUT typemaps
--------------

These typemaps are for pointer/reference parameters that are both input and
output and are mapped to a Ada reference parameter.

The following typemaps can be applied to turn a pointer or reference into a
reference parameters, that is the parameter is both an input and an output.
In Ada, the 'ref' keyword is used for reference parameters.

        bool               *INOUT, bool               &INOUT
        signed char        *INOUT, signed char        &INOUT
        unsigned char      *INOUT, unsigned char      &INOUT
        short              *INOUT, short              &INOUT
        unsigned short     *INOUT, unsigned short     &INOUT
        int                *INOUT, int                &INOUT
        unsigned int       *INOUT, unsigned int       &INOUT
        long               *INOUT, long               &INOUT
        unsigned long      *INOUT, unsigned long      &INOUT
        long long          *INOUT, long long          &INOUT
        unsigned long long *INOUT, unsigned long long &INOUT
        float              *INOUT, float              &INOUT
        double             *INOUT, double             &INOUT
         
For example, suppose you were trying to wrap the following function :

        void neg(double *x) {
             *x = -(*x);
        }

You could wrap it with SWIG as follows :

        %include "typemaps.i"
        void neg(double *INOUT);

or you can use the %apply directive :

        %include "typemaps.i"
        %apply double *INOUT { double *x };
        void neg(double *x);

The Ada output of the function would be the new value returned by the 
reference parameter. In Ada you would use it like this:


       double x = 5.0;
       neg(ref x);

The implementation of the OUTPUT and INOUT typemaps is different to the scripting
languages in that the scripting languages will return the output value as part 
of the function return value.

*/


%define INOUT_TYPEMAP(TYPE, CTYPE, ADATYPE, TYPECHECKPRECEDENCE)

  %typemap (ctype)          TYPE  *INOUT,     TYPE  &INOUT                  "CTYPE *"
  %typemap (imtype)         TYPE  *INOUT,     TYPE  &INOUT                  "ADATYPE"
  %typemap (adatype)        TYPE  *INOUT,     TYPE  &INOUT                  "ADATYPE"

  %typemap (adain)          TYPE  *INOUT,     TYPE  &INOUT                  "$adainput"

  %typemap (in)             TYPE  *INOUT,     TYPE  &INOUT                  %{ $1 = ($1_ltype) $input; %}

  %typecheck(SWIG_TYPECHECK_##TYPECHECKPRECEDENCE) 
                            TYPE  *INOUT,     TYPE  &INOUT                  ""
%enddef

 
INOUT_TYPEMAP (bool,               unsigned int,         swig.bool_Pointer,               BOOL_PTR)
//INOUT_TYPEMAP(char,               char,                 char,     CHAR_PTR)                              // tbd
INOUT_TYPEMAP (signed char,        signed char,          swig.signed_char_Pointer,           INT8_PTR)
INOUT_TYPEMAP (unsigned char,      unsigned char,        swig.unsigned_char_Pointer,         UINT8_PTR)
INOUT_TYPEMAP (short,              short,                swig.short_Pointer,                 INT16_PTR)
INOUT_TYPEMAP (unsigned short,     unsigned short,       swig.unsigned_short_Pointer,        UINT16_PTR)
INOUT_TYPEMAP (int,                int,                  swig.int_Pointer,                   INT32_PTR)
INOUT_TYPEMAP (unsigned int,       unsigned int,         swig.unsigned_Pointer,              UINT32_PTR)
INOUT_TYPEMAP (long,               long,                 swig.long_Pointer,                  INT32_PTR)
INOUT_TYPEMAP (unsigned long,      unsigned long,        swig.unsigned_long_Pointer,         UINT32_PTR)
INOUT_TYPEMAP (long long,          long long,            swig.long_long_integer_Pointer,     INT64_PTR)
INOUT_TYPEMAP (unsigned long long, unsigned long long,   swig.unsigned_long_long_Pointer,     UINT64_PTR)
INOUT_TYPEMAP (float,              float,                swig.float_Pointer,                 FLOAT_PTR)
INOUT_TYPEMAP (double,             double,               swig.double_Pointer,            DOUBLE_PTR)


#undef INOUT_TYPEMAP
