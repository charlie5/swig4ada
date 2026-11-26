with
     abstract_typedef2.A_UF,
     abstract_typedef2.Base_UF,

     System,

     Checks;


procedure Tester
--
--  The case 'abstract_typedef2' of upstream's suite, after its Python test: an instance of a class template
--  which defines the pure virtual function of its base, whose result is a typedef of a pointer, and whose
--  parameter is a typedef of a typedef of the base.
--
is
   use abstract_typedef2,
       Checks;

   use type System.Address;

   the_A   : aliased A_UF.Item := A_UF.Item (A_UF.construct (5));
   as_Base : constant access Base_UF.Item'Class := the_A'Access;
begin
   check (A_UF.set    (the_A'Access, 3) = System.Null_Address,     "the function which defines the pure virtual one");
   check (Base_UF.set (as_Base,      3) = System.Null_Address,     "and through the base, by the vtable");

   finish;
end Tester;
