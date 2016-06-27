/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * preprocessor.h
 *
 * SWIG preprocessor module.
 * ----------------------------------------------------------------------------- */

/* $Id: preprocessor.h 961 2009-03-03 14:54:44Z krischik $ */

#ifndef SWIG_PREPROCESSOR_H_
#define SWIG_PREPROCESSOR_H_

#include "swigwarn.h"

#ifdef __cplusplus
extern "C" {
#endif
  extern int Preprocessor_expr(String *s, int *error);
  extern char *Preprocessor_expr_error(void);
  extern Hash *Preprocessor_define(const String_or_char *str, int swigmacro);
  extern void Preprocessor_undef(const String_or_char *name);
  extern void Preprocessor_init(void);
  extern void Preprocessor_delete(void);
  extern String *Preprocessor_parse(String *s);
  extern void Preprocessor_include_all(int);
  extern void Preprocessor_import_all(int);
  extern void Preprocessor_ignore_missing(int);
  extern void Preprocessor_error_as_warning(int);
  extern List *Preprocessor_depend(void);
  extern void Preprocessor_expr_init(void);
  extern void Preprocessor_expr_delete(void);

#ifdef __cplusplus
}
#endif
#endif
