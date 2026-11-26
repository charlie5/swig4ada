with
     global_ns_arg.Binding,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'global_ns_arg' of upstream's suite, after its Python test: functions whose parameter and result
--  are a typedef which is named from the outermost scope ('::Integer').
--
is
   use global_ns_arg,
       global_ns_arg.Binding,
       interfaces.C,
       Checks;
begin
   check (foo (1) = 1,                                        "a parameter and result named from the outermost scope");
   check (bar_fn  = 1,                                        "and a result alone");

   finish;
end Tester;
