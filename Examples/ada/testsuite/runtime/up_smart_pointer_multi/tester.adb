with
     smart_pointer_multi.Foo,
     smart_pointer_multi.Bar,
     smart_pointer_multi.Spam,
     smart_pointer_multi.Grok,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'smart_pointer_multi' of upstream's suite, after its Python test: smart pointers whose 'operator->'
--  returns another smart pointer, by value and by reference, which C++ follows in turn to the class which it points
--  to. Each is given the functions of that class.
--
is
   use smart_pointer_multi,
       interfaces.C,
       Checks;

   the_Foo  : aliased  Foo .Item := Foo .construct;
   the_Bar  : aliased  Bar .Item := Bar .construct (the_Foo'unchecked_Access);
   the_Spam : constant Spam.Item := Spam.construct (the_Bar'unchecked_Access);
   the_Grok : constant Grok.Item := Grok.construct (the_Bar'unchecked_Access);
begin
   the_Foo.x := 3;
   check (Spam.getx (the_Spam) = 3,                                     "a function through a smart pointer which gives another by value");
   check (Bar.getx (Spam.dereference (the_Spam)) = 3,                   "and through the one which it gives");

   Bar.dereference (Grok.dereference (the_Grok).all).x := 4;
   check (Grok.getx (the_Grok) = 4,                                     "through one which gives another by reference");
   check (the_Foo.x = 4,                                                "and the member is that of the object pointed to");

   finish;
end Tester;
