//  The sizes of the classes of Bullet which the tester declares, as C++ has them.
//
#include <cstddef>
#include <btBulletDynamicsCommon.h>

inline std::size_t size_of_vector3        () { return sizeof (btVector3); }
inline std::size_t size_of_quaternion     () { return sizeof (btQuaternion); }
inline std::size_t size_of_matrix3x3      () { return sizeof (btMatrix3x3); }
inline std::size_t size_of_transform      () { return sizeof (btTransform); }
inline std::size_t size_of_configuration  () { return sizeof (btDefaultCollisionConfiguration); }
inline std::size_t size_of_dispatcher     () { return sizeof (btCollisionDispatcher); }
inline std::size_t size_of_broadphase     () { return sizeof (btDbvtBroadphase); }
inline std::size_t size_of_solver         () { return sizeof (btSequentialImpulseConstraintSolver); }
inline std::size_t size_of_world          () { return sizeof (btDiscreteDynamicsWorld); }
inline std::size_t size_of_sphere         () { return sizeof (btSphereShape); }
inline std::size_t size_of_plane          () { return sizeof (btStaticPlaneShape); }
inline std::size_t size_of_motion_state   () { return sizeof (btDefaultMotionState); }
inline std::size_t size_of_body           () { return sizeof (btRigidBody); }
inline std::size_t size_of_construction   () { return sizeof (btRigidBody::btRigidBodyConstructionInfo); }
