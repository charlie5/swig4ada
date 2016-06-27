with
     swigg_Module,
     System;


package body doh_Support
is
   use swig_p_Doh,
       swigg_Module,
       interfaces.C.strings;



   function to_String (Self : doh_Item'Class) return String
   is
      the_C_String : constant interfaces.c.strings.chars_ptr := Node_to_CStr (Self);
   begin
      if the_C_String = null_Ptr
      then
         return "";
      end if;

      return Value (the_C_String);
   end to_String;



   function "+" (Self : in doh_Item'Class) return unbounded_String
   is
   begin
      return to_unbounded_String (to_String (Self));
   end "+";




   function to_Doh (Self : in String) return doh_Item
   is
   begin
      return doh_Item (c_to_doh_string (new_String (Self)));
   end to_Doh;



   function "-" (Self : in unbounded_String) return doh_Item
   is
   begin
      return to_Doh (to_String (Self));
   end "-";



   procedure replace_All (in_Source : in doh_Item;   search_for   : in String;
                                                     replace_with : in String)
   is
   begin
      doh_replace_All (in_Source, -search_for, -replace_with);
   end replace_All;



   function exists (Self : in doh_Item'Class) return Boolean
   is
      use type system.Address;
   begin
      return getCPtr (self) /= system.null_Address;
   end exists;



   procedure print_to (Self     : in doh_Item'Class;
                       the_Text : in String)
   is
   begin
      swigg_Module.print_to (Self,  new_String (the_Text));
   end print_to;



   procedure print_to (Self     : in doh_Item'Class;
                       the_Text : in unbounded_String)
   is
   begin
      print_to (Self,  new_String (to_String (the_Text)));
   end print_to;


end doh_Support;
