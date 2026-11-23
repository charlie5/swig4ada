with
     inherit_missing.Binding,
     inherit_missing.Pointers,
     inherit_missing.Bar,
     inherit_missing.Spam,

     interfaces.C.Strings,
     ada.unchecked_Conversion,
     System,

     Checks;


procedure Tester
--
--  The case 'inherit_missing' of upstream's suite, after its Python test: a class whose base class
--  is declared and never given to SWIG, and a class which is derived from it. The base is known
--  only by a pointer, so an object of a derived class is given as one by its address.
--
is
   use inherit_missing,
       inherit_missing.Binding,
       interfaces.C.Strings,
       Checks;

   function as_Foo is new ada.unchecked_Conversion (System.Address, Pointers.Foo_Pointer);

   the_Foo  : constant Pointers.Foo_Pointer := new_Foo;
   the_Bar  : aliased  Bar.Item             := Bar.Item  (Bar.construct);
   the_Spam : aliased  Spam.Item            := Spam.Item (Spam.construct);
   as_Bar   : constant Bar.Pointer          := the_Spam'unchecked_Access;
begin
   check (String'(Value (do_blah (the_Foo)))                  = "Foo::blah",    "the function of the base which is not known");
   check (String'(Value (do_blah (as_Foo (the_Bar'Address))))  = "Bar::blah",    "that of a class which is derived from it, called by C++ through the base");
   check (String'(Value (do_blah (as_Foo (the_Spam'Address)))) = "Spam::blah",   "and of a class derived from that");
   check (String'(Value (as_Bar.blah))                        = "Spam::blah",   "which Ada dispatches to as well");

   delete_Foo (the_Foo);
   Spam.destruct_0 (the_Spam);
   Bar.destruct_0  (the_Bar);
   finish;
end Tester;
