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

        complex(T re = T(), T im = T());
        complex(const complex& other);

        T real() const;
        T imag() const;
    };
}
