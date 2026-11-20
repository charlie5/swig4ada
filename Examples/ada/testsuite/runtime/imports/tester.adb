with
     imports.Binding,
     imports.Horse,
     imports.Horse.Guards,

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

      --  The members which the derived class adds ('coat' and 'tag') are not read here. C++ places the first of them
      --  in the unused tail of the base class, where GNAT begins a type extension after the whole of its parent, so
      --  Ada has them at the wrong offset. They are read through C++ instead.

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

   finish;
end Tester;
