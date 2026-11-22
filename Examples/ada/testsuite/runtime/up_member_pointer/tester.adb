with
     member_pointer.Square,
     member_pointer.Circle,
     member_pointer.Funktions,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'member_pointer' of upstream's suite: pointers to member functions. They are not supported, so
--  whatever takes or returns one is left out with a warning, which the launcher checks, and this checks
--  that the classes of the case are bound all the same. (Upstream's own test is of those pointers.)
--
is
   use member_pointer,
       interfaces.C,
       Checks;

   the_Square : aliased Square.Item := Square.Item (Square.construct (10.0));
   the_Circle : aliased Circle.Item := Circle.Item (Circle.construct (1.0));
   the_Funcs  : aliased Funktions.Item;
   Left       : aliased int := 1;
begin
   check (the_Square.area      = 100.0,                    "the area of a square, a virtual function");
   check (the_Square.perimeter =  40.0,                    "and its perimeter");
   check (the_Circle.area > 3.14 and the_Circle.area < 3.15,     "the area of a circle");

   check (Funktions.addByValue (the_Funcs, Left'unchecked_Access, 2) = 3,     "a member function of the class whose pointers are left out");

   finish;
end Tester;
