with
     DOHs.Binding,
     swigg_Module.Binding,
     ada.Text_IO;


package body doh_Support
is
   use swigg_Module,
       swigg_Module.Binding,
       interfaces.C.strings;



   function to_String (Self : doh_Item) return String
   is
      the_C_String : constant interfaces.c.strings.chars_ptr := Node_to_CStr (Node_Pointer (Self));
   begin
      if the_C_String = null_Ptr
      then
         return "";
      end if;

      return Value (the_C_String);
   end to_String;



   function "+" (Self : in doh_Item) return unbounded_String
   is
   begin
      return to_unbounded_String (to_String (Self));
   end "+";




   function to_Doh (Self : in String) return String_Pointer
   is
   begin
      return c_to_doh_string (new_String (Self));
   end to_Doh;



   function "-" (Self : in unbounded_String) return String_Pointer
   is
   begin
      return to_Doh (to_String (Self));
   end "-";



   procedure replace_All (in_Source : in doh_Item;   search_for   : in String;
                                                     replace_with : in String)
   is
   begin
      doh_replace_All (in_Source,
                       -search_for,
                       -replace_with);
   end replace_All;



   function exists (Self : in doh_Item) return Boolean
   is
   begin
      return Self /= null;
   end exists;



   procedure print_to (Self     : in doh_Item;
                       the_Text : in String)
   is
   begin
      print_to (String_Pointer (Self),  new_String (the_Text));
   end print_to;



   procedure print_to (Self     : in doh_Item;
                       the_Text : in unbounded_String)
   is
   begin
      print_to (String_Pointer (Self),
                new_String (to_String (the_Text)));
   end print_to;



   procedure log (Self : in doh_Item)
   is
      use ada.Text_IO,
          DOHs.Binding;
   begin
      put_Line (+DohStr (DOH_Pointer (Self)));
   end log;


end doh_Support;
