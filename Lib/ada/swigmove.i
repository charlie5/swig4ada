/* -----------------------------------------------------------------------------
 * swigmove.i
 *
 * Input typemaps library for implementing full move semantics when passing
 * parameters by value.
 *
 * The object of the caller is moved from, and is left as its class leaves an
 * object which has been moved from. Ada passes the object by reference, so the
 * wrapper has a pointer to it.
 * ----------------------------------------------------------------------------- */

%typemap (in) SWIGTYPE MOVE
%{
  $1 = SWIG_STD_MOVE (*($&1_ltype) $input);
%}
