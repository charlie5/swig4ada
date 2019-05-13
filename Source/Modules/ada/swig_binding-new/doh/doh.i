%module DOHs


%{
#include "doh.h"
%}


// The headers to be wrapped.
//

%ignore DohEncoding;
%ignore DohvPrintf;

//typedef void FILE;
%ignore DohNewFileFromFile;

%ignore DohSortList;
%ignore DohNewVoid;
%ignore DohNone;
%ignore DohFuncPtr;

%include "doh.h"


// Support Functions
//

%inline
%{

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
