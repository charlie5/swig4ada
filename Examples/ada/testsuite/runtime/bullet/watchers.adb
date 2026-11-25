package body Watchers
is

   procedure on_Tick (World : access btDynamicsWorld.Item'Class;   Step : in btScalar)
   is
      pragma Unreferenced (World);
   begin
      Ticks     := Ticks + 1;
      Last_Step := Step;
   end on_Tick;



   overriding
   procedure drawLine (Self : in out Drawer;   from  : in btVector3.Pointer;
                                               to    : in btVector3.Pointer;
                                               color : in btVector3.Pointer)
   is
      pragma Unreferenced (from, to, color);
   begin
      Self.Lines := Self.Lines + 1;
   end drawLine;



   overriding
   procedure drawContactPoint (Self : in out Drawer;   PointOnB  : in btVector3.Pointer;
                                                       normalOnB : in btVector3.Pointer;
                                                       distance  : in btScalar;
                                                       lifeTime  : in interfaces.C.int;
                                                       color     : in btVector3.Pointer)
   is
      pragma Unreferenced (Self, PointOnB, normalOnB, distance, lifeTime, color);
   begin
      null;
   end drawContactPoint;



   overriding
   procedure reportErrorWarning (Self : in out Drawer;   warningString : in interfaces.C.Strings.chars_ptr)
   is
      pragma Unreferenced (Self, warningString);
   begin
      null;
   end reportErrorWarning;



   overriding
   procedure draw3dText (Self : in out Drawer;   location   : in btVector3.Pointer;
                                                 textString : in interfaces.C.Strings.chars_ptr)
   is
      pragma Unreferenced (Self, location, textString);
   begin
      null;
   end draw3dText;



   overriding
   procedure setDebugMode (Self : in out Drawer;   debugMode : in interfaces.C.int)
   is
   begin
      Self.Mode := debugMode;
   end setDebugMode;



   overriding
   function getDebugMode (Self : access Drawer) return interfaces.C.int
   is
   begin
      return Self.Mode;
   end getDebugMode;

end Watchers;
