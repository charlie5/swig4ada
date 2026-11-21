with enum_example.foo;     use enum_example.foo;
with enum_example.Binding; use enum_example.Binding;
with interfaces.C;
with ada.Text_IO;          use ada.Text_IO;


with ada.Command_Line;

procedure Tester 
is
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

   use enum_example;
begin
   put_Line ("color.Red   => " & integer'Image (color'Pos (Red)));
   put_Line ("color.Blue  => " & integer'Image (color'Pos (Blue)));
   put_Line ("color.Green => " & integer'Image (color'Pos (Green)));

   new_line;
   put_Line ("foo.speed.Impulse   => " & integer'Image (foo.Impulse'enum_Rep));
   put_Line ("foo.speed.Warp      => " & integer'Image (foo.Warp'enum_Rep));
   put_Line ("foo.speed.Ludicrous => " & integer'Image (foo.Ludicrous'enum_Rep));

   check (color'Pos (Red) = 0 and color'Pos (Blue) = 1 and color'Pos (Green) = 2,   "the literals of 'color' are in the order of the C++ enumeration");
   check (Red'enum_Rep = 0 and Blue'enum_Rep = 1 and Green'enum_Rep = 2,            "and have its values");
   check (foo.Impulse'enum_Rep = 10 and foo.Warp'enum_Rep = 20 and foo.Ludicrous'enum_Rep = 30,   "the literals of 'speed' have the values which C++ gives them");

   new_Line;
   enum_test (Red,   foo.Impulse);
   enum_test (Blue,  foo.Warp);
   enum_test (Green, foo.Ludicrous);

   new_Line;

   declare
      the_Foo : Foo.item;
   begin
      Enum_test (the_Foo, foo.Impulse);
      Enum_test (the_Foo, foo.Warp);
      Enum_test (the_Foo, foo.Ludicrous);
   end;
   if Failures /= 0
   then
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
end Tester;