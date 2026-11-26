with
     namespace_virtual_method.Foo_2,
     namespace_virtual_method.Spam,

     System,
     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'namespace_virtual_method' of upstream's suite, after its Python test: a pure virtual function
--  which takes a reference to a class of another namespace, which is declared and not defined, overridden
--  in a derived class which names that class from within its own namespace.
--
is
   use namespace_virtual_method,
       interfaces.C,
       Checks;

   the_Spam : aliased Spam.Item := Spam.Item (Spam.construct);
   as_Foo   : constant access Foo_2.Item'Class := the_Spam'Access;
   the_Foo  : aliased namespace_virtual_method.Foo := System.Null_Address;     -- Which 'bar' does not read.
begin
   check (Spam .bar (the_Spam'Access, the_Foo'unchecked_Access) = 1,     "the function which overrides");
   check (Foo_2.bar (as_Foo,          the_Foo'unchecked_Access) = 1,     "and through the base, by the vtable");

   finish;
end Tester;
