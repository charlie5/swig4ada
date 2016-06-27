with enum_example.foo;     use enum_example.foo;
with enum_example.Binding; use enum_example.Binding;
with interfaces.C;
with ada.Text_IO;          use ada.Text_IO;


procedure Tester 
is
   use enum_example;
begin
   put_Line ("color.Red   => " & integer'Image (color'Pos (Red)));
   put_Line ("color.Blue  => " & integer'Image (color'Pos (Blue)));
   put_Line ("color.Green => " & integer'Image (color'Pos (Green)));

   new_line;
   put_Line ("foo.speed.Impulse   => " & integer'Image (foo.Impulse'enum_Rep));
   put_Line ("foo.speed.Warp      => " & integer'Image (foo.Warp'enum_Rep));
   put_Line ("foo.speed.Ludicrous => " & integer'Image (foo.Ludicrous'enum_Rep));

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
end Tester;