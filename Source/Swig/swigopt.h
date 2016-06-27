/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * swigopt.h
 *
 * Header file for the SWIG command line processing functions
 * ----------------------------------------------------------------------------- */

/* $Id: swigopt.h 961 2009-03-03 14:54:44Z krischik $ */

 extern void  Swig_init_args(int argc, char **argv);
 extern void  Swig_mark_arg(int n);
 extern int   Swig_check_marked(int n);
 extern void  Swig_check_options(int check_input);
 extern void  Swig_arg_error();
