with
     using2.Binding,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'using2' of upstream's suite, after its Python test: a function whose parameter is a typedef of
--  a class which is named through an alias of its namespace and a 'using' declaration.
--
is
   use using2.Binding,
       interfaces.C,
       Checks;
begin
   check (spam (37) = 37,                                     "a typedef of a class, through a using declaration");

   finish;
end Tester;
