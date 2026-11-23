with
     imports.Binding,
     imports.Horse,
     imports.Horse.Guards,
     imports.Vec3,
     imports.More,
     imports.Panel,
     imports.Wider,

     imports_base.Binding,
     imports_base.Animal,
     imports_base.Tag,
     imports_base.Vec,

     interfaces.C,

     Checks;


procedure Tester
--
--  Two modules, the second of which imports the first: it uses the first's enumeration,
--  structure and classes, and derives a class from one of them.
--
is
   use imports,
       imports.Binding,
       imports_base,
       imports_base.Binding,
       interfaces.C,
       Checks;

begin
   the_imported_module_alone :
   declare
      A : constant Vec.Item := (x => 1.0, y => 2.0);
      B : constant Vec.Item := (x => 3.0, y => 4.0);
   begin
      check (dot (A, B) = 11.0,                           "a function of the imported module");
   end the_imported_module_alone;

   types_of_the_imported_module :
   declare
      V : constant Vec.Item := scaled ((x => 1.5, y => -2.0), 2.0);
      T : aliased  Tag.Item := Tag.construct (5);
      U : aliased  Tag.Item;
   begin
      check (V.x = 3.0 and V.y = -4.0,                    "a structure of the imported module is passed and returned");
      check (brightest (Red, Blue) = Blue,                "an enumeration of the imported module is passed and returned");
      check (id_of (T) = 5,                               "a class of the imported module is passed by value");

      make_tag (9, U'unchecked_Access);
      check (U.id = 9,                                    "a class of the imported module is returned by value");

      Tag.destruct (T);
      Tag.destruct (U);
   end types_of_the_imported_module;

   a_class_derived_from_an_imported_class :
   declare
      the_Horse : aliased Horse.Item := Horse.construct (Green);
      the_Guard : Horse.Guards.Guard (the_Horse'Access) with Unreferenced;
      an_Animal : constant Animal.Pointer := the_Horse'unchecked_Access;
   begin
      check (the_Horse.legs = 4,                          "the constructor of the imported base class has run");

      --  The members which the derived class adds are read and written through functions. C++ places the first of
      --  them in the unused tail of the base class, where GNAT begins a type extension after the whole of its parent,
      --  so the components of the Ada record are not where the members are.
      --
      check (Horse.coat (the_Horse'Access) = Green,       "a member which the derived class adds is read");
      check (Horse.tag  (the_Horse'Access).id = 17,       "a member of a class type is reached");

      Horse.set_coat (the_Horse, Blue);
      check (Horse.coat     (the_Horse'Access) = Blue,    "the member is written");
      check (Horse.get_coat (the_Horse'Access) = Blue,    "and C++ sees the value which Ada wrote");
      Horse.set_coat (the_Horse, Green);

      check (Animal.get_legs (the_Horse'Access) = 4,      "a function of the imported base class is called on the derived object");
      check (Horse.get_coat  (the_Horse'Access) = Green,  "a function of the derived class");

      check (an_Animal.speed = 60,                        "Ada dispatches through a pointer to the imported base class");
      check (speed_of (an_Animal) = 60,                   "C++ dispatches through a pointer to the imported base class");
   end a_class_derived_from_an_imported_class;

   an_object_of_the_imported_class :
   declare
      the_Animal : aliased Animal.Item := Animal.construct (6);
   begin
      check (speed_of (the_Animal'unchecked_Access) = 6,  "an object of the imported class is used by the importing module");
      Animal.destruct_0 (the_Animal);
   end an_object_of_the_imported_class;

   a_structure_derived_from_an_imported_structure :
   declare
      the_Vec : aliased Vec3.Item;
   begin
      fill3 (the_Vec'unchecked_Access);

      check (the_Vec.Vec.x = 1.0 and the_Vec.Vec.y = 2.0, "the members of the imported base structure are where C++ has them");
      check (the_Vec.z = 3.0,                             "and the member which the structure adds follows them");

      the_Vec.Vec.y := 20.0;
      the_Vec.z     := 30.0;
      check (sum3 (the_Vec'unchecked_Access) = 51.0,      "C++ reads what Ada wrote to both");
   end a_structure_derived_from_an_imported_structure;

   a_class_which_uses_the_tail_of_an_imported_Base :
   declare
      the_More : aliased More.Item := More.construct;
   begin
      --  'Odd' is an 'int' and a 'char', and no plain structure, so C++ has the 'char' which 'More' adds at 5,
      --  within the size of 'Odd'. The members of 'Odd' are known here though its module is imported.
      --
      check (More.Item'Size / 8 = size_of_more,           "a class derived from an imported class has the size which C++ gives it");
      check (the_More.d = 'z',                            "the member which it adds is where C++ has it, in the tail of its base");
      check (More.as_Odd (the_More).i = 7,                "the imported base is reached");
      check (More.as_Odd (the_More).c = 'a',              "with each of its members");

      the_More.d := 'q';
      check (d_of (the_More'unchecked_Access) = 'q',      "C++ reads what Ada writes to the member");
      check (i_of (the_More'unchecked_Access) = 7,        "which has not lain over the base");
   end a_class_which_uses_the_tail_of_an_imported_Base;

   a_member_of_an_imported_structure_with_bit_Fields :
   declare
      the_Panel : aliased Panel.Item;
   begin
      fill_panel (the_Panel'unchecked_Access);

      check (the_Panel.kind = 'p',                        "the member before one of an imported structure");
      check (the_Panel.flags.ready = 1 and the_Panel.flags.level = 9,   "the bit-fields of the imported structure");
      check (the_Panel.flags.count = 44,                  "and its member after them");
      check (the_Panel.after = 55,                        "and the member which follows it");

      the_Panel.after := 66;
      check (after_of (the_Panel'unchecked_Access) = 66,  "C++ reads what Ada writes after the imported structure");
   end a_member_of_an_imported_structure_with_bit_Fields;

   functions_which_override_those_of_an_imported_Class :
   declare
      the_Horse : aliased  Horse.Item      := Horse.construct (Green);
      an_Animal : constant Animal.Pointer  := the_Horse'unchecked_Access;
      Three     : aliased  Paces           := 3;
   begin
      --  The virtual functions of 'Animal' are known here though its module is imported, so one of 'Horse' which
      --  overrides has the types of the one which it overrides: 'stride' takes a 'const int&' where that of
      --  'Animal' takes a 'const Paces&', and 'self' returns a 'Horse*' where that of 'Animal' returns an 'Animal*'.
      --
      check (an_Animal.stride (Three'unchecked_Access) = 6,   "a function whose parameter is written otherwise than in the imported base overrides it");
      check (stride_of (an_Animal) = 6,                       "as C++ finds");
      check (an_Animal.self.legs = 4,                         "a function whose result is of the derived class overrides one of the imported base");
      check (legs_of_self (an_Animal) = 4,                    "as C++ finds");

      Horse.destruct_0 (the_Horse);
   end functions_which_override_those_of_an_imported_Class;

   a_class_derived_from_an_imported_class_with_a_pointer_and_an_Array :
   declare
      the_Wider : aliased Wider.Item := Wider.construct;
   begin
      --  'Mixed' is a 'char', a pointer and three 'short's: 24 bytes of which two are unused, where C++ has 'extra'.
      --
      check (Wider.Item'Size / 8 = size_of_wider,             "the size of the imported base is worked out from a pointer and an array");
      check (the_Wider.extra = 'w',                           "and the member which is added is in its tail");

      the_Wider.extra := 'x';
      check (extra_of (the_Wider'unchecked_Access) = 'x',     "C++ reads what Ada writes there");
      check (codes_of (the_Wider'unchecked_Access) = 6,       "which has not lain over the array of the base");
   end a_class_derived_from_an_imported_class_with_a_pointer_and_an_Array;

   finish;
end Tester;
