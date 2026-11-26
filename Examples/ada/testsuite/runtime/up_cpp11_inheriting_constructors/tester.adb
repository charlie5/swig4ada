with
     cpp11_inheriting_constructors.BaseClass,
     cpp11_inheriting_constructors.DerivedClass,
     cpp11_inheriting_constructors.SomeClass,
     cpp11_inheriting_constructors.TInheritCtorBase,
     cpp11_inheriting_constructors.UseInheritCtorTypedef,
     cpp11_inheriting_constructors.UseTemplateInheritCtor,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'cpp11_inheriting_constructors' of upstream's suite, after its Python test: constructors which a class
--  inherits from its base ('using BaseClass::BaseClass;'), in a class and in a template instance, a protected function
--  of a base which 'using' makes public, through a typedef of the base, and a member with an initial value.
--
is
   use cpp11_inheriting_constructors,
       interfaces.C,
       Checks;

   the_Derived  : constant DerivedClass    .Item := DerivedClass    .construct (10);
   the_Template : constant TInheritCtorBase.Item := TInheritCtorBase.construct (7);
begin
   check (BaseClass.retrieveValue (DerivedClass.as_BaseClass (the_Derived).all) = 10,          "a constructor which the class inherits");
   check (BaseClass.retrieveValue (TInheritCtorBase.as_BaseClass (the_Template).all) = 7,      "and one which an instance of a template inherits");

   check (UseInheritCtorTypedef .protectedValue (UseInheritCtorTypedef .construct (42)) = 42,  "a protected function which 'using' names through a typedef");
   check (UseTemplateInheritCtor.protectedValue (UseTemplateInheritCtor.construct (42)) = 42,  "and through a typedef of a template instance");

   check (SomeClass.construct.value = 5,                                                        "a member with an initial value");
   check (SomeClass.construct (3).value = 3,                                                    "and one which the other constructor sets");

   finish;
end Tester;
