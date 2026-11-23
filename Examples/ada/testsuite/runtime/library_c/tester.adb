with
     library_c.Binding,
     library_c.Pointers,
     library_c.SWIGCDATA,

     interfaces.C.Strings,
     System,
     swig.pointers,
     ada.unchecked_Conversion,

     Checks;


procedure Tester
--
--  A binding to C which uses the further library files: parameters which are input, output or
--  both ('typemaps.i'), the arguments of a program ('argcargv.i'), a file ('file.i') and raw data ('cdata.i').
--
is
   use library_c,
       library_c.Binding,
       interfaces.C,
       interfaces.C.Strings,
       Checks;

   use type library_c.Pointers.FILE_Pointer;

   function to_Address is new ada.unchecked_Conversion (chars_ptr, System.Address);

begin
   input_and_output_Parameters :
   declare
      Whole : aliased int           := 0;
      Part  : aliased double        := 0.0;
      X     : aliased int           := 7;
      S     : aliased short         := 21;
      U     : aliased unsigned_long := 5;
      F     : aliased C_float       := 3.0;
   begin
      check (add (1.5, 2.25) = 3.75,                 "an input parameter is given by its value");
      check (is_set (1) = 1 and is_set (0) = 0,      "of another type");

      split (6.5, Whole'unchecked_Access, Part'unchecked_Access);
      check (Whole = 6 and Part = 0.5,               "an output parameter is set by C");

      negate (X'unchecked_Access);
      check (X = -7,                                 "a parameter which is both is read and set by C");

      scale_all (S'unchecked_Access, U'unchecked_Access, F'unchecked_Access);
      check (S = 42 and U = 15 and F = 1.5,          "of each of several types");
   end input_and_output_Parameters;

   the_arguments_of_a_Program :
   declare
      Arguments : aliased swig.pointers.chars_ptr_array := [new_String ("one"), new_String ("three"), new_String ("")];
   begin
      check (total_length (3, Arguments (Arguments'First)'unchecked_Access) = 8,   "a count and an array of strings are passed as they are");

      for Each of Arguments
      loop
         free (Each);
      end loop;
   end the_arguments_of_a_Program;

   a_File :
   declare
      the_File : constant library_c.Pointers.FILE_Pointer := open_scratch;
      the_Text :          chars_ptr                       := new_String ("twelve chars");
   begin
      check (the_File /= null,                       "a file is held by a pointer");
      check (put_text (the_File, the_Text) = 1,      "and passed back to C");
      check (size_of_file (the_File) = 12,           "which has written to it");
      check (close_file (the_File) = 0,              "and closes it");

      free (the_Text);
   end a_File;

   raw_Data :
   declare
      Numbers : aliased array (1 .. 3) of aliased int := [1, 2, 3];
      Copy    : aliased array (1 .. 3) of aliased int := [others => 0];
      Data    : constant SWIGCDATA.Item := cdata_int (Numbers (1)'unchecked_Access, 3);
      Bytes   : constant SWIGCDATA.Item := cdata (Numbers'Address, 5);
   begin
      check (Data.len = 3 * int'Size / char'Size,                "the data of an array is as long as its elements");
      check (Bytes.len = 5,                                      "and that of plain storage as long as is asked");
      check (sum_of_bytes (Data.data, Data.len) = 6,             "its bytes are read by C");

      memmove (Copy'Address, to_Address (Data.data), Data.len);
      check (Copy (1) = 1 and Copy (2) = 2 and Copy (3) = 3,     "and are copied");
   end raw_Data;

   a_parameter_typemap_which_a_result_matches :
   begin
      --  'long *INPUT' is applied to every 'long *'. The parameter is the value itself; the result is still a pointer.
      --
      check (kept (7).all = 7,                                   "a result of the type of an input parameter is a pointer");
   end a_parameter_typemap_which_a_result_matches;

   finish;
end Tester;
