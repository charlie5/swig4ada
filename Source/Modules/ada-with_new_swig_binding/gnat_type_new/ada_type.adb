--  with ada_Variable;

--  old ...
--
with ada_Package;
--  with ada_Subprogram;
--  with ada_Variable;             use ada_Variable;
with ada_Utility;              use ada_Utility;

--  with ada.Characters.handling;   use ada.Characters.handling;
--
--  with system;


package body ada_Type
is

--     use GMP.discrete;


   --  Globals
   --

--     NL : String := portable_new_line_Token;




   --  Attributes
   --

--     function required_Types (Self : in Item) return ada_Type.views
--     is
--     begin
--        return (1..0 => <>);
--     end required_Types;



   procedure Name_is (Self : access Item;
                      Now  : in     unbounded_String)
   is
   begin
      self.Name := Now;

   end Name_is;



   function Name (Self : access Item) return unbounded_String
   is
   begin
      return self.Name;
   end Name;



   function qualified_Name (Self : access Item) return unbounded_String
   is
      use ada_Package;
   begin
      if self.declaration_package.Name = "standard" then
         return self.Name;
      else
         return self.declaration_package.qualified_Name & "." & self.Name;
      end if;
   end qualified_Name;



   procedure declaration_Package_is (Self : access Item;
                                     Now  : access ada_Package.item'class)
   is
   begin
      self.declaration_Package := Now;
   end declaration_Package_is;



   function declaration_Package (Self : access Item) return access ada_Package.item'class
   is
   begin
      return self.declaration_Package;
   end declaration_Package;



   function is_ultimately_Unsigned (Self : access Item'Class) return Boolean
   is
   begin
      return Index (to_Lower (self.resolved_type.Name), "unsigned") /= 0;
   end is_ultimately_Unsigned;


end ada_Type;
