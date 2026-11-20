/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * std::string for Ada, which is the type 'std_String' of the support package
 * 'swig.std_Strings'. This file makes the type known, and adds to the wrapper the
 * functions which that package imports.
 * ----------------------------------------------------------------------------- */

%{
#include <string>

/* One copy of each function is shared by all of the wrapper files of a program. The two which construct a string
   return it by value: C++ then takes the address of the new object as a hidden first argument, which is where a
   constructor takes it, so Ada may import them as constructors. */

#if defined(__GNUC__)
#  define SWIG_ADA_STRING_SHARED __attribute__ ((weak))
#else
#  define SWIG_ADA_STRING_SHARED
#endif

extern "C" {

SWIG_ADA_STRING_SHARED std::string  swig_ada_std_string_construct ()                         { return std::string ();           }
SWIG_ADA_STRING_SHARED std::string  swig_ada_std_string_construct_from_chars (const char* s) { return std::string (s ? s : ""); }

SWIG_ADA_STRING_SHARED const char*  swig_ada_std_string_c_str    (const std::string* s)          { return s->c_str ();    }
SWIG_ADA_STRING_SHARED size_t       swig_ada_std_string_length   (const std::string* s)          { return s->length ();   }
SWIG_ADA_STRING_SHARED void         swig_ada_std_string_assign   (std::string* s, const char* v) { s->assign (v ? v : ""); }
SWIG_ADA_STRING_SHARED void         swig_ada_std_string_destruct (std::string* s)                { typedef std::string T;   s->~T (); }

}
%}

namespace std {
  class string;
}
