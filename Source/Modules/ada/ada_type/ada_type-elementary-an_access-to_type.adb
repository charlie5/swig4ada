with Ada.Text_IO; use Ada.Text_IO;
package body ada_Type.elementary.an_access.to_type
is

   --  Forge
   --

   function new_Item (declaration_Package : access ada_Package.item'class := null;
                      Name                : in     unbounded_String       := null_unbounded_String;
                      accessed_Type       : in     ada_Type.view) return View
   is
   begin
      return new ada_Type.elementary.an_access.to_type.item'(declaration_package => declaration_Package,
                                                             name                => Name,
                                                             accessed_type       => accessed_Type);
   end new_Item;




   --  Attributes
   --

   function accessed_Type (Self : in Item'Class) return ada_Type.view
   is
   begin
      return Self.accessed_Type;
   end accessed_Type;



   overriding
   function required_Types (Self : access Item)  return ada_Type.views
   is
   begin
      return (1 => Self.accessed_Type);
   end required_Types;



   overriding
   function context_required_Types (Self : access Item)  return ada_Type.views
   is
   begin
      return (1 => Self.accessed_Type);
   end context_required_Types;



   overriding
   function  depends_on            (Self : access Item;   a_Type    : in     ada_Type.view;
                                                          Depth     : in     Natural) return Boolean
   is
   begin
      put_line ("In depends_on for access to type.");
      return    Self.accessed_Type.all'Access = a_Type
        or else Self.accessed_Type.depends_on (a_Type, Depth + 1);
   end depends_on;



   overriding
   function  depends_on             (Self : access Item;   a_Package : access ada_Package.item'Class;
                                                           Depth     : in     Natural) return Boolean
   is
   begin
      return    Self.accessed_Type.declaration_Package = a_Package
        or else Self.accessed_Type.depends_on (a_Package, Depth + 1);
   end depends_on;



   overriding
   function  depends_directly_on   (Self : access Item;   a_Type    : in     ada_Type.view;
                                                          Depth     : in     Natural) return Boolean
   is
      pragma Unreferenced (Depth);
   begin
      return Self.accessed_Type.all'Access = a_Type;
   end depends_directly_on;



   overriding
   function resolved_Type (Self : access Item) return ada_Type.view
   is
   begin
      --  log ("'ultimate_base_Type' ~ c_type_Kind: '" & a_c_type_kind'Image (Self.my.c_type_Kind) & "'");

--        if Self.declaration_Package.Kind = header_Import then

      return Self.all'Access;
--        return Self.accessed_Type.resolved_Type.my_view_Type;

--        else
--           return Self.all'access;
--        end if;

   end resolved_Type;


end ada_Type.elementary.an_access.to_type;
