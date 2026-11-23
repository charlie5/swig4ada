with
     enums.Binding,

     Checks;


procedure Tester
--
--  The case 'enums' of upstream's suite, after its Python test: enumerations of C which have a
--  name, a typedef or neither, as the type of a parameter and of a variable.
--
is
   use enums,
       enums.Binding,
       Checks;
begin
   bar2 (FGHJI);
   bar3 (FGHJI);
   bar1 (CSP_ITERATION_BWD);
   check (True,                                           "a function takes a value of an enumeration, by its name and by its typedef");

   check (Exclamation'Enum_Rep (enumInstance) = 2,        "a variable which is declared with its enumeration has the value which the library gave it");
   check (ContainYourself'Enum_Rep (the_Slap)  = 10,      "as has one of three which are declared with theirs");
   check (ContainYourself'Enum_Rep (the_Mine)  = 11,      "the second");
   check (ContainYourself'Enum_Rep (the_Thigh) = 12,      "and the third");

   finish;
end Tester;
