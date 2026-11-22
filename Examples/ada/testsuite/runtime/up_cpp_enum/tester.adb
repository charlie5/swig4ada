with
     cpp_enum.Foo,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'cpp_enum' of upstream's suite, after its Python test: enumerations with no name, as a member
--  of a class and as a variable, and literals whose values are written as casts.
--
is
   use cpp_enum,
       interfaces.C,
       Checks;

   use type Foo.anonymous_enum_1;

   the_Foo : aliased Foo.Item := Foo.construct;
begin
   check (the_Foo.hola = Foo.Hello,               "a member which is an enumeration has the value its constructor gave");

   the_Foo.hola := Foo.Hi;
   check (the_Foo.hola = Foo.Hi,                  "and is set");

   the_Foo.hola := Foo.Hello;
   check (the_Foo.hola = Foo.Hello,               "and set again");

   the_hi := Hello;
   check (the_hi = Hello,                         "a variable which is an enumeration of no name");

   --  A value which is written as a cast is worked out ('(mytype0) 10', 'static_cast< mytype1 >(10)').
   --
   check (Enum2796'Enum_Rep (CASE0A) = 10,        "a literal whose value is a cast");
   check (CASE0C = CASE0A and CASE1A = CASE0A,    "and those which have the same value are equal to it");

   finish;
end Tester;
