%module swigg_module


%{
#include "swigconfig.h"
#include "swigwarn.h"

#include "swig.h"
#include "preprocessor.h"

#include "swigtree.h"
#include "swigopt.h"
#include "swigfile.h"
%}


%import "../doh/doh.i"

%rename (Swig_error_file)   Swig_error;

%ignore Swig_fragment_clear;
%ignore Swig_naming_init;


// The headers to be wrapped.
//

%include "swigconfig.h"
%include "swigwarn.h"

%ignore SwigType_remember_trace;
%ignore Swig_symbol_clookup_check;
%ignore Swig_symbol_clookup_local_check;
struct Wrapper;

%include "swig.h"
%include "swigwrap.h"

%include "preprocessor.h"
%include "swigtree.h"

#define FILE void
%include "swigfile.h"

%include "swigopt.h"



// Support Functions
//

%inline
%{

  char*
  String_in (char*    the_string_Array[],
             int      at_Index)
  {
    return the_string_Array [at_Index];
  }


  String*
  c_to_doh_String (char*    c_String)
  {
    return NewStringf ("%s", c_String);
  }

/*
  Node*
  get_attribute (Node*      node,
                 String*    key)
  {
    return Getattr (node, key);
  }


  void
  set_attribute (Node*      node,
                 String*    key,
                 String*    value)
  {
    Setattr (node, key, value);
  }
*/


  int
  check_attribute (Node*      node,
                   String*    key,
                   String*    value)
  {
    return checkAttribute (node, key, value);
  }

                 

  char*
  Node_to_CStr (Node*    node)
  {
    return Char (node);
  }


  DOH*
  node_Type (Node*    node)
  {
    return nodeType (node);
  }


  Node*
  parent_Node (Node*    node)
  {
    return parentNode (node);
  }


  File*
  new_File (String*    name,
            char*      mode)
  {
    return NewFile (name, mode, NULL);

  }


  void
  Print_to (String*    Self,
            char*      the_Text)
  {
    Printv (Self,  the_Text, "\n", NIL);
  }


  void
  dump (File*    from,
        File*    to)
  {
    Dump (from, to);
  }
  

  void
  close_File (File*    Self)
  {
    DohDelete (Self);
  }
  


  void
  doh_replace_All (DOH*            Self,
                   String*         Pattern,
                   String*         Substitute)
  {
    DohReplace (Self,  Pattern, Substitute,  DOH_REPLACE_ANY);
  }


  void
  Swig_save_1 (char*    name_Space, 
               Node*    the_Node, 
               char*    Value)
  {
    Swig_save (name_Space, the_Node, Value, NIL);
  }


  void 
  Swig_require_2 (const char*    name_Space, 
                  Node*          the_Node, 
                  String*        Value_1,
                  String*        Value_2)
  {
    Swig_require (name_Space, the_Node, Value_1, Value_2, NIL);
  }


  void 
  Wrapper_add_local_2 (Wrapper*                 the_Wrapper, 
                       const String_or_char*    Name,
                       char*                    Item_1,
                       char*                    Item_2)
  {
    Wrapper_add_localv (the_Wrapper,  Name,  Item_1, Item_2,  NIL);
  }


  Node*
  first_Child (Node*   Self)
  {
    return firstChild (Self);
  }


  Node*
  next_Sibling (Node*   Self)
  {
    return nextSibling (Self);
  }

%}
