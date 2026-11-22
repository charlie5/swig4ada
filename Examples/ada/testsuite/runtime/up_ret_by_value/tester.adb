with
     ret_by_value.Binding,
     ret_by_value.test,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'ret_by_value' of upstream's suite, after its Python test: a structure which is returned by value.
--
is
   use ret_by_value,
       interfaces.C,
       Checks;

   the_Test : constant test.Item := Binding.get_test;
begin
   check (the_Test.myInt   = 100,     "the first member of a structure which is returned by value");
   check (the_Test.myShort = 200,     "and the second");

   finish;
end Tester;
