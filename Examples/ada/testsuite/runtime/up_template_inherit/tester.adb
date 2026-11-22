with
     template_inherit.Binding,
     template_inherit.FooInt,
     template_inherit.FooDouble,
     template_inherit.FooUInt,
     template_inherit.BarInt,
     template_inherit.BarDouble,
     template_inherit.BarUInt,

     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'template_inherit' of upstream's suite, after its Python test: a class template with
--  virtual functions which is derived from another, and three instances of each.
--
is
   use template_inherit,
       template_inherit.Binding,
       interfaces.C.Strings,
       Checks;

   function "=" (Left : in chars_ptr;   Right : in String) return Boolean
   is (String'(Value (Left)) = Right);

   a : aliased FooInt   .Item := FooInt   .Item (FooInt   .construct);
   b : aliased FooDouble.Item := FooDouble.Item (FooDouble.construct);
   c : aliased BarInt   .Item := BarInt   .Item (BarInt   .construct);
   d : aliased BarDouble.Item := BarDouble.Item (BarDouble.construct);
   e : aliased FooUInt  .Item := FooUInt  .Item (FooUInt  .construct);
   f : aliased BarUInt  .Item := BarUInt  .Item (BarUInt  .construct);
begin
   check (a.blah = "Foo",     "the virtual function of the base, of an instance");
   check (b.blah = "Foo",     "of a second");
   check (e.blah = "Foo",     "of a third");

   check (c.blah = "Bar",     "the function which the derived template overrides, of an instance");
   check (d.blah = "Bar",     "of a second");
   check (f.blah = "Bar",     "of a third");

   check (c.foomethod = "foomethod",     "a function of the base which the derived class inherits");
   check (d.foomethod = "foomethod",     "of a second instance");
   check (f.foomethod = "foomethod",     "of a third");

   check (invoke_blah_int    (a'unchecked_Access) = "Foo",     "C++ calls the virtual function of an object of the base");
   check (invoke_blah_int    (c'unchecked_Access) = "Bar",     "and dispatches to that of the derived class");
   check (invoke_blah_double (b'unchecked_Access) = "Foo",     "of a second instance");
   check (invoke_blah_double (d'unchecked_Access) = "Bar",     "and its derived class");
   check (invoke_blah_uint   (e'unchecked_Access) = "Foo",     "of a third");
   check (invoke_blah_uint   (f'unchecked_Access) = "Bar",     "and its derived class");

   finish;
end Tester;
