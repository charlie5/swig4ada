/* -----------------------------------------------------------------------------
 * std_sstream.i
 *
 * The standard string streams for Ada. A stream may be used only by reference.
 * ----------------------------------------------------------------------------- */

%include <std_iostream.i>

%{
#include <sstream>
%}

namespace std {
    class stringbuf;
    class istringstream;
    class ostringstream;
    class stringstream;
}
