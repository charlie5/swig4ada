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

%typemap (in, moves="1") SWIGTYPE MOVE     // 'moves' tells the Ada module that a construction function moves it, too.
%{
  $1 = SWIG_STD_MOVE (*($&1_ltype) $input);
%}
