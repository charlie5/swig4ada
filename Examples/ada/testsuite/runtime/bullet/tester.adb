with
     bullet.Binding,
     bullet.btVector3,
     bullet.btQuaternion,
     bullet.btMatrix3x3,
     bullet.btTransform,
     bullet.btDefaultMotionState,
     bullet.btMotionState,
     bullet.btCollisionShape,
     bullet.btSphereShape,
     bullet.btStaticPlaneShape,
     bullet.btRigidBody,
     bullet.btRigidBodyConstructionInfo,
     bullet.btDefaultCollisionConfiguration,
     bullet.btCollisionConfiguration,
     bullet.btCollisionDispatcher,
     bullet.btDispatcher,
     bullet.btDbvtBroadphase,
     bullet.btBroadphaseInterface,
     bullet.btSequentialImpulseConstraintSolver,
     bullet.btConstraintSolver,
     bullet.btDiscreteDynamicsWorld,
     bullet.btCollisionWorld,
     bullet.btPoint2PointConstraint,
     bullet.btTypedConstraint,
     bullet.ClosestRayResultCallback,
     bullet.RayResultCallback,
     bullet.ContactResultCallback,

     Motions,
     Contacts,

     system,

     swig,
     interfaces.C,
     Checks;


procedure Tester
--
--  A binding to Bullet, made from its own headers: its vectors, quaternions and transforms (plain structures, and
--  classes which C++ constructs), shapes of a hierarchy of classes with virtual functions, rigid bodies, and a world
--  which is made of its collision configuration, dispatcher, broadphase and solver, all of which Ada declares. A
--  sphere falls under gravity, onto a plane, and a motion state which is declared in Ada is told where it is. Another
--  is held by a constraint where it begins. A ray is cast through the world, and the contacts of a body are given to a
--  callback which is declared in Ada.
--
is
   use bullet,
       bullet.Binding,
       Checks;

   use type interfaces.C.int,
            interfaces.C.size_t,
            interfaces.C.C_float,     -- 'btScalar'.
            swig.bool,
            system.Address;

   function bytes (Bits : in Natural) return interfaces.C.size_t is (interfaces.C.size_t (Bits / 8));

   function near (Left, Right : in btScalar;   Within : in btScalar := 0.01) return Boolean
   is (abs (Left - Right) <= Within);

   function value (X, Y, Z : in btScalar) return btVector3.Item
   is
      the_X : aliased btScalar := X;
      the_Y : aliased btScalar := Y;
      the_Z : aliased btScalar := Z;
   begin
      return btVector3.construct (the_X'unchecked_Access, the_Y'unchecked_Access, the_Z'unchecked_Access);
   end value;

begin
   check (bytes (btVector3   .Item'Object_Size) = size_of_vector3,      "a vector has the size of its class, a structure of four numbers");
   check (bytes (btQuaternion.Item'Object_Size) = size_of_quaternion,   "and so has a quaternion");
   check (bytes (btMatrix3x3 .Item'Object_Size) = size_of_matrix3x3,    "and a matrix, which C++ constructs");
   check (bytes (btTransform .Item'Object_Size) = size_of_transform,    "and a transform");
   check (bytes (btDefaultCollisionConfiguration    .Item'Object_Size) = size_of_configuration,  "and a collision configuration, with virtual functions");
   check (bytes (btCollisionDispatcher              .Item'Object_Size) = size_of_dispatcher,     "and a dispatcher");
   check (bytes (btDbvtBroadphase                   .Item'Object_Size) = size_of_broadphase,     "and a broadphase");
   check (bytes (btSequentialImpulseConstraintSolver.Item'Object_Size) = size_of_solver,         "and a solver");
   check (bytes (btDiscreteDynamicsWorld            .Item'Object_Size) = size_of_world,          "and a world");
   check (bytes (btSphereShape                      .Item'Object_Size) = size_of_sphere,         "and a sphere");
   check (bytes (btStaticPlaneShape                 .Item'Object_Size) >= size_of_plane,         "and a plane is no smaller than its class"); -- A type extension, whose
                                                                                                                                   -- members GNAT places after the
                                                                                                                                   -- whole of its parent.
   check (bytes (btDefaultMotionState               .Item'Object_Size) = size_of_motion_state,   "and a motion state");
   check (bytes (btRigidBody                        .Item'Object_Size) = size_of_body,           "and a rigid body");
   check (bytes (btRigidBodyConstructionInfo        .Item'Object_Size) = size_of_construction,   "and what a body is made from");

   vectors :
   declare
      A : aliased btVector3.Item := value (1.0, 2.0, 3.0);
      B : aliased btVector3.Item := value (4.0, 5.0, 6.0);
   begin
      check (btVector3.dot (A, B'unchecked_Access) = 32.0,         "the dot product of two vectors, which Ada declares");
      check (near (btVector3.length (value (3.0, 4.0, 0.0)), 5.0),  "and the length of one");
      check (btVector3.getY (A).all = 2.0,                         "a part of a vector is read");
   end vectors;

   falling :
   declare
      Configuration : aliased btDefaultCollisionConfiguration.Item;
      Dispatcher    : aliased btCollisionDispatcher.Item := btCollisionDispatcher.construct (Configuration'unchecked_Access);
      Broadphase    : aliased btDbvtBroadphase.Item := btDbvtBroadphase.construct;
      Solver        : aliased btSequentialImpulseConstraintSolver.Item;
      World         : aliased btDiscreteDynamicsWorld.Item := btDiscreteDynamicsWorld.construct (Dispatcher   'unchecked_Access,
                                                                                                 Broadphase   'unchecked_Access,
                                                                                                 Solver       'unchecked_Access,
                                                                                                 Configuration'unchecked_Access);
      Gravity       : aliased btVector3.Item := value (0.0, -10.0, 0.0);
      Up            : aliased btVector3.Item := value (0.0,   1.0, 0.0);
      Inertia       : aliased btVector3.Item := value (0.0,   0.0, 0.0);
      None          : aliased btVector3.Item := value (0.0,   0.0, 0.0);

      Sphere        : aliased btSphereShape     .Item := btSphereShape     .construct (1.0);
      Ground        : aliased btStaticPlaneShape.Item := btStaticPlaneShape.construct (Up'unchecked_Access, 0.0);

      Motion        : aliased Motions.Recorder := (btMotionState.Item with Start_Height => 10.0, Height => 0.0, Steps => 0);
      Rest          : aliased btDefaultMotionState.Item;

      Steps         : interfaces.C.int;
   begin
      btDiscreteDynamicsWorld.setGravity (World, Gravity'unchecked_Access);
      btSphereShape.calculateLocalInertia (Sphere, 1.0, Inertia'unchecked_Access);
      check (near (btVector3.getX (Inertia).all, 0.4),             "the inertia of a sphere is worked out, through the vtable of a shape");

      declare
         Ball_Info   : aliased btRigidBodyConstructionInfo.Item := btRigidBodyConstructionInfo.construct (1.0, Motion'unchecked_Access,
                                                                                                         Sphere'unchecked_Access,
                                                                                                         Inertia'unchecked_Access);
         Ground_Info : aliased btRigidBodyConstructionInfo.Item := btRigidBodyConstructionInfo.construct (0.0, Rest'unchecked_Access,
                                                                                                         Ground'unchecked_Access,
                                                                                                         None'unchecked_Access);
         Ball        : aliased btRigidBody.Item := btRigidBody.construct (Ball_Info  'unchecked_Access);
         Floor       : aliased btRigidBody.Item := btRigidBody.construct (Ground_Info'unchecked_Access);

         --  A second sphere, away from the first, which a constraint holds at the point where it begins.
         --
         Lamp_State  : aliased btDefaultMotionState.Item;
         Lamp_Info   : aliased btRigidBodyConstructionInfo.Item := btRigidBodyConstructionInfo.construct (1.0, Lamp_State'unchecked_Access,
                                                                                                         Sphere'unchecked_Access,
                                                                                                         Inertia'unchecked_Access);
         Lamp        : aliased btRigidBody.Item := btRigidBody.construct (Lamp_Info'unchecked_Access);
         Lamp_Place  : aliased btVector3.Item   := value (5.0, 10.0, 0.0);
         Centre      : aliased btVector3.Item   := value (0.0,  0.0, 0.0);
         Hook        : aliased btPoint2PointConstraint.Item := btPoint2PointConstraint.construct (Lamp'unchecked_Access, Centre'unchecked_Access);
      begin
         check (near (btVector3.getY (btRigidBody.getCenterOfMassPosition (Ball'Access).all).all, 10.0),
                "a body begins where a motion state which Ada declares says, which Bullet asks through the vtable");

         btDiscreteDynamicsWorld.addRigidBody (World, Ball 'unchecked_Access);
         btDiscreteDynamicsWorld.addRigidBody (World, Floor'unchecked_Access);

         btRigidBody.translate (Lamp, Lamp_Place'unchecked_Access);
         btPoint2PointConstraint.setPivotB (Hook, Lamp_Place'unchecked_Access);     -- The point in the world at which it is held.
         btDiscreteDynamicsWorld.addRigidBody  (World, Lamp'unchecked_Access);
         btDiscreteDynamicsWorld.addConstraint (World, Hook'unchecked_Access);

         for Each in 1 .. 60
         loop
            Steps := btDiscreteDynamicsWorld.stepSimulation (World'Access, 1.0 / 60.0, 1, 1.0 / 60.0);
         end loop;

         check (Steps = 1,                                         "a world which Ada declares steps the bodies");
         check (near (btVector3.getY (btRigidBody.getCenterOfMassPosition (Ball'Access).all).all, 4.9167),
                "and the sphere falls under gravity as C++ has it: "
                & btScalar'Image (btVector3.getY (btRigidBody.getCenterOfMassPosition (Ball'Access).all).all));
         check (Motion.Steps = 60 and near (Motion.Height, 5.0833), "and the motion state is told of it at each step, a step behind, as Bullet"
                                                                   & " gives it the transform which it interpolates");

         for Each in 1 .. 240
         loop
            Steps := btDiscreteDynamicsWorld.stepSimulation (World'Access, 1.0 / 60.0, 1, 1.0 / 60.0);
         end loop;

         check (near (Motion.Height, 1.0, Within => 0.05),          "the sphere comes to rest on the plane: " & btScalar'Image (Motion.Height));
         check (near (btVector3.getY (btRigidBody.getCenterOfMassPosition (Lamp'Access).all).all, 10.0, Within => 0.05),
                "a sphere which a constraint holds stays where it is held: "
                & btScalar'Image (btVector3.getY (btRigidBody.getCenterOfMassPosition (Lamp'Access).all).all));

         casting_a_Ray :
         declare
            From : aliased btVector3.Item := value (0.0,  10.0, 0.0);
            To   : aliased btVector3.Item := value (0.0, -10.0, 0.0);
            Ray  : aliased ClosestRayResultCallback.Item := ClosestRayResultCallback.construct (From'unchecked_Access, To'unchecked_Access);
         begin
            btDiscreteDynamicsWorld.rayTest (World, From'unchecked_Access, To'unchecked_Access, Ray'unchecked_Access);

            check (RayResultCallback.hasHit (Ray'Access) /= 0,       "a ray which Ada declares is cast through the world, and hits");
            check (near (btVector3.getY (ClosestRayResultCallback.m_hitPointWorld (Ray'Access).all).all, 2.0, Within => 0.05),
                   "the top of the sphere, which rests on the plane");
            check (Ray.m_collisionObject.all'Address = Ball'Address, "and says it is the sphere that it hit");

            ClosestRayResultCallback.destruct_0 (Ray);
         end casting_a_Ray;

         contacts_of_a_Body :
         declare
            --  A sphere which does not move, put where it overlaps the one which the constraint holds (Bullet gives no
            --  contact of a sphere which rests on a plane, as C++ shows too).
            --
            Probe_State : aliased btDefaultMotionState.Item;
            Probe_Info  : aliased btRigidBodyConstructionInfo.Item := btRigidBodyConstructionInfo.construct (0.0, Probe_State'unchecked_Access,
                                                                                                          Sphere'unchecked_Access,
                                                                                                          None'unchecked_Access);
            Probe       : aliased btRigidBody.Item := btRigidBody.construct (Probe_Info'unchecked_Access);
            Probe_Place : aliased btVector3.Item   := value (6.5, 10.0, 0.0);
            Touches     : aliased Contacts.Counter;
         begin
            btRigidBody.translate (Probe, Probe_Place'unchecked_Access);
            btDiscreteDynamicsWorld.addRigidBody (World, Probe'unchecked_Access);

            btCollisionWorld.contactTest (World, Lamp'unchecked_Access, Touches'unchecked_Access);

            check (Touches.Points >= 1,                               "the contacts of a body are given to a callback which Ada declares");
            check (Touches.Other = Probe'Address,                      "with the body which it touches");
            check (near (Touches.Distance, -0.5, Within => 0.05),      "and how far the two overlap");

            btDiscreteDynamicsWorld.removeRigidBody (World, Probe'unchecked_Access);

            ContactResultCallback.destruct_0 (ContactResultCallback.Item (Touches));
            btRigidBody.destruct_0 (Probe);
            btDefaultMotionState.destruct_0 (Probe_State);
         end contacts_of_a_Body;

         btDiscreteDynamicsWorld.removeConstraint (World, Hook'unchecked_Access);
         btDiscreteDynamicsWorld.removeRigidBody  (World, Lamp'unchecked_Access);

         btDiscreteDynamicsWorld.removeRigidBody (World, Floor'unchecked_Access);
         btDiscreteDynamicsWorld.removeRigidBody (World, Ball 'unchecked_Access);

         btPoint2PointConstraint.destruct_0 (Hook);
         btRigidBody.destruct_0 (Lamp);
         btDefaultMotionState.destruct_0 (Lamp_State);
         btRigidBody.destruct_0 (Floor);
         btRigidBody.destruct_0 (Ball);
      end;

      btDefaultMotionState.destruct_0 (Rest);
      btMotionState.destruct_0 (btMotionState.Item (Motion));
      btStaticPlaneShape.destruct_0 (Ground);
      btSphereShape     .destruct_0 (Sphere);
      btDiscreteDynamicsWorld            .destruct_0 (World);
      btSequentialImpulseConstraintSolver.destruct_0 (Solver);
      btDbvtBroadphase                   .destruct_0 (Broadphase);
      btCollisionDispatcher              .destruct_0 (Dispatcher);
      btDefaultCollisionConfiguration    .destruct_0 (Configuration);
   end falling;

   finish;
end Tester;
