with
     values.Binding,
     values.Point,

     Callbacks,

     interfaces.C,

     Checks;


procedure Tester
--
--  References, pointers, enumerations, plain structures and callbacks.
--
is
   use values,
       values.Binding,
       interfaces.C,
       Checks;

begin
   references_and_pointers :
   declare
      I    : aliased int    := 41;
      J    : aliased int    := 5;
      A, B : aliased double := 1.5;
   begin
      increment (I'unchecked_Access);
      check (I = 42,                             "a value is changed through a reference");
      check (twice (I'unchecked_Access) = 84,    "a value is read through a constant reference");

      B := 9.25;
      check (largest (A'unchecked_Access, B'unchecked_Access).all = 9.25,   "a reference is returned");

      swap_ints (I'unchecked_Access, J'unchecked_Access);
      check (I = 5 and J = 42,                   "two values are swapped through pointers");
   end references_and_pointers;

   enumerations :
   begin
      check (next (Red)   = Green,               "an enumeration is passed and returned");
      check (next (Green) = Blue,                "a literal with a value of its own");
      check (value_of (Green) = 5,               "C++ sees the value which the literal was given");
      check (value_of (Blue)  = 6,               "and the value of the literal after it");
   end enumerations;

   structures :
   declare
      P : aliased Point.Item := make_point (3, 4);
   begin
      check (P.x = 3 and P.y = 4,                "a structure is returned by value");
      check (manhattan (P) = 7,                  "a structure is passed by value");

      shift (P'unchecked_Access, 10, 20);
      check (P.x = 13 and P.y = 24,              "a structure is changed through a pointer");
   end structures;

   functions_called_by_Cpp :
   begin
      check (apply     (add'Access,      3, 4) = 7,    "C++ calls a C++ function through a pointer given by Ada");
      check (apply     (Callbacks.multiply'Access, 3, 4) = 12,   "C++ calls an Ada function");
      check (apply_raw (Callbacks.multiply'Access, 5, 6) = 30,   "C++ calls an Ada function through a pointer type with no typedef");
   end functions_called_by_Cpp;

   finish;
end Tester;
