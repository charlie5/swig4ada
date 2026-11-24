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

/* A pointer to a class member, as a result: a structure which holds it, which C returns as it returns the record
   of 'swig' which Ada takes it for ('member_function_Pointer', of two words, or 'member_data_Pointer', of one). */
template <typename T> struct swig_ada_member { T value; };
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

/* The type descriptors of the swig runtime. Ada passes a pointer as it is, and its type is checked when the binding is
   compiled, so the Ada runtime has no table of types. A typemap written for another language may still name a descriptor
   ('$descriptor', 'SWIGTYPE_p_Foo') and convert through one: each descriptor which a wrapper names is declared in its
   header, by the Ada module, and a conversion gives the pointer back as it is. */
typedef struct swig_type_info {
  const char *name;
} swig_type_info;

#define SWIG_ConvertPtr(obj, ptr, type, flags)     ((void) (type), *(ptr) = (void *) (obj), 0)
#define SWIG_NewPointerObj(ptr, type, flags)       ((void) (type), (void *) (ptr))

/* What a function which returns a class gives when it has failed, and left an exception pending: bytes of zero, as
   an object of the class may not be one which can be made. (Such a class is one which is copied bit by bit.) */
#ifdef __cplusplus
template <typename T> static T& swig_ada_no_result ()
{
  static char storage [sizeof (T)];
  return *reinterpret_cast< T * > (storage);
}
#endif

/* A container of a given size. Its elements are made by their default constructor, which the element type may not have:
   the container is then empty, and a pending exception says why. (Without this, the wrapper of a container of such a
   type would not compile, whether or not the constructor were ever called.) */
#if defined (__cplusplus) && __cplusplus >= 201103L
#include <stddef.h>
#include <type_traits>
template <typename C> static C* swig_ada_new_sized_as (size_t n, std::true_type)  { return new C (n); }
template <typename C> static C* swig_ada_new_sized_as (size_t,   std::false_type)
{
  SWIG_AdaThrowException (SWIG_AdaException, "a container cannot be given a size, as its element type has no default constructor");
  return new C ();
}
template <typename C> static C* swig_ada_new_sized (size_t n)
{
  return swig_ada_new_sized_as< C > (n, std::is_default_constructible< typename C::value_type > ());
}
#elif defined (__cplusplus)
#include <stddef.h>
template <typename C> static C* swig_ada_new_sized (size_t n) { return new C (n); }
#endif

%}



%pragma(ada) imclasscode=%{ %}

%insert(runtime) 
%{

%}
