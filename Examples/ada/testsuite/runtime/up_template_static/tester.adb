with
     template_static.foo_i,
     template_static.foo_d,
     template_static.Foo,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'template_static' of upstream's suite, after its Python test: a static member of a class template,
--  of which each instance has its own, and a static member function template of a class in a namespace, of
--  which the interface file names an instance.
--
is
   use template_static,
       interfaces.C,
       Checks;
begin
   check (foo_i.test = 0 and foo_d.test = 0,                 "the static member of each instance of a template");

   foo_i.test := 3;
   check (foo_i.test = 3 and foo_d.test = 0,                 "which is its own");

   check (Foo.test = 5,                                       "the static member of a class in a namespace");
   check (Foo.bar_double (1) = 1.0,                           "and an instance of its member function template");

   finish;
end Tester;
