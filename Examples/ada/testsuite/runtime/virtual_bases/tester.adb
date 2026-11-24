with
     virtual_bases.Binding,
     virtual_bases.W,
     virtual_bases.X,
     virtual_bases.Y,
     virtual_bases.Z,
     virtual_bases.U,
     virtual_bases.M,

     interfaces.C,

     Checks;


procedure Tester
--
--  Classes with no virtual function which inherit a base class virtually. C++ lays each virtual base out after all
--  of the rest of the object, once, so the Ada record has it last, and has the place of the pointer to the table
--  through which C++ finds it. Each object is declared in Ada, and C++ constructs it.
--
is
   use virtual_bases,
       virtual_bases.Binding,
       interfaces.C,
       Checks;

begin
   a_virtual_Base :
   declare
      the_W : aliased W.Item;
   begin
      check (W.Item'Size / 8 = size_of_w,                    "the record of a class with a virtual base has the size of its class");
      check (the_W.w = 20,                                   "its own member is where C++ has it, after the pointer to the table");
      check (the_W.V.v = 10,                                 "and the virtual base, which is in its tail");

      the_W.w   := 21;
      the_W.V.v := 11;
      check (w_of (the_W'unchecked_Access) = 21,             "C++ reads the member which Ada writes");
      check (v_of (the_W'unchecked_Access) = 11,             "and the virtual base, which it finds through the table");
      check (W.as_V (the_W).v = 11,                          "which is reached through 'as_V' too");
   end a_virtual_Base;

   a_Diamond :
   declare
      the_Y : aliased Y.Item;
   begin
      check (Y.Item'Size / 8 = size_of_y,                    "a diamond, whose two bases share their virtual base");
      check (the_Y.y = 40,                                   "its own member is after the two bases");
      check (the_Y.V.v = 10,                                 "and the virtual base is last, once");

      set_v (W.as_V (Y.as_W (the_Y).all), 77);
      check (v_through_x (the_Y'unchecked_Access) = 77,      "the virtual base which is set through one base is that of the other");
      check (v_through_w (the_Y'unchecked_Access) = 77,      "and of the first");
      check (the_Y.V.v = 77,                                 "and the one which the record has");
      check (X.as_V (Y.as_X (the_Y).all).v = 77,             "and the one which the other base reaches");
   end a_Diamond;

   a_Base_with_a_virtual_Base :
   declare
      the_Z : aliased Z.Item;
   begin
      check (Z.Item'Size / 8 = size_of_z,                    "a class derived from one with a virtual base, which has the base's own part first");
      check (the_Z.z = 5,                                    "its own member is in what is left of that part");
      check (z_of (the_Z'unchecked_Access) = 5,              "as C++ has it");
      check (the_Z.V.v = 10,                                 "and the virtual base after it");
      check (W.as_V (Z.as_W (the_Z).all).v = 10,             "which the base reaches");
   end a_Base_with_a_virtual_Base;

   a_virtual_Base_with_a_virtual_Base :
   declare
      the_U : aliased U.Item;
   begin
      check (U.Item'Size / 8 = size_of_u,                    "a class whose virtual base has a virtual base");
      check (the_U.u = 6,                                    "its own member");
      check (w_of_u (the_U'unchecked_Access) = 20,           "its virtual base, which comes first of the two");
      check (U.as_W (the_U).w = 20,                          "which is reached through 'as_W'");
      check (v_of_u (the_U'unchecked_Access) = 10,           "and the virtual base of that one, which comes last");
      check (the_U.V.v = 10,                                 "and which the record has");
   end a_virtual_Base_with_a_virtual_Base;

   a_nearly_empty_virtual_Base :
   declare
      the_M : aliased M.Item;
   begin
      check (M.Item'Size / 8 = size_of_m,                    "a class whose virtual base has nothing but its pointer, which the two share");
      check (the_M.m = 7,                                    "its own member is after that pointer");
      check (m_of (the_M'unchecked_Access) = 7,              "as C++ has it");
      check (the_M.V.v = 10,                                 "and the virtual base of its virtual base is last");
      check (v_of_m (the_M'unchecked_Access) = 10,           "where C++ finds it");
   end a_nearly_empty_virtual_Base;

   finish;
end Tester;
