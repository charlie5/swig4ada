/* What the tester needs beside yaml-cpp itself: the sizes of a node and an emitter, to compare with those of their
   Ada records. */

#include <yaml-cpp/yaml.h>

inline int size_of_node ()    { return sizeof (YAML::Node); }
inline int size_of_emitter () { return sizeof (YAML::Emitter); }
inline int size_of_mark ()    { return sizeof (YAML::Mark); }
