/* The containers of the C++ standard library, made by Ada and filled by C++. */

%module containers

%include <std_vector.i>
%include <std_list.i>
%include <std_deque.i>
%include <std_set.i>
%include <std_map.i>
%include <std_pair.i>

%{
#include "example.h"
%}

%template (int_Vector)     std::vector<int>;
%template (int_List)       std::list<int>;
%template (int_Deque)      std::deque<int>;
%template (int_Set)        std::set<int>;
%template (int_double_Map) std::map<int, double>;
%template (int_double_Pair) std::pair<int, double>;

%include "example.h"

%template (colour_Vector)  std::vector<Palette::colour>;
