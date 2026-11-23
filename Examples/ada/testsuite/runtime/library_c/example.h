/* A C library whose binding uses the further library files: 'typemaps.i', 'cdata.i', 'argcargv.i' and 'file.i'. */

#include <stdio.h>
#include <string.h>

/* Parameters which are input, output, or both ('typemaps.i'). */
static inline double add       (double *a, double *b)                   { return *a + *b; }
static inline void   split     (double x, int *whole, double *part)     { *whole = (int) x;  *part = x - *whole; }
static inline void   negate    (int *x)                                 { *x = -*x; }
static inline void   scale_all (short *s, unsigned long *u, float *f)   { *s *= 2;  *u *= 3;  *f *= 0.5f; }
static inline int    is_set    (unsigned char *flag)                    { return *flag != 0; }

/* The arguments of a program ('argcargv.i'). */
static inline int total_length (int ARGC, char **ARGV)   { int n = 0;  for (int i = 0; i < ARGC; i++) n += (int) strlen (ARGV [i]);  return n; }

/* A file, which is used by pointer ('file.i'). */
static inline FILE* open_scratch (void)                         { return tmpfile (); }
static inline int   put_text     (FILE *f, const char *text)    { return fputs (text, f) >= 0; }
static inline long  size_of_file (FILE *f)                      { fflush (f);  return ftell (f); }
static inline int   close_file   (FILE *f)                      { return fclose (f); }

/* Raw data ('cdata.i'). */
static inline int sum_of_bytes (const char *data, size_t len)   { int s = 0;  for (size_t i = 0; i < len; i++) s += (unsigned char) data [i];  return s; }

/* A typemap for a parameter which is applied to every pointer of its type, and so to a result too. */
static inline long *kept (long *value)   { static long the_kept;  the_kept = *value;  return &the_kept; }
