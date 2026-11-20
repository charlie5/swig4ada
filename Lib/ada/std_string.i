/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * std::string for Ada. The typemaps which map std::string onto 'swig.std_String'
 * are part of ada.swg, so all which remains is to make the type known.
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

namespace std {
  class string;
}
