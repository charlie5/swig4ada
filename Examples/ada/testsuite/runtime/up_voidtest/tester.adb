with
     voidtest.Binding,
     voidtest.Foo,
     voidtest.FooVoidTypedef,

     swig,
     System,

     Checks;


procedure Tester
--
--  The case 'voidtest' of upstream's suite, after its Python test: functions which return
--  nothing, among them ones which say so by a typedef of 'void', and pointers to 'void'.
--
is
   use voidtest,
       voidtest.Binding,
       Checks;

   use type swig.void_ptr,
            swig.bool,
            System.Address,
            Foo.Pointer;

   the_Foo  : aliased Foo.Item;
   the_Void : aliased FooVoidTypedef.Item := FooVoidTypedef.Item (FooVoidTypedef.construct);
begin
   globalfunc;
   globalfunc_typedef;
   globalfunc_renamed;

   Foo.memberfunc (the_Foo);
   Foo.staticmemberfunc;
   Foo.memberfunc_renamed (the_Foo);
   Foo.staticmemberfunc_renamed;

   FooVoidTypedef.memberfunc       (the_Void);
   FooVoidTypedef.memberfunc_const (the_Void);
   FooVoidTypedef.staticmemberfunc;

   check (True,     "functions which return nothing are called, as functions, members and static members");

   check (FooVoidTypedef.memberfunc_const_voidptr (the_Void'Access) = swig.void_ptr (System.null_Address),   "a function which returns a pointer to 'void', by a typedef");

   declare
      v1 : constant swig.void_ptr := vfunc1 (swig.void_ptr (the_Foo'Address));
      v2 : constant swig.void_ptr := vfunc2 (the_Foo'unchecked_Access);
      v3 : constant Foo.Pointer   := vfunc3 (v1);
   begin
      check (v1 = v2,                                        "an object passes as a pointer to 'void', and as itself");
      check (v3 = the_Foo'unchecked_Access,                  "and comes back as a pointer to its class");
      check (vfunc4 (the_Foo'unchecked_Access) = v3,         "or by a function of its class alone");
      check (test_pointers_equal (v1, v2) /= swig.bool'Val (0),     "C++ finds the two pointers equal");
      check (Foo.get_this (the_Foo) = v1,                    "and the object gives its own address");

      Foo.memberfunc (v3.all);
   end;

   finish;
end Tester;
