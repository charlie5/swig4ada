with
     enum_forward.Binding,

     Checks;


procedure Tester
--
--  The case 'enum_forward' of upstream's suite, after its Python test: enumerations of C which are declared ahead
--  of their use, two of them only so (their literals are not shown), one of those three times, and one defined
--  after. An enumeration whose literals are not shown is one of a single literal, 'nil', of value 0.
--
is
   use enum_forward,
       enum_forward.Binding,
       Checks;
begin
   check (test_function1 (get_enum1) = nil,                             "an enumeration which is declared ahead");
   check (test_function2 (get_enum2) = nil,                             "one which is declared ahead three times");
   check (test_function3 (get_enum3) = EEE,                             "and one which is defined after");
   check (test_function3 (FFF) = FFF,                                   "with each of its literals");

   finish;
end Tester;
