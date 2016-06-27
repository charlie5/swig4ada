--  with ada_Variable;

--  old ...
--
with ada_Package;              use ada_Package;
--  with ada_Subprogram;
--  with ada_Variable;             use ada_Variable;
--  with gnat_utility;              use gnat_utility;

--  with ada.Characters.handling;   use ada.Characters.handling;
--  with system;


package body ada_Type.a_subType
is
--     use GMP.discrete;


   --  Globals
   --

--     NL : String := portable_new_line_Token;




   --  Forge
   --

   function Subtype_construct (declaration_Package : access ada_Package.item'class := null;
                               Name                : in unbounded_String  := null_unbounded_String;
                               base_Type           : in ada_Type.view) return a_subType.item'class
   is
   begin
      return Item'(declaration_package => declaration_Package,
                   name                => Name,
                   base_type           => base_Type);
   end Subtype_construct;




   function new_Subtype (declaration_Package : access ada_Package.item'class := null;
                         Name                : in unbounded_String  := null_unbounded_String;
                         base_Type           : in ada_Type.view) return a_subType.view
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
--        return (1 => self.base_Type);
--     end required_Types;



   overriding
   function  depends_on (Self : access Item;   a_Type : in ada_Type.view) return Boolean
   is
   begin
      return    self.base_Type.all'Access = a_Type
        or else self.base_Type.depends_on (a_Type);
   end depends_on;



   overriding
   function  depends_directly_on (Self : access Item;   a_Type : in ada_Type.view) return Boolean
   is
   begin
      return self.base_Type.all'Access = a_Type;
   end depends_directly_on;



   overriding
   function depends_on (Self : access Item;   a_Package : access ada_Package.item'class) return Boolean
   is
   begin
      return    self.base_Type.declaration_Package = a_Package
        or else self.base_Type.depends_on (a_Package);
   end depends_on;



   overriding
   function  context_required_Types (Self : access Item) return ada_Type.views
   is
   begin
      return (1 => self.base_Type);
   end context_required_Types;



   overriding
   function  required_Types    (Self : access Item) return ada_Type.views
   is
   begin
      return (1 => self.base_Type);
   end required_Types;



   function base_Type (Self : access Item) return ada_Type.view
   is
   begin
      return self.base_Type;
   end base_Type;



   overriding
   function resolved_Type (Self : access Item) return ada_Type.view   -- tbd: move this into 'Language' ... its app code !!
   is
   begin
      --  log ("'ultimate_base_Type' ~ c_type_Kind: '" & a_c_type_kind'Image (self.my.c_type_Kind) & "'");

--        if self.declaration_Package.Kind = header_Import then

      return self.base_Type.resolved_Type;

--        else
--           return Self.all'access;
--        end if;

   end resolved_Type;


end ada_Type.a_subType;
