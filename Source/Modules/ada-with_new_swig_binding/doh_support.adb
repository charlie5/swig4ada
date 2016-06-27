with swigg.Pointers;
with interfaces.C.strings;   use interfaces.C.strings;
with swigg.Binding;          use swigg.Binding;
with System;


package body doh_Support
is
   use swigg.Pointers; -- .Doh_Pointer;



   function to_String (Self : in doh_Item) return String
   is
      the_C_String : constant interfaces.c.strings.chars_ptr := Node_to_CStr (Node_Pointer (Self));
   begin
      if the_C_String = null_Ptr then
         return "";
      end if;

      return Value (the_C_String);
   end to_String;



   function "+" (Self : in doh_Item) return unbounded_String
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
      doh_replace_All (in_Source,
                       String_Pointer (-search_for),
                       String_Pointer (-replace_with));
   end replace_All;



   function exists (Self : in doh_Item) return Boolean
   is
      use type system.Address;
   begin
--        return getCPtr (self) /= system.null_Address;
      return Self /= null;
   end exists;



   procedure print_to (Self     : in     doh_Item;
                       the_Text : in     unbounded_String)
   is
   begin
      print_to (String_Pointer (Self),
                new_String (to_String (the_Text)));
   end print_to;



   procedure print_to (Self     : in     doh_Item;
                       the_Text : in     String)
   is
   begin
      print_to (String_Pointer (Self),
                new_String (the_Text));
   end print_to;


end doh_Support;
