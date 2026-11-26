with
     template_extend2.lBaz,
     template_extend2.dBaz,

     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'template_extend2' of upstream's suite, after its Python test: a function which '%extend' adds to each of
--  two instances of a template of a namespace, each with a body of its own.
--
is
   use template_extend2,
       interfaces.C.Strings,
       Checks;

   the_lBaz : constant lBaz.Item := lBaz.construct;
   the_dBaz : constant dBaz.Item := dBaz.construct;
begin
   check (Value (lBaz.foo (the_lBaz)) = "lBaz::foo",                    "the function which is added to one instance");
   check (Value (dBaz.foo (the_dBaz)) = "dBaz::foo",                    "and that of the other");

   finish;
end Tester;
