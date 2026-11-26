with
     using1.Binding,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'using1' of upstream's suite, after its Python test: a function whose parameter is a typedef of
--  a class which is named through an alias of its namespace and a 'using namespace' directive.
--
is
   use using1.Binding,
       interfaces.C,
       Checks;
begin
   check (spam (37) = 37,                                     "a typedef of a class, through a using directive");

   finish;
end Tester;
