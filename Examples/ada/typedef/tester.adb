with
     example.foo,

     ada.Text_IO,
     ada.Command_Line;


procedure Tester
--
--  An enumeration which is declared within a class.
--
is
   use example,
       ada.Text_IO;

   use type foo.bar;

   Failures : Natural := 0;


   procedure check (Condition : in Boolean;   What : in String)
   is
   begin
      if Condition
      then
         put_Line ("   ok      " & What);
      else
         put_Line ("   FAILED  " & What);
         Failures := Failures + 1;
      end if;
   end check;


   the_Bars : constant foo.bar_array := [foo.e_circles, foo.e_faceA, foo.e_faceB];

begin
   check (foo.bar'Pos (foo.e_faceB) = 2,                "the literals are in the order of the C++ enumeration");
   check (foo.e_circles'Enum_Rep = 0 and foo.e_faceB'Enum_Rep = 2,   "and have its values");
   check (foo.bar'Size <= 32 and foo.bar'Object_Size = 32,   "an object of it has the size of a C++ enumeration");
   check (the_Bars (1) = foo.e_faceA,                   "it has an array type");

   if Failures /= 0
   then
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
end Tester;
