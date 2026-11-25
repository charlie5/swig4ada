with
     bullet.ContactResultCallback,
     bullet.btManifoldPoint,
     bullet.btCollisionObjectWrapper,
     interfaces.C,
     system;

package Contacts
--
-- A callback which is declared in Ada and derived from that of Bullet for the contacts of a body, which Bullet calls
-- with each point at which the body touches another. It is at library level, as Bullet calls it through the vtable.
--
is
   use bullet;

   type Counter is new ContactResultCallback.Item with
      record
         Points   : Natural        := 0;                     -- How many points of contact Bullet has given.
         Distance : btScalar       := 1.0e9;                 -- The least distance between the bodies at them.
         Other    : system.Address := system.null_Address;   -- The other body.
      end record;

   overriding
   function addSingleResult (Self : access Counter;   cp          : in btManifoldPoint.Pointer;
                                                      colObj0Wrap : in btCollisionObjectWrapper.Pointer;
                                                      partId0     : in interfaces.C.int;
                                                      index0      : in interfaces.C.int;
                                                      colObj1Wrap : in btCollisionObjectWrapper.Pointer;
                                                      partId1     : in interfaces.C.int;
                                                      index1      : in interfaces.C.int) return btScalar;
   pragma Convention (CPP, addSingleResult);

end Contacts;
