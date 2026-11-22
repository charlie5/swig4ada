with
     typedef_inherit.Binding,
     typedef_inherit.Foo,
     typedef_inherit.Bar,
     typedef_inherit.Spam,
     typedef_inherit.Grok,
     typedef_inherit.Thing,
     typedef_inherit.DerivedThing,

     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'typedef_inherit' of upstream's suite, after its Python test: classes
--  which are derived from a base that is named by a typedef.
--
is
   use typedef_inherit,
       typedef_inherit.Binding,
       interfaces.C.Strings,
       Checks;

   function "=" (Left : in chars_ptr;   Right : in String) return Boolean
   is (String'(Value (Left)) = Right);

   a : aliased Foo         .Item := Foo         .Item (Foo         .construct);
   b : aliased Bar         .Item := Bar         .Item (Bar         .construct);
   c : aliased Spam        .Item := Spam        .Item (Spam        .construct);
   d : aliased Grok        .Item := Grok        .Item (Grok        .construct);
   e : aliased Thing       .Item := Thing       .Item (Thing       .construct);
   f : aliased DerivedThing.Item := DerivedThing.Item (DerivedThing.construct);
begin
   check (do_blah  (a'unchecked_Access) = "Foo::blah",              "the virtual function of a base class");
   check (do_blah  (b'unchecked_Access) = "Bar::blah",              "and of a class derived from it by a typedef of its name");

   check (do_blah2 (c'unchecked_Access) = "Spam::blah",             "a base which is a structure with a typedef");
   check (do_blah2 (d'unchecked_Access) = "Grok::blah",             "and the class derived from it");
   check (Spam.far1 (d'Access) = "Spam::far1",                      "which inherits a function of its base");

   check (Thing.blah (Thing.Item'Class (f)'Access) = "DerivedThing::blah",   "a class derived through a typedef is of the class of its base, and dispatches");
   check (do_blah3 (e'unchecked_Access) = "Thing::blah",            "the base");
   check (do_blah3 (f'unchecked_Access) = "DerivedThing::blah",     "and the derived class");

   finish;
end Tester;
