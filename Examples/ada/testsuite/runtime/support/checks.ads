package Checks
--
-- A minimal test harness for the run-time test cases.
--
is
   procedure check (Condition : in Boolean;   Message : in String);
   --
   -- Reports the message as passed or failed.

   procedure finish;
   --
   -- Reports the totals, and sets the exit status of the program to failure if any check failed.

end Checks;
