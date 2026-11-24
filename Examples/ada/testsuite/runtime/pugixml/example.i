/* A binding to pugixml, from its own header: small classes which are handles, passed and returned by value. */

%module pugixml

%include <std_string.i>
%include <std_except.i>      // The base of its exceptions, with the shape of GNU libstdc++.

%{
#include <pugixml.hpp>
%}

%include <pugiconfig.hpp>
%include <pugixml.hpp>
