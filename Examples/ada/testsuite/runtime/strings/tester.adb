with
     strings.Binding,
     strings.Person,
     strings.Pointers,

     swig.std_Strings,
     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  Strings of the C++ standard library: as parameters, results,
--  references and members of a class.
--
is
   use strings,
       strings.Binding,
       swig.std_Strings,
       interfaces.C,
       Checks;

begin
   parameters_and_results :
   declare
      Name   : aliased std_String := to_std_String (to_C ("world"));
      Result : aliased std_String;
   begin
      greet (Name'unchecked_Access, Result'unchecked_Access);
      check (to_Ada (Result) = "hello world",                       "a string is passed by reference and one returned by value");
      check (length_of (Result) = 11,                               "a string is passed by value");

      repeat (Name'unchecked_Access, 30, Result'unchecked_Access);
      check (Length (Result) = 150,                                 "a result too long to be held within the string itself");
      check (to_Ada (Result) (146 .. 150) = "world",                "whose characters are those which C++ made");

      destruct (Result);
      destruct (Name);
   end parameters_and_results;

   references :
   declare
      Text  : aliased std_String := to_std_String (to_C ("ab"));
      More  : aliased std_String := to_std_String (to_C ("cdef"));
   begin
      append_to (Text'unchecked_Access, More'unchecked_Access);
      check (to_Ada (Text) = "abcdef",                              "C++ changes a string of the caller through a reference");

      check (to_Ada (longest (Text'unchecked_Access, More'unchecked_Access).all) = "abcdef",   "a reference to a string is returned");
      check (longest (Text'unchecked_Access, More'unchecked_Access) = Text'unchecked_Access,  "which is the string of the caller");

      clear_it (Text'unchecked_Access);
      check (Length (Text) = 0,                                     "and through a pointer");

      destruct (More);
      destruct (Text);
   end references;

   strings_of_the_library :
   begin
      check (to_Ada (title.all) = "untitled",                       "a reference to a string of the library");
      assign (title_at.all, to_C ("named"));
      check (to_Ada (title.all) = "named",                          "which Ada changes through a pointer to it");
   end strings_of_the_library;

   members :
   declare
      Name       : aliased std_String  := to_std_String (to_C ("Ada"));
      City       : aliased std_String  := to_std_String (to_C ("London, which is a long way away"));
      the_Person : aliased Person.Item := Person.construct (Name'unchecked_Access, 36);
      Text       : aliased std_String;
   begin
      check (to_Ada (the_Person.name) = "Ada",                      "a string member, set by the constructor");
      check (the_Person.age = 36,                                   "the member between two strings");
      check (to_Ada (the_Person.city) = "nowhere",                  "and the string member after it");

      Person.move_to (the_Person, City'unchecked_Access);
      check (to_Ada (the_Person.city) = "London, which is a long way away",   "C++ changes a string member");

      Person.describe (the_Person, Text'unchecked_Access);
      check (to_Ada (Text) = "Ada of London, which is a long way away",       "a function of the class returns a string");
      check (to_Ada (Person.get_name (the_Person).all) = "Ada",     "and a reference to a member");

      assign (the_Person.name, to_C ("Countess"));
      check (Person.name_size (the_Person) = 8,                     "C++ reads a string member which Ada changed");
      check (total_length (the_Person'unchecked_Access) = 8 + 32,   "through a pointer to the object");

      destruct (Text);
      Person.destruct_0 (the_Person);
      destruct (City);
      destruct (Name);
   end members;

   a_string_by_another_Name :
   declare
      Text   : aliased std_String := to_std_String (to_C ("loud"));
      Result : aliased std_String;
   begin
      --  'string' (by 'using std::string;') and a typedef of 'std::string' are that type, so a function which
      --  returns one gives its result to an object of the caller, as one which returns a 'std::string' does.
      --
      shout (Text'unchecked_Access, Result'unchecked_Access);
      check (to_Ada (Result) = "loud!",                             "a string which is named through a 'using' declaration is returned by value");

      labelled (7, Result'unchecked_Access);
      check (to_Ada (Result) = "label 7",                           "and one which is named through a typedef");

      destruct (Result);
      destruct (Text);
   end a_string_by_another_Name;

   a_C_string_of_a_typedef_of_char :
   declare
      use interfaces.C.Strings;
      Text  : chars_ptr               := new_String ("four");
      Bytes : aliased   byte_t_Array  := [65, 66];
   begin
      check (String'(Value (motto)) = "ada",                        "a pointer to a typedef of 'char' is a 'chars_ptr', returned");
      check (count_of (Text) = 4,                                   "and passed");
      check (first_byte (strings.Pointers.byte_t_Pointer'(Bytes (0)'unchecked_Access)) = 65,
             "and one to a typedef of 'unsigned char' is a pointer to bytes");
      free (Text);
   end a_C_string_of_a_typedef_of_char;

   finish;
end Tester;
