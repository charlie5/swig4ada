with
     global_vars.Binding,

     swig.std_Strings,
     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'global_vars' of upstream's suite, after its Python test: global variables of several
--  kinds, among them a string, a reference and a pointer, which are read and set.
--
is
   use global_vars,
       global_vars.Binding,
       swig.std_Strings,
       interfaces.C,
       Checks;

   Read : aliased std_String;
begin
   init;

   check (to_Ada (b) = "string b",                "a string which C++ has set");

   assign (b, to_C ("a string value"));
   check (to_Ada (b) = "a string value",          "is set from Ada");

   read_b (Read'unchecked_Access);
   check (to_Ada (Read) = "a string value",       "and C++ reads what Ada set");

   check (x = 1234,                               "a number which C++ has set");

   x := 9876;
   check (x = 9876 and read_x = 9876,             "is set from Ada, and read by C++");

   check (c_member.all = 9876,                    "a reference to it is a pointer to it");

   h := Hola;
   check (hr.all = Hola,                          "a reference to an enumeration likewise");

   destruct (Read);
   finish;
end Tester;
