/* What the tester needs beside LevelDB itself: a folder of its own for a database. */

#include <string>
#include <cstdlib>
#include <unistd.h>

inline std::string scratch_folder ()                          { char name [] = "/tmp/swig4ada-leveldb-XXXXXX";  return mkdtemp (name); }
inline void        remove_folder  (const std::string& name)   { rmdir (name.c_str ()); }

/* What C++ does with a database which it is given, of whatever kind: one which is declared in Ada ('Notebooks')
   implements the functions of 'leveldb::DB' which return a status, through its director. */
#include <leveldb/db.h>

inline std::string put_into    (leveldb::DB* db, const std::string& key, const std::string& value) { return db->Put (leveldb::WriteOptions (), key, value).ToString (); }
inline std::string delete_from (leveldb::DB* db, const std::string& key)                           { return db->Delete (leveldb::WriteOptions (), key).ToString (); }
inline std::string get_from    (leveldb::DB* db, const std::string& key)
{
  std::string     value;
  leveldb::Status status = db->Get (leveldb::ReadOptions (), key, &value);
  return status.ok () ? value : status.ToString ();
}
