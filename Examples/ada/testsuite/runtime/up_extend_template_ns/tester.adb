with
     extend_template_ns.Foo_One,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'extend_template_ns' of upstream's suite, after its Python test: functions which '%extend' adds to an
--  instance of a template in a namespace, which names it from within the namespace and from without.
--
is
   use extend_template_ns,
       interfaces.C,
       Checks;

   the_Foo : constant Foo_One.Item := Foo_One.construct;
begin
   check (Foo_One.test1 (the_Foo, 37) = 37,                             "a function added within the namespace");
   check (Foo_One.test2 (the_Foo, 42) = 42,                             "and one added from without");

   finish;
end Tester;
