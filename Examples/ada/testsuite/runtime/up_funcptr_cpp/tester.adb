with
     funcptr_cpp.Binding,

     Callbacks,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'funcptr_cpp' of upstream's suite, after its Python test: pointers to functions which take a reference,
--  and return a number, a pointer or a reference, given by constants of those types which have no typedef, one of
--  them constant itself, and called by C++; and a function of Ada given in their place.
--
is
   use funcptr_cpp.Binding,
       interfaces.C,
       Checks;
begin
   check (call1 (ADD_BY_VALUE,     10, 11) = 21,                        "a pointer to a function which returns a number");
   check (call2 (ADD_BY_POINTER,   12, 13) = 25,                        "one which returns a pointer");
   check (call3 (ADD_BY_REFERENCE, 14, 15) = 29,                        "and one which returns a reference");
   check (call1 (ADD_BY_VALUE_C,    2,  3) = 5,                         "a constant which is a constant pointer");
   check (callconst1 (ADD_BY_VALUE_C, 2, 3) = 5,                        "given for a parameter which is a constant pointer");

   check (call1 (Callbacks.multiply'Access, 3, 4) = 12,                 "a function of Ada in the place of one of C++");

   finish;
end Tester;
