with
     pugixml.Pointers,
     ada.unchecked_Conversion;

package body Collectors
is
   use pugixml.Pointers;

   function to_Characters is new ada.unchecked_Conversion (swig.void_ptr, char_t_Pointer);


   overriding
   function for_each (Self : access Walker;   node : access xml_node.Item) return swig.bool
   is
      the_Name : constant char_array := char_array (C_char_t_Pointers.Value (xml_node.name (node.all)));
   begin
      append (Self.Names, to_Ada (the_Name) & Integer'Image (Integer (Self.depth)) & " ");
      return 1;     -- Carry on with the walk.
   end for_each;



   overriding
   procedure write (Self : in out Writer;   data : in swig.void_ptr;
                                            size : in size_t)
   is
      the_Text : constant char_array := char_array (C_char_t_Pointers.Value (to_Characters (data), ptrdiff_t (size)));
   begin
      append (Self.Text, to_Ada (the_Text, trim_Nul => False));
   end write;

end Collectors;
