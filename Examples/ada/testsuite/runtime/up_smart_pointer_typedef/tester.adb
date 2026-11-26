with
     smart_pointer_typedef.Foo,
     smart_pointer_typedef.Bar,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'smart_pointer_typedef' of upstream's suite, after its Python test: a smart pointer whose 'operator->'
--  returns a typedef of a pointer. The smart pointer is given the functions and the member variables of the class which
--  it points to, as functions ('x' and 'set_x').
--
is
   use smart_pointer_typedef,
       interfaces.C,
       Checks;

   use type Foo.Pointer;

   the_Foo : aliased Foo.Item := Foo.construct;
   the_Bar : constant Bar.Item := Bar.construct (the_Foo'unchecked_Access);
begin
   check (Bar.dereference (the_Bar) = the_Foo'unchecked_Access,        "'operator->' gives the object which is pointed to");

   Bar.set_x (the_Bar, 3);
   check (Bar.getx (the_Bar) = 3,                                       "a member variable of that class is set through the smart pointer");
   check (Bar.x (the_Bar) = 3 and the_Foo.x = 3,                        "and read, and is that of the object pointed to");

   Bar.dereference (the_Bar).x := 4;
   check (Foo.getx (Bar.dereference (the_Bar).all) = 4,                 "and through what 'operator->' gives");

   finish;
end Tester;
