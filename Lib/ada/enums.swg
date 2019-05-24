// -----------------------------------------------------------------------------
// Include this file in order for C/C++ enums to be wrapped by proper Ada enums.
// Note that the PINVOKE layer handles the enum as an int.
// -----------------------------------------------------------------------------


// const enum SWIGTYPE & typemaps

%typemap (ctype)                        const enum SWIGTYPE &            "int*"
%typemap (imtype)                       const enum SWIGTYPE &            "interfaces.c.Int"
//%typemap (adatype)                      const enum SWIGTYPE &            "$*adaclassname"
//%typemap (adatype)                      const enum SWIGTYPE &            "$*adaclassname"



%typemap (in)                           const enum SWIGTYPE & ($*1_ltype  temp)
%{ 
   temp = *($1_ltype)$input; 
   $1 = &temp; 
//   temp = ($*1_ltype)$input; 
//   $1 = &temp; 
%}


%typemap (out)                          const enum SWIGTYPE & 
%{ 
  $result = (int*) $1; 
//  $result = *$1; 
%}



%typecheck (SWIG_TYPECHECK_POINTER)     const enum SWIGTYPE & ""



%typemap (throws)                       const enum SWIGTYPE & 
%{
  (void) $1;
  SWIG_AdaThrowException (SWIG_AdaException, "C++ $1_type exception thrown");
%}



%typemap (adain)                        const enum SWIGTYPE &          "standard.$enum_class_name.raw_Value_of ($adainput)"

%typemap (adaout)                       const enum SWIGTYPE & 
%{
    return $enum_class_name.true_Value_of ($imcall);
%}




%typemap (adavarout)                    const enum SWIGTYPE & 
%{
    get {
      return ($*adaclassname)$imcall;
    } 
%}



// enum SWIGTYPE typemaps

%typemap (ctype)                        enum SWIGTYPE                  "int"
%typemap (imtype)                       enum SWIGTYPE                  "interfaces.c.Int"
//%typemap (adatype)                      enum SWIGTYPE                  "$adaclassname"

%typemap (in)                           enum SWIGTYPE                  %{ $1 = ($1_ltype) $input; %}
%typemap (out)                          enum SWIGTYPE                  %{ $result = $1; %}


%typecheck (SWIG_TYPECHECK_POINTER)     enum SWIGTYPE                  ""


%typemap (throws)                       enum SWIGTYPE 
%{
  (void) $1;
  SWIG_AdaThrowException (SWIG_AdaException, "C++ $1_type exception thrown");
%}


%typemap (adain)                        enum SWIGTYPE                  "standard.$enum_class_name.raw_Value_of ($adainput)"

%typemap (adaout)                       enum SWIGTYPE 
%{
   return standard.$enum_class_name.true_Value_of ($imcall);
%}



%typemap (adavarout)                    enum SWIGTYPE 
%{
    get {
      return ($adaclassname)$imcall;
    } 
%}



%typemap (adabase)                      enum SWIGTYPE                  ""
%typemap (adaclassmodifiers)            enum SWIGTYPE                  "package"
%typemap (adacode)                      enum SWIGTYPE                  ""
%typemap (adaimports)                   enum SWIGTYPE                  "with ada.unchecked_Conversion;\n\nwith interfaces.C;\n\n"
%typemap (adainterfaces)                enum SWIGTYPE                  ""
%typemap (adabody)                      enum SWIGTYPE                  ""


%adaenum (proper);
