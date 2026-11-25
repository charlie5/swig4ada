with
     bullet.btMotionState,
     bullet.btTransform;

package Motions
--
-- A motion state which is declared in Ada and derived from that of Bullet, which Bullet asks for the transform at which
-- a body begins, and tells of the transform of the body after each step. It is at library level, as Bullet calls its
-- functions through the vtable of the class.
--
is
   use bullet;

   type Recorder is new btMotionState.Item with
      record
         Start_Height : btScalar := 0.0;     -- The height at which the body begins.
         Height       : btScalar := 0.0;     -- The height of the body after the last step.
         Steps        : Natural  := 0;       -- How many times Bullet has told of it.
      end record;

   overriding
   procedure getWorldTransform (Self : in out Recorder;   worldTrans : in btTransform.Pointer);
   pragma Convention (CPP, getWorldTransform);

   overriding
   procedure setWorldTransform (Self : in out Recorder;   worldTrans : in btTransform.Pointer);
   pragma Convention (CPP, setWorldTransform);

end Motions;
