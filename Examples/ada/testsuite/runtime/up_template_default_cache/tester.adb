with
     template_default_cache.Binding,
     template_default_cache.Model,
     template_default_cache.ModelPtr,
     template_default_cache.ModelPtr_2,

     Checks;


procedure Tester
--
--  The case 'template_default_cache' of upstream's suite, after its Python test: two instances of one template, of
--  the classes 'Model' of two namespaces, each named by a typedef 'ModelPtr' in its namespace, and so bound as
--  'ModelPtr' and 'ModelPtr_2' (the names which the typedefs give them, not those of their '%template').
--
is
   use template_default_cache,
       template_default_cache.Binding,
       Checks;

   the_A     : constant ModelPtr  .Item := get_mp_a;
   the_B     : constant ModelPtr_2.Item := get_mp_b;
   the_Model : constant Model     .Item := Model.construct;
   from_Foo  : constant ModelPtr  .Item := Model.foo (the_Model);
begin
   check (the_A'Size = 8 and the_B'Size = 8,                            "an instance for each namespace, each of its own type");
   check (from_Foo'Size = 8,                                            "the instance of the other namespace, from a member function");

   finish;
end Tester;
