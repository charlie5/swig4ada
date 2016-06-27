with
     swig_p_Doh,
     swig_p_DohIterator,

     ada.Strings.unbounded,
     interfaces.c.strings;


package doh_Support
--
--
--
is
   use ada.Strings.unbounded;

   subtype doh_Item     is swig_p_Doh.Item;
   subtype doh_File     is swig_p_Doh.Item;
   subtype doh_Node     is swig_p_Doh.Item;
   subtype doh_String   is swig_p_Doh.Item;
   subtype doh_SwigType is swig_p_Doh.Item;
   subtype doh_parmList is swig_p_Doh.Item;
   subtype doh_Parm     is swig_p_Doh.Item;
   subtype doh_List     is swig_p_Doh.Item;

   subtype doh_Iterator is swig_p_DohIterator.item;

   null_DOH : doh_Item;


   function to_String (Self : in doh_Item'Class)   return String;
   function "+"       (Self : in doh_Item'Class)   return String    renames to_String;

   function to_Doh    (Self : in String)           return doh_Item;
   function "-"       (Self : in String)           return doh_Item  renames to_Doh;
   function "-"       (Self : in unbounded_String) return doh_Item;

   function "+"       (Self : in doh_Item'Class)   return unbounded_String;


   function to_C      (Self : in String)           return interfaces.c.strings.chars_ptr
     renames interfaces.c.strings.new_String;


   function exists    (Self : in doh_Item'Class)   return Boolean;


   procedure print_to (Self     : in     doh_Item'Class;   the_Text : in String);
   procedure print_to (Self     : in     doh_Item'Class;   the_Text : in unbounded_String);


   procedure replace_All (in_Source : in doh_Item;   search_for   : in String;
                                                     replace_with : in String);


end doh_Support;
