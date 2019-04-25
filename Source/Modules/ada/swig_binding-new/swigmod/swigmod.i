%module swigmod

%{
#include "swigconfig.h"
#include "swigwarn.h"

#include "swig.h"
#include "preprocessor.h"

#include "swigtree.h"
#include "swigopt.h"
#include "swigmod.h"
#include "swigfile.h"
%}


%import "../swigg/swigg.i"


// The headers to be wrapped.
//

%ignore Swig_register_module;
%ignore Swig_find_module;
%ignore argv_template_string;
%ignore argc_template_string;


%include "swigmod.h"


// Support Functions
//

%inline
%{
  
  void
  exit_with_Fail()
  {
    SWIG_exit (EXIT_FAILURE);
  }


  void
  do_base_top (Language*    Self,
               Node*        node)
  {
    Self->Language::top (node);
  }

%}
