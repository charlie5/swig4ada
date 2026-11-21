with
     add_link.Foo,

     ada.Text_IO,
     ada.Command_Line;


procedure Tester
--
--  A class which is given a member function by the interface file ('%extend').
--
is
   use add_link,
       ada.Text_IO;

   use type Foo.Pointer;

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


   the_Foo : aliased  Foo.Item    := Foo.construct;
   Another : constant Foo.Pointer := Foo.blah (the_Foo);

begin
   check (Another /= null,                   "the added function returns a new object");
   check (Another /= the_Foo'unchecked_Access,   "which is not the object it was called on");

   if Failures /= 0
   then
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
end Tester;
