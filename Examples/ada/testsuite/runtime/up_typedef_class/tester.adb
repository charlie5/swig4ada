with
     typedef_class.RealA,
     typedef_class.B,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'typedef_class' of upstream's suite, after its Python test: a function takes an object
--  of a class by a typedef of it which is declared in another class.
--
is
   use typedef_class,
       interfaces.C,
       Checks;

   the_A : aliased RealA.Item;
   the_B : aliased B.Item;
begin
   the_A.a := 3;
   check (B.testA (the_B, the_A'unchecked_Access) = 3,   "an object of the class is given where a typedef of it is asked for");

   finish;
end Tester;
