with
     virtual_bases.Binding,
     virtual_bases.W,
     virtual_bases.X,
     virtual_bases.Y,
     virtual_bases.Z,
     virtual_bases.U,
     virtual_bases.M,
     virtual_bases.Square,
     virtual_bases.Label,
     virtual_bases.Shape,
     virtual_bases.Cable,
     virtual_bases.Port,

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

   a_virtual_Base_of_a_tagged_Type :
   declare
      the_Square : aliased Square.Item;
   begin
      check (the_Square.side = 4,                            "a class with virtual functions and a virtual base, whose tagged type has no parent: its own member is after its tag");
      check (sides_of (the_Square'unchecked_Access) = 4,     "C++ finds the virtual base through the table of an object which Ada declared");
      check (area_of (the_Square'unchecked_Access) = 16,     "a virtual function of the class, which overrides that of the virtual base");
      check (corners_of (the_Square'unchecked_Access) = 4,   "and one of its own");
      check (Square.area (the_Square'unchecked_Access) = 16,      "which Ada calls through the table");
      check (Square.corners (the_Square'unchecked_Access) = 4,    "and the other");
      check (area_of_shape (Square.as_Shape (the_Square'unchecked_Access)) = 16,   "and C++ through the virtual base, which 'as_Shape' reaches");
      check (Shape.area (Square.as_Shape (the_Square'unchecked_Access)) = 16,      "and Ada likewise");
      Square.destruct_0 (the_Square);
   end a_virtual_Base_of_a_tagged_Type;

   a_nearly_empty_virtual_Parent :
   declare
      the_Label : aliased Label.Item;
   begin
      check (Label.label (the_Label'unchecked_Access) = 8,   "a class whose virtual base has nothing but its pointer, which is its parent: its own member");
      check (name_of (the_Label'unchecked_Access) = 7,       "a virtual function of the parent");
      check (text_of (the_Label'unchecked_Access) = 9,       "and one of its own");
      check (Label.text (the_Label'unchecked_Access) = 9,    "which Ada calls through the table");
      Label.destruct_0 (the_Label);
   end a_nearly_empty_virtual_Parent;

   a_Parent_and_a_virtual_Base :
   declare
      the_Cable : aliased Cable.Item;     -- C++ constructs it in the record, which is no smaller than the class.
   begin
      check (Cable.length (the_Cable'unchecked_Access) = 30,     "a class with a parent and a virtual base: its own member, through its function");
      check (length_of (the_Cable'unchecked_Access) = 30,        "as C++ has it");
      check (port_of (the_Cable'unchecked_Access) = 10,          "C++ finds the virtual base of an object which Ada declared");
      check (Cable.fit (the_Cable'unchecked_Access) = 22,        "Ada calls an override of a function of the parent through the table");
      check (Cable.open (the_Cable'unchecked_Access) = 11,       "and the override of one of the virtual base, which has a place of its own");
      check (Cable.signal (the_Cable'unchecked_Access) = 33,     "and a function of its own");
      check (open_of (the_Cable'unchecked_Access) = 11,          "and C++ likewise");
      check (open_port (Cable.as_Port (the_Cable'unchecked_Access)) = 11,   "and through the virtual base, which 'as_Port' reaches");
      check (Port.open (Cable.as_Port (the_Cable'unchecked_Access)) = 11,   "and Ada so");
      Cable.destruct_0 (the_Cable);
   end a_Parent_and_a_virtual_Base;

   finish;
end Tester;
