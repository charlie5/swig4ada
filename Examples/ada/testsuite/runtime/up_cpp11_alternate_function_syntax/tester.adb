with
     cpp11_alternate_function_syntax.SomeStruct,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'cpp11_alternate_function_syntax' of upstream's suite, after its Python test: member
--  functions which are declared with a trailing return type ('auto f (int x) -> int'), some of them
--  constant or 'noexcept'.
--
is
   use cpp11_alternate_function_syntax,
       interfaces.C,
       Checks;

   the_Struct : aliased SomeStruct.Item := SomeStruct.Item (SomeStruct.construct);
begin
   check (the_Struct.addNormal                 (4, 5) = 9,   "a function which is declared in the usual way");
   check (the_Struct.addAlternate              (4, 5) = 9,   "one with a trailing return type");
   check (the_Struct.addAlternateConst         (4, 5) = 9,   "one which is constant");
   check (the_Struct.addAlternateNoExcept      (4, 5) = 9,   "one which is 'noexcept'");
   check (the_Struct.addAlternateConstNoExcept (4, 5) = 9,   "and one which is both");
   check (the_Struct.addFinal                  (4, 5) = 9,   "a virtual one which is final");

   SomeStruct.destruct_0 (the_Struct);
   finish;
end Tester;
