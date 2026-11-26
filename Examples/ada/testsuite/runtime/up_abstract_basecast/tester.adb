with
     abstract_basecast.BaseClass,
     abstract_basecast.DerivedClass,

     System,

     Checks;


procedure Tester
--
--  The case 'abstract_basecast' of upstream's suite, after its Python test: a function which returns a reference to
--  the abstract base of its class, through which the object is used.
--
is
   use abstract_basecast,
       Checks;

   use type System.Address,
            BaseClass.Pointer;

   the_Derived : aliased DerivedClass.Item := DerivedClass.Item (DerivedClass.construct);
   the_Base    : constant BaseClass.Pointer := DerivedClass.f (the_Derived'Access);
begin
   DerivedClass.g (the_Derived);
   check (the_Base.all'Address = the_Derived'Address,                   "a reference to the base is to the object itself");

   BaseClass.g (the_Base.all);     -- Which dispatches to the function of the class (no membership of a type of C++ is tested).
   check (DerivedClass.f (the_Derived'Access) = the_Base,               "and is the same each time");

   DerivedClass.destruct_0 (the_Derived);
   finish;
end Tester;
