/* -----------------------------------------------------------------------------
 * Include this file in order for C/C++ enums to be wrapped by the so called
 * typesafe enum pattern. Each enum has an equivalent Ada class named after the
 * enum and each enum item is a static instance of this class.
 * ----------------------------------------------------------------------------- */

// const enum SWIGTYPE & typemaps

%typemap (ctype)                         const enum SWIGTYPE &               "int"
%typemap (imtype)                        const enum SWIGTYPE &               "interfaces.c.int"
%typemap (adatype)                       const enum SWIGTYPE &               "$*adaclassname"


%typemap (in)                            const enum SWIGTYPE & ($*1_ltype  temp)
%{ 
   temp = ($*1_ltype) $input; 
   $1   = &temp; 
%}

%typemap (out)                           const enum SWIGTYPE &               %{ $result = *$1; %}


%typecheck (SWIG_TYPECHECK_POINTER)      const enum SWIGTYPE &               ""


%typemap (throws)                        const enum SWIGTYPE & 
%{
  (void) $1;
  SWIG_AdaThrowException (SWIG_AdaException, "C++ $1_type exception thrown");
%}


%typemap (adain)                         const enum SWIGTYPE &               "$adainput.swigValue"

%typemap (adaout)                        const enum SWIGTYPE & 
%{
    return $*adaclassname.swigToEnum($imcall);
%}



%typemap (adavarout)                     const enum SWIGTYPE & 
%{
    get {
      return $*adaclassname.swigToEnum($imcall);
    } 
%}




// enum SWIGTYPE typemaps

%typemap (ctype)                         enum SWIGTYPE                       "int"
%typemap (imtype)                        enum SWIGTYPE                       "interfaces.c.int"
%typemap (adatype)                       enum SWIGTYPE                       "$adaclassname"

%typemap (in)                            enum SWIGTYPE                       %{ $1 = ($1_ltype) $input; %}
%typemap (out)                           enum SWIGTYPE                       %{ $result = $1; %}


%typecheck (SWIG_TYPECHECK_POINTER)      enum SWIGTYPE                       ""


%typemap (throws)                        enum SWIGTYPE 
%{
  (void) $1;
  SWIG_AdaThrowException (SWIG_AdaException, "C++ $1_type exception thrown");
%}


%typemap (adain)                         enum SWIGTYPE                       "$adainput.swigValue"

%typemap (adaout)                        enum SWIGTYPE 
%{
    return $adaclassname.swigToEnum ($imcall);
%}


%typemap (adavarout)                     enum SWIGTYPE
%{
    get {
      return $adaclassname.swigToEnum($imcall);
    } 
%}




%typemap (adabase)                       enum SWIGTYPE                       ""
%typemap (adaclassmodifiers)             enum SWIGTYPE                       "package "
%typemap (adacode)                       enum SWIGTYPE                       ""
%typemap (adaimports)                    enum SWIGTYPE                       ""
%typemap (adainterfaces)                 enum SWIGTYPE                       ""


/*
 * The swigToEnum method is used to find the Ada enum from a C++ enum integer value. The default one here takes 
 * advantage of the fact that most enums do not have initial values specified, so the lookup is fast. If initial
 * values are specified then a lengthy linear search through all possible enums might occur. Specific typemaps could be
 * written to possibly optimise this lookup by taking advantage of characteristics peculiar to the targeted enum.
 * The special variable, $enumvalues, is replaced with a comma separated list of all the enum values.
 */
 
%typemap (adabody)                       enum SWIGTYPE    " "
/*
%{
  public readonly int swigValue;

  public static $adaclassname swigToEnum(int swigValue) {
    if (swigValue < swigValues.Length && swigValues[swigValue].swigValue == swigValue)
      return swigValues[swigValue];
    for (int i = 0; i < swigValues.Length; i++)
      if (swigValues[i].swigValue == swigValue)
        return swigValues[i];
    throw new System.ArgumentOutOfRangeException("No enum $adaclassname with value " + swigValue);
  }

  public override string ToString() {
    return swigName;
  }

  private $adaclassname(string swigName) {
    this.swigName = swigName;
    this.swigValue = swigNext++;
  }

  private $adaclassname(string swigName, int swigValue) {
    this.swigName = swigName;
    this.swigValue = swigValue;
    swigNext = swigValue+1;
  }

  private static $adaclassname[] swigValues = { $enumvalues };
  private static int swigNext = 0;
  private readonly string swigName;
%}
*/



%adaenum (typesafe);         // instruct swig to use the typesafe enum method.
