with
     typedef_funcptr.Binding,

     Operations,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'typedef_funcptr' of upstream's suite, after its Python test: functions which take a pointer to a function,
--  of a type with no typedef whose parameters are a typedef, and of two typedefs of such a type, each given a function
--  of Ada, which C++ calls.
--
is
   use typedef_funcptr,
       typedef_funcptr.Binding,
       interfaces.C,
       Checks;
begin
   check (do_op (100, 10, Operations.add'Access)      = 110,            "a pointer to a function of a type with no typedef");
   check (do_op (100, 10, Operations.subtract'Access) = 90,             "and another function");

   check (do_op_typedef_int     (100, 10, Operations.add'Access)      = 110
      and do_op_typedef_int     (100, 10, Operations.subtract'Access) = 90,     "of a typedef of the type");

   check (do_op_typedef_Integer (100, 10, Operations.add'Access)      = 110
      and do_op_typedef_Integer (100, 10, Operations.subtract'Access) = 90,     "and of one whose parameters are a typedef");

   finish;
end Tester;
