%module DOHs


%{
#include "doh.h"
//#include "dohint.h"
%}


//typedef doh_String String;


// The headers to be wrapped.
//

%ignore DohEncoding;
%ignore DohvPrintf;
%ignore DohNewFileFromFile;
%ignore DohSortList;
%ignore DohNewVoid;
%ignore DohNone;
%ignore DohFuncPtr;
%ignore DohFuncPtr_t;

%include "doh.h"


// Support Functions
//

%inline
%{

  #include <execinfo.h>

/*
  String*
  c_to_doh_String (char*    c_String)
  {
    return NewStringf ("%s", c_String);
  }



  void
  doh_replace_All (DOH*            Self,
                   String*         Pattern,
                   String*         Substitute)
  {
    DohReplace (Self,  Pattern, Substitute,  DOH_REPLACE_ANY);
  }
*/


  DOH*
  doh_Copy (DOH*    Self)
  {
    return Copy (Self);
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

%}
