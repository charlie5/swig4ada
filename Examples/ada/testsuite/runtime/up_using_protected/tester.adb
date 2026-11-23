with
     using_protected.Foo,
     using_protected.FooBar,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'using_protected' of upstream's suite, after its Python test: a class makes protected
--  members of its base public by 'using' declarations.
--
is
   use using_protected,
       interfaces.C,
       Checks;

   the_FooBar : aliased FooBar.Item := FooBar.Item (FooBar.construct);
begin
   the_FooBar.x := 3;
   check (the_FooBar.x = 3,                       "a protected member variable of the base is set");
   check (Foo.blah (the_FooBar'Access, 4) = 4,    "a protected function of the base is called");

   FooBar.destruct_0 (the_FooBar);
   finish;
end Tester;
