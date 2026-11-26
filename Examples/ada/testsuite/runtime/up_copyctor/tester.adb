with
     copyctor.Bar,
     copyctor.Car,
     copyctor.Foo,
     copyctor.Hoo,

     Checks;


procedure Tester
--
--  The case 'copyctor' of upstream's suite, after its Python test: '%copyctor', which gives each class a copy
--  constructor, beside one from another class and an instance of a constructor template, which '%template' names.
--
is
   use copyctor,
       Checks;

   the_Bar  : aliased Bar.Item := Bar.construct;
   the_Car  : aliased Car.Item := Car.construct;
   the_Foo  : aliased Foo.Item := Foo.construct;
   the_Hoo  : aliased Hoo.Item := Hoo.construct;

   Bar_Copy  : constant Bar.Item := Bar.construct (the_Bar'unchecked_Access);
   Foo_Copy  : constant Foo.Item := Foo.construct (the_Foo'unchecked_Access);
   Hoo_Copy  : constant Hoo.Item := Hoo.construct (the_Hoo'unchecked_Access);

   Foo_of_Bar : constant Foo.Item := Foo.construct (the_Bar'unchecked_Access);
   Hoo_of_Bar : constant Hoo.Item := Hoo.construct (the_Bar'unchecked_Access);
   Hoo_of_Car : constant Hoo.Item := Hoo.construct (the_Car'unchecked_Access);
begin
   check (Bar_Copy'Size = 8 and Foo_Copy'Size = 8 and Hoo_Copy'Size = 8,      "each class is copied by the constructor which '%copyctor' adds");
   check (Foo_of_Bar'Size = 8 and Hoo_of_Bar'Size = 8,                       "a class is made from another");
   check (Hoo_of_Car'Size = 8,                                               "and by the instance of a constructor template");

   finish;
end Tester;
