/* A binding to pugixml, from its own header: small classes which are handles, passed and returned by value. */

%module pugixml

%include <std_string.i>
%include <std_except.i>      // The base of its exceptions, with the shape of GNU libstdc++.
%include <std_wstring.i>     // Its conversions to and from wide strings.
%include <std_iostream.i>    // Its streams, which are used by reference.

%{
#include <pugixml.hpp>
%}

%include <pugiconfig.hpp>
%include <pugixml.hpp>

//  The ranges which 'children' and 'attributes' give, of each kind of iterator.
//
%template (xml_node_range)       pugi::xml_object_range<pugi::xml_node_iterator>;
%template (xml_attribute_range)  pugi::xml_object_range<pugi::xml_attribute_iterator>;
%template (xml_named_node_range) pugi::xml_object_range<pugi::xml_named_node_iterator>;
