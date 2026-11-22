/* Further classes of the C++ standard library, each used at run time. */

%module library

%include <std_multiset.i>
%include <std_multimap.i>
%include <std_complex.i>
%include <std_wstring.i>
%include <std_sstream.i>

%{
#include "example.h"
%}

%template (int_Multiset)        std::multiset<int>;
%template (int_double_Multimap) std::multimap<int, double>;
%template (double_Complex)      std::complex<double>;

%include "example.h"
