with
     smart_pointer_simple.Foo,
     smart_pointer_simple.Bar,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'smart_pointer_simple' of upstream's suite, after its Python test: a member and a
--  function of a class are reached through a smart pointer to it.
--
is
   use smart_pointer_simple,
       interfaces.C,
       Checks;

   the_Foo : aliased  Foo.Item;
   the_Bar : aliased  Bar.Item    := Bar.construct (the_Foo'unchecked_Access);
   Pointee : constant Foo.Pointer := Bar.dereference (the_Bar);
begin
   Bar.dereference (the_Bar).x := 3;
   check (Bar.getx (the_Bar) = 3,       "a member which is set through the smart pointer is read by a function called through it");

   Pointee.x := 4;
   check (Foo.getx (Pointee.all) = 4,   "the object which it points to is the one which was given");
   check (the_Foo.x = 4,                "as the object itself shows");

   finish;
end Tester;
