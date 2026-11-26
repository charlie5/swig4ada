with
     pointer_reference.Binding,
     pointer_reference.Struct,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'pointer_reference' of upstream's suite, after its Python test: a reference to a constant pointer
--  ('Struct *const&'), as a parameter and as a result, which is a pointer to the pointer in Ada, and an overload of
--  a function on such a parameter.
--
is
   use pointer_reference,
       pointer_reference.Binding,
       interfaces.C,
       Checks;

   the_Struct : aliased Struct.Item    := Struct.construct (20);
   to_Struct  : aliased Struct.Pointer := the_Struct'unchecked_Access;
begin
   check (get.all.value = 10,                                           "a result which is a reference to a pointer");

   set (to_Struct'unchecked_Access);
   check (Struct.instance.value = 20,                                   "and a parameter, through which the static member is set");

   check (overloading (1) = 111,                                        "an overload of a number");
   check (overloading (to_Struct'unchecked_Access) = 222,               "and one of a reference to a pointer");

   finish;
end Tester;
