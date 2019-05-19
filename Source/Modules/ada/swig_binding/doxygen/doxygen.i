%module DOHs


%{
#include "doxycommands.h"
#include "doxyentity.h" 
#include "doxyparser.h"
#include "doxytranslator.h"
#include "javadoc.h"
#include "pydoc.h"
%}


%import "../swigg/swigg.i"


// The headers to be wrapped.
//

//%include "doxycommands.h"

%include "doxyentity.h" 

//%ignore DoxygenParser::getIgnoreFeature;
//%ignore DoxyCommandEnum DoxygenParser::commandBelongs(const std::string &theCommand);
//%ignore *::commandBelongs();
//%ignore *::split();
//%include "doxyparser.h"

%include "doxytranslator.h"

//%include "javadoc.h"
//%include "pydoc.h"


// Support Functions
//

%inline
%{

%}
