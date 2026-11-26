with
     overload_copy.Foo,

     System,

     Checks;


procedure Tester
--
--  The case 'overload_copy' of upstream's suite, after its Python test: a class with a default constructor
--  and a copy constructor, which C++ therefore constructs, and which is bound as a limited record.
--
is
   use overload_copy,
       Checks;

   use type System.Address;

   the_Foo  : aliased Foo.Item := Foo.construct;
   the_Copy : aliased Foo.Item := Foo.construct (the_Foo'unchecked_Access);
begin
   check (Foo.Item'Size = 8,                                 "an empty class is of one byte, as in C++");
   check (the_Copy'Address /= the_Foo'Address,                "a copy is made by the copy constructor");

   Foo.destruct_0 (the_Copy);
   Foo.destruct_0 (the_Foo);

   finish;
end Tester;
