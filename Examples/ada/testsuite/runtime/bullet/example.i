/* A binding to Bullet, from its own headers: its vectors, quaternions, matrices and transforms, the shapes of its
   collision library, and a dynamics world which steps rigid bodies. */

%module bullet

%{
#include <btBulletDynamicsCommon.h>
#include "example.h"
%}

%include <LinearMath/btScalar.h>
%include <LinearMath/btMinMax.h>
%include <LinearMath/btAlignedAllocator.h>
%include <LinearMath/btVector3.h>
%include <LinearMath/btQuadWord.h>
%include <LinearMath/btQuaternion.h>
%include <LinearMath/btMatrix3x3.h>
%include <LinearMath/btTransform.h>
%include <LinearMath/btMotionState.h>
%include <LinearMath/btDefaultMotionState.h>
//  The searches of Bullet's vector, and 'remove', which uses one, need the elements to be compared ('operator==' or
//  'operator<'), which the elements of some of its instances cannot be (a 'btSolverBody'): C++ instantiates a member
//  of a template only where it is used, and the wrapper uses each. They are left out of every instance.
//
%ignore btAlignedObjectArray::findBinarySearch;
%ignore btAlignedObjectArray::findLinearSearch;
%ignore btAlignedObjectArray::findLinearSearch2;
%ignore btAlignedObjectArray::remove;

%include <LinearMath/btAlignedObjectArray.h>
%include <LinearMath/btThreads.h>
%include <LinearMath/btIDebugDraw.h>

%include <BulletCollision/BroadphaseCollision/btBroadphaseProxy.h>
%include <BulletCollision/BroadphaseCollision/btBroadphaseInterface.h>
%include <BulletCollision/BroadphaseCollision/btDispatcher.h>
%include <BulletCollision/BroadphaseCollision/btOverlappingPairCallback.h>
%include <BulletCollision/BroadphaseCollision/btOverlappingPairCache.h>
%include <BulletCollision/BroadphaseCollision/btDbvt.h>
%include <BulletCollision/BroadphaseCollision/btDbvtBroadphase.h>

%include <BulletCollision/CollisionShapes/btCollisionShape.h>
%include <BulletCollision/CollisionShapes/btConvexShape.h>
%include <BulletCollision/CollisionShapes/btConvexInternalShape.h>
%include <BulletCollision/CollisionShapes/btPolyhedralConvexShape.h>
%include <BulletCollision/CollisionShapes/btBoxShape.h>
%include <BulletCollision/CollisionShapes/btSphereShape.h>
%include <BulletCollision/CollisionShapes/btTriangleCallback.h>
%include <BulletCollision/CollisionShapes/btConcaveShape.h>
%include <BulletCollision/CollisionShapes/btStaticPlaneShape.h>

%include <BulletCollision/NarrowPhaseCollision/btManifoldPoint.h>
%include <BulletCollision/NarrowPhaseCollision/btPersistentManifold.h>
%include <BulletCollision/CollisionDispatch/btCollisionObject.h>
%include <BulletCollision/CollisionDispatch/btCollisionObjectWrapper.h>
%include <BulletCollision/CollisionDispatch/btCollisionCreateFunc.h>
%include <BulletCollision/CollisionDispatch/btCollisionConfiguration.h>
%include <BulletCollision/CollisionDispatch/btDefaultCollisionConfiguration.h>
%include <BulletCollision/CollisionDispatch/btCollisionDispatcher.h>
%include <BulletCollision/CollisionDispatch/btCollisionWorld.h>

%include <BulletDynamics/Dynamics/btRigidBody.h>
%include <BulletDynamics/ConstraintSolver/btContactSolverInfo.h>
%include <BulletDynamics/ConstraintSolver/btSolverBody.h>
%include <BulletDynamics/ConstraintSolver/btSolverConstraint.h>
%include <BulletDynamics/ConstraintSolver/btTypedConstraint.h>
%include <BulletDynamics/ConstraintSolver/btJacobianEntry.h>
%include <BulletDynamics/ConstraintSolver/btPoint2PointConstraint.h>
%include <BulletDynamics/ConstraintSolver/btHingeConstraint.h>
%include <BulletDynamics/ConstraintSolver/btConstraintSolver.h>
//  The solver declares the forms of its row solvers for SSE, which a build of Bullet without SSE (as this one is)
//  does not define, so that a program which is linked with its binding would not link.
//
%ignore btSequentialImpulseConstraintSolver::getSSE2ConstraintRowSolverGeneric;
%ignore btSequentialImpulseConstraintSolver::getSSE2ConstraintRowSolverLowerLimit;
%ignore btSequentialImpulseConstraintSolver::getSSE4_1ConstraintRowSolverGeneric;
%ignore btSequentialImpulseConstraintSolver::getSSE4_1ConstraintRowSolverLowerLimit;

%include <BulletDynamics/ConstraintSolver/btSequentialImpulseConstraintSolver.h>
%include <BulletDynamics/Dynamics/btActionInterface.h>
%include <BulletDynamics/Dynamics/btDynamicsWorld.h>
%include <BulletDynamics/Dynamics/btDiscreteDynamicsWorld.h>

//  The instances of Bullet's own vector ('btAlignedObjectArray<T>') which the classes hold (the arrays of a world, of
//  a pair cache and of a solver), each with the instance of the allocator which it holds, an empty class.
//
%define %bt_array(NAME, TYPE)
%template (NAME ## _allocator) btAlignedAllocator<TYPE, 16>;
%template (NAME)               btAlignedObjectArray<TYPE>;
%enddef

%bt_array (btCollisionObjectArray,      btCollisionObject*)
%bt_array (btConstCollisionObjectArray, const btCollisionObject*)
%bt_array (btBroadphasePairArray,       btBroadphasePair)
%bt_array (btRigidBodyArray,            btRigidBody*)
%bt_array (btTypedConstraintArray,      btTypedConstraint*)
%bt_array (btPersistentManifoldArray,   btPersistentManifold*)
%bt_array (btActionInterfaceArray,      btActionInterface*)
%bt_array (btIntArray,                  int)
%bt_array (btScalarArray,               btScalar)
%bt_array (btVector3Array,              btVector3)
%bt_array (btSolverBodyArray,           btSolverBody)
%bt_array (btSolverConstraintArray,     btSolverConstraint)
%bt_array (btConstraintInfo1Array,      btTypedConstraint::btConstraintInfo1)
%bt_array (btDbvtStkNNArray,            btDbvt::sStkNN)
%bt_array (btDbvtStkNPSArray,           btDbvt::sStkNPS)
%bt_array (btDbvtNodeArray,             const btDbvtNode*)
%bt_array (btDbvtNodeStack,             btAlignedObjectArray<const btDbvtNode*>)

%include "example.h"
