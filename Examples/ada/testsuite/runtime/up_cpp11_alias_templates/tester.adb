with
     cpp11_alias_templates.Binding,
     cpp11_alias_templates.ContainerInt,
     cpp11_alias_templates.FixedArrayFloat4,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'cpp11_alias_templates' of upstream's suite, after its Python test: functions which return instances of
--  alias templates ('Box<int>', an alias of 'Container<int>', 'Boxed<int>', an alias of the alias, and 'Quad<float>',
--  of 'FixedArray<float, 4>'), which are the instances which they stand for.
--
is
   use cpp11_alias_templates,
       cpp11_alias_templates.Binding,
       interfaces.C,
       Checks;

   the_Box   : constant ContainerInt    .Item := make_box   (55);
   the_Boxed : constant ContainerInt    .Item := make_boxed (99);
   the_Quad  : constant FixedArrayFloat4.Item := make_quad;
begin
   check (ContainerInt.get (the_Box) = 55,                              "an instance of an alias template");

   ContainerInt.set (the_Box, 77);
   check (ContainerInt.get (the_Box) = 77,                              "which is the instance of the template which it names");

   check (ContainerInt.get (the_Boxed) = 99,                            "and through an alias of the alias");

   FixedArrayFloat4.set (the_Quad, 2, 3.5);
   check (FixedArrayFloat4.size (the_Quad) = 4,                         "an alias which gives one of the arguments of its template");
   check (FixedArrayFloat4.get  (the_Quad, 2) = 3.5,                    "and the other");

   finish;
end Tester;
