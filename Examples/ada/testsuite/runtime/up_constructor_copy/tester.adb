with
     constructor_copy.Foo1,
     constructor_copy.Bari,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'constructor_copy' of upstream's suite, after its Python test: a class and a template
--  instance are copied by their copy constructors. (The test also requires that a class with no
--  copy constructor cannot be copied, which Ada shows when it is compiled: 'Foo8' and 'Bard' have
--  no constructor which takes one of themselves.)
--
is
   use constructor_copy,
       interfaces.C,
       Checks;

   f1  : aliased Foo1.Item := Foo1.construct (3);
   f11 : aliased Foo1.Item := Foo1.construct (f1'unchecked_Access);
   bi  : aliased Bari.Item := Bari.construct (5);
   bc  : aliased Bari.Item := Bari.construct (bi'unchecked_Access);
begin
   check (f1.x = 3 and f11.x = f1.x,   "a class is copied by its copy constructor");
   check (bi.x = 5 and bc.x = bi.x,    "and so is an instance of a class template");

   finish;
end Tester;
