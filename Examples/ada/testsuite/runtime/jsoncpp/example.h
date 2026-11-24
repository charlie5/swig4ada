/* What the tester needs beside jsoncpp itself: the size of a value, to compare with that of its Ada record. */

#include <json/json.h>

inline int size_of_value () { return sizeof (Json::Value); }
