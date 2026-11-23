with
     extend_template.Foo_0,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'extend_template' of upstream's suite, after its Python test: functions which '%extend'
--  adds to a class template, in an instance of it.
--
is
   use extend_template,
       interfaces.C,
       Checks;

   the_Foo : aliased Foo_0.Item;
begin
   check (Foo_0.test1 (the_Foo, 37) = 37,   "a function which is added to the template");
   check (Foo_0.test2 (the_Foo, 42) = 42,   "and one which is added to it in its namespace");

   finish;
end Tester;
