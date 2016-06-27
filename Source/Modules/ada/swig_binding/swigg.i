

%module(directors="1") swigg

%{
//#include "doh.h"
//#include "dohint.h"

#include "swigconfig.h"
#include "swigwarn.h"

#include "swig.h"
#include "preprocessor.h"

#include "swigtree.h"
#include "swigopt.h"
#include "swigmod.h"
#include "swigfile.h"
//#include "swigwrap.h"
%}


%rename (a_current)    _current;
%rename (a_index)      _index;



%ignore _current;
//%rename(doh_String)        String;


//%ignore Language_getCPlusMode;
%ignore Language::getCPlusMode;

%ignore Swig_fragment_clear;
%ignore Swig_naming_init;
%ignore SwigType_template_deftype;
%ignore SwigType_template_defargs;


//#define String   doh_String
//%{
//typedef 
//%}


%ignore ModuleFactory;

//#define Swig_error                Swig_error_file

#define PRIVATE                   a_PRIVATE
#define PROTECTED                 a_PROTECTED

%rename(Swig_error_file)       Swig_error;
%rename(SwigScanner_struct)    struct SwigScanner;


%ignore start_line;



// support functions
//

%inline
%{

  #include <execinfo.h>


  int
  runtime_call_Depth ()
  {
    void*      the_Backtrace [5000];
    int        Count               = backtrace (the_Backtrace, 5000);  // tbd: mem leak ?

    return Count;  
  }





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





  bool
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
    return NewFile (name, mode);

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
    Close (Self);
  }
  



  void
  doh_replace_All (DOH*            Self,
                   String*         Pattern,
                   String*         Substitute)
  {
    DohReplace (Self,  Pattern, Substitute,  DOH_REPLACE_ANY);
  }





  DOH*
  doh_Copy (DOH*    Self)
  {
    return Copy (Self);
  }






  //extern int  Swig_save(const char *ns, Node *node,...);

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




//extern void Swig_restore(Node *node);






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





  void
  exit_with_Fail()
  {
    SWIG_exit (EXIT_FAILURE);
  }





  // doh iterators
  //


  DohIterator
  doh_First (DOH*    obj)
  {
    return DohFirst (obj);
  }


  DohIterator
  doh_Next (DohIterator    iter)
  {
    return DohNext (iter);
  }



  DOH*
  get_Item (DohIterator    Self)
  {
    return Self.item;
  }





  // the 'do_base_*' functions are a hack to overcome the swig/ada modules inability to handle calling overridden base functions.
  //


  void
  do_base_top (Language*    Self,
               Node*        node)
  {
    Self->Language::top (node);
  }



  void
  do_base_enumDeclaration (Language*    Self,
                           Node*        node)
  {
    Self->Language::enumDeclaration (node);
  }



  void
  do_base_classHandler (Language*    Self,
                        Node*        node)
  {
    Self->Language::classHandler (node);
  }




  void
  do_base_memberfunctionHandler (Language*    Self,
                                 Node*        node)
  {
    Self->Language::memberfunctionHandler (node);
  }




  void
  do_base_staticmemberfunctionHandler (Language*    Self,
                                       Node*        node)
  {
    Self->Language::staticmemberfunctionHandler (node);
  }





  void
  do_base_constructorHandler (Language*    Self,
                              Node*        node)
  {
    Self->Language::constructorHandler (node);
  }





  void
  do_base_destructorHandler (Language*    Self,
                              Node*        node)
  {
    Self->Language::destructorHandler (node);
  }





  void
  do_base_memberconstantHandler (Language*    Self,
                                 Node*        node)
  {
    Self->Language::memberconstantHandler (node);
  }


  int
  do_base_insertDirective (Language*    Self,
                           Node*        node)
  {
    return Self->Language::insertDirective (node);
  }


  int
  do_base_typemapDirective (Language*    Self,
                            Node*        node)
  {
    return Self->Language::typemapDirective (node);
  }


  void
  do_base_namespaceDeclaration (Language*    Self,
                                 Node*        node)
  {
    Self->Language::namespaceDeclaration (node);
  }



  void
  do_base_includeDirective (Language*    Self,
                            Node*        node)
  {
    Self->Language::includeDirective (node);
  }

%}  




#define _current   a_current
#define _index     a_index




// directors
//

%feature("director") Dispatcher;
%feature("director") Dispatcher::cplus_mode;
%feature("director") Language;

//%feature("director") Language::allow_overloading; 


// the headers to be wrapped
//

//%include "doh.h"
//%include "dohint.h"

%include "swigconfig.h"
%include "swigwarn.h"
%include "swig.h"
%include "preprocessor.h"
%include "swigtree.h"
%include "swigwrap.h"
%include "swigmod.h"
%include "swigfile.h"
%include "swigopt.h"

