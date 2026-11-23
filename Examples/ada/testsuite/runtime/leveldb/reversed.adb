package body Reversed
is
   the_Name : constant interfaces.C.Strings.chars_ptr := interfaces.C.Strings.new_String ("swig4ada.Reversed");


   overriding
   function Compare (Self : access Item;   a : in Slice.Pointer;
                                           b : in Slice.Pointer) return int
   is
   begin
      Self.Calls := Self.Calls + 1;
      return Slice.compare (b.all, a);
   end Compare;



   overriding
   function Name (Self : access Item) return interfaces.C.Strings.chars_ptr
   is
      pragma Unreferenced (Self);
   begin
      return the_Name;
   end Name;



   overriding
   procedure FindShortestSeparator (Self : in out Item;   start : in swig.std_Strings.std_string_Pointer;
                                                          limit : in Slice.Pointer)
   is
   begin
      null;     -- The key is left as it is, which LevelDB allows.
   end FindShortestSeparator;



   overriding
   procedure FindShortSuccessor (Self : in out Item;   key : in swig.std_Strings.std_string_Pointer)
   is
   begin
      null;
   end FindShortSuccessor;

end Reversed;
