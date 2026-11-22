/* -----------------------------------------------------------------------------
 * std_unique_ptr.i
 *
 * SWIG library file for handling std::unique_ptr.
 *
 * A 'std::unique_ptr' is bound like any other class, so this file declares the
 * data member of the GNU libstdc++ implementation, which gives the Ada record
 * the layout of the C++ object. An instance must be named ('%template
 * (Klass_owner) std::unique_ptr<Klass>;') for the functions which take or
 * return one to be bound; otherwise they are left out, with a warning.
 *
 * '%unique_ptr (TYPE)' says that such a pointer which is passed by value is
 * moved from, as it cannot be copied.
 * ----------------------------------------------------------------------------- */

// The generic 'unique_ptr.swg' is not included: it declares the class with no members, and this file must declare it.

%define %unique_ptr(TYPE)
%typemap (in, moves="1") std::unique_ptr< TYPE >
%{
  $1 = SWIG_STD_MOVE (*($&1_ltype) $input);
%}
%enddef

namespace std {
  template <class T> class unique_ptr {
    public:
      T* impl_M_ptr;

      unique_ptr ();
     ~unique_ptr ();
      T* get () const;
      T* release ();
      void reset (T* p = 0);
  };
}
