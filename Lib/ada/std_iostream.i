/* -----------------------------------------------------------------------------
 * std_iostream.i
 *
 * The standard streams for Ada. A stream may be used only by reference.
 * ----------------------------------------------------------------------------- */

%{
#include <iostream>
%}

namespace std {
    class ios_base;
    class ostream;
    class istream;
    class iostream;

    extern istream cin;
    extern ostream cout;
    extern ostream cerr;
    extern ostream clog;
}
