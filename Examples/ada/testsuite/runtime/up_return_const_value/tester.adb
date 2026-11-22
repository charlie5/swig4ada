with
     return_const_value.Foo,
     return_const_value.Foo_ptr,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'return_const_value' of upstream's suite, after its Python test: a smart
--  pointer which is returned by value, and returned as a constant.
--
is
   use return_const_value,
       interfaces.C,
       Checks;

   the_Pointer  : aliased Foo_ptr.Item := Foo_ptr.construct (Foo.Pointer'(null));
   the_Constant : aliased Foo_ptr.Item := Foo_ptr.construct (Foo.Pointer'(null));
begin
   Foo_ptr.getPtr (the_Pointer'unchecked_Access);
   check (Foo_ptr.getVal (the_Pointer) = 17,                   "a smart pointer which is returned by value");
   check (Foo.getVal (Foo_ptr.dereference (the_Pointer).all) = 17,   "and what it points to");

   Foo_ptr.getConstPtr (the_Constant'unchecked_Access);
   check (Foo_ptr.getVal (the_Constant) = 17,                  "one which is returned as a constant");

   Foo_ptr.destruct_0 (the_Constant);
   Foo_ptr.destruct_0 (the_Pointer);

   finish;
end Tester;
