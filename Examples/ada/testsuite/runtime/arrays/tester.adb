with
     arrays.Binding,
     arrays.Vec3,
     arrays.Grid,

     swig.Pointers,
     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  Arrays and pointers, as parameters, results, members and variables,
--  the standard types which the other cases do not use, and variables of C++.
--
is
   use arrays,
       arrays.Binding,
       interfaces.C,
       Checks;

   use type swig.bool,
            swig.long_long,
            swig.Pointers.int_Pointer;

   True  : constant swig.bool := swig.bool'Val (1);
   False : constant swig.bool := swig.bool'Val (0);

begin
   parameters :
   declare
      Three  : aliased swig.int_Array    := [1, 2, 3];
      Values : aliased swig.double_Array := [0.5, 1.5, 2.0];
      Vecs   : aliased Vec3.Item_Array   := [(v => [1.0, 0.0, 0.0]),
                                             (v => [4.0, 0.0, 0.0])];
   begin
      check (sum3 (Three (0)'unchecked_Access) = 6,                 "an array of a fixed length is passed");
      check (total (Values (0)'unchecked_Access, 3) = 4.0,          "a pointer to constant values, with their count");

      scale (Values (0)'unchecked_Access, 3, 2.0);
      check (Values (2) = 4.0,                                      "C++ changes an array of the caller");

      check (length2 ((v => [1.0, 2.0, 2.0])) = 9.0,                "a structure with an array member is passed by value");
      check (unit (1).v (1) = 1.0 and unit (1).v (0) = 0.0,         "and returned by value");
      check (sum_vecs (Vecs (0)'unchecked_Access, 2) = 5.0,         "an array of structures is passed");
   end parameters;

   members :
   declare
      the_Grid : aliased Grid.Item;
   begin
      grid_fill (the_Grid'unchecked_Access, 10);

      check (the_Grid.cells (0, 0) = 10,                            "an array of two dimensions: its first element");
      check (the_Grid.cells (0, 2) = 12,                            "the last of its first row");
      check (the_Grid.cells (1, 0) = 13,                            "the first of its second row");
      check (the_Grid.cells (1, 2) = 15,                            "its last element");

      the_Grid.cells (1, 1) := 100;
      check (grid_sum (the_Grid'unchecked_Access) = 161,            "C++ reads what Ada wrote to it");

      check (to_Ada (the_Grid.label) = "g",                         "the member which follows it is where C++ has it");
      check (the_Grid.corners (1).v (2) = 9.0,                      "as is an array of structures");
   end members;

   pointers :
   declare
      the_Values : aliased swig.Pointers.int_Pointer;
      the_Count  : aliased int := 0;
      the_Name   : aliased Strings.chars_ptr;
      the_Entry  : aliased swig.Pointers.int_Pointer := table_start;
   begin
      get_table (the_Values'unchecked_Access, the_Count'unchecked_Access);
      check (the_Count = 4,                                         "a count is returned through a pointer");
      check (the_Values = table_start,                              "a pointer is returned through a pointer to it");
      check (the_Values.all = 2,                                    "and points to the values of C++");

      next_entry (the_Entry'unchecked_Access);
      check (the_Entry.all = 4,                                     "a pointer is changed through a reference to it");

      get_name (the_Name'unchecked_Access);
      check (String'(Strings.Value (the_Name)) = "table",           "a string is returned through a pointer");
   end pointers;

   text :
   declare
      the_Buffer : aliased char_array := [0 .. 15 => nul];
      the_Text   :         Strings.chars_ptr := Strings.new_String ("banana");
   begin
      check (write_text (Strings.to_chars_ptr (the_Buffer'unchecked_Access), 16) = 7,   "C++ writes text to a buffer of the caller");
      check (to_Ada (the_Buffer) = "written",                       "which Ada reads");
      check (count_char (the_Text, 'a') = 3,                        "a character is passed");

      Strings.free (the_Text);
   end text;

   standard_types :
   declare
      the_Flag  : aliased swig.bool := False;
      the_Float : aliased c_float   := 5.0;
   begin
      check (negate (False) = True and negate (True) = False,       "bool");
      check (big (3) = 3_000_000_000,                               "long long");
      check (high_bit (1) = 129,                                    "unsigned char");
      check (half (3.0) = 1.5,                                      "float");
      check (shorten (70_000) = 4_464,                              "short");
      check (mask (16#FF00#, 16#0FF0#) = 16#0F00#,                  "unsigned long");

      toggle (the_Flag'unchecked_Access);
      check (the_Flag = True,                                       "a reference to a bool");

      halve (the_Float'unchecked_Access);
      check (the_Float = 2.5,                                       "a pointer to a float");
   end standard_types;

   variables :
   begin
      check (limit = 10,                                            "a variable of C++ is read");
      limit := 25;
      check (read_limit = 25,                                       "and C++ sees what Ada writes to it");

      check (weights (2) = 2.5,                                     "an array variable");
      weights (0) := 8.0;
      check (read_weight (0) = 8.0,                                 "which Ada changes");

      check (origin.v (1) = 2.0,                                    "a variable which is a structure");
      check (fixed = 42,                                            "a constant of C++, which has no symbol, by its value");
      check (String'(Strings.Value (title)) = "arrays",             "a variable which is a string");
      check (cursor = table_start,                                  "a variable which is a pointer");

      the_range := 4;
      check (read_range = 4,                                        "a variable whose name is a reserved word of Ada");
   end variables;

   finish;
end Tester;
