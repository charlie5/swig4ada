with
     using_nested_member_typedef.UsingDerived,
     using_nested_member_typedef.UsingDerivedDeep,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'using_nested_member_typedef' of upstream's suite, after its Python test: a protected function of a
--  nested class, made public in a class derived from it by a 'using' declaration which names it through a typedef
--  of the base and the base's own typedef of itself, one and two classes deep.
--
is
   use using_nested_member_typedef,
       interfaces.C,
       Checks;

   the_Derived : constant UsingDerived    .Item := UsingDerived    .construct;
   the_Deep    : constant UsingDerivedDeep.Item := UsingDerivedDeep.construct;
begin
   check (UsingDerived    .hh (the_Derived, 81) = 81,             "a function which 'using' names through typedefs");
   check (UsingDerivedDeep.jj (the_Deep,    81) = 81,             "and one of a class nested two deep");

   finish;
end Tester;
