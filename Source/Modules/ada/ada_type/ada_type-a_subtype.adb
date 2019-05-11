with
     ada_Package;
with Ada.Text_IO; use Ada.Text_IO;


package body ada_Type.a_subType
is
   --  Globals
   --

--     NL : String := portable_new_line_Token;




   --  Forge
   --

   function Subtype_construct (declaration_Package : access ada_Package.item'Class := null;
                               Name                : in     unbounded_String       := null_unbounded_String;
                               base_Type           : in     ada_Type.view) return a_subType.item'class
   is
   begin
      return Item'(declaration_package => declaration_Package,
                   name                => Name,
                   base_type           => base_Type);
   end Subtype_construct;




   function new_Subtype (declaration_Package : access ada_Package.item'Class := null;
                         Name                : in     unbounded_String       := null_unbounded_String;
                         base_Type           : in     ada_Type.view) return a_subType.view
   is
   begin
      return new Item'(Item (Subtype_construct (declaration_Package,  Name, base_Type)));                  -- tbd: do this better
--        return new ada_Type.item'class'(Subtype_construct (declaration_Package,  Name, base_Type));
   end new_Subtype;




   --  Attributes
   --

--     function required_Types (Self : in Item) return ada_Type.views
--     is
--     begin
--        return (1 => Self.base_Type);
--     end required_Types;



   overriding
   function  depends_on            (Self : access Item;   a_Type    : in     ada_Type.view;
                                                          Depth     : in     Natural) return Boolean
   is
   begin
      put_line ("In depends_on for SUBTYPE.");
      return    Self.base_Type.all'Access = a_Type
        or else Self.base_Type.depends_on (a_Type, Depth + 1);
   end depends_on;



   overriding
   function  depends_directly_on   (Self : access Item;   a_Type    : in     ada_Type.view;
                                                          Depth     : in     Natural) return Boolean
   is
      pragma Unreferenced (Depth);
   begin
      return Self.base_Type.all'Access = a_Type;
   end depends_directly_on;



   overriding
   function  depends_on             (Self : access Item;   a_Package : access ada_Package.item'Class;
                                                           Depth     : in     Natural) return Boolean
   is
   begin
      return    Self.base_Type.declaration_Package = a_Package
        or else Self.base_Type.depends_on (a_Package, Depth + 1);
   end depends_on;



   overriding
   function  context_required_Types (Self : access Item) return ada_Type.views
   is
   begin
      return (1 => Self.base_Type);
   end context_required_Types;



   overriding
   function  required_Types    (Self : access Item) return ada_Type.views
   is
   begin
      return (1 => Self.base_Type);
   end required_Types;



   function base_Type (Self : access Item) return ada_Type.view
   is
   begin
      return Self.base_Type;
   end base_Type;



   overriding
   function resolved_Type (Self : access Item) return ada_Type.view   -- tbd: move this into 'Language' ... its app code !!
   is
   begin
--        put_Line ("'resolved_Type' ~ Self: '" & to_String (Self.qualified_Name) & "'");

--        if Self.declaration_Package.Kind = header_Import then

      return Self.base_Type.resolved_Type;

--        else
--           return Self.all'access;
--        end if;

   end resolved_Type;


end ada_Type.a_subType;
