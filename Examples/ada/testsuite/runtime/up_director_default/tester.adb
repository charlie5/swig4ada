with
     director_default.Foo,
     director_default.Bar,
     director_default.DefaultsBase,
     director_default.DefaultsDerived,

     Messages,

     swig.Pointers,
     swig.std_Strings,
     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'director_default' of upstream's suite, after its Python test: classes whose constructor and virtual
--  function have default arguments, one of them with a director, whose function is overridden in Ada and called
--  by C++ with its default argument; and a pure virtual function whose result and parameter are typedefs.
--
is
   use director_default,
       swig.std_Strings,
       interfaces.C,
       Checks;

   use type swig.Pointers.int_Pointer;

   Word   : aliased std_String := to_std_String (to_C ("hi"));
   Result : aliased std_String;

begin
   of_a_Class :
   declare
      the_Bar   : aliased Bar.Item := Bar.Item (Bar.construct);
      other_Bar : aliased Bar.Item := Bar.Item (Bar.construct (1));
   begin
      Bar.Msg (the_Bar, Word, Result'unchecked_Access);
      check (to_Ada (Result) = "Bar-hi",                                    "a virtual function which returns a string, given its argument");

      Bar.Msg (the_Bar, Result'unchecked_Access);
      check (to_Ada (Result) = "Bar-default",                               "and with its default argument");

      Bar.GetMsg (other_Bar, Result'unchecked_Access);
      check (to_Ada (Result) = "Bar-default",                               "through a function which calls it, of an object of the other constructor");

      Bar.destruct_0 (other_Bar);
      Bar.destruct_0 (the_Bar);
   end of_a_Class;

   of_a_Class_with_a_Director :
   declare
      the_Foo   : aliased Foo.Item := Foo.Item (Foo.construct);
      other_Foo : aliased Foo.Item := Foo.Item (Foo.construct (1));
   begin
      Foo.GetMsg (the_Foo, Result'unchecked_Access);     -- The class of C++ is not the one which the interface file shows.
      check (to_Ada (Result) = "Foo-default",                               "the function of the class of C++");

      Foo.GetMsg (other_Foo, Word, Result'unchecked_Access);
      check (to_Ada (Result) = "Foo-hi",                                    "given its argument, of an object of the other constructor");

      Foo.destruct_0 (other_Foo);
      Foo.destruct_0 (the_Foo);
   end of_a_Class_with_a_Director;

   overridden_in_Ada :
   declare
      the_Echo : aliased Messages.Echo;
   begin
      Foo.GetMsg (the_Echo, Result'unchecked_Access);
      check (to_Ada (Result) = "echo default",                              "C++ calls the function of Ada, with its default argument");

      Foo.GetMsg (the_Echo, Word, Result'unchecked_Access);
      check (to_Ada (Result) = "echo hi",                                   "and with the argument which it is given");

      Foo.Msg (the_Echo, Word, Result'unchecked_Access);
      check (to_Ada (Result) = "echo hi",                                   "and through the class-wide function, which makes the virtual call");

      Foo.destruct_0 (Foo.Item (the_Echo));
   end overridden_in_Ada;

   of_typedefs :
   declare
      the_Derived : aliased DefaultsDerived.Item := DefaultsDerived.Item (DefaultsDerived.construct);
      as_Base     : constant access DefaultsBase.Item'Class := the_Derived'Access;
   begin
      check (DefaultsBase.defaultargs (as_Base, 1.5, null) = null,          "a pure virtual function whose result is a typedef of a pointer");
      check (DefaultsBase.defaultargs (as_Base, 1.5)       = null,          "and with its default argument");
   end of_typedefs;

   destruct (Result);
   destruct (Word);

   finish;
end Tester;
