/* A binding to yaml-cpp, from its own headers: a node which holds a shared pointer, exceptions of the standard
   library's, and an emitter. Nothing is ignored but one function which the library does not define. */

%module yamlcpp

%include <std_string.i>
%include <std_except.i>
%include <std_vector.i>
%include <std_pair.i>
%include <std_iostream.i>
%include <std_map.i>
%include <std_list.i>

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
//  A node has a 'begin' and an 'end' which are 'const', and others which are not, which are one profile in Ada; those which are
//  not give an iterator through which a value is assigned to an element, and are named apart.
//
%rename (mutable_begin) YAML::Node::begin ();
%rename (mutable_end)   YAML::Node::end ();

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

//  The iterators of a node ('begin' and 'end', of which the 'const' ones are kept), from the headers of yaml-cpp's
//  implementation, which declare them: an iterator holds a 'node_iterator' (the iterators of the vectors of the nodes
//  of a sequence and a map, as GNU libstdc++ has them, of 'std_vector.i') and the shared pointer to the memory of its
//  document, and gives an 'iterator_value', which is a node and a pair of nodes (the key and the value of an element of
//  a map). Its operators are named: '++' is 'next', '*' is 'current', and the instances of the templates '==' and '!='
//  for an iterator of its own kind are 'same_as' and 'differs_from'.
//
%template (key_value)            std::pair<YAML::Node, YAML::Node>;

%rename (next)    YAML::detail::iterator_base::operator++ ();
%rename (current) YAML::detail::iterator_base::operator* () const;

%include <yaml-cpp/node/detail/iterator_fwd.h>
%include <yaml-cpp/node/detail/node_iterator.h>
%include <yaml-cpp/node/detail/iterator.h>
%include <yaml-cpp/node/iterator.h>

%template (node_ptr_pair)        std::pair<YAML::detail::node*, YAML::detail::node*>;
%template (node_seq)             std::vector<YAML::detail::node*>;
%template (node_map)             std::vector<std::pair<YAML::detail::node*, YAML::detail::node*> >;
%template (node_seq_iterator)    __gnu_cxx::__normal_iterator<YAML::detail::node**, std::vector<YAML::detail::node*> >;
%template (node_map_iterator)    __gnu_cxx::__normal_iterator<std::pair<YAML::detail::node*, YAML::detail::node*>*,
                                                              std::vector<std::pair<YAML::detail::node*, YAML::detail::node*> > >;
%template (node_iterator_types)  YAML::detail::node_iterator_type<YAML::detail::node>;
%template (node_iterator)        YAML::detail::node_iterator_base<YAML::detail::node>;
%template (value_iterator)       YAML::detail::iterator_base<YAML::detail::iterator_value>;
%template (const_value_iterator) YAML::detail::iterator_base<const YAML::detail::iterator_value>;

%extend YAML::detail::iterator_base<const YAML::detail::iterator_value> {
  %template (same_as)      operator==<const YAML::detail::iterator_value>;
  %template (differs_from) operator!=<const YAML::detail::iterator_value>;
}

%extend YAML::detail::iterator_base<YAML::detail::iterator_value> {
  %template (same_as)      operator==<YAML::detail::iterator_value>;
  %template (differs_from) operator!=<YAML::detail::iterator_value>;
}

//  The conversions of a value to and from a node, which yaml-cpp's 'as' and the constructor template of a node use: a
//  structure of the class template 'convert', specialised for each type, of two static functions, 'encode', which makes
//  a node of a value, and 'decode', which reads one into a value and says whether it could. An instance is named for
//  each type which the tester uses, among them a vector and a map, whose conversions are partial specialisations.
//
%template (Ints)   std::vector<int>;
%template (Counts) std::map<std::string, int>;
%template (IntList) std::list<int>;

%include <yaml-cpp/node/convert.h>

%template (int_conversion)    YAML::convert<int>;
%template (double_conversion) YAML::convert<double>;
%template (bool_conversion)   YAML::convert<bool>;
%template (string_conversion) YAML::convert<std::string>;
%template (ints_conversion)   YAML::convert<std::vector<int> >;
%template (counts_conversion) YAML::convert<std::map<std::string, int> >;
%template (list_conversion)   YAML::convert<std::list<int> >;

//  A document which is not well formed is refused by an exception ('YAML::ParserException'), which the wrapper records.
//  It is caught as the standard exception which it is derived from, whose 'throws' typemap ('std_except.i') records its
//  own message.
//
%catches (std::runtime_error) YAML::Load;

%include <yaml-cpp/node/parse.h>
%include <yaml-cpp/node/emit.h>

%include "example.h"
