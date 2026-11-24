/* -----------------------------------------------------------------------------
 * std_iostream.i
 *
 * The standard streams for Ada. A stream may be used only by reference.
 *
 * Each stream is an instance of a class template ('std::ostream' is
 * 'std::basic_ostream<char, std::char_traits<char> >'), by which a header may
 * name it. The templates are declared, with no definition, and each instance is
 * named by a typedef, so that the core takes either name for the other and the
 * stream is one incomplete class, whichever way it is written.
 * ----------------------------------------------------------------------------- */

%{
#include <iostream>
%}

namespace std {
    template <class CharT>                                 struct char_traits;
    template <class CharT, class Traits = char_traits<CharT> > class basic_ios;
    template <class CharT, class Traits = char_traits<CharT> > class basic_streambuf;
    template <class CharT, class Traits = char_traits<CharT> > class basic_istream;
    template <class CharT, class Traits = char_traits<CharT> > class basic_ostream;
    template <class CharT, class Traits = char_traits<CharT> > class basic_iostream;

    class ios_base;

    typedef basic_ios<char>           ios;
    typedef basic_streambuf<char>     streambuf;
    typedef basic_istream<char>       istream;
    typedef basic_ostream<char>       ostream;
    typedef basic_iostream<char>      iostream;

    typedef basic_ios<wchar_t>        wios;
    typedef basic_streambuf<wchar_t>  wstreambuf;
    typedef basic_istream<wchar_t>    wistream;
    typedef basic_ostream<wchar_t>    wostream;
    typedef basic_iostream<wchar_t>   wiostream;

    extern istream cin;
    extern ostream cout;
    extern ostream cerr;
    extern ostream clog;
}
