/* Further classes of the C++ standard library: a multiset, a multimap, a complex number, a wide string and the streams. */

#include <set>
#include <map>
#include <complex>
#include <string>
#include <sstream>
#include <iostream>

/* The size which C++ gives each, for comparison with that of its Ada type. */
inline int size_of_multiset () { return sizeof (std::multiset<int>);         }
inline int size_of_multimap () { return sizeof (std::multimap<int, double>); }
inline int size_of_complex  () { return sizeof (std::complex<double>);       }
inline int size_of_wstring  () { return sizeof (std::wstring);               }

/* A multiset and a multimap made by Ada, filled and read by C++. */
inline void fill  (std::multiset<int>& s, int count)           { for (int i = 1; i <= count; i++) s.insert (i % 3); }
inline int  sum   (std::multiset<int>& s)                      { int t = 0; for (std::multiset<int>::iterator i = s.begin (); i != s.end (); ++i) t += *i; return t; }

inline void   fill  (std::multimap<int, double>& m, int count) { for (int i = 1; i <= count; i++) m.insert (std::pair<int, double> (i % 2, i * 0.5)); }
inline double total (std::multimap<int, double>& m)            { double t = 0; for (std::multimap<int, double>::iterator i = m.begin (); i != m.end (); ++i) t += i->second; return t; }

/* Complex numbers. */
inline std::complex<double> product   (const std::complex<double>& a, const std::complex<double>& b) { return a * b; }
inline std::complex<double> conjugate (std::complex<double> a)                                       { return std::conj (a); }
inline double               magnitude (const std::complex<double>& a)                                { return std::abs (a); }
inline void                 rotate    (std::complex<double>* a)                                      { *a = *a * std::complex<double> (0, 1); }

/* Wide strings. */
inline size_t       wide_length (const std::wstring& s)   { return s.length (); }
inline void         wide_append (std::wstring& s)         { s += L" and a tail which is far too long to be held within the string itself"; }
inline std::wstring wide_make   ()                        { return std::wstring (L"made by C++"); }
inline wchar_t      wide_at     (const std::wstring& s, int i) { return s [i]; }

/* Streams, which are used by reference. */
inline std::ostringstream* new_stream  ()                            { return new std::ostringstream; }
inline void                delete_stream (std::ostringstream* s)     { delete s; }
inline std::ostream&       as_ostream  (std::ostringstream& s)       { return s; }
inline void                write       (std::ostream& s, int value)  { s << value << ';'; }
inline int                 written     (std::ostringstream& s)       { return (int) s.str ().size (); }
inline bool                is_good     (std::ostream& s)             { return s.good (); }
inline std::ostream&       standard_output ()                        { return std::cout; }
