with
     string_example.Binding,
     string_example.aaa,

     swig.std_Strings,

     interfaces.C,
     ada.Text_IO;


with ada.Command_Line;

procedure Tester
--
--  Exercises a C++ 'std::string' from Ada: as a parameter passed by value and by
--  reference, as the result of a function and as the member of a class.
--
is
   use string_example,
       string_example.Binding,
       swig.std_Strings,
       interfaces.C,
       ada.Text_IO;

   Failures : Natural := 0;


   procedure check (Condition : in Boolean;   What : in String)
   --
   --  Notes a result which is not as it should be, so that the tester ends with a failure status.
   --
   is
   begin
      if not Condition
      then
         ada.Text_IO.put_Line ("   FAILED  " & What);
         Failures := Failures + 1;
      end if;
   end check;

   Solid : aliased std_String := to_std_String (to_C ("a string made in Ada"));
   Empty : aliased std_String;                                                    -- An empty string, constructed by C++.

begin
   put_Line ("Size of a string in C++:" & std_string_Size'Image);
   put_Line ("Size of a string in Ada:" & Integer'Image (std_String'Size / interfaces.C.char'Size));
   new_Line;

   put_Line ("Solid:  '" & to_Ada (Solid) & "'   Length:" & Length (Solid)'Image);
   put_Line ("Empty:  '" & to_Ada (Empty) & "'   Length:" & Length (Empty)'Image);

   check (Integer (std_string_Size) = std_String'Size / interfaces.C.char'Size,   "the Ada type has the size which C++ gives a string");
   check (to_Ada (Solid) = "a string made in Ada" and Length (Solid) = 20,        "a string made in Ada holds its text");
   check (to_Ada (Empty) = ""                     and Length (Empty) =  0,        "a string which C++ constructs is empty");
   new_Line;

   foo   (Solid);                                                                 -- Passed by value.
   fooey (Solid'unchecked_Access);                                                -- Passed by reference.
   put_Line ("Solid:  '" & to_Ada (Solid) & "'");
   check (to_Ada (Solid) = "a string made in Ada (changed by fooey)",   "C++ changes a string which is passed by reference");
   new_Line;

   declare
      Name   : aliased std_String := to_std_String (to_C ("Ada"));
      Result : aliased std_String;
   begin
      greeting (Name, Result'unchecked_Access);                                   -- C++ returns the string by value, which Ada receives in 'Result'.
      put_Line ("Result: '" & to_Ada (Result) & "'");
      check (to_Ada (Result) = "Hello Ada, and welcome to a string which is returned by value.",   "a string is returned by value");

      assign   (Result, to_C ("assigned"));
      put_Line ("Result: '" & to_Ada (Result) & "'");
      check (to_Ada (Result) = "assigned",   "a string is assigned to");

      destruct (Result);
      destruct (Name);
   end;

   new_Line;

   declare
      an_Aaa : aliased aaa.Item := aaa.construct;                                 -- A class with a string member.
   begin
      put_Line ("aaa:    Rank =>" & an_Aaa.Rank'Image & "   Name => '" & to_Ada (an_Aaa.Name) & "'   Age =>" & an_Aaa.Age'Image);
      check (an_Aaa.Rank = 1 and an_Aaa.Age = 42,                           "the members on each side of a string member");
      check (to_Ada (an_Aaa.Name) = "a name given by the constructor",      "and the string member itself");
      aaa.destruct (an_Aaa);
   end;

   destruct (Solid);
   destruct (Empty);
   if Failures /= 0
   then
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
end Tester;
