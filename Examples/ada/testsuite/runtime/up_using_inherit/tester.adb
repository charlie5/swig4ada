with
     using_inherit.Foo,
     using_inherit.Bar,
     using_inherit.Bar2,
     using_inherit.Bar3,
     using_inherit.Bar4,
     using_inherit.Fred1,
     using_inherit.Fred2,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'using_inherit' of upstream's suite, after its Python test: classes which redefine an overloaded
--  function of their base class, and name those of the base with a 'using' declaration.
--
--  A function which is named so is a function of the class in Ada too, as it is in C++. (The base class has
--  no virtual function, so it is a part of the record, and its other functions are reached through 'as_Foo'.)
--
is
   use using_inherit,
       interfaces.C,
       Checks;

   the_Bar   : aliased Bar  .Item;
   the_Bar2  : aliased Bar2 .Item;
   the_Bar3  : aliased Bar3 .Item;
   the_Bar4  : aliased Bar4 .Item;
   the_Fred1 : aliased Fred1.Item;
   the_Fred2 : aliased Fred2.Item;

begin
   check (Bar.test (the_Bar, int'(3)) = 3,                             "Bar::test (int), which a 'using' declaration names");
   check (Bar.test (the_Bar, double'(3.5)) = 3.5,                      "Bar::test (double)");
   check (Foo.test (Bar.as_Foo (the_Bar).all, int'(3)) = 3,            "which is still that of its base");

   check (Bar2.test (the_Bar2, int'(3)) = 6,                           "Bar2::test (int), which it redefines");
   check (Bar2.test (the_Bar2, double'(3.5)) = 7.0,                    "Bar2::test (double)");
   check (Foo.test (Bar2.as_Foo (the_Bar2).all, int'(3)) = 3,          "and that of its base, which is still reached");

   check (Bar3.test (the_Bar3, int'(3)) = 6,                           "Bar3::test (int)");
   check (Bar3.test (the_Bar3, double'(3.5)) = 7.0,                    "Bar3::test (double)");

   check (Bar4.test (the_Bar4, int'(3)) = 6,                           "Bar4::test (int)");
   check (Bar4.test (the_Bar4, double'(3.5)) = 7.0,                    "Bar4::test (double)");

   check (Fred1.test (the_Fred1, int'(3)) = 3,                         "Fred1::test (int), which is that of its base, named by 'using'");
   check (Fred1.test (the_Fred1, double'(3.5)) = 7.0,                  "Fred1::test (double), which it redefines");

   check (Fred2.test (the_Fred2, int'(3)) = 3,                         "Fred2::test (int)");
   check (Fred2.test (the_Fred2, double'(3.5)) = 7.0,                  "Fred2::test (double)");

   finish;
end Tester;
