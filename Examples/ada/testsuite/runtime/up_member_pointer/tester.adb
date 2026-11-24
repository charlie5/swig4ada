with
     member_pointer.Binding,
     member_pointer.Square,
     member_pointer.Circle,
     member_pointer.Funktions,

     swig,
     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'member_pointer' of upstream's suite: pointers to member functions, which are taken from functions,
--  variables and constants of C++, and given back to C++, which calls through them.
--
is
   use member_pointer,
       member_pointer.Binding,
       interfaces.C,
       Checks;

   use type swig.member_function_Pointer;

   the_Square : aliased Square.Item := Square.Item (Square.construct (10.0));
   the_Circle : aliased Circle.Item := Circle.Item (Circle.construct (1.0));
   the_Funcs  : aliased Funktions.Item;
   Left       : aliased int := 1;

   area_pt    : constant swig.member_function_Pointer := Binding.areapt;     -- Ada takes it for the constant 'AREAPT' too.
   perim_pt   : constant swig.member_function_Pointer := perimeterpt;
begin
   check (the_Square.area      = 100.0,                    "the area of a square, a virtual function");
   check (the_Square.perimeter =  40.0,                    "and its perimeter");
   check (the_Circle.area > 3.14 and the_Circle.area < 3.15,     "the area of a circle");

   check (Funktions.addByValue (the_Funcs, Left'unchecked_Access, 2) = 3,     "a member function of the class whose pointers are taken");

   --  Upstream's test.
   --
   check (do_op (the_Square'unchecked_Access, area_pt)  = 100.0,               "a pointer to a member function which a function returns is given back to C++");
   check (do_op (the_Square'unchecked_Access, perim_pt) =  40.0,               "and another, to a virtual function, through which C++ dispatches");
   check (area_pt /= perim_pt,                                                 "the two are not alike");

   check (do_op (the_Square'unchecked_Access, areavar)      = 100.0,           "a variable which is a pointer to a member function");
   check (do_op (the_Square'unchecked_Access, perimetervar) =  40.0,           "and another");

   areavar := perim_pt;
   check (do_op (the_Square'unchecked_Access, areavar) = 40.0,                 "which Ada sets");
   areavar := area_pt;

   check (do_op (the_Square'unchecked_Access, member_pointer.AREAPT) = 100.0,  "a constant which is a pointer to a member function");
   check (do_op (the_Square'unchecked_Access, PERIMPT) =  40.0,                "and another");
   check (NULLPT /= member_pointer.AREAPT,                                     "and one whose value is none");

   check (do_op_td (the_Square'unchecked_Access, perim_pt)          = 40.0,    "a typedef of such a pointer, as a parameter");
   check (do_op_td (the_Square'unchecked_Access, perimeterpt_td)    = 40.0,    "and as a result");
   check (do_op_td (the_Square'unchecked_Access, perimetervar_td)   = 40.0,    "and as a variable");

   check (call1 (ADD_BY_VALUE,      1, 2) =  3,                                "a pointer to a member function with parameters, which returns a value");
   check (call2 (ADD_BY_POINTER,    3, 4) =  7,                                "one which returns a pointer");
   check (call3 (ADD_BY_REFERENCE,  5, 6) = 11,                                "one which returns a reference");

   finish;
end Tester;
