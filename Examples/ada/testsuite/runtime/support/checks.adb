with
     ada.Command_Line,
     ada.Text_IO;

package body Checks
is
   use ada.Text_IO;

   Passes   : Natural := 0;
   Failures : Natural := 0;


   procedure check (Condition : in Boolean;   Message : in String)
   is
   begin
      if Condition
      then
         Passes := Passes + 1;
         put_Line ("   ok      " & Message);
      else
         Failures := Failures + 1;
         put_Line ("   FAILED  " & Message);
      end if;
   end check;



   procedure finish
   is
   begin
      new_Line;
      put_Line ("Checks passed:" & Passes'Image & "   failed:" & Failures'Image);

      if Failures > 0
      then
         ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
      end if;
   end finish;

end Checks;
