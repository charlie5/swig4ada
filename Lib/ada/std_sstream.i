/* -----------------------------------------------------------------------------
 * std_sstream.i
 *
 * The standard string streams for Ada. A stream may be used only by reference.
 * As in std_iostream.i, each is an instance of a template which is declared
 * alone, named by a typedef.
 * ----------------------------------------------------------------------------- */

%include <std_iostream.i>

%{
#include <sstream>
%}

namespace std {
    template <class CharT> class allocator;

    template <class CharT, class Traits = char_traits<CharT>, class Alloc = allocator<CharT> > class basic_stringbuf;
    template <class CharT, class Traits = char_traits<CharT>, class Alloc = allocator<CharT> > class basic_istringstream;
    template <class CharT, class Traits = char_traits<CharT>, class Alloc = allocator<CharT> > class basic_ostringstream;
    template <class CharT, class Traits = char_traits<CharT>, class Alloc = allocator<CharT> > class basic_stringstream;

    typedef basic_stringbuf<char>          stringbuf;
    typedef basic_istringstream<char>      istringstream;
    typedef basic_ostringstream<char>      ostringstream;
    typedef basic_stringstream<char>       stringstream;
}
