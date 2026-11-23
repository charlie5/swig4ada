with
     virtual_classes.Binding,
     virtual_classes.Shape,
     virtual_classes.Circle,
     virtual_classes.Circle.Guards,
     virtual_classes.Square,
     virtual_classes.Square.Guards,
     virtual_classes.Grid,
     virtual_classes.Scaler,
     virtual_classes.Tripler,
     virtual_classes.Guarded,
     virtual_classes.Opened,
     virtual_classes.Shown,
     virtual_classes.Worded,
     virtual_classes.Vault,
     virtual_classes.Keeper,
     virtual_classes.Filter,

     swig.Pointers,

     Triangles,
     Hexagons,
     Sieves,

     interfaces.C,

     Checks;


procedure Tester
--
--  Classes with virtual functions: an Ada object is dispatched to by C++, a C++ object is
--  dispatched to by Ada, a class derived in Ada overrides a C++ function, and every object
--  which is made is destructed.
--
is
   use virtual_classes,
       virtual_classes.Binding,
       interfaces.C,
       Checks;

begin
   check (shape_count = 0,   "there are no shapes at the start");

   objects_made_by_Ada :
   declare
      the_Circle : aliased Circle.Item := Circle.construct (2.0);
      the_Square : aliased Square.Item := Square.construct (5.0);

      circle_Guard : Circle.Guards.Guard (the_Circle'Access) with Unreferenced;
      square_Guard : Square.Guards.Guard (the_Square'Access) with Unreferenced;

      the_Shapes : constant array (1 .. 2) of access Shape.Item'Class := [the_Circle'unchecked_Access,
                                                                          the_Square'unchecked_Access];
   begin
      check (shape_count = 2,                  "C++ has constructed two shapes");
      check (Circle.radius (the_Circle'Access) = 2.0,   "the constructor of a derived class sets its member");
      check (the_Circle.x = 0.0,               "the constructor of the base class sets its member");

      Shape.move (the_Square, 3.0, 4.0);
      check (the_Square.x = 3.0 and the_Square.y = 4.0,   "a function of the base class changes a derived object");

      check (the_Shapes (1).area  = 12.0,      "Ada dispatches to the area of a circle");
      check (the_Shapes (2).area  = 25.0,      "Ada dispatches to the area of a square");
      check (the_Shapes (1).sides = 0,         "Ada dispatches to a function which the circle inherits");
      check (the_Shapes (2).sides = 4,         "Ada dispatches to a function which the square overrides");

      check (area_of  (the_Circle'unchecked_Access) = 12.0,   "C++ dispatches to the area of an object made by Ada");
      check (sides_of (the_Square'unchecked_Access) = 4,      "C++ dispatches to an overriding function of an object made by Ada");
   end objects_made_by_Ada;

   check (shape_count = 0,   "the guards have destructed both shapes");

   an_object_made_by_Cpp :
   declare
      the_Shape : constant Shape.Pointer := new_square (3.0);
   begin
      check (shape_count = 1,                  "C++ has made a shape");
      check (the_Shape.area  = 9.0,            "Ada dispatches to an object made by C++");
      check (the_Shape.sides = 4,              "Ada dispatches to its overriding function");

      dispose (the_Shape);
      check (shape_count = 0,                  "C++ has deleted the shape");
   end an_object_made_by_Cpp;

   a_class_derived_in_Ada :
   declare
      the_Triangle : aliased Triangles.Item := (Square.construct (1.0) with Base   => 4.0,     -- The parent part is made by its C++ constructor.
                                                                           Height => 3.0);
   begin

      check (shape_count = 1,                                   "the C++ constructor of the parent has run");
      check (area_of  (the_Triangle'unchecked_Access) = 6.0,    "C++ dispatches to a function overridden in Ada");
      check (sides_of (the_Triangle'unchecked_Access) = 3,      "C++ dispatches to a second function overridden in Ada");

      Square.destruct_0 (Square.Item (the_Triangle));
      check (shape_count = 0,                                   "the shape is destructed");
   end a_class_derived_in_Ada;

   members_of_a_derived_class :
   declare
      use swig.Pointers,
          swig.Pointers.c_int_Pointers;     -- For its pointer arithmetic.

      the_Grid : aliased Grid.Item := Grid.construct;
      Values   : aliased swig.int_Array := [1, 2, 3];
   begin
      --  The members which a derived class adds are read and written through functions, as C++ lays the
      --  first of them in the unused tail of the base class, where Ada cannot place a component.
      --
      check (Grid.kind  (the_Grid'Access) = 'g',             "a member which fits in the tail of the base class");
      check (Grid.scale (the_Grid'Access) = 1.5,             "a member which follows it");
      check (Grid.visible (the_Grid'Access) = 1,             "a bit field of one bit");
      check (Grid.depth   (the_Grid'Access) = 9,             "a bit field of four bits");
      check (Grid.hidden  (the_Grid'Access) = 77,            "a protected member");

      Grid.set_kind  (the_Grid, 'k');
      Grid.set_depth (the_Grid, 5);
      check (Grid.get_kind  (the_Grid'Access) = 'k',         "C++ sees a member which Ada wrote");
      check (Grid.get_depth (the_Grid'Access) = 5,           "C++ sees a bit field which Ada wrote");
      check (Grid.visible   (the_Grid'Access) = 1,           "the bit field beside it is unchanged");

      check (Grid.cells (the_Grid'Access).all = 10,          "the first element of an array member");
      check (int_Pointer'(Grid.cells (the_Grid'Access) + 2).all = 30,   "its last element");

      Grid.set_cells (the_Grid, Values (Values'First)'unchecked_Access);
      check (Grid.cell_sum (the_Grid'Access) = 6,            "C++ sees an array member which Ada wrote");

      Shape.destruct_0 (Shape.Item (the_Grid));
   end members_of_a_derived_class;

   a_class_derived_from_an_abstract_class :
   declare
      the_Hexagon : aliased Hexagons.Item;     -- Its abstract parent is constructed by C++.
   begin
      the_Hexagon.Side := 2.0;

      check (shape_count = 1,                                 "the constructor of the abstract parent has run");
      check (the_Hexagon.x = 0.0 and the_Hexagon.y = 0.0,     "and has set the members of the parent");

      Shape.move (the_Hexagon, 1.0, 2.0);
      check (the_Hexagon.x = 1.0 and the_Hexagon.y = 2.0,     "a function of the abstract parent is called");

      check (area_of  (the_Hexagon'unchecked_Access) = 10.0,  "C++ dispatches to the function which was pure virtual");
      check (sides_of (the_Hexagon'unchecked_Access) = 6,     "C++ dispatches to a second function overridden in Ada");

      Shape.destruct_0 (Shape.Item (the_Hexagon));
      check (shape_count = 0,                                 "the shape is destructed");
   end a_class_derived_from_an_abstract_class;

   virtual_functions_with_a_default_Argument :
   declare
      the_Tripler : aliased Tripler.Item   := Tripler.Item (Tripler.construct);
      as_Scaler   : constant Scaler.Pointer := the_Tripler'unchecked_Access;
   begin
      --  Each such function is one virtual function, and those which follow it are in their own places.
      --
      check (as_Scaler.scaled (5, 2) = 11,                "a virtual function with a default argument dispatches, with all its arguments");
      check (Scaler.scaled (as_Scaler, 5) = 11,           "and with the default one left out");
      check (as_Scaler.after = 70,                        "the virtual function which follows it dispatches to its own function");
      check (as_Scaler.offset (4) = 104,                  "a pure virtual function with a default argument");
      check (Scaler.offset (as_Scaler) = 101,             "and with the argument left out");
      check (as_Scaler.last = 90,                         "the last virtual function of the class is in its place");

      check (call_scaled (as_Scaler) = 11,                "C++ calls the first");
      check (call_after  (as_Scaler) = 70,                "the one which follows it");
      check (call_offset (as_Scaler) = 101,               "the pure one");
      check (call_last   (as_Scaler) = 90,                "and the last");
   end virtual_functions_with_a_default_Argument;

   virtual_functions_which_are_not_bound :
   declare
      as_Guarded : constant Guarded.Pointer := new_opened;
      an_Opened  : aliased  Opened.Item     := Opened.Item (Opened.construct);
   begin
      --  'Guarded::hidden' is ignored and the destructor of 'Guarded' is protected. Each keeps its place,
      --  so the functions about them dispatch to their own.
      --
      check (as_Guarded.first = 10,                       "the virtual function before one which is ignored dispatches");
      check (as_Guarded.third = 30,                       "and so does the one after it");
      check (call_first (as_Guarded) = 10,                "as C++ finds");
      check (call_third (as_Guarded) = 30,                "of each");

      check (an_Opened.first = 10 and an_Opened.third = 30,   "an object which Ada makes has them in their places too");
      check (an_Opened.fourth = 40,                       "a function which the derived class adds follows the destructor's places");
      check (call_fourth (an_Opened'unchecked_Access) = 40,   "as C++ finds");

      drop_opened (as_Guarded);
      Opened.destruct_0 (an_Opened);
   end virtual_functions_which_are_not_bound;

   a_class_whose_base_class_is_ignored :
   declare
      the_Shown : aliased Shown.Item := Shown.Item (Shown.construct);
   begin
      --  'Hidden' is ignored, and is bound for its shape alone: 'Shown' has its storage and its virtual functions.
      --
      check (the_Shown.mine = 7,                          "its own member is where C++ has it, after those of its base");

      the_Shown.set_mine (8);
      check (mine_of (the_Shown'unchecked_Access) = 8,    "and C++ reads what Ada sets there");
      check (secret_of (the_Shown'unchecked_Access) = 41, "and C++ finds the member of the base in an object which Ada made");

      check (the_Shown.first  = 1,                        "a virtual function of the ignored base is called");
      check (the_Shown.second = 20,                       "one which the class overrides dispatches to its own");
      check (the_Shown.third  = 30,                       "and one which it adds follows those of its base");
      check (call_second (the_Shown'unchecked_Access) = 20,   "as C++ finds");
      check (call_third  (the_Shown'unchecked_Access) = 30,   "of each");

      Shown.destruct_0 (the_Shown);
   end a_class_whose_base_class_is_ignored;

   a_virtual_function_which_is_overloaded_in_a_derived_Class :
   declare
      the_Longer : constant Worded.Pointer := new_longer;
      a_Worded   : aliased  Worded.Item    := Worded.Item (Worded.construct);
   begin
      --  'Worded' adds 'label (double)' to the 'label (int)' of its base, which it names by 'using'. The new
      --  function is no override: it has a place of its own, and 'tail' the place after it.
      --
      check (the_Longer.label (int'(1))    =   21,        "the virtual function of the base dispatches");
      check (the_Longer.label (double'(1.5)) = 2000,      "its overload in the derived class dispatches to its own place");
      check (the_Longer.tail               =   50,        "and the function which follows the overload to its own");

      check (a_Worded.label (int'(1))      =   11,        "an object which Ada makes has the function of its base");
      check (a_Worded.label (double'(1.5)) = 1000,        "the overload");
      check (a_Worded.tail                 =    5,        "and the function after it");
      check (call_label (a_Worded'unchecked_Access) = 1000,   "as C++ finds");
      check (call_tail  (a_Worded'unchecked_Access) =    5,   "of each");

      drop_worded (the_Longer);
      Worded.destruct_0 (a_Worded);
   end a_virtual_function_which_is_overloaded_in_a_derived_Class;

   private_virtual_Functions :
   declare
      the_Keeper : aliased  Keeper.Item   := Keeper.Item (Keeper.construct);
      as_Vault   : constant Vault.Pointer := the_Keeper'unchecked_Access;
      a_Vault    : aliased  Vault.Item    := Vault.Item (Vault.construct);
      Five       : aliased  Count         := 5;
   begin
      --  'Vault::hidden' is private and virtual: it is not bound, and has its place between 'shown' and 'last'.
      --  'Keeper' overrides it and 'shown' privately, which adds nothing to its type: the functions of 'Vault'
      --  have the places, and a call of one dispatches.
      --
      check (a_Vault.shown = 10 and a_Vault.last = 30,    "the virtual functions about a private one are in their places");
      check (a_Vault.through_hidden = 20,                 "and the private one is reached by C++");

      check (as_Vault.shown = 1000,                       "a function which a derived class overrides privately is dispatched to");
      check (as_Vault.through_hidden = 2000,              "as is a private one which it overrides privately");
      check (as_Vault.last = 300,                         "the function after the private one dispatches to its own override");
      check (the_Keeper.more = 400,                       "and one which the derived class adds follows them all");
      check (call_last (as_Vault) = 300,                  "as C++ finds");
      check (call_more (the_Keeper'unchecked_Access) = 400,   "of each");

      --  'Vault::open' takes a 'const Count&' and 'Keeper::open' a 'const int&', which is the same type.
      --
      check (a_Vault.open (Five'unchecked_Access) = 6,    "a function with a parameter which is named by a typedef");
      check (as_Vault.open (Five'unchecked_Access) = 105, "is overridden by one which names the type itself");
      check (call_open (as_Vault) = 105,                  "as C++ finds");

      Keeper.destruct_0 (the_Keeper);
      Vault.destruct_0 (a_Vault);
   end private_virtual_Functions;

   an_abstract_class_with_an_inherited_pure_virtual_Function :
   declare
      the_Sieve : aliased Sieves.Item;     -- Its abstract parent is constructed by C++.
   begin
      --  'Filter' has 'refine' of its own and 'produce' of 'Source'. Its constructor is that of a concrete class
      --  of the wrapper, which must define both.
      --
      check (call_produce (the_Sieve'unchecked_Access) = 77,   "C++ dispatches to the pure virtual function of the base's base, overridden in Ada");
      check (call_refine  (the_Sieve'unchecked_Access) = 88,   "and to that of the base");

      Filter.destruct_0 (Filter.Item (the_Sieve));
   end an_abstract_class_with_an_inherited_pure_virtual_Function;

   finish;
end Tester;
