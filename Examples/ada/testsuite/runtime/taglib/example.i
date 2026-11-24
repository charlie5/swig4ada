/* A binding to TagLib, from its own headers: a hierarchy of files and tags, behind a handle which is a value. */

%module taglib

%include <std_string.i>
%include <std_wstring.i>

%{
#include <taglib/fileref.h>
#include <taglib/tpropertymap.h>
#include <taglib/tbytevectorlist.h>
#include "example.h"
%}

#define TAGLIB_EXPORT
#define TAGLIB_MSVC_SUPPRESS_WARNING_NEEDS_TO_HAVE_DLL_INTERFACE

%include <taglib/taglib.h>
%include <taglib/tbytevector.h>
%include <taglib/tstring.h>
%include <taglib/tlist.h>
%include <taglib/tmap.h>

%template (StringList_base) TagLib::List<TagLib::String>;
%template (ByteVectorList_base) TagLib::List<TagLib::ByteVector>;

%include <taglib/tbytevectorlist.h>
%include <taglib/tstringlist.h>
%include <taglib/tvariant.h>

%template (VariantMap) TagLib::Map<TagLib::String, TagLib::Variant>;
%template (SimplePropertyMap) TagLib::Map<TagLib::String, TagLib::StringList>;

%include <taglib/tpropertymap.h>
%include <taglib/tiostream.h>
%include <taglib/tag.h>
%include <taglib/audioproperties.h>
%include <taglib/tfile.h>
%include <taglib/fileref.h>

%include "example.h"
