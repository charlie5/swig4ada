with
     virtual_classes.Binding,
     virtual_classes.Shape,
     virtual_classes.Circle,
     virtual_classes.Circle.Guards,
     virtual_classes.Square,
     virtual_classes.Square.Guards,

     Triangles,

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
      check (the_Circle.radius = 2.0,          "the constructor of a derived class sets its member");
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

   finish;
end Tester;
