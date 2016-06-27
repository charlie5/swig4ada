with swigg.Pointers;
with swigg.DohIterator;
--  with Wrapper;

with ada.Strings.unbounded; use ada.Strings.unbounded;
with interfaces.c.strings;


package doh_Support
--
--
--
is

   subtype doh_Item     is swigg.Pointers.DOH_Pointer;
   subtype doh_File     is swigg.Pointers.DOH_Pointer;
   subtype doh_Node     is swigg.Pointers.DOH_Pointer;
   subtype doh_String   is swigg.Pointers.DOH_Pointer;
   subtype doh_SwigType is swigg.Pointers.DOH_Pointer;
   subtype doh_parmList is swigg.Pointers.DOH_Pointer;
   subtype doh_Parm     is swigg.Pointers.DOH_Pointer;
   subtype doh_List     is swigg.Pointers.DOH_Pointer;

   subtype doh_Iterator is swigg.DohIterator.Pointer;


   null_DOH : doh_Item;



   function to_String (Self : in doh_Item) return String;
   function "+"       (Self : in doh_Item) return String           renames to_String;

   function to_Doh    (Self : in String)                return doh_Item;
   function "-"       (Self : in String)                return doh_Item  renames to_Doh;
   function "-"       (Self : in unbounded_String)      return doh_Item;

   function "+"       (Self : in doh_Item) return unbounded_String;


   function to_C      (Self : in String) return interfaces.c.strings.chars_ptr
     renames interfaces.c.strings.new_String;


   function exists    (Self : in doh_Item) return Boolean;




   procedure print_to (Self     : in     doh_Item;
                       the_Text : in     String);

   procedure print_to (Self     : in     doh_Item;
                       the_Text : in     unbounded_String);


   procedure replace_All (in_Source : in doh_Item;   search_for   : in String;
                                                     replace_with : in String);


end doh_Support;
