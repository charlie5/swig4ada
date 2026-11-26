with
     typedef_inherit_using.X,
     typedef_inherit_using.Derived,
     typedef_inherit_using.Derived2,
     typedef_inherit_using.UsesConv,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'typedef_inherit_using' of upstream's suite, after its Python test: functions of a base class which
--  'using' declarations name in a derived class, through the base and through a typedef of it, and a conversion
--  operator of a private base which one names.
--
is
   use typedef_inherit_using,
       interfaces.C,
       Checks;

   the_Derived  : constant Derived .Item := Derived .construct;
   the_Derived2 : constant Derived2.Item := Derived2.construct;
   the_UsesConv : constant UsesConv.Item := UsesConv.construct;
begin
   check (Derived.m (the_Derived) = 11,                               "a function of the base which 'using' names");
   check (Derived.n (the_Derived, 7) = 7,                             "and another");
   check (X.m (Derived.as_X (the_Derived).all) = 11,                  "and the same through the base");
   check (Derived2.m (the_Derived2) = 11,                             "one which is named through a typedef of the base");
   check (UsesConv.toInt (the_UsesConv) = 42,                         "a conversion operator of a private base, renamed");

   finish;
end Tester;
