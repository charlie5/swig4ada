with
     char_constant,

     interfaces.C,

     ada.Text_IO,
     ada.Command_Line;


procedure Tester
--
--  A character constant which is not an ASCII character.
--
is
   use char_constant,
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

begin
   check (char'Pos (SPECIALCHAR) = 16#E1#,   "the constant has the code of the character (a acute, in Latin 1)");

   if Failures /= 0
   then
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
end Tester;
