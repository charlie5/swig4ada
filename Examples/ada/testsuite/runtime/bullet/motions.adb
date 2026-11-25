with
     bullet.btVector3;

package body Motions
is

   overriding
   procedure getWorldTransform (Self : in out Recorder;   worldTrans : in btTransform.Pointer)
   is
      X      : aliased btScalar       := 0.0;
      Y      : aliased btScalar       := Self.Start_Height;
      Z      : aliased btScalar       := 0.0;
      Origin : aliased btVector3.Item := btVector3.construct (X'unchecked_Access, Y'unchecked_Access, Z'unchecked_Access);
   begin
      btTransform.setIdentity (worldTrans.all);
      btTransform.setOrigin   (worldTrans.all, Origin'unchecked_Access);
   end getWorldTransform;



   overriding
   procedure setWorldTransform (Self : in out Recorder;   worldTrans : in btTransform.Pointer)
   is
   begin
      Self.Height := btVector3.getY (btTransform.getOrigin (worldTrans.all).all).all;
      Self.Steps  := Self.Steps + 1;
   end setWorldTransform;

end Motions;
