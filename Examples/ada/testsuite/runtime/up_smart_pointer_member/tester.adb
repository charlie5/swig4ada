with
     smart_pointer_member.Binding,
     smart_pointer_member.Foo,
     smart_pointer_member.Bar,
     smart_pointer_member.CBar,

     swig,
     interfaces.C,
     System,

     Checks;


procedure Tester
--
--  The case 'smart_pointer_member' of upstream's suite, after its Python test: the members of a class, reached
--  through a smart pointer and through one which gives a pointer to a constant. They are an array, a number, a
--  constant which the class defines outside, one with its value in the class, a static variable and a static function.
--  ('Binding' is named, not used, as its function 'foo' would hide the package 'Foo'.)
--
is
   use smart_pointer_member,
       interfaces.C,
       Checks;

   use type System.Address,
            swig.int_Array;

   the_Foo  : aliased Foo.Item := Foo.construct;
   the_Bar  : aliased Bar.Item := Bar.construct (the_Foo'unchecked_Access);
   the_CBar : constant CBar.Item := CBar.construct (the_Foo'unchecked_Access);

   Numbers  : aliased swig.int_Array (0 .. 3) := [5, 6, 7, 8];
begin
   the_Foo.y := 1;
   check (the_Foo.y = 1,                                                "a member of the class");

   Bar.set_y (the_Bar, 2);
   check (the_Foo.y = 2 and Bar.y (the_Bar) = 2,                        "is set and read through the smart pointer");
   check (Binding.get_y (the_Bar'unchecked_Access) = 2,                 "as C++ reads it");

   check (Bar.x (the_Bar).all'Address = the_Foo.x (0)'Address,          "an array is the first of its elements");

   Bar.set_x (the_Bar, Numbers (0)'unchecked_Access);
   check (the_Foo.x = Numbers,                                          "and is set from an array");

   check (Bar.z (the_Bar) = 3 and Foo.z = 3,                            "a static constant which is defined outside its class");
   check (Binding.get_z (the_Bar'unchecked_Access) = 3,                 "as C++ reads it");
   check (Bar.ZZ (the_Bar) = 3 and Foo.ZZ = 3,                          "and one whose value is in its class");

   Bar.set_zx (the_Bar, 7);
   check (Foo.zx = 7 and Bar.zx (the_Bar) = 7,                          "a static variable is set and read through the smart pointer");

   check (Bar.boo (the_Bar) = 0 and Foo.boo = 0 and Bar.bua = 0,        "a static function, through it and of its own class");

   check (CBar.y (the_CBar) = 2 and CBar.zx (the_CBar) = 7,             "a smart pointer to a constant reads the members");
   check (CBar.x (the_CBar).all'Address = the_Foo.x (0)'Address,        "and the array");

   the_Foo.x (2) := 9;
   check (Bar.dereference (the_Bar).x (2) = 9,                          "a member is reached through 'dereference' too");
   check (Binding.foo (the_Foo'unchecked_Access) = 0,                   "a friend which is defined in the class is a function of its one parameter");

   finish;
end Tester;
