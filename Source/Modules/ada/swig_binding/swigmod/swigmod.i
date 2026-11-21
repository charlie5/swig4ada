%module swigmod

%{
#include "swigconfig.h"
#include "swigwarn.h"

#include "swig.h"
#include "preprocessor.h"

#include "swigtree.h"
#include "swigopt.h"

// The Ada module binds the protected members of the 'Language' class, so the wrappers need access to them.
//
#define protected public
#include "swigmod.h"
#undef protected

#include "swigfile.h"
%}


%import "../swig_core/swig_core.i"


// The headers to be wrapped.
//

%ignore Language::getCPlusMode;

%ignore Swig_register_module;
%ignore Swig_find_module;
%ignore argv_template_string;
%ignore argc_template_string;

class DoxygenTranslator;

%ignore ModuleFactory;
%ignore TargetLanguageModule;
%ignore SWIG_main;

%include "swigmod.h"


// Support Functions
//

%inline
%{
  
  void
  exit_with_Fail()
  {
    Exit (EXIT_FAILURE);
  }


  void
  do_base_top (Language*    Self,
               Node*        node)
  {
    Self->Language::top (node);
  }

%}
