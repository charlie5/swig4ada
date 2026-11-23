with
     enum_template.Binding,

     Checks;


procedure Tester
--
--  The case 'enum_template' of upstream's suite, after its Python test: an enumeration which is
--  also the argument of a class template instance is still passed and returned as an enumeration.
--
is
   use enum_template,
       enum_template.Binding,
       Checks;
begin
   check (MakeETest = eTest1,   "a function returns a value of the enumeration");

   TakeETest (eTest0);
   check (True,                 "and one takes a value of it");

   finish;
end Tester;
