package body Contacts
is

   overriding
   function addSingleResult (Self : access Counter;   cp          : in btManifoldPoint.Pointer;
                                                      colObj0Wrap : in btCollisionObjectWrapper.Pointer;
                                                      partId0     : in interfaces.C.int;
                                                      index0      : in interfaces.C.int;
                                                      colObj1Wrap : in btCollisionObjectWrapper.Pointer;
                                                      partId1     : in interfaces.C.int;
                                                      index1      : in interfaces.C.int) return btScalar
   is
      pragma Unreferenced (colObj0Wrap, partId0, index0, partId1, index1);
   begin
      Self.Points   := Self.Points + 1;
      Self.Distance := btScalar'Min (Self.Distance, btManifoldPoint.getDistance (cp.all));
      Self.Other    := btCollisionObjectWrapper.getCollisionObject (colObj1Wrap.all).all'Address;

      return 0.0;
   end addSingleResult;

end Contacts;
