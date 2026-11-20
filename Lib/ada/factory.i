/* -----------------------------------------------------------------------------
 * factory.i
 *
 * The %factory directive, which in other languages makes a factory method return
 * an object of its most derived class.
 *
 * Ada has no need of it. A C++ class with virtual functions is bound as a tagged
 * type which shares the vtable of the class, so an object reached through a pointer
 * to a base class already has the tag of its own class: dispatching calls and
 * membership tests work without any conversion. The directive is accepted, and
 * does nothing.
 * ----------------------------------------------------------------------------- */

%define %factory(Method,Types...)
%enddef
