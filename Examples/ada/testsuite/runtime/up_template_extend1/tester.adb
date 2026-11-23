with
     template_extend1.lBaz,
     template_extend1.dBaz,

     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'template_extend1' of upstream's suite, after its Python test: a function which
--  '%extend' adds to each of two instances of a class template, under their own names.
--
is
   use template_extend1,
       interfaces.C.Strings,
       Checks;

   the_lBaz : aliased lBaz.Item;
   the_dBaz : aliased dBaz.Item;
begin
   check (String'(Value (lBaz.foo (the_lBaz))) = "lBaz::foo",   "the function which is added to the first instance");
   check (String'(Value (dBaz.foo (the_dBaz))) = "dBaz::foo",   "and the one which is added to the second");

   finish;
end Tester;
