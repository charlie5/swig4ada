with
     director_enum.Foo,
     director_enum.B2,
     director_enum.A2,
     director_enum.Pointers,

     Greeters,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'director_enum' of upstream's suite, after its Python test: virtual functions which take and return an
--  enumeration (renamed) and one of their class, and a reference to one, one of them overridden in Ada and called by
--  C++; and constructors which take an enumeration, with it as their default argument.
--
is
   use director_enum,
       interfaces.C,
       Checks;

   use type Pointers.Hallo_Pointer,
            Foo.Bye;

   the_Foo  : aliased Foo.Item       := Foo.Item (Foo.construct);
   the_Yo   : aliased Greeters.Yo_Sayer;
   the_B2   : aliased B2.Item        := B2.Item (B2.construct (EA));
   Greeting : aliased Hallo          := awright;
   as_A2    : constant access A2.Item'Class := the_B2'Access;
begin
   check (Foo.ping (the_Foo'Access, hello) = hello,                    "a virtual function of an enumeration, through a function of the class");
   check (Foo.say_hello (the_Foo'Access, hi) = hello,                  "and another");
   check (Foo.ping (the_Yo'Access, hi) = yo,                           "C++ calls the function of Ada which overrides it");

   check (Foo.ping_member_enum (the_Foo'Access, Foo.aufwiedersehen) = Foo.aufwiedersehen,
          "an enumeration of the class");
   check (Foo.ping_ref (the_Foo'Access, Greeting'unchecked_Access) = Greeting'unchecked_Access,
          "and a reference to one, which is the object given");

   check (A2.f (as_A2, 3) = 3 and A2.f (as_A2) = 0,                    "a class made from an enumeration, and a virtual function with a default argument");

   Foo.destruct_0 (Foo.Item (the_Yo));
   Foo.destruct_0 (the_Foo);
   finish;
end Tester;
