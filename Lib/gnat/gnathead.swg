/* -----------------------------------------------------------------------------
 * gnathead.swg
 *
 * Gnat/Ada support code - insertions into C wrapper code
 * ----------------------------------------------------------------------------- */


%insert(runtime) 
%{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#if defined(_WIN32) || defined(__CYGWIN32__)
#  define DllExport   __declspec( dllexport )
#  define SWIGSTDCALL __stdcall
#else
#  define DllExport  
#  define SWIGSTDCALL
#endif 


#ifdef __cplusplus
#  include <new>
#endif

%}




/*
%insert(runtime) 
%{

// Support for throwing Ada exceptions from C/C++ 

typedef enum 
{
  SWIG_AdaException,
  SWIG_AdaOutOfMemoryException,
  SWIG_AdaIndexOutOfRangeException,
  SWIG_AdaDivideByZeroException,
  SWIG_AdaArgumentOutOfRangeException,
  SWIG_AdaNullReferenceException
} SWIG_AdaExceptionCodes;


typedef void (SWIGSTDCALL* SWIG_AdaExceptionCallback_t)(const char *);


typedef struct 
{
  SWIG_AdaExceptionCodes code;
  SWIG_AdaExceptionCallback_t callback;
} 
  SWIG_AdaExceptions_t;


static 
SWIG_AdaExceptions_t 
SWIG_ada_exceptions[] = 
{
  { SWIG_AdaException, NULL },
  { SWIG_AdaOutOfMemoryException, NULL },
  { SWIG_AdaIndexOutOfRangeException, NULL },
  { SWIG_AdaDivideByZeroException, NULL },
  { SWIG_AdaArgumentOutOfRangeException, NULL },
  { SWIG_AdaNullReferenceException, NULL } 
};


static 
void 
SWIG_AdaThrowException (SWIG_AdaExceptionCodes code, const char *msg) 
{
  SWIG_AdaExceptionCallback_t callback = SWIG_ada_exceptions[SWIG_AdaException].callback;
  if (code >=0 && (size_t)code < sizeof(SWIG_ada_exceptions)/sizeof(SWIG_AdaExceptions_t)) {
    callback = SWIG_ada_exceptions[code].callback;
  }
  callback(msg);
}

%}
*/



/*
%insert(runtime) 
%{
#ifdef __cplusplus
extern "C" 
#endif

DllExport void SWIGSTDCALL SWIGRegisterExceptionCallbacks_$module (SWIG_AdaExceptionCallback_t systemException,
                                                                   SWIG_AdaExceptionCallback_t outOfMemory, 
                                                                   SWIG_AdaExceptionCallback_t indexOutOfRange, 
                                                                   SWIG_AdaExceptionCallback_t divideByZero, 
                                                                   SWIG_AdaExceptionCallback_t argumentOutOfRange,
                                                                   SWIG_AdaExceptionCallback_t nullReference) 
{
  SWIG_ada_exceptions [SWIG_AdaException].callback                   = systemException;
  SWIG_ada_exceptions [SWIG_AdaOutOfMemoryException].callback        = outOfMemory;
  SWIG_ada_exceptions [SWIG_AdaIndexOutOfRangeException].callback    = indexOutOfRange;
  SWIG_ada_exceptions [SWIG_AdaDivideByZeroException].callback       = divideByZero;
  SWIG_ada_exceptions [SWIG_AdaArgumentOutOfRangeException].callback = argumentOutOfRange;
  SWIG_ada_exceptions [SWIG_AdaNullReferenceException].callback      = nullReference;
}
%}
*/




%pragma(ada) imclasscode=%{ %}
/*
  class SWIGExceptionHelper {

    public delegate void SWIGExceptionDelegate(string message);

    static SWIGExceptionDelegate systemDelegate = new SWIGExceptionDelegate(ThrowSystemException);
    static SWIGExceptionDelegate outOfMemoryDelegate = new SWIGExceptionDelegate(ThrowOutOfMemoryException);
    static SWIGExceptionDelegate indexOutOfRangeDelegate = new SWIGExceptionDelegate(ThrowIndexOutOfRangeException);
    static SWIGExceptionDelegate divideByZeroDelegate = new SWIGExceptionDelegate(ThrowDivideByZeroException);
    static SWIGExceptionDelegate argumentOutOfRangeDelegate = new SWIGExceptionDelegate(ThrowArgumentOutOfRangeException);
    static SWIGExceptionDelegate nullReferenceDelegate = new SWIGExceptionDelegate(ThrowNullReferenceException);

    [DllImport("$dllimport", EntryPoint="SWIGRegisterExceptionCallbacks_$module")]
    public static extern void SWIGRegisterExceptionCallbacks_$module(
      SWIGExceptionDelegate systemExceptionDelegate,
      SWIGExceptionDelegate outOfMemoryDelegate, 
      SWIGExceptionDelegate indexOutOfRangeDelegate, 
      SWIGExceptionDelegate divideByZeroDelegate, 
      SWIGExceptionDelegate argumentOutOfRangeDelegate,
      SWIGExceptionDelegate nullReferenceDelegate);

    static void ThrowSystemException(string message) {
      throw new System.SystemException(message);
    }

    static void ThrowOutOfMemoryException(string message) {
      throw new System.OutOfMemoryException(message);
    }

    static void ThrowIndexOutOfRangeException(string message) {
      throw new System.IndexOutOfRangeException(message);
    }

    static void ThrowDivideByZeroException(string message) {
      throw new System.DivideByZeroException(message);
    }

    static void ThrowArgumentOutOfRangeException(string message) {
      throw new System.ArgumentOutOfRangeException(message);
    }

    static void ThrowNullReferenceException(string message) {
      throw new System.NullReferenceException(message);
    }

    static SWIGExceptionHelper() {
      SWIGRegisterExceptionCallbacks_$module(systemDelegate, outOfMemoryDelegate, indexOutOfRangeDelegate, divideByZeroDelegate, argumentOutOfRangeDelegate, nullReferenceDelegate);
    }
  }

  static SWIGExceptionHelper exceptionHelper = new SWIGExceptionHelper();
%}
*/





%insert(runtime) 
%{
/* Callback for returning strings to Ada without leaking memory */

typedef char * (SWIGSTDCALL* SWIG_AdaStringHelperCallback)(const char *);
static SWIG_AdaStringHelperCallback SWIG_ada_string_callback = NULL;
%}





%pragma(ada) imclasscode=%{ %}
/*
  class SWIGStringHelper {

    public delegate string SWIGStringDelegate(string message);
    static SWIGStringDelegate stringDelegate = new SWIGStringDelegate(CreateString);

    [DllImport("$dllimport", EntryPoint="SWIGRegisterStringCallback_$module")]
    public static extern void SWIGRegisterStringCallback_$module(SWIGStringDelegate stringDelegate);

    static string CreateString(string cString) {
      return cString;
    }

    static SWIGStringHelper() {
      SWIGRegisterStringCallback_$module(stringDelegate);
    }
  }

  static SWIGStringHelper stringHelper = new SWIGStringHelper();
%}
*/




%insert(runtime) 
%{

/* probably obsolete ...
#ifdef __cplusplus
extern "C" 
#endif
DllExport void SWIGSTDCALL SWIGRegisterStringCallback_$module(SWIG_AdaStringHelperCallback callback) {
  SWIG_ada_string_callback = callback;
}
*/



/* Contract support */
/*
#define SWIG_contract_assert(nullreturn, expr, msg) if (!(expr)) {SWIG_AdaThrowException(SWIG_AdaArgumentOutOfRangeException, msg); return nullreturn; } else
*/
%}
