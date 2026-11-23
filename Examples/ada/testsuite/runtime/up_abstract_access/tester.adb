with
     abstract_access.D,
     abstract_access.D.Guards,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'abstract_access' of upstream's suite, after its Python test: a chain of four classes,
--  each of which defines privately or protectedly a pure virtual function of the first. A public
--  function of the first calls through them all.
--
is
   use abstract_access,
       interfaces.C,
       Checks;

   the_D     : aliased D.Item := D.Item (D.construct);
   the_Guard : D.Guards.Guard (the_D'Access) with Unreferenced;     -- 'D' has no destructor of its own; that of 'A' is virtual.
begin
   check (the_D.do_x = 1,   "a function which calls a private pure virtual function reaches the definitions of the derived classes");

   finish;
end Tester;
