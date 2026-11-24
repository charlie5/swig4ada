/* A binding to yaml-cpp, from its own headers: a node which holds a shared pointer, exceptions of the standard
   library's, and an emitter. Nothing is ignored but one function which the library does not define. */

%module yamlcpp

%include <std_string.i>
%include <std_except.i>
%include <std_vector.i>
%include <std_iostream.i>

%{
#include <yaml-cpp/yaml.h>
#include "example.h"
%}

//  'dll.h' makes 'YAML_CPP_API' an attribute of visibility, which SWIG does not read; for a static library it makes it
//  nothing. (This is for SWIG's reading alone: the wrapper includes the headers as they are.)
//
#define YAML_CPP_STATIC_DEFINE

%include <yaml-cpp/dll.h>

//  The buffer of an 'ostream_wrapper'.
//
%template (Chars) std::vector<char>;
%include <yaml-cpp/noexcept.h>
%include <yaml-cpp/mark.h>
%include <yaml-cpp/emitterstyle.h>
%include <yaml-cpp/emitterdef.h>
%include <yaml-cpp/emittermanip.h>
%include <yaml-cpp/ostream_wrapper.h>
//  'null.h' declares a function of the old interface which the library does not define ('// old API only'), so that a
//  program which is linked with its binding would not link. It is the one declaration which is ignored.
//
%ignore YAML::IsNull (const Node&);

%include <yaml-cpp/null.h>
%include <yaml-cpp/emitter.h>
%include <yaml-cpp/exceptions.h>
%include <yaml-cpp/node/type.h>
%include <yaml-cpp/node/ptr.h>
%include <yaml-cpp/node/node.h>

//  The member templates of a node, of which an instance is named for each type which the tester uses: a node is made
//  from a value, a value is read from it ('as'), a child is found by its key ('operator[]'), and values are appended
//  to a sequence ('push_back').
//
//
//  'operator[]' has a 'const' overload and one which is not, which are one profile in Ada, so that the core would keep the
//  first alone ('child'), which gives a copy of the child. The other is named apart ('element'): the node which it gives is a
//  part of its document, and a value which is assigned to it ('assign', of 'operator=') changes the document.
//
%rename (element) YAML::Node::operator[] (std::string const &);
%rename (element) YAML::Node::operator[] (int const &);

%extend YAML::Node {
  %template (Node)        Node<int>;
  %template (Node)        Node<std::string>;
  %template (as_int)      as<int>;
  %template (as_double)   as<double>;
  %template (as_string)   as<std::string>;
  %template (child)       operator[]<std::string>;
  %template (child)       operator[]<int>;
  %template (push_back)   push_back<int>;
  %template (push_back)   push_back<std::string>;
  %template (assign)      operator=<int>;
  %template (assign)      operator=<std::string>;
}

//  The documents which 'LoadAll' gives.
//
%template (Nodes) std::vector<YAML::Node>;

//  A document which is not well formed is refused by an exception ('YAML::ParserException'), which the wrapper records.
//  It is caught as the standard exception which it is derived from, whose 'throws' typemap ('std_except.i') records its
//  own message.
//
%catches (std::runtime_error) YAML::Load;

%include <yaml-cpp/node/parse.h>
%include <yaml-cpp/node/emit.h>

%include "example.h"
