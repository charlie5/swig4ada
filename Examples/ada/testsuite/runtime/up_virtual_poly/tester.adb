with
     virtual_poly.Binding,
     virtual_poly.NNumber,
     virtual_poly.NInt,
     virtual_poly.NDouble,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'virtual_poly' of upstream's suite, after its Python test: virtual functions whose result
--  is covariant (a derived class returns a pointer to itself where its base returns one to the base).
--  In Ada the result is that of the base, and the object is seen as its own class by a conversion.
--
is
   use virtual_poly,
       interfaces.C,
       Checks;

   use type NNumber.Pointer;

   the_Double : aliased NDouble.Item := NDouble.Item (NDouble.construct (3.5));
   the_Int    : aliased NInt   .Item := NInt   .Item (NInt   .construct (2));

   --  A copy is made by C++, and is seen as its own class through 'narrow': an object which C++ has
   --  made is not converted to a derived type in Ada, which checks a tag that such an object has not.
   --
   double_Copy : constant NNumber.Pointer := NDouble.copy (the_Double'Access);
   int_Copy    : constant NNumber.Pointer := NInt   .copy (the_Int   'Access);
begin
   check (NDouble.get (the_Double'Access) = NDouble.get (NDouble.narrow (double_Copy)),            "a copy which is made through a covariant function");
   check (NInt   .get (the_Int   'Access) = NInt   .get (NInt   .narrow (int_Copy)),               "of each class");

   declare
      Unused : constant NInt.Pointer := Binding.incr (NInt.narrow (int_Copy)) with Unreferenced;
   begin
      check (NInt.get (the_Int'Access) + 1 = NInt.get (NInt.narrow (int_Copy)),                    "the copy is changed alone");
   end;

   check (NDouble.get (NDouble.narrow (NDouble.ref_this (the_Double'Access))) = 3.5,               "a covariant function which returns a reference");
   check (NDouble.ref_this (the_Double'Access) = the_Double'unchecked_Access,                      "which is to the object itself");

   check (NDouble.get (NDouble.narrow (NNumber.nnumber (the_Double'Access))) = 3.5,                "a pointer to the base is narrowed to the derived class");
   check (NInt   .get (NInt   .narrow (NNumber.nnumber (the_Int   'Access))) = 2,                  "of each class");

   NNumber.destruct (double_Copy.all);
   NNumber.destruct (int_Copy   .all);

   finish;
end Tester;
