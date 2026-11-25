//  The sizes of the classes of tinyxml2 which the tester declares, as C++ has them.
//
#include <cstddef>
#include <tinyxml2.h>

inline std::size_t size_of_document () { return sizeof (tinyxml2::XMLDocument); }
inline std::size_t size_of_printer  () { return sizeof (tinyxml2::XMLPrinter);  }
inline std::size_t size_of_visitor  () { return sizeof (tinyxml2::XMLVisitor);  }
