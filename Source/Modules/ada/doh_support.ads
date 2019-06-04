with
     swig_Core.Pointers,

     DOHs.Pointers,
     DOHs.DohIterator,
     DOHs.const_String_or_char_ptr,

     ada.Strings.unbounded,
     interfaces.C.strings;


package doh_Support
--
-- Utilities to help dealing with DOH objects.
--
is
   use ada.Strings.unbounded,
       swig_Core.Pointers,
       DOHs.Pointers;

   subtype doh_Item     is DOH_Pointer;
   subtype doh_File     is DOH_Pointer;
   subtype doh_Node     is Node_Pointer;
   subtype doh_String   is DOH_Pointer;
   subtype doh_SwigType is DOH_Pointer;
   subtype doh_parmList is DOH_Pointer;
   subtype doh_Parm     is DOH_Pointer;
   subtype doh_List     is DOH_Pointer;

   subtype doh_Iterator is DOHs.DohIterator.Pointer;

   subtype const_String is DOHs.const_String_or_char_ptr.item;

   null_DOH : doh_Item;


   function to_String (Self : in doh_Item)   return String;
   function "+"       (Self : in doh_Item)   return String   renames to_String;
   function "+"       (Self : in doh_Item)   return unbounded_String;

   function to_Doh    (Self : in String)           return String_Pointer;
   function "-"       (Self : in String)           return String_Pointer   renames to_Doh;
   function "-"       (Self : in unbounded_String) return String_Pointer;

   function to_C      (Self : in String)     return interfaces.C.strings.chars_ptr
     renames interfaces.C.strings.new_String;

   function exists    (Self : in doh_Item)   return Boolean;

   procedure print_to (Self : in doh_Item;   the_Text : in String);
   procedure print_to (Self : in doh_Item;   the_Text : in unbounded_String);

   procedure replace_all (Self : in doh_Item;   search_for   : in String;
                                                replace_with : in String);
   procedure log (Self : in doh_Item);


   -- Nodes
   --

   procedure set_Attribute (Node : in doh_Node;   Named : in String;
                                                  Value : in String);
   procedure set_Attribute (Node : in doh_Node;   Named : in String;
                                                  Value : in String_Pointer);
   function  get_Attribute (Node : in doh_Node;   Named : in String) return doh_Node;
   function  Attribute     (Node : in doh_Node;   Named : in String) return String;

   function check_Attribute (Node : in doh_Node;  Named : in String;
                                                  Value : in String) return Boolean;


end doh_Support;
