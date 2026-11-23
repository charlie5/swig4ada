with
     ada_Layout,
     ada_Package,
     ada_Variable,
     ada_Type.elementary.scalar.discrete.integer.signed,
     ada_Type.composite.a_record,

     ada.Strings.unbounded,

     Checks;


procedure layout_Test
--
--  Makes records by hand, and checks the place which the layout engine gives each of their
--  components against the place which GCC gives the members of the same class or structure.
--
is
   use ada_Layout,
       ada_Type,
       ada.Strings.unbounded,
       Checks;

   package Records  renames ada_Type.composite.a_record;
   package Integers renames ada_Type.elementary.scalar.discrete.integer.signed;

   function "+" (Text : in String) return unbounded_String
     renames to_unbounded_String;


   --  The packages and the standard types which the records are made of.
   --
   Standard_p   : constant ada_Package.view := ada_Package.new_ada_Package ("standard",                             is_Core => True);
   Interfaces_p : constant ada_Package.view := ada_Package.new_ada_Package ("interfaces", Parent => Standard_p,     is_Core => True);
   C_p          : constant ada_Package.view := ada_Package.new_ada_Package ("c",          Parent => Interfaces_p,   is_Core => True);
   Module_p     : constant ada_Package.view := ada_Package.new_ada_Package ("shapes",     Parent => Standard_p);
   Other_p      : constant ada_Package.view := ada_Package.new_ada_Package ("imported",   Parent => Standard_p);

   Char     : constant ada_Type.view := Integers.new_Item (C_p, +"char")    .all'Access;
   Int      : constant ada_Type.view := Integers.new_Item (C_p, +"int")     .all'Access;
   Unsigned : constant ada_Type.view := Integers.new_Item (C_p, +"unsigned").all'Access;
   Double   : constant ada_Type.view := Integers.new_Item (C_p, +"double")  .all'Access;


   function new_Record (Name : in String;   in_Package : in ada_Package.view := Module_p) return Records.view
   is
      the_Package : constant ada_Package.view := ada_Package.new_ada_Package (Name, Parent => in_Package);
   begin
      return Records.new_Item (the_Package, +"Item");
   end new_Record;


   procedure add (To : in Records.view;   Name      : in String;
                                          of_Type   : in ada_Type.view;
                                          Bits      : in Integer := ada_Variable.undefined_Bitfield;
                                          is_a_Base : in Boolean := False)
   is
      the_Component : constant ada_Variable.view := ada_Variable.new_ada_Variable (+Name, of_Type);
   begin
      the_Component.bit_Field     := Bits;
      the_Component.is_base_Class := is_a_Base;
      To.add_Component (the_Component);
   end add;


   Size, Alignment, data_Size : Natural;

begin
   a_plain_structure :     -- struct { char c; int i; double d; }
   declare
      the_Record : constant Records.view := new_Record ("Plain");
      the_Places : component_Places (1 .. 3);
   begin
      add (the_Record, "c", Char);
      add (the_Record, "i", Int);
      add (the_Record, "d", Double);

      check (laid_Out (the_Record, the_Places, Size, Alignment, data_Size),   "a plain structure is laid out");
      check (the_Places (1).First = 0  and the_Places (1).Size = 8,           "its first member is at the start");
      check (the_Places (2).First = 32 and the_Places (2).Size = 32,          "an 'int' is aligned to four bytes");
      check (the_Places (3).First = 64,                                       "a 'double' is aligned to eight");
      check (Size = 128 and Alignment = 64,                                   "the structure has the size and alignment of C");
      check (not needs_Layout (the_Record),                                   "and GNAT lays it out the same, so it needs no clause");
      check (is_plain_Structure (the_Record),                                 "it is a plain structure");
   end a_plain_structure;

   bit_fields :            -- struct { unsigned a : 3; unsigned b : 5; unsigned c : 30; int d; }
   declare
      the_Record : constant Records.view := new_Record ("Bits");
      the_Places : component_Places (1 .. 4);
   begin
      add (the_Record, "a", Unsigned, Bits => 3);
      add (the_Record, "b", Unsigned, Bits => 5);
      add (the_Record, "c", Unsigned, Bits => 30);
      add (the_Record, "d", Int);

      check (laid_Out (the_Record, the_Places, Size, Alignment, data_Size),   "a structure with bit-fields is laid out");
      check (the_Places (1).First = 0 and the_Places (1).Size = 3,            "a bit-field is at the start");
      check (the_Places (2).First = 3 and the_Places (2).Size = 5,            "the next follows it within the same unit");
      check (the_Places (3).First = 32 and the_Places (3).Size = 30,          "one which would cross its unit begins the next unit");
      check (the_Places (4).First = 64,                                       "a member which is no bit-field follows, aligned");
      check (Size = 96,                                                       "the structure has the size of C");
      check (needs_Layout (the_Record),                                       "and needs a clause, as GNAT places bit-fields otherwise");
   end bit_fields;

   a_base_whose_tail_is_used :     -- struct Base { int i; char c; Base (); };   struct Derived : Base { char d; };
   declare
      the_Base    : constant Records.view := new_Record ("Base");
      the_Derived : constant Records.view := new_Record ("Derived");
      base_Places : component_Places (1 .. 2);
      the_Places  : component_Places (1 .. 2);
   begin
      add (the_Base, "i", Int);
      add (the_Base, "c", Char);
      the_Base.is_not_layout_Pod;     -- It declares a constructor.

      check (laid_Out (the_Base, base_Places, Size, Alignment, data_Size),    "a class with a constructor is laid out");
      check (Size = 64 and data_Size = 40,                                    "its size is eight bytes, of which five hold its members");

      add (the_Derived, "Base", the_Base.all'Access, is_a_Base => True);
      add (the_Derived, "d",    Char);
      the_Derived.is_not_layout_Pod;

      check (laid_Out (the_Derived, the_Places, Size, Alignment, data_Size),  "a class which is derived from it is laid out");
      check (the_Places (1).Size = 40,                                        "its base takes only what its members hold");
      check (the_Places (2).First = 40,                                       "so the member which it adds lies in the tail of the base");
      check (Size = 64,                                                       "and the class is no larger than its base");
      check (needs_Layout (the_Derived),                                      "it needs a clause");
      check (is_reduced_Base (the_Derived, 1, the_Places),                    "its base is a reduced one");
      check (placed_Name (the_Derived, 1, the_Places) = "Base_storage",       "which is storage alone, by name");
      check (placed_Name (the_Derived, 2, the_Places) = "d",                  "a member keeps its name");
   end a_base_whose_tail_is_used;

   a_base_which_is_a_plain_structure :     -- struct Base { int i; char c; };   struct Derived : Base { char d; };
   declare
      the_Base    : constant Records.view := new_Record ("plain_Base");
      the_Derived : constant Records.view := new_Record ("plain_Derived");
      the_Places  : component_Places (1 .. 2);
   begin
      add (the_Base, "i", Int);
      add (the_Base, "c", Char);

      add (the_Derived, "plain_Base", the_Base.all'Access, is_a_Base => True);
      add (the_Derived, "d",          Char);
      the_Derived.is_not_layout_Pod;     -- It has a base class.

      check (laid_Out (the_Derived, the_Places, Size, Alignment, data_Size),  "a class which is derived from a plain structure is laid out");
      check (the_Places (1).Size = 64,                                        "its base takes the whole of its size");
      check (the_Places (2).First = 64,                                       "so the member which it adds follows the base");
      check (Size = 96,                                                       "and the class is larger than its base");
      check (not needs_Layout (the_Derived),                                  "GNAT lays it out the same");
   end a_base_which_is_a_plain_structure;

   a_class_of_another_module :
   declare
      the_Record : constant Records.view := new_Record ("Thing", in_Package => Other_p);
      the_Places : component_Places (1 .. 1);
   begin
      add (the_Record, "i", Int);

      --  The members of a class of an imported module are collected, so it is laid out as any other is.
      --
      check (laid_Out (the_Record, the_Places, Size, Alignment, data_Size),   "a class of an imported module is laid out");
      check (the_Places (1).First = 0 and Size = 32,                          "by the place and size of its members");
   end a_class_of_another_module;

   finish;
end layout_Test;
