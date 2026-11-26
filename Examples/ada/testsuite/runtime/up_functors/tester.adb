with
     functors.Functor0,
     functors.Functor1,
     functors.Functor2,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'functors' of upstream's suite, after its Python test: classes with an 'operator()' of no, one and two
--  parameters, which is 'call' in Ada (as Python's library names it '__call__'; the interface file names it only for
--  other languages), and a function of the class which calls it.
--
is
   use functors,
       interfaces.C,
       Checks;

   Zero : constant Functor0.Item := Functor0.construct (10);
   One  : constant Functor1.Item := Functor1.construct (10);
   Two  : constant Functor2.Item := Functor2.construct (10);
begin
   check (Functor0.call (Zero)       = -10,                             "an operator of no parameter");
   check (Functor1.call (One, 1)     = 11,                              "of one");
   check (Functor2.call (Two, 1, 2)  = 13,                              "and of two");

   check (Functor0.operate (Zero) = -10 and Functor1.operate (One, 1) = 11 and Functor2.operate (Two, 1, 2) = 13,
          "and the function of each class which calls it");

   finish;
end Tester;
