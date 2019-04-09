%module DOHs


%{
#include "doh.h"
//#include "dohint.h"
%}


//%rename (a_current)    _current;
//%rename (a_index)      _index;



//%ignore _current;


//%rename(doh_String)        String;
//#define String   doh_String

typedef doh_String String;



//#define PRIVATE                   a_PRIVATE
//#define PROTECTED                 a_PROTECTED


//%ignore start_line;



//#define _current   a_current
//#define _index     a_index



// The headers to be wrapped.
//

%ignore DohEncoding;
%ignore DohvPrintf;
%ignore DohNewFileFromFile;
%ignore DohSortList;
%ignore DohNewVoid;
%ignore DohNone;

%include "doh.h"


//%ignore DohHashMethods;
//%ignore DohListMethods;
//%ignore DohFileMethods;
//%ignore DohStringMethods;

//struct  DohObjInfo;
//%ignore DohObjInfo;

//%include "dohint.h"


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

/*
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
*/
%}
