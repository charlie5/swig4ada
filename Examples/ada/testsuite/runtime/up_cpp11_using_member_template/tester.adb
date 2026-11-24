with
     cpp11_using_member_template.Derived,
     cpp11_using_member_template.MoreDerived,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'cpp11_using_member_template' of upstream's suite, after its Python test: classes derived from a
--  base whose one member is a 'std::shared_ptr' of a type which is not bound, and whose one constructor takes
--  one. The base is bytes of its size in the record of each derived class, which C++ constructs.
--
is
   use cpp11_using_member_template,
       interfaces.C,
       Checks;

   the_Derived      : aliased Derived.Item;
   the_More_Derived : aliased MoreDerived.Item;
begin
   check (Derived.value (the_Derived) = 1,                                              "an object which Ada declares is constructed, with the storage of its base");
   check (Derived.value (MoreDerived.as_Derived (the_More_Derived).all) = 2,            "and one derived from it in turn, which is reached as its base");

   Derived    .destruct (the_Derived);
   MoreDerived.destruct (the_More_Derived);

   finish;
end Tester;
