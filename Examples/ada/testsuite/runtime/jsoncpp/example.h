/* What the tester needs beside jsoncpp itself: the sizes of a value and a reader, to compare with those of their Ada
   records. */

#include <json/json.h>

inline int size_of_value ()  { return sizeof (Json::Value); }
inline int size_of_reader () { return sizeof (Json::Reader); }
