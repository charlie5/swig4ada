with
     using_private.Foo,
     using_private.FooBar,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'using_private' of upstream's suite, after its Python test: a class which is derived
--  privately makes members of its base public again by 'using' declarations. Its base is the parent
--  of the Ada type, so the members are those of the parent.
--
is
   use using_private,
       interfaces.C,
       Checks;

   the_FooBar : aliased FooBar.Item := FooBar.Item (FooBar.construct);
begin
   the_FooBar.x := 3;
   check (the_FooBar.x = 3,                                 "a member variable of the private base is set");
   check (Foo.blah (the_FooBar'Access, 4) = 4,              "a function of the private base is called");
   check (Foo.defaulted (the_FooBar'Access) = -1,           "one with a default argument, which is left out");
   check (Foo.defaulted (the_FooBar'Access, 222) = 222,     "and which is given");

   FooBar.destruct_0 (the_FooBar);
   finish;
end Tester;
