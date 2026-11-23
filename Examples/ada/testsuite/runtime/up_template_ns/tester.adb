with
     template_ns.pairii,
     template_ns.pairdd,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'template_ns' of upstream's suite, after its Python test: two instances of a class
--  template which the input declares in the namespace 'std', each made from its members and copied.
--
is
   use template_ns,
       interfaces.C,
       Checks;

   Two   : aliased int    := 2;
   Three : aliased int    := 3;
   High  : aliased double := 3.5;
   Low   : aliased double := 2.5;

   p1 : aliased pairii.Item := pairii.construct (Two'unchecked_Access, Three'unchecked_Access);
   p2 : aliased pairii.Item := pairii.construct (p1'unchecked_Access);
   p3 : aliased pairdd.Item := pairdd.construct (High'unchecked_Access, Low'unchecked_Access);
   p4 : aliased pairdd.Item := pairdd.construct (p3'unchecked_Access);
begin
   check (p2.first = 2 and p2.second = 3,       "an instance of integers is made from its members, and copied");
   check (p4.first = 3.5 and p4.second = 2.5,   "and one of real numbers");

   finish;
end Tester;
