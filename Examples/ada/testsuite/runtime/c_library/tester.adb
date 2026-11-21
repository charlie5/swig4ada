with
     c_library.Binding,
     c_library.the_Record,
     c_library.Number,
     c_library.Node,
     c_library.Shape,

     Callbacks,

     swig,
     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  A binding to a C library: constants, variables, structures, a union,
--  an enumeration, arrays, strings, a linked list and a callback.
--
is
   use c_library,
       c_library.Binding,
       interfaces.C,
       Checks;

begin
   constants_and_variables :
   begin
      check (MAX_NAME = 16 and VERSION = 3,     "constants made by '#define'");
      check (MASK = 252,                        "a constant which is an expression");

      check (counter = 5,                       "a variable of the library is read");
      bump;
      check (counter = 6,                       "a change which C makes to it is seen");
      counter := 100;
      bump;
      check (counter = 101,                     "a change which Ada makes to it is seen by C");

      check (ratio = 2.5,                       "a variable of type double");
      check (samples (2) = 30,                  "an array variable is read");
      samples (2) := 33;
      check (sum_array (samples (0)'unchecked_Access, 4) = 103,   "C reads an array variable which Ada has changed");
   end constants_and_variables;

   functions_and_strings :
   declare
      Text : Strings.chars_ptr := Strings.new_String ("sixteen");
   begin
      check (square (12) = 144,                              "a function is called");
      check (name_length (Text) = 7,                         "a string is passed to C");
      check (String'(Strings.Value (greeting)) = "hello from C",      "a string is returned by C");
      check (advance (STOPPED) = RUNNING,                    "an enumeration is passed and returned");
      check (advance (RUNNING) = FINISHED,                   "a literal with a value of its own");

      Strings.free (Text);
   end functions_and_strings;

   structures :
   declare
      R    : aliased c_library.the_Record.Item := make_record (7, 1.5);
      Name : Strings.chars_ptr       := Strings.new_String ("renamed");
   begin
      check (R.id = 7 and R.weight = 1.5,       "a structure is returned by value");
      check (R.state = RUNNING,                 "its enumeration member");
      check (to_Ada (R.name) = "made",          "its character array member");
      check (weight_of (R) = 1.5,               "a structure is passed by value");

      rename_record (R'unchecked_Access, Name);
      check (to_Ada (R.name) = "renamed",       "a structure is changed through a pointer");

      Binding.the_record.id := 99;
      check (Binding.the_record.id = 99,        "a structure variable of the library");

      Strings.free (Name);
   end structures;

   a_union :
   declare
      N : Number.Item (Number.as_int_variant);
   begin
      N.as_int := 1234;
      check (as_int (N) = 1234,                 "a union is passed by value");
   end a_union;

   arrays :
   declare
      Values : aliased swig.int_Array := [1 .. 5 => 0];
   begin
      fill_array (Values (1)'unchecked_Access, 5, 10);
      check (Values (1) = 10 and Values (5) = 14,                 "C fills an array made by Ada");
      check (sum_array (Values (1)'unchecked_Access, 5) = 60,     "C reads the array");
   end arrays;

   a_linked_list_and_a_callback :
   declare
      Third  : aliased Node.Item := (value => 3, next => null);
      Second : aliased Node.Item := (value => 2, next => Third 'unchecked_Access);
      First  : aliased Node.Item := (value => 1, next => Second'unchecked_Access);
      Offset : aliased int       := 10;
   begin
      check (list_length (First'unchecked_Access) = 3,   "C follows a list made by Ada");
      check (visit (First'unchecked_Access, Callbacks.add_to'Access, Offset'Address) = 36,
             "C calls an Ada function for each node, with a context");
   end a_linked_list_and_a_callback;

   structures_with_no_name :
   declare
      the_Shape : aliased Shape.Item;
   begin
      fill_shape (the_Shape'unchecked_Access);

      check (the_Shape.kind = 1,                           "a member ahead of a structure with no name");
      check (the_Shape.origin.x = 2 and the_Shape.origin.y = 3,   "a member which is declared with such a structure");
      check (the_Shape.corner.x = 4 and the_Shape.corner.y = 5,   "and a second");
      check (the_Shape.link.y = 5,                         "and a pointer to one");
      check (the_Shape.size.width = 6 and the_Shape.size.height = 7,   "a member of a structure with a name, which follows them");
      check (the_Shape.tag = 8,                            "and the last member");

      the_Shape.origin.y := 30;
      the_Shape.tag      := 80;
      check (shape_sum (the_Shape'unchecked_Access) = 1 + 2 + 30 + 4 + 5 + 6 + 7 + 80,   "C reads what Ada wrote to them");

      the_Shape.link := the_Shape.origin'unchecked_Access;
      check (linked_y (the_Shape'unchecked_Access) = 30,   "and follows a pointer which Ada set");
   end structures_with_no_name;

   finish;
end Tester;
