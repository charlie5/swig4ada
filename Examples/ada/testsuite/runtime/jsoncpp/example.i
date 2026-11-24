/* A binding to jsoncpp, from its own headers: a class library which nobody wrote as a test. */

%module jsoncpp

%include <std_string.i>
%include <std_except.i>      // The base of its exceptions, with the shape of GNU libstdc++.
%include <std_iostream.i>
%include <std_vector.i>
%include <std_deque.i>
%include <std_stack.i>

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

//  The containers of a reader: its stack of the values which it is reading ('Reader::Nodes'), its errors
//  ('Reader::Errors', of its private 'ErrorInfo'), and the errors which it gives.
//
%template (ValueStack)       std::stack<Json::Value*>;
%template (ErrorInfoDeque)   std::deque<Json::Reader::ErrorInfo>;
%template (ReaderErrors)     std::vector<Json::Reader::StructuredError>;
%template (CharReaderErrors) std::vector<Json::CharReader::StructuredError>;

%include <json/writer.h>

%include "example.h"
