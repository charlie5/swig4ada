with
     warnings.Binding,
     interfaces.C,
     Checks;


procedure Tester
--
--  The binding of declarations which are warned of. What can be bound is bound; the launcher
--  compares the warnings themselves with the 'expected-warnings' file of this case.
--
is
   use Standard.warnings.Binding,
       interfaces.C,
       Checks;
begin
   check (kept (41) = 42,     "a function with nothing to warn of is bound, beside those which are left out");

   finish;
end Tester;
