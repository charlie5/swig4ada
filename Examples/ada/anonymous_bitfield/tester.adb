with
     anonymous_bitfield.Foo,
     anonymous_bitfield.Binding,

     interfaces.C,

     ada.Text_IO,
     ada.Command_Line;


procedure Tester
--
--  A structure of bit-fields, some of which have no name. C fills it and Ada
--  reads it, then Ada changes it and C reads it, and the two sizes are compared.
--
is
   use anonymous_bitfield,
       anonymous_bitfield.Binding,
       interfaces.C,
       ada.Text_IO;

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


   the_Foo : aliased Foo.Item;

begin
   check (Foo.Item'Object_Size / 8 = Integer (size_of_Foo),   "the record has the size which C gives the structure");

   fill (the_Foo'unchecked_Access);

   check (the_Foo.x = -3 and the_Foo.y = 5,   "the first bit-fields");
   check (the_Foo.f = 1,                      "the bit-field after one with no name");
   check (the_Foo.z = -1000,                  "a signed bit-field after another with no name");
   check (the_Foo.seq = 123_456,              "the bit-field whose width is an expression");

   the_Foo.y   := -8;
   the_Foo.seq := 1;

   check (total (the_Foo'unchecked_Access) = -3 - 8 + 1 - 1000 + 1,   "C reads the bit-fields which Ada wrote");

   if Failures /= 0
   then
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
end Tester;
