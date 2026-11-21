/* Strings of the C++ standard library: as parameters, results, references and members. */

#include <string>

inline std::string        greet      (const std::string& name)        { return "hello " + name; }
inline int                length_of  (std::string text)               { return (int) text.size (); }
inline void               append_to  (std::string& text, const std::string& more)   { text += more; }
inline void               clear_it   (std::string* text)              { text->clear (); }
inline const std::string& longest    (const std::string& a, const std::string& b)   { return a.size () >= b.size () ? a : b; }
inline std::string        repeat     (const std::string& text, int times)           { std::string r;  for (int i = 0; i < times; i++) r += text;  return r; }

static std::string the_title = "untitled";
inline std::string&       title      ()                               { return the_title; }
inline std::string*       title_at   ()                               { return &the_title; }

class Person {
public:
  std::string name;
  int         age;
  std::string city;

  Person (const std::string& n, int a) : name (n), age (a), city ("nowhere")   {}

  std::string        describe  () const                   { return name + " of " + city; }
  const std::string& get_name  () const                   { return name; }
  void               move_to   (const std::string& c)     { city = c; }
  int                name_size () const                   { return (int) name.size (); }
};

inline int   total_length (Person* p)                     { return (int) (p->name.size () + p->city.size ()); }
