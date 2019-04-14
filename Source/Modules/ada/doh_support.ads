with
--     swig_p_Doh,
--     swig_p_DohIterator,
     swigg_module.Pointers,
     DOHs.Pointers,
     DOHs.DohIterator,
     ada.Strings.unbounded,
     interfaces.c.strings;


package doh_Support
--
--
--
is
   use ada.Strings.unbounded,
       swigg_module.Pointers,
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

   null_DOH : doh_Item;


   function to_String (Self : in doh_Item)   return String;
   function "+"       (Self : in doh_Item)   return String    renames to_String;
   function "+"       (Self : in doh_Item)   return unbounded_String;

   function to_Doh    (Self : in String)           return String_Pointer;
   function "-"       (Self : in String)           return String_Pointer  renames to_Doh;
   function "-"       (Self : in unbounded_String) return String_Pointer;



   function to_C      (Self : in String)     return interfaces.c.strings.chars_ptr
     renames interfaces.c.strings.new_String;


   function exists    (Self : in doh_Item)   return Boolean;


   procedure print_to (Self     : in     doh_Item;   the_Text : in String);
   procedure print_to (Self     : in     doh_Item;   the_Text : in unbounded_String);


   procedure replace_All (in_Source : in doh_Item;   search_for   : in String;
                                                     replace_with : in String);


end doh_Support;
