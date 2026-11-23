with
     smart_pointer_overload.Foo,
     smart_pointer_overload.Bar,

     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'smart_pointer_overload' of upstream's suite, after its Python test: the overloads of
--  a function of a class are each reached through a smart pointer to it.
--
is
   use smart_pointer_overload,
       interfaces.C,
       interfaces.C.Strings,
       Checks;

   the_Foo : aliased Foo.Item;
   the_Bar : aliased Bar.Item  := Bar.construct (the_Foo'unchecked_Access);
   Hello   :         chars_ptr := new_String ("hello");
begin
   check (Foo.test (the_Foo, int'(3))      = 1,   "the overload of an integer");
   check (Foo.test (the_Foo, double'(3.5)) = 2,   "of a real number");
   check (Foo.test (the_Foo, Hello)        = 3,   "and of a string");

   check (Bar.test (the_Bar, int'(3))      = 1,   "the overload of an integer, through the smart pointer");
   check (Bar.test (the_Bar, double'(3.5)) = 2,   "of a real number");
   check (Bar.test (the_Bar, Hello)        = 3,   "and of a string");

   free (Hello);
   finish;
end Tester;
