with
     overload_extend.Foo,
     overload_extend.Bar,

     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'overload_extend' of upstream's suite, after its Python test: overloads which '%extend' adds to a class,
--  one of which takes the place of a member function of the same profile, and one of which has a default argument;
--  and a constructor and destructor which '%extend' adds to a structure.
--
is
   use overload_extend,
       interfaces.C,
       interfaces.C.Strings,
       Checks;

   the_Foo : constant Foo.Item := Foo.construct;
   Text    :          chars_ptr := new_String ("hello");
   the_Bar :          Bar.Item  := Bar.construct;
begin
   check (Foo.test (the_Foo)           = 0,                             "the overload which '%extend' adds in the place of the member");
   check (Foo.test (the_Foo, 3)        = 1,                             "one of a number");
   check (Foo.test (the_Foo, Text)     = 2,                             "of a string");
   check (Foo.test (the_Foo, 3.0, 2.0) = 5.0,                           "of two reals");
   check (Foo.test (the_Foo, 3.0)      = 1003.0,                        "and with its default argument");

   the_Bar.variable := 7;
   check (the_Bar.variable = 7,                                         "a structure made by the constructor which '%extend' adds");

   free (Text);
   finish;
end Tester;
