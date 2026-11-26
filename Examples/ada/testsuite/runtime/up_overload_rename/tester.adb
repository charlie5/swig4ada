with
     overload_rename.Foo,

     Checks;


procedure Tester
--
--  The case 'overload_rename' of upstream's suite, after its Python test: constructors with default arguments,
--  of which the interface file renames one. Ada tells constructors apart by their profiles, so each is 'construct'.
--
is
   use overload_rename,
       Checks;

   One   : constant Foo.Item := Foo.construct (1.0);
   Two   : constant Foo.Item := Foo.construct (1.0, 1.0);
   Three : constant Foo.Item := Foo.construct (1.0, 1);
   Four  : constant Foo.Item := Foo.construct (1.0, 1, 1.0);
begin
   check (One'Size = 8 and Two'Size = 8,                                "a constructor, with its default argument and without it");
   check (Three'Size = 8 and Four'Size = 8,                             "and the one which is renamed, likewise");

   finish;
end Tester;
