with
     DOHs.Binding,
     swig_Core.Binding,
     ada.Text_IO;


package body doh_Support
is
   use DOHs.Binding,
       swig_Core,
       swig_Core.Binding,
       Interfaces,
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



   procedure replace_All (Self : in doh_Item;   search_for   : in String;
                                                     replace_with : in String)
   is
   begin
      doh_replace_All (Self,
                       -search_for,
                       -replace_with);
   end replace_All;



   function exists (Self : in doh_Item) return Boolean
   is
      use DOHs.Pointers.C_DOH_Pointers;
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
      use ada.Text_IO;
   begin
      put_Line (+DohStr (DOH_Pointer (Self)));
   end log;



   -- Nodes
   --

   procedure set_Attribute (Node : in doh_Node;   Named : in String;
                                                  Value : in String)
   is
      Status : constant C.int := DohSetattr (DOH_Pointer (Node),
                                             DOH_Pointer (-Named),
                                             DOH_Pointer (-Value));
      use type C.int;
   begin
      if    Status /= 0   -- Success.
        and Status /= 1   -- Successful replacement.
      then
         raise Constraint_Error with "Status:" & C.int'Image (Status);
      end if;
   end set_Attribute;



   procedure set_Attribute (Node : in doh_Node;   Named : in String;
                                                  Value : in String_Pointer)
   is
      Status : constant C.int := DohSetattr (DOH_Pointer ( Node),
                                             DOH_Pointer (-Named),
                                             DOH_Pointer ( Value));
      use type C.int;
   begin
      if Status /= 0
      then
         raise Constraint_Error with "Status:" & C.int'Image (Status);
      end if;
   end set_Attribute;



   function get_Attribute (Node : in doh_Node;   Named : in String) return doh_Node
   is
   begin
      return doh_Node (DohGetattr (DOH_Pointer (Node),
                                   DOH_Pointer (-Named)));
   end get_Attribute;


   function Attribute (Node : in doh_Node;   Named : in String) return String
   is
   begin
      return +doh_String (get_Attribute (Node, Named));
   end Attribute;



   function check_Attribute (Node : in doh_Node;  Named : in String;
                                                  Value : in String) return Boolean
   is
      use type C.int;
   begin
      return checkAttribute (Node, DOH_Pointer (-Named),
                                   DOH_Pointer (-Value)) /= 0;
   end check_Attribute;


end doh_Support;
