//  The sizes of the structures of Assimp which the tester reads, as C++ has them.
//
#include <cstddef>
#include <assimp/scene.h>

inline std::size_t size_of_scene     () { return sizeof (aiScene); }
inline std::size_t size_of_mesh      () { return sizeof (aiMesh); }
inline std::size_t size_of_face      () { return sizeof (aiFace); }
inline std::size_t size_of_vector3   () { return sizeof (aiVector3D); }
inline std::size_t size_of_node      () { return sizeof (aiNode); }
inline std::size_t size_of_string    () { return sizeof (aiString); }
