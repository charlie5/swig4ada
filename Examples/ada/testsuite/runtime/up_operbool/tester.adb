with
     operbool.Test,

     swig,

     Checks;


procedure Tester
--
--  The case 'operbool' of upstream's suite, after its Python test: a conversion operator to 'bool', which
--  the interface file renames.
--
is
   use operbool,
       Checks;

   use type swig.bool;

   the_Test : constant Test.Item := Test.construct;
begin
   check (Test.operator_bool (the_Test) = swig.bool'Val (0),     "the conversion to 'bool' is false");

   finish;
end Tester;
