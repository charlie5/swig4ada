
// tbd: do we need to provide backwards compatability ? is this file needed ? (RAK)

/* -----------------------------------------------------------------------------
 * This file provides backwards compatible enum wrapping. SWIG versions 1.3.21
 * and earlier wrapped global enums with constant integers in the module
 * class. Enums declared within a C++ class were wrapped by constant integers
 * in the Ada proxy class.
 * ----------------------------------------------------------------------------- */

// const enum SWIGTYPE & typemaps
%typemap(ctype) const enum SWIGTYPE & "int"
%typemap(imtype) const enum SWIGTYPE & "interfaces.c.int"
%typemap(adatype) const enum SWIGTYPE & "interfaces.c.Int"

%typemap(in) const enum SWIGTYPE & ($*1_ltype temp)
%{
   temp = ($*1_ltype)$input; 
   $1 = &temp; 
%}

%typemap(out) const enum SWIGTYPE & %{ $result = *$1; %}

%typecheck(SWIG_TYPECHECK_INT32) const enum SWIGTYPE & ""

%typemap(throws) const enum SWIGTYPE & %{
  (void)$1;
  SWIG_AdaThrowException(SWIG_AdaException, "C++ $1_type exception thrown");
%}

%typemap(adain) const enum SWIGTYPE & "$adainput"
%typemap(adaout) const enum SWIGTYPE & 
%{
    return Integer ($imcall);  -- kkk5
%}

%typemap(adavarout) const enum SWIGTYPE &
%{
    get {
      return $imcall;
    } 
%}


// enum SWIGTYPE typemaps
%typemap(ctype) enum SWIGTYPE "int"
%typemap(imtype) enum SWIGTYPE "interfaces.c.int"
%typemap(adatype) enum SWIGTYPE "interfaces.c.Int"

%typemap(in) enum SWIGTYPE %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE %{ $result = $1; %}

%typecheck(SWIG_TYPECHECK_INT32) enum SWIGTYPE ""

%typemap(throws) enum SWIGTYPE %{
  (void)$1;
  SWIG_AdaThrowException(SWIG_AdaException, "C++ $1_type exception thrown");
%}

%typemap(adain) enum SWIGTYPE "$adainput"
%typemap(adaout) enum SWIGTYPE 
%{
    return Integer ($imcall);
%}

%typemap(adavarout) enum SWIGTYPE %{
    get {
      return $imcall;
    } %}

%typemap(adabase)           enum SWIGTYPE ""
%typemap(adaclassmodifiers) enum SWIGTYPE ""
%typemap(adacode)           enum SWIGTYPE ""
%typemap(adaimports)        enum SWIGTYPE ""
%typemap(adainterfaces)     enum SWIGTYPE ""

%typemap(adabody) enum SWIGTYPE ""

%adaenum(simple);

