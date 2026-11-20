/* -----------------------------------------------------------------------------
 * adahead.swg
 *
 * Ada support code - insertions into C wrapper code
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

/* Replaces an object of the caller by a result which C++ has just made: the object is destructed, and the
   result is moved (or, before C++11, copied) into its place. The assignment of the class is not used. */
template <typename T> static void swig_ada_replace (T* target, T& value)
{
  target->~T ();
#  if __cplusplus >= 201103L
  new (target) T (static_cast<T &&> (value));
#  else
  new (target) T (value);
#  endif
}
#endif


/* Exceptions.

   A C++ exception must not leave a wrapper function, so a wrapper which catches one (see the 'throws' typemaps)
   records it here, as does a typemap which detects an error. The record holds the latest such event, and may
   be examined, and cleared, from Ada by importing the three functions below (Convention => C).
*/

typedef enum {
  SWIG_AdaNoException = 0,
  SWIG_AdaException,
  SWIG_AdaNullReferenceException,
  SWIG_AdaOutOfMemoryException,
  SWIG_AdaIndexOutOfRangeException,
  SWIG_AdaDivideByZeroException,
  SWIG_AdaArgumentOutOfRangeException,
  SWIG_AdaIOException,
  SWIG_AdaOverflowException
} SWIG_AdaExceptionCodes;

#ifndef SWIG_ADA_PENDING_EXCEPTION
#define SWIG_ADA_PENDING_EXCEPTION

#  if defined(__GNUC__)
#    define SWIG_ADA_SHARED __attribute__ ((weak))     /* One copy is shared by all of the wrapper files of a program. */
#  else
#    define SWIG_ADA_SHARED
#  endif

#  ifdef __cplusplus
extern "C" {
#  endif

SWIG_ADA_SHARED int  swig_ada_pending_exception_code           = SWIG_AdaNoException;
SWIG_ADA_SHARED char swig_ada_pending_exception_message [1024] = "";

SWIG_ADA_SHARED int         swig_ada_pending_exception      (void) { return swig_ada_pending_exception_code;    }
SWIG_ADA_SHARED const char *swig_ada_pending_exception_text (void) { return swig_ada_pending_exception_message; }

SWIG_ADA_SHARED void swig_ada_clear_pending_exception (void) {
  swig_ada_pending_exception_code        = SWIG_AdaNoException;
  swig_ada_pending_exception_message [0] = 0;
}

#  ifdef __cplusplus
}
#  endif

#endif

static void SWIG_AdaThrowException (SWIG_AdaExceptionCodes code, const char *msg) {
  swig_ada_pending_exception_code = code;
  strncpy (swig_ada_pending_exception_message, msg ? msg : "", sizeof (swig_ada_pending_exception_message) - 1);
  swig_ada_pending_exception_message [sizeof (swig_ada_pending_exception_message) - 1] = 0;
}

/* Contracts (%contract): a violated contract is recorded as a pending exception, and the wrapper returns. */
#define SWIG_contract_assert(nullreturn, expr, msg) if (!(expr)) { SWIG_AdaThrowException (SWIG_AdaArgumentOutOfRangeException, msg); return nullreturn; } else

/* Kept so that a wrapper which uses no exception does not draw an 'unused function' warning. */
static void (*swig_ada_throw_exception_reference) (SWIG_AdaExceptionCodes, const char *) = SWIG_AdaThrowException;

%}



%pragma(ada) imclasscode=%{ %}

%insert(runtime) 
%{

%}
