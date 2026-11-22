with
     smart_pointer_member.Binding,
     smart_pointer_member.Foo,
     smart_pointer_member.Bar,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'smart_pointer_member' of upstream's suite, after its Python test: the members of a
--  class are reached through a smart pointer to it, which Ada does by 'dereference'.
--
is
   use smart_pointer_member,
       interfaces.C,
       Checks;

   the_Foo : aliased Foo.Item;
   the_Bar : aliased Bar.Item := Bar.construct (the_Foo'unchecked_Access);
begin
   the_Foo.y := 1;
   check (the_Foo.y = 1,                                       "a member of the class is set");

   Bar.dereference (the_Bar).y := 2;
   check (the_Foo.y = 2,                                       "and set through the smart pointer");
   check (Binding.get_y (the_Bar'unchecked_Access) = 2,        "which C++ reads through it too");

   the_Foo.x (2) := 7;
   check (Bar.dereference (the_Bar).x (2) = 7,                 "an array member is reached through it");

   check (Foo.z = 3 and Binding.get_z (the_Bar'unchecked_Access) = 3,   "a static constant member, from Ada and through the pointer");
   check (Foo.ZZ = 3,                                          "one which has its value in the class");

   Foo.zx := 5;
   check (Foo.zx = 5,                                          "a static member is set");

   check (Foo.boo = 0 and Bar.bua = 0,                         "a static function of each class");
   check (Binding.foo (the_Foo'unchecked_Access) = 0,          "a friend which is defined in the class is a function of its one parameter");

   finish;
end Tester;
