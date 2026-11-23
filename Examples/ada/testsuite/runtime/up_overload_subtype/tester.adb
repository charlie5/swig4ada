with
     overload_subtype.Binding,
     overload_subtype.Foo,
     overload_subtype.Bar,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'overload_subtype' of upstream's suite, after its Python test: a function which is
--  overloaded on a class and on a class which is derived from it.
--
is
   use overload_subtype,
       interfaces.C,
       Checks;

   the_Foo : aliased Foo.Item;
   the_Bar : aliased Bar.Item;
begin
   check (Binding.spam (the_Foo'unchecked_Access) = 1,   "the function of the base class is called with an object of it");
   check (Binding.spam (the_Bar'unchecked_Access) = 2,   "and that of the derived class with an object of that");

   finish;
end Tester;
