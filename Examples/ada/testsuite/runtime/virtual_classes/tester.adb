with
     virtual_classes.Binding,
     virtual_classes.Shape,
     virtual_classes.Circle,
     virtual_classes.Circle.Guards,
     virtual_classes.Square,
     virtual_classes.Square.Guards,
     virtual_classes.Grid,

     swig.Pointers,

     Triangles,
     Hexagons,

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

   finish;
end Tester;
