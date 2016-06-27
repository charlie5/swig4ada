package body ada_Type.composite.a_protected
is

   --  Attributes
   --

   overriding
   function  required_Types (Self : access Item)  return ada_Type.views
   is
   begin
      raise Program_Error; -- tbd:
      return (1 .. 0 => <>);
   end required_Types;


   overriding
   function  context_required_Types (Self : access Item)  return ada_Type.views
   is
   begin
      raise Program_Error; -- tbd:
      return (1 .. 0 => <>);
   end context_required_Types;



   overriding
   function  depends_on (Self : access Item;   a_Type : in ada_Type.view) return Boolean
   is
   begin
      raise Program_Error; -- tbd:
      return False;
   end depends_on;



   overriding
   function  depends_directly_on (Self : access Item;   a_Type : in ada_Type.view) return Boolean
   is
   begin
      raise Program_Error; -- tbd:
      return False;
   end depends_directly_on;



   overriding
   function depends_on (Self : access Item;   a_Package : access ada_Package.item'class) return Boolean
   is
   begin
      raise Program_Error; -- tbd:
      return False;
   end depends_on;



   overriding
   function resolved_Type (Self : access Item) return ada_Type.view   -- tbd: move this into 'Language' ... its app code !!
   is
   begin
      return Self.all'Access;
   end resolved_Type;


end ada_Type.composite.a_protected;

