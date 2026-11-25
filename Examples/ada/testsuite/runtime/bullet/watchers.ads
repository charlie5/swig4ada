with
     bullet.btIDebugDraw,
     bullet.btDynamicsWorld,
     bullet.btVector3,
     interfaces.C.Strings;

package Watchers
--
-- What Bullet tells of a world as it steps it and draws it: a function which is given each tick of a world, which is
-- named to Bullet by a pointer to it, and a drawer which is declared in Ada and derived from Bullet's, whose functions
-- Bullet calls through the vtable as it draws a world. They are at library level, as Bullet calls them.
--
is
   use bullet;

   Ticks     : Natural  := 0;     -- How many ticks the world has had.
   Last_Step : btScalar := 0.0;   -- The time of the last.

   procedure on_Tick (World : access btDynamicsWorld.Item'Class;   Step : in btScalar);
   pragma Convention (C, on_Tick);


   type Drawer is new btIDebugDraw.Item with
      record
         Lines : Natural           := 0;     -- How many lines Bullet has drawn through it.
         Mode  : interfaces.C.int  := 0;
      end record;

   overriding
   procedure drawLine (Self : in out Drawer;   from  : in btVector3.Pointer;
                                               to    : in btVector3.Pointer;
                                               color : in btVector3.Pointer);
   pragma Convention (CPP, drawLine);

   overriding
   procedure drawContactPoint (Self : in out Drawer;   PointOnB  : in btVector3.Pointer;
                                                       normalOnB : in btVector3.Pointer;
                                                       distance  : in btScalar;
                                                       lifeTime  : in interfaces.C.int;
                                                       color     : in btVector3.Pointer);
   pragma Convention (CPP, drawContactPoint);

   overriding
   procedure reportErrorWarning (Self : in out Drawer;   warningString : in interfaces.C.Strings.chars_ptr);
   pragma Convention (CPP, reportErrorWarning);

   overriding
   procedure draw3dText (Self : in out Drawer;   location   : in btVector3.Pointer;
                                                 textString : in interfaces.C.Strings.chars_ptr);
   pragma Convention (CPP, draw3dText);

   overriding
   procedure setDebugMode (Self : in out Drawer;   debugMode : in interfaces.C.int);
   pragma Convention (CPP, setDebugMode);

   overriding
   function getDebugMode (Self : access Drawer) return interfaces.C.int;
   pragma Convention (CPP, getDebugMode);

end Watchers;
