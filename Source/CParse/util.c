/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * util.c
 *
 * Parsing utilities.
 * ----------------------------------------------------------------------------- */

char cvsroot_util_c[] = "$Id: util.c 961 2009-03-03 14:54:44Z krischik $";

#include "swig.h"
#include "cparse.h"

/* -----------------------------------------------------------------------------
 * Swig_cparse_replace_descriptor()
 *
 * Replaces type descriptor string $descriptor() with the SWIG type descriptor
 * string.
 * ----------------------------------------------------------------------------- */

void Swig_cparse_replace_descriptor(String *s) {
  char tmp[512];
  String *arg = 0;
  SwigType *t;
  char *c = 0;

  while ((c = strstr(Char(s), "$descriptor("))) {
    char *d = tmp;
    int level = 0;
    while (*c) {
      if (*c == '(')
	level++;
      if (*c == ')') {
	level--;
	if (level == 0) {
	  break;
	}
      }
      *d = *c;
      d++;
      c++;
    }
    *d = 0;
    arg = NewString(tmp + 12);
    t = Swig_cparse_type(arg);
    Delete(arg);
    arg = 0;

    if (t) {
      String *mangle;
      String *descriptor;

      mangle = SwigType_manglestr(t);
      descriptor = NewStringf("SWIGTYPE%s", mangle);
      SwigType_remember(t);
      *d = ')';
      d++;
      *d = 0;
      Replace(s, tmp, descriptor, DOH_REPLACE_ANY);
      Delete(mangle);
      Delete(descriptor);
      Delete(t);
    } else {
      Swig_error(Getfile(s), Getline(s), "Bad $descriptor() macro.\n");
      break;
    }
  }
}

/* -----------------------------------------------------------------------------
 * cparse_normalize_void()
 *
 * This function is used to replace arguments of the form (void) with empty
 * arguments in C++
 * ----------------------------------------------------------------------------- */

void cparse_normalize_void(Node *n) {
  String *decl = Getattr(n, "decl");
  Parm *parms = Getattr(n, "parms");

  if (SwigType_isfunction(decl)) {
    if ((ParmList_len(parms) == 1) && (SwigType_type(Getattr(parms, "type")) == T_VOID)) {
      Replaceall(decl, "f(void).", "f().");
      Delattr(n, "parms");
    }
  }
}
