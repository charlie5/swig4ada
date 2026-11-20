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
        // No copy constructor is declared: that of a pair is trivial where those of its
        // members are, and declaring one here would have it bound as a class which is not.

        pair();
        pair(T first, U second);

        T first;
        U second;
    };
}
