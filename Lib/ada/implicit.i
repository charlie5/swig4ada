/* -----------------------------------------------------------------------------
 * implicit.i
 *
 * The %implicit directive, which in other languages lets an argument of one type
 * be given where a class which can be constructed from it is expected.
 *
 * Ada has no implicit conversions, so the directive is accepted and does nothing:
 * the constructor of the class is called explicitly.
 * ----------------------------------------------------------------------------- */

%define %implicit(Type...)
%enddef
