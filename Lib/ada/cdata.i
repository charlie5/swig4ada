/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 *
 * In Ada the data is a record of a pointer and a length, as it is in C, and
 * 'memmove' takes a pointer and a length, so no typemap is needed.
 * ----------------------------------------------------------------------------- */

#define SWIG_CDATA_APPLIED

%include <typemaps/cdata_begin.swg>

typedef struct SWIGCDATA {
  char *data;
  size_t len;
} SWIGCDATA;

%include <typemaps/cdata_end.swg>
