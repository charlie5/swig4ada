/* A binding to jsoncpp, from its own headers: a class library which nobody wrote as a test. */

%module jsoncpp

%include <std_string.i>
%include <std_iostream.i>
%include <std_vector.i>

%{
#include <json/json.h>
#include "example.h"
%}

//  'Json::String' is a 'std::basic_string' whose allocator 'std::conditional' chooses, which SWIG cannot work out.
//  With 'JSONCPP_USE_SECURE_MEMORY' 0, as the library is built, it is 'std::string', which SWIG is told here.
//
namespace Json { typedef std::string String; }

%include <json/config.h>
%include <json/allocator.h>
%include <json/json_features.h>
%include <json/forwards.h>
%include <json/value.h>

//  The vectors which jsoncpp uses: the names of the members of a value ('Value::Members'), and the arguments of a
//  path. Without them a class with such a member is taken for a plain record, and the functions which use them are
//  left out.
//
%template (Strings)       std::vector<std::string>;
%template (PathArguments) std::vector<Json::PathArgument>;
%include <json/reader.h>
%include <json/writer.h>

%include "example.h"
