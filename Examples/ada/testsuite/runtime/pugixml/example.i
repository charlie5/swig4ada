/* A binding to pugixml, from its own header: small classes which are handles, passed and returned by value. */

%module pugixml

%include <std_string.i>

%{
#include <pugixml.hpp>
%}

%include <pugiconfig.hpp>
%include <pugixml.hpp>
