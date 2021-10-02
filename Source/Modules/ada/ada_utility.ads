with
     GMP.discrete,
     ada.Characters.Latin_1,
     ada.Strings.unbounded;


package ada_Utility
--
-- Utilities.
--
is
   use ada.Strings.unbounded;

   function "+" (From : in unbounded_String) return String
     renames To_String;

   function "+" (From : in String) return unbounded_String
     renames To_Unbounded_String;

   --  Other
   --
   new_line_Token : constant String := (1 => ada.Characters.Latin_1.LF);


   procedure replace_All (Self       : in out ada.strings.unbounded.unbounded_String;
                          Token      : in     String;
                          with_Token : in     String);


   function Text_before_last_dot    (Self : in String) return String;
   function Text_after_last_dot     (Self : in String) return String;

   function Text_before_first_dot   (Self : in unbounded_String) return unbounded_String;
   function Text_after_first_dot    (Self : in unbounded_String) return unbounded_String;


   procedure strip_Namespaces       (Self : in out unbounded_String);
   procedure strip_const_Qualifiers (Self : in out unbounded_String);


   function class_Prefix_in         (Self : in unbounded_String) return unbounded_String;
   function identifier_Suffix_in    (Self : in unbounded_String) return unbounded_String;


   function to_Int   (Self : in String)           return GMP.discrete.Integer;
   function to_Int   (Self : in unbounded_String) return GMP.discrete.Integer;

   function to_Lower (Self : in unbounded_String) return unbounded_String;

   function Image    (Self : in Integer) return String;
   --
   --  Integer'Image without leading spaces.


   function is_an_ada_Standard_Package_Identifier (Self : in unbounded_String) return Boolean;
   function is_reserved_Word                      (Self : in unbounded_String) return Boolean;

   function to_ada_Identifier                     (Self : in unbounded_String) return unbounded_String;

end ada_Utility;
