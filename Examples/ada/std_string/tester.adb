with
     string_example.Binding,
     string_example.aaa,

     swig.std_Strings,

     interfaces.C,
     ada.Text_IO;


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

   Solid : aliased std_String := to_std_String (to_C ("a string made in Ada"));
   Empty : aliased std_String;                                                    -- An empty string, constructed by C++.

begin
   put_Line ("Size of a string in C++:" & std_string_Size'Image);
   put_Line ("Size of a string in Ada:" & Integer'Image (std_String'Size / interfaces.C.char'Size));
   new_Line;

   put_Line ("Solid:  '" & to_Ada (Solid) & "'   Length:" & Length (Solid)'Image);
   put_Line ("Empty:  '" & to_Ada (Empty) & "'   Length:" & Length (Empty)'Image);
   new_Line;

   foo   (Solid);                                                                 -- Passed by value.
   fooey (Solid'unchecked_Access);                                                -- Passed by reference.
   put_Line ("Solid:  '" & to_Ada (Solid) & "'");
   new_Line;

   declare
      Name   : aliased std_String := to_std_String (to_C ("Ada"));
      Result : aliased std_String;
   begin
      greeting (Name, Result'unchecked_Access);                                   -- C++ returns the string by value, which Ada receives in 'Result'.
      put_Line ("Result: '" & to_Ada (Result) & "'");

      assign   (Result, to_C ("assigned"));
      put_Line ("Result: '" & to_Ada (Result) & "'");

      destruct (Result);
      destruct (Name);
   end;

   new_Line;

   declare
      an_Aaa : aliased aaa.Item := aaa.construct;                                 -- A class with a string member.
   begin
      put_Line ("aaa:    Rank =>" & an_Aaa.Rank'Image & "   Name => '" & to_Ada (an_Aaa.Name) & "'   Age =>" & an_Aaa.Age'Image);
      aaa.destruct (an_Aaa);
   end;

   destruct (Solid);
   destruct (Empty);
end Tester;
