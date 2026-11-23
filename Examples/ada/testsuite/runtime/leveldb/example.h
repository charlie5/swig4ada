/* What the tester needs beside LevelDB itself: a folder of its own for a database. */

#include <string>
#include <cstdlib>
#include <unistd.h>

inline std::string scratch_folder ()                          { char name [] = "/tmp/swig4ada-leveldb-XXXXXX";  return mkdtemp (name); }
inline void        remove_folder  (const std::string& name)   { rmdir (name.c_str ()); }
