/* What the tester needs beside jsoncpp itself: the sizes of a value, a reader and an iterator, to compare with those of their Ada
   records. */

#include <json/json.h>

inline int size_of_value ()  { return sizeof (Json::Value); }
inline int size_of_reader () { return sizeof (Json::Reader); }
inline int size_of_const_iterator () { return sizeof (Json::ValueConstIterator); }
