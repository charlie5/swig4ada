with
     cpp_namespace.Binding,
     cpp_namespace.Test,
     cpp_namespace.Test2,
     cpp_namespace.Test3,
     cpp_namespace.Test4,
     cpp_namespace.Test5,

     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'cpp_namespace' of upstream's suite, after its Python test: declarations in namespaces,
--  which are opened again, named by 'using' declarations and directives, and derived from across them.
--
is
   use cpp_namespace,
       cpp_namespace.Binding,
       interfaces.C,
       interfaces.C.Strings,
       Checks;

   function "=" (Left : in chars_ptr;   Right : in String) return Boolean
   is (String'(Value (Left)) = Right);

   the_Test : aliased Test.Item;
   Hello    : chars_ptr := new_String ("hello");

   t2 : aliased Test2.Item := Test2.Item (Test2.construct);
   t3 : aliased Test3.Item := Test3.Item (Test3.construct);
   t4 : aliased Test4.Item := Test4.Item (Test4.construct);
   t5 : aliased Test5.Item := Test5.Item (Test5.construct);
begin
   check (fact (4) = 24,                                         "a function of a namespace");
   check (cpp_namespace.Foo = 42,                                "a variable of a namespace, which has the name of another namespace");

   check (Test.method (the_Test) = "Test::method",               "a member function of a class of a namespace");
   check (do_method  (the_Test'unchecked_Access) = "Test::method",     "a function which takes the class by a typedef of a pointer to it");
   check (do_method2 (the_Test'unchecked_Access) = "Test::method",     "and by one which is named with its namespace");

   weird (Hello, 4);
   check (True,                                                  "a function whose parameters are typedefs of odd names");

   check (foo3 (42) = 42,                                        "a typedef which a 'using' declaration brings into another namespace");

   check (do_method3 (t2'unchecked_Access, 40) = "Test2::method",     "a class of one namespace");
   check (do_method3 (t3'unchecked_Access, 40) = "Test3::method",     "one derived from it in a second, where a 'using' declaration names the base");
   check (do_method3 (t4'unchecked_Access, 40) = "Test4::method",     "one derived in a third, by a 'using' directive");
   check (do_method3 (t5'unchecked_Access, 40) = "Test5::method",     "and one outside any, derived from a typedef of the second");

   free (Hello);
   finish;
end Tester;
