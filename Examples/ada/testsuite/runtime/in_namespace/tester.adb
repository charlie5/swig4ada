with
     outer.in_namespace.Binding,
     outer.in_namespace.Flags,
     outer.in_namespace.Derived,
     outer.in_namespace.Shape,

     interfaces.C,

     Checks;


procedure Tester
--
--  A binding which is generated with '-namespace outer': its packages are children of 'Outer',
--  and its records are laid out, and its functions imported, as they are with no such package.
--
is
   use outer.in_namespace,
       outer.in_namespace.Binding,
       interfaces.C,
       Checks;

begin
   a_record_with_a_Clause :
   declare
      the_Flags : aliased Flags.Item;
   begin
      flags_set (the_Flags'unchecked_Access);

      check (the_Flags.a = 5 and the_Flags.b = 17,       "bit-fields are where C++ has them");
      check (the_Flags.c = 100,                          "and the member which follows them");

      the_Flags.b := 3;
      check (flags_sum (the_Flags'unchecked_Access) = 108,   "C++ reads what Ada wrote");
   end a_record_with_a_Clause;

   a_member_in_the_tail_of_a_base :
   declare
      the_Derived : aliased Derived.Item := Derived.construct;
   begin
      check (the_Derived.d = 'y',                              "a member in the tail of its base class is read");
      check (base_i (the_Derived'unchecked_Access) = 1,        "and the base class is as C++ made it");

      the_Derived.d := 'z';
      check (derived_d (the_Derived'unchecked_Access) = 'z',   "C++ reads what Ada wrote to the member");
      check (Derived.as_Base (the_Derived).i = 1,              "the base class is reached");
   end a_member_in_the_tail_of_a_base;

   an_enumeration :
   begin
      check (next (Red) = Green and next (Green) = Red,  "an enumeration of the top package is passed and returned");
   end an_enumeration;

   a_virtual_class :
   declare
      the_Shape : aliased Shape.Item := Shape.construct (4);
   begin
      check (the_Shape.corners = 4,                          "a virtual function is called from Ada");
      check (corners_of (the_Shape'unchecked_Access) = 4,    "and by C++");

      Shape.destruct_0 (the_Shape);
   end a_virtual_class;

   finish;
end Tester;
