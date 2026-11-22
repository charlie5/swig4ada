with
     typedef_scope.Bar,

     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'typedef_scope' of upstream's suite, after its Python test: a class has a typedef of a
--  name which is also declared outside it, and its functions name both (the other as '::FooType').
--
is
   use typedef_scope,
       interfaces.C,
       interfaces.C.Strings,
       Checks;

   the_Bar : aliased Bar.Item;
   Hello   : chars_ptr := new_String ("hello");
begin
   check (Bar.test1 (the_Bar, 42, Hello) = 42,                    "the typedef of the class is a number");
   check (String'(Value (Bar.test2 (the_Bar, 42, Hello))) = "hello",      "and the one outside it a string");

   free (Hello);
   finish;
end Tester;
