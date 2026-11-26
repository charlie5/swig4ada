with
     abstract_typedef.A,
     abstract_typedef.AbstractBaseClass,
     abstract_typedef.Engine,

     swig,

     Checks;


procedure Tester
--
--  The case 'abstract_typedef' of upstream's suite, after its Python test: a pure virtual function whose parameter
--  is a reference to a class, defined in a class which is derived from a typedef of the base, with the parameter
--  named by a typedef of the class. The definition is private in C++, so it is called through the base.
--
is
   use abstract_typedef,
       Checks;

   use type swig.bool;

   the_Engine : aliased Engine.Item := Engine.construct;
   the_A      : aliased A.Item      := A.Item (A.construct);
   as_Base    : constant access AbstractBaseClass.Item'Class := the_A'Access;
begin
   check (AbstractBaseClass.write (as_Base, the_Engine'unchecked_Access) = swig.bool'Val (1),
          "the definition of the function, through the vtable of the base");

   finish;
end Tester;
