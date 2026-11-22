/* -----------------------------------------------------------------------------
 * std_complex.i
 *
 * std::complex for Ada.
 * ----------------------------------------------------------------------------- */

%{
#include <complex>
%}

namespace std {

    template<class T> class complex {
      public:
        // The real part is followed by the imaginary part, as the C++ standard requires.
        T            impl_M_real;
        T            impl_M_imag;

        // Neither a copy constructor nor a destructor is declared: a complex number is trivial, and C++
        // passes and returns it as it does a plain structure.
        complex(T re = T(), T im = T());

        T real() const;
        T imag() const;
    };
}
