with
     ada_Utility,
     ada.Strings.unbounded;


package Swigg
--
-- Top namespace for the Swig Ada module.
--
is
   subtype Text is ada.Strings.unbounded.unbounded_String;

   NL : constant String;


private

   NL : constant String := ada_Utility.portable_new_line_Token;

end Swigg;
