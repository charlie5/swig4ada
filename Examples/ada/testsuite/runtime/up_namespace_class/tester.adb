with
     namespace_class.EulerT3D,
     namespace_class.BooT_i,
     namespace_class.FooT_i,
     namespace_class.FooT_d,
     namespace_class.FooT_H,
     namespace_class.Foo,
     namespace_class.Bar,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'namespace_class' of upstream's suite, after its Python test: classes and class templates
--  which are declared in namespaces, instances which are named from within and from outside them, and
--  an enumeration of a namespace as the argument of a template.
--
is
   use namespace_class,
       interfaces.C,
       Checks;

   One    : aliased int := 1;
   Unused : BooT_i.Item with Unreferenced;

   an_Int   : aliased FooT_i.Item;
   a_Double : aliased FooT_d.Item;
   a_Hello  : aliased FooT_H.Item;
   a_Foo    : aliased Foo.Item;
begin
   EulerT3D.toFrame (One'unchecked_Access, One'unchecked_Access, One'unchecked_Access);
   check (True,                                       "a static function of a class in a namespace, with references to numbers");

   check (FooT_i.quack (an_Int,   1)   = 1,           "a function of a template instance which is named within its namespace");
   check (FooT_d.moo   (a_Double, 1.0) = 1.0,         "of an instance which is named from outside it");
   check (FooT_H.foo   (a_Hello,  Hi)  = Hi,          "and of one whose argument is an enumeration of the namespace");

   check (Foo.bar (a_Foo, Hi) = Hi,                   "a class which is derived from one of another namespace");
   check (Bar.foo (Foo.as_Bar (a_Foo).all, Hi) = Hi,  "whose function is reached through the base");

   finish;
end Tester;
