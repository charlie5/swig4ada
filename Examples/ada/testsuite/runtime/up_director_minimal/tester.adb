with
     director_minimal.Minimal,

     Runners,

     swig,

     Checks;


procedure Tester
--
--  The case 'director_minimal' of upstream's suite, after its Python test: a virtual function which a class derived
--  in Ada overrides, and which a function of the class calls. It is called through the vtable, and needs no director.
--
is
   use director_minimal,
       Checks;

   use type swig.bool;

   the_Minimal : aliased Minimal.Item := Minimal.Item (Minimal.construct);
   the_Always  : aliased Runners.Always;
begin
   check (Minimal.get (the_Minimal'Access) = swig.bool'Val (0),     "the function of the class");
   check (Minimal.get (the_Always 'Access) = swig.bool'Val (1),     "and that of Ada which overrides it, which C++ calls");

   Minimal.destruct_0 (Minimal.Item (the_Always));
   Minimal.destruct_0 (the_Minimal);

   finish;
end Tester;
