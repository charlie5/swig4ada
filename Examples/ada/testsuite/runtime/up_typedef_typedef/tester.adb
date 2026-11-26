with
     typedef_typedef.B,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'typedef_typedef' of upstream's suite, after its Python test: a parameter whose type is a typedef
--  named through a typedef of its class ('C::Bar::Foo', which is 'A::Foo'), which an 'in' typemap of 'A::Foo'
--  must match, as the typemap sets the argument whatever is given.
--
is
   use typedef_typedef,
       interfaces.C,
       Checks;

   the_B : constant B.Item := B.construct;
begin
   check (B.getValue (the_B, 123) = 1234,                     "the typemap of the typedef is applied");

   finish;
end Tester;
