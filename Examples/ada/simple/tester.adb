
with simple_example;         use simple_example;
with simple_example.Binding; use simple_example.Binding;

with ada.text_IO;    use ada.text_IO;
with interfaces.C;   use interfaces.C; 


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

begin

   put_Line ("Foo is " & double'Image (Foo));
   check (Foo = 3.0,   "the variable has the value which C gave it");

   Foo := 5.0;
   put_Line ("Foo is " & double'Image (Foo));
   check (Foo = 5.0,   "the variable has the value which Ada gave it");
   
   put_Line ("Greatest common denominator of 100 & 15 is " & int'Image (GCD (100, 15)));
   check (GCD (100, 15) = 5,   "the greatest common denominator of 100 and 15 is 5");

   if Failures /= 0
   then
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
end Tester;
