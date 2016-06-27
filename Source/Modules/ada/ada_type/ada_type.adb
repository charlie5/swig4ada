with
     Swigg;

--  old ...
--
with ada_Package;
with ada_Utility;


package body ada_Type
is
   use ada_Utility;



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
      Self.Name := Now;

   end Name_is;



   function Name (Self : access Item) return unbounded_String
   is
   begin
      return Self.Name;
   end Name;



   function qualified_Name (Self : access Item) return unbounded_String
   is
      use ada_Package;
   begin
      if Self.declaration_package.Name = "standard"
      then
         return Self.Name;
      else
         return Self.declaration_package.qualified_Name & "." & Self.Name;
      end if;
   end qualified_Name;



   procedure declaration_Package_is (Self : access Item;
                                     Now  : access ada_Package.item'class)
   is
   begin
      Self.declaration_Package := Now;
   end declaration_Package_is;



   function declaration_Package (Self : access Item) return access ada_Package.item'class
   is
   begin
      return Self.declaration_Package;
   end declaration_Package;



   function is_ultimately_Unsigned (Self : access Item'Class) return Boolean
   is
   begin
      return Index (to_Lower (Self.resolved_type.Name), "unsigned") /= 0;
   end is_ultimately_Unsigned;




   function Image (Self : access Item)  return String
   is
   begin
      return to_String (Self.qualified_Name);
   end Image;



   function Image (Self : in Views) return String
   is
      the_Image : swigg.Text;
   begin
      for i in Self'Range
      loop
         append (the_Image,  Image (Self (i)) & swigg.NL);
      end loop;

      return to_String (the_Image);
   end Image;


end ada_Type;
