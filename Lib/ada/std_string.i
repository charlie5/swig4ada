/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * std::string for Ada, which is the type 'std_String' of the support package
 * 'swig.std_Strings'. This file makes the type known, and asks for the functions
 * which that package imports to be added to the wrapper.
 * ----------------------------------------------------------------------------- */

// The functions are a fragment of 'ada.swg', as a spec may need them where this file is not included.
//
%fragment ("SwigAdaStdString");

namespace std {
  class string;
}
