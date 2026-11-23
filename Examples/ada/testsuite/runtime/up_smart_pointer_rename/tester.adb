with
     smart_pointer_rename.Foo,
     smart_pointer_rename.Bar,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'smart_pointer_rename' of upstream's suite, after its Python test: functions of a class
--  which the interface file renames are reached by their new names through a smart pointer to it,
--  which has a function of its own of the old name.
--
is
   use smart_pointer_rename,
       interfaces.C,
       Checks;

   the_Foo : aliased Foo.Item;
   the_Bar : aliased Bar.Item := Bar.construct (the_Foo'unchecked_Access);
begin
   check (Bar.test   (the_Bar)       = 3,   "the function of the smart pointer itself");
   check (Bar.ftest1 (the_Bar, 1)    = 1,   "a renamed function of the class, through the pointer");
   check (Bar.ftest2 (the_Bar, 2, 3) = 2,   "and its renamed overload");

   finish;
end Tester;
