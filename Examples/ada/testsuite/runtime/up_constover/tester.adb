with
     constover.Binding,
     constover.Foo,

     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'constover' of upstream's suite, after its Python test: functions which are overloaded
--  on whether a parameter, or the function itself, is constant, each renamed in the interface file.
--
is
   use constover,
       interfaces.C.Strings,
       Checks;

   the_Foo : aliased Foo.Item;
   Text    : chars_ptr := new_String ("test");

   function "=" (Left : in chars_ptr;   Right : in String) return Boolean
   is (String'(Value (Left)) = Right);

begin
   check (Binding.test        (Text) = "test",                  "the function of a pointer");
   check (Binding.test_pconst (Text) = "test_pconst",           "and that of a pointer to a constant");

   check (Foo.test         (the_Foo, Text) = "test",              "a member function of a pointer");
   check (Foo.test_pconst  (the_Foo, Text) = "test_pconst",       "of a pointer to a constant");
   check (Foo.test_constm  (the_Foo, Text) = "test_constmethod",  "a constant member function");
   check (Foo.test_pconstm (the_Foo, Text) = "test_pconstmethod", "and one of a pointer to a constant");

   free (Text);
   finish;
end Tester;
