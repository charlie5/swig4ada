package body ada_Type.composite.a_protected
is

   --  Attributes
   --

   overriding
   function required_Types (Self : access Item) return ada_Type.views
   is
   begin
      raise Program_Error; -- todo
      return (1 .. 0 => <>);
   end required_Types;


   overriding
   function context_required_Types (Self : access Item) return ada_Type.views
   is
   begin
      raise Program_Error; -- todo
      return (1 .. 0 => <>);
   end context_required_Types;


   overriding
   function depends_on (Self : access Item;   a_Type : in ada_Type.view;
                                              Depth  : in Natural) return Boolean
   is
   begin
      raise Program_Error; -- todo
      return False;
   end depends_on;


   overriding
   function depends_directly_on (Self : access Item;   a_Type : in ada_Type.view;
                                                       Depth  : in Natural) return Boolean
   is
   begin
      raise Program_Error; -- todo
      return False;
   end depends_directly_on;


   overriding
   function depends_on (Self : access Item;   a_Package : access ada_Package.item'Class;
                                              Depth     : in     Natural) return Boolean
   is
   begin
      raise Program_Error; -- todo
      return False;
   end depends_on;


   overriding
   function resolved_Type (Self : access Item) return ada_Type.view
   is
   begin
      return Self.all'Access;
   end resolved_Type;


end ada_Type.composite.a_protected;
