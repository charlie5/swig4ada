with
     struct_initialization.Binding,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'struct_initialization' of upstream's suite, after its Python test: variables
--  which are declared with their structure, some of them arrays, and given their values there.
--
is
   use struct_initialization.Binding,
       interfaces.C,
       Checks;
begin
   check (instanceC1.x = 10,             "a variable which is declared with its structure, and given a value");
   check (instanceD1.x = 10,             "the first of three of them");
   check (instanceD2.x = 20,             "the second");
   check (instanceD3.x = 30,             "the third");
   check (instanceE1 (0).x = 1,          "an array of them");
   check (instanceE1 (2).x = 3,          "and its last element");
   check (instanceF1 (0).x = 1,          "the first of three arrays");
   check (instanceF2 (1).x = -2,         "the second");
   check (instanceF3 (1).x = 22,         "the third");

   instanceA1.x := 5;
   check (instanceA1.x = 5,              "a variable with no initial value is set");

   finish;
end Tester;
