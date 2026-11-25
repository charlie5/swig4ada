/* A binding to tinyxml2, from its own header: a document which owns its nodes, a hierarchy of nodes reached by
   pointer, and a visitor, which is derived in Ada and called back by the library. Nothing is ignored. */

%module tinyxml2

%include <file.i>            // 'LoadFile' and 'SaveFile' of a 'FILE *', and the printer which writes to one.

%{
#include <tinyxml2.h>
#include "example.h"

//  The pools of a document are instances of a template whose argument is the size of a class of the namespace,
//  written as the header writes it ('MemPoolT< sizeof(XMLElement) >').
//
using namespace tinyxml2;
%}

%include <tinyxml2.h>

//  The private members of a document and a printer: a vector of its own, of a fixed initial room, and the pools from
//  which a document makes its nodes.
//
%template (NodePointers) tinyxml2::DynArray<tinyxml2::XMLNode*, 10>;
%template (Chars)        tinyxml2::DynArray<char, 20>;
%template (Names)        tinyxml2::DynArray<const char*, 10>;

namespace tinyxml2 {
  %template (ElementPool)   MemPoolT<sizeof(XMLElement)>;
  %template (AttributePool) MemPoolT<sizeof(XMLAttribute)>;
  %template (TextPool)      MemPoolT<sizeof(XMLText)>;
  %template (CommentPool)   MemPoolT<sizeof(XMLComment)>;

  //  Each pool keeps its blocks in such a vector, of pointers to a structure of its own.
  //
  %template (ElementBlocks)   DynArray<MemPoolT<sizeof(XMLElement)>::Block*, 10>;
  %template (AttributeBlocks) DynArray<MemPoolT<sizeof(XMLAttribute)>::Block*, 10>;
  %template (TextBlocks)      DynArray<MemPoolT<sizeof(XMLText)>::Block*, 10>;
  %template (CommentBlocks)   DynArray<MemPoolT<sizeof(XMLComment)>::Block*, 10>;
}

%include "example.h"
