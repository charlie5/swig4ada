with
     namespaces.Binding,
     namespaces.Size,
     namespaces.Counter,
     namespaces.Figure,
     namespaces.Box,
     namespaces.Box.Guards,

     interfaces.C,

     Checks;


procedure Tester
--
--  Declarations in namespaces, one of them nested: a constant, an enumeration, a structure,
--  functions, and classes with and without virtual functions.
--
is
   use namespaces,
       namespaces.Binding,
       interfaces.C,
       Checks;

begin
   check (Dimensions = 2,                        "a constant of a namespace has its value");
   check (Axis'Pos (Vertical) = 1,               "an enumeration of a namespace");

   declare
      the_Size : constant Size.Item := (width => 3, height => 4);
   begin
      check (area (the_Size) = 12,               "a function of a namespace takes a structure of it");
   end;

   check (twice (21) = 42,                       "a function of a nested namespace");

   a_class_which_is_not_virtual :
   declare
      the_Counter : aliased Counter.Item;
   begin
      Counter.add (the_Counter, 5);
      Counter.add (the_Counter, 6);
      check (Counter.get (the_Counter) = 11,     "a class of a namespace is constructed and used");

      Counter.destruct (the_Counter);            -- Its destructor is reached through the wrapper.
   end a_class_which_is_not_virtual;

   check (figures_alive = 0,                     "there are no figures at the start");

   a_virtual_class :
   declare
      the_Box   : aliased Box.Item := Box.construct (3);
      the_Guard : Box.Guards.Guard (the_Box'Access) with Unreferenced;
   begin
      check (figures_alive = 1,                           "a class of a nested namespace is constructed");
      check (Box.volume (the_Box'Access) = 27,            "its member function is called");
      check (Box.corners (the_Box'Access) = 8,            "its virtual function is called");
      check (corners_of (the_Box'unchecked_Access) = 8,   "C++ dispatches to it through a pointer to its base class");
   end a_virtual_class;

   check (figures_alive = 0,                     "the guard has called the virtual destructor, by its C++ symbol");

   finish;
end Tester;
