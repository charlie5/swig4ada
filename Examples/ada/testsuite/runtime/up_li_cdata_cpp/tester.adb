with
     li_cdata_cpp.Binding,
     li_cdata_cpp.SWIGCDATA,

     swig,
     interfaces.C.Strings,
     System,
     ada.unchecked_Conversion,

     Checks;


procedure Tester
--
--  The case 'li_cdata_cpp' of upstream's suite, after its Python test: raw data, which is copied into storage
--  which 'malloc' gives, and read back by 'cdata' as a record of a pointer and a length.
--
is
   use li_cdata_cpp,
       li_cdata_cpp.Binding,
       interfaces.C,
       interfaces.C.Strings,
       Checks;

   procedure free (Storage : in swig.void_ptr)
     with Import, Convention => C, External_Name => "free";

   function to_Address is new ada.unchecked_Conversion (chars_ptr, System.Address);

   Text    : aliased constant char_array (1 .. 7) := [ 'A', 'B', 'C', nul, 'a', 'b', 'c' ];
   Storage : constant swig.void_ptr             := malloc (256);
begin
   memmove (Storage, Text'Address, Text'Length);

   declare
      Data : constant SWIGCDATA.Item := cdata (Storage, 7);
      Read : aliased char_array (1 .. 7)  := [others => nul];
   begin
      check (Data.len = 7,                                               "the data is as long as is asked");

      memmove (Read'Address, to_Address (Data.data), Data.len);     -- 'Value' would stop at the nul.
      check (Read = Text,                                                "and holds what was copied, a nul among it");
   end;

   free (Storage);
   finish;
end Tester;
