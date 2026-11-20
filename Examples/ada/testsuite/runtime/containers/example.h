#include <vector>
#include <list>
#include <deque>
#include <set>
#include <map>
#include <utility>

/* The size which C++ gives each container, for comparison with that of its Ada type. */
inline int size_of_vector () { return sizeof (std::vector<int>);       }
inline int size_of_list   () { return sizeof (std::list<int>);         }
inline int size_of_deque  () { return sizeof (std::deque<int>);        }
inline int size_of_set    () { return sizeof (std::set<int>);          }
inline int size_of_map    () { return sizeof (std::map<int, double>);  }
inline int size_of_pair   () { return sizeof (std::pair<int, double>); }

/* Functions which fill, and read, a container made by Ada. */
inline void fill (std::vector<int>& v, int count) { for (int i = 1; i <= count; i++) v.push_back (i * 10); }
inline int  sum  (std::vector<int>& v)            { int s = 0; for (size_t i = 0; i < v.size (); i++) s += v [i]; return s; }

inline void fill (std::list<int>&  l, int count)  { for (int i = 1; i <= count; i++) l.push_back (i); }
inline int  sum  (std::list<int>&  l)             { int s = 0; for (std::list<int>::iterator i = l.begin (); i != l.end (); ++i) s += *i; return s; }

inline void fill (std::deque<int>& d, int count)  { for (int i = 1; i <= count; i++) d.push_back (i); }
inline void fill (std::set<int>&   s, int count)  { for (int i = 1; i <= count; i++) s.insert (i % 5); }

inline void   fill   (std::map<int, double>& m, int count) { for (int i = 1; i <= count; i++) m [i] = i * 1.5; }
inline double lookup (std::map<int, double>& m, int key)   { return m [key]; }

inline std::pair<int, double> make_pair_of (int i, double d) { return std::pair<int, double> (i, d); }
