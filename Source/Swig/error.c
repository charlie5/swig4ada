/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * error.c
 *
 * Error handling functions.   These are used to issue warnings and
 * error messages.
 * ----------------------------------------------------------------------------- */

char cvsroot_error_c[] = "$Id: error.c 961 2009-03-03 14:54:44Z krischik $";

#include "swig.h"
#include <stdarg.h>
#include <ctype.h>

/* -----------------------------------------------------------------------------
 * Commentary on the warning filter.
 *
 * The warning filter is a string of numbers prefaced by (-) or (+) to
 * indicate whether or not a warning message is displayed.  For example:
 *
 *      "-304-201-140+210+201"
 *
 * The filter string is scanned left to right and the first occurrence
 * of a warning number is used to determine printing behavior.
 *
 * The same number may appear more than once in the string.  For example, in the 
 * above string, "201" appears twice.  This simply means that warning 201
 * was disabled after it was previously enabled.  This may only be temporary
 * setting--the first number may be removed later in which case the warning
 * is reenabled.
 * ----------------------------------------------------------------------------- */

#if defined(_WIN32)
#  define  DEFAULT_ERROR_MSG_FORMAT EMF_MICROSOFT
#else
#  define  DEFAULT_ERROR_MSG_FORMAT EMF_STANDARD
#endif
static ErrorMessageFormat msg_format = DEFAULT_ERROR_MSG_FORMAT;
static int silence = 0;		/* Silent operation */
static String *filter = 0;	/* Warning filter */
static int warnall = 0;
static int nwarning = 0;
static int nerrors = 0;

static int init_fmt = 0;
static char wrn_wnum_fmt[64];
static char wrn_nnum_fmt[64];
static char err_line_fmt[64];
static char err_eof_fmt[64];

static String *format_filename(const String_or_char *filename);

/* -----------------------------------------------------------------------------
 * Swig_warning()
 *
 * Issue a warning message
 * ----------------------------------------------------------------------------- */

void Swig_warning(int wnum, const String_or_char *filename, int line, const char *fmt, ...) {
  String *out;
  char *msg;
  int wrn = 1;
  va_list ap;
  if (silence)
    return;
  if (!init_fmt)
    Swig_error_msg_format(DEFAULT_ERROR_MSG_FORMAT);

  va_start(ap, fmt);

  out = NewStringEmpty();
  vPrintf(out, fmt, ap);

  msg = Char(out);
  if (isdigit((unsigned char) *msg)) {
    unsigned long result = strtoul(msg, &msg, 10);
    if (msg != Char(out)) {
      msg++;
      wnum = result;
    }
  }

  /* Check in the warning filter */
  if (filter) {
    char temp[32];
    char *c;
    char *f = Char(filter);
    sprintf(temp, "%d", wnum);
    while (*f != '\0' && (c = strstr(f, temp))) {
      if (*(c - 1) == '-') {
	wrn = 0;		/* Warning disabled */
        break;
      }
      if (*(c - 1) == '+') {
	wrn = 1;		/* Warning enabled */
        break;
      }
      f += strlen(temp);
    }
  }
  if (warnall || wrn) {
    String *formatted_filename = format_filename(filename);
    if (wnum) {
      Printf(stderr, wrn_wnum_fmt, formatted_filename, line, wnum);
    } else {
      Printf(stderr, wrn_nnum_fmt, formatted_filename, line);
    }
    Printf(stderr, "%s", msg);
    nwarning++;
    Delete(formatted_filename);
  }
  Delete(out);
  va_end(ap);
}

/* -----------------------------------------------------------------------------
 * Swig_error()
 *
 * Issue an error message
 * ----------------------------------------------------------------------------- */

void Swig_error(const String_or_char *filename, int line, const char *fmt, ...) {
  va_list ap;
  String *formatted_filename = NULL;

  if (silence)
    return;
  if (!init_fmt)
    Swig_error_msg_format(DEFAULT_ERROR_MSG_FORMAT);

  va_start(ap, fmt);
  formatted_filename = format_filename(filename);
  if (line > 0) {
    Printf(stderr, err_line_fmt, formatted_filename, line);
  } else {
    Printf(stderr, err_eof_fmt, formatted_filename);
  }
  vPrintf(stderr, fmt, ap);
  va_end(ap);
  nerrors++;
  Delete(formatted_filename);
}

/* -----------------------------------------------------------------------------
 * Swig_error_count()
 *
 * Returns number of errors received.
 * ----------------------------------------------------------------------------- */

int Swig_error_count(void) {
  return nerrors;
}

/* -----------------------------------------------------------------------------
 * Swig_error_silent()
 *
 * Set silent flag
 * ----------------------------------------------------------------------------- */

void Swig_error_silent(int s) {
  silence = s;
}


/* -----------------------------------------------------------------------------
 * Swig_warnfilter()
 *
 * Takes a comma separate list of warning numbers and puts in the filter.
 * ----------------------------------------------------------------------------- */

void Swig_warnfilter(const String_or_char *wlist, int add) {
  char *c;
  char *cw;
  String *s;
  if (!filter)
    filter = NewStringEmpty();

  s = NewString("");
  Clear(s);
  cw = Char(wlist);
  while (*cw != '\0') {
    if (*cw != ' ') {
      Putc(*cw, s);
    }
    ++cw;
  }
  c = Char(s);
  c = strtok(c, ", ");
  while (c) {
    if (isdigit((int) *c) || (*c == '+') || (*c == '-')) {
      /* Even if c is a digit, the rest of the string might not be, eg in the case of typemap 
       * warnings (a bit odd really), eg: %warnfilter(SWIGWARN_TYPEMAP_CHARLEAK_MSG) */
      if (add) {
	Insert(filter, 0, c);
	if (isdigit((int) *c)) {
	  Insert(filter, 0, "-");
	}
      } else {
	char *temp = (char *)malloc(sizeof(char)*strlen(c) + 2);
	if (isdigit((int) *c)) {
	  sprintf(temp, "-%s", c);
	} else {
	  strcpy(temp, c);
	}
	Replace(filter, temp, "", DOH_REPLACE_FIRST);
        free(temp);
      }
    }
    c = strtok(NULL, ", ");
  }
  Delete(s);
}

void Swig_warnall(void) {
  warnall = 1;
}


/* ----------------------------------------------------------------------------- 
 * Swig_warn_count()
 *
 * Return the number of warnings
 * ----------------------------------------------------------------------------- */

int Swig_warn_count(void) {
  return nwarning;
}

/* -----------------------------------------------------------------------------
 * Swig_error_msg_format()
 *
 * Set the type of error/warning message display
 * ----------------------------------------------------------------------------- */

void Swig_error_msg_format(ErrorMessageFormat format) {
  const char *error = "Error";
  const char *warning = "Warning";

  const char *fmt_eof = 0;
  const char *fmt_line = 0;

  /* here 'format' could be directly a string instead of an enum, but
     by now a switch is used to translated into one. */
  switch (format) {
  case EMF_MICROSOFT:
    fmt_line = "%s(%d)";
    fmt_eof = "%s(999999)";	/* Is there a special character for EOF? Just use a large number. */
    break;
  case EMF_STANDARD:
  default:
    fmt_line = "%s:%d";
    fmt_eof = "%s:EOF";
  }

  sprintf(wrn_wnum_fmt, "%s: %s(%%d): ", fmt_line, warning);
  sprintf(wrn_nnum_fmt, "%s: %s: ", fmt_line, warning);
  sprintf(err_line_fmt, "%s: %s: ", fmt_line, error);
  sprintf(err_eof_fmt, "%s: %s: ", fmt_eof, error);

  msg_format = format;
  init_fmt = 1;
}

/* -----------------------------------------------------------------------------
 * format_filename()
 *
 * Remove double backslashes in Windows filename paths for display
 * ----------------------------------------------------------------------------- */
static String *format_filename(const String_or_char *filename) {
  String *formatted_filename = NewString(filename);
#if defined(_WIN32)
  Replaceall(formatted_filename, "\\\\", "\\");
#endif
  return formatted_filename;
}
