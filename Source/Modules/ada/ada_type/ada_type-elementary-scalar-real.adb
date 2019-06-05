package body ada_Type.elementary.scalar.real
is

   --  Attributes
   --

   overriding
   function required_Types (Self : access Item) return ada_Type.views
   is
      pragma Unreferenced (Self);
   begin
      return (1 .. 0 => <>);
   end required_Types;


   overriding
   function context_required_Types (Self : access Item) return ada_Type.views
   is
      pragma Unreferenced (Self);
   begin
      return (1 .. 0 => <>);
   end context_required_Types;


   overriding
   function depends_on (Self : access Item;   a_Type : in ada_Type.view;
                                              Depth  : in Natural) return Boolean
   is
      pragma Unreferenced (Self, a_Type, Depth);
   begin
      return False;
   end depends_on;


   overriding
   function depends_directly_on (Self : access Item;   a_Type : in ada_Type.view;
                                                       Depth  : in Natural) return Boolean
   is
      pragma Unreferenced (Self, a_Type, Depth);
   begin
      return False;
   end depends_directly_on;


   overriding
   function depends_on (Self : access Item;   a_Package : access ada_Package.item'Class;
                                              Depth     : in     Natural) return Boolean
   is
      pragma Unreferenced (Self, a_Package, Depth);
   begin
      return False;
   end depends_on;


end ada_Type.elementary.scalar.real;
