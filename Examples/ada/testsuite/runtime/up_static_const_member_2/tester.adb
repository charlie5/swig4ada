with
     static_const_member_2.CavityPackFlags,
     static_const_member_2.Test_int,
     static_const_member_2.Foo,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'static_const_member_2' of upstream's suite, after its Python test: static members which
--  are constants with a value in their class, constants which are defined outside it, a variable, a
--  reference and objects of their own class.
--
is
   use static_const_member_2,
       interfaces.C,
       Checks;
begin
   check (CavityPackFlags.forward_field = 1 and CavityPackFlags.backward_field = 2,   "static constants which have their value in the class");
   check (CavityPackFlags.cavity_flags = 3,                    "one which is defined outside it has the value which the library gave it");
   check (CavityPackFlags.reftest.all = 42,                    "a static member which is a reference refers to its variable");

   CavityPackFlags.flags := 5;
   check (CavityPackFlags.flags = 5,                           "a static member variable is written and read");

   check (Test_int.current_profile = 4,                        "a static constant of a template instance");
   check (Test_int.anonymous_enum_1'Enum_Rep (Test_int.RightIndex) = 1,   "a value of an enumeration of the instance");

   check (Foo.BAZ.val = 2 * Foo.BAR.val and Foo.BAR.val = 1,   "static members which are objects of their own class");

   finish;
end Tester;
