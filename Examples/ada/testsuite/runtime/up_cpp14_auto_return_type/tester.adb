with
     cpp14_auto_return_type.Binding,
     cpp14_auto_return_type.X,

     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'cpp14_auto_return_type' of upstream's suite, after its Python test: functions whose result type is
--  'auto', which the interface file declares again with their types, one of them through '%extend'.
--
is
   use cpp14_auto_return_type,
       interfaces.C,
       interfaces.C.Strings,
       Checks;
begin
   check (Binding.va_static_cast = 42,                                  "a function whose result is 'auto', declared with its type");
   check (String'(Value (X.a (X.construct))) = "a string",               "and a member function, through '%extend'");

   finish;
end Tester;
