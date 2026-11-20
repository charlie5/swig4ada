/* -----------------------------------------------------------------------------
 * std_pair.i
 *
 * std::pair for Ada.
 * ----------------------------------------------------------------------------- */

%{
#include <utility>
%}

namespace std {

    template<class T, class U> struct pair {
        typedef T first_type;
        typedef U second_type;

        pair();
        pair(T first, U second);
        pair(const pair& other);

        T first;
        U second;
    };
}
