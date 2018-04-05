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



%pragma(ada) imclasscode=%{ %}

%insert(runtime) 
%{

%}
