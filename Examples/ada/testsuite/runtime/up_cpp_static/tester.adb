with
     cpp_static.StaticFunctionTest,
     cpp_static.StaticMemberTest,
     cpp_static.StaticBase,
     cpp_static.StaticDerived,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'cpp_static' of upstream's suite, after its Python test: static member functions
--  and static member variables, among them one of the same name in a base and in its derived class.
--
is
   use cpp_static,
       interfaces.C,
       Checks;
begin
   StaticFunctionTest.static_func;
   StaticFunctionTest.static_func_2 (1);
   StaticFunctionTest.static_func_3 (1, 2);
   check (True,                                           "static functions of no, one and two parameters are called");

   check (StaticMemberTest.static_int = 99,               "a static member has the value which C++ gave it");
   check (StaticMemberTest.grab_int   = 99,               "which a static function returns");

   StaticMemberTest.static_int := 10;
   check (StaticMemberTest.static_int = 10,               "it is set from Ada");
   check (StaticMemberTest.grab_int   = 10,               "and C++ reads what Ada set");

   check (StaticBase.statty = 11,                         "the static member of a base class");
   check (StaticBase.grab_statty_base = 11,               "as C++ reads it");
   check (StaticDerived.statty = 111,                     "one of the same name in the derived class is another variable");
   check (StaticDerived.grab_statty_derived = 111,        "as C++ reads it");

   StaticBase   .statty := 22;
   StaticDerived.statty := 222;

   check (StaticBase.statty = 22 and StaticBase.grab_statty_base = 22,                 "the one of the base class is set");
   check (StaticDerived.statty = 222 and StaticDerived.grab_statty_derived = 222,      "and the one of the derived class, each alone");

   finish;
end Tester;
