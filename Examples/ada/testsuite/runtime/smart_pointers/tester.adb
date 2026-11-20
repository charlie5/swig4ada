with
     smart_pointers.Binding,
     smart_pointers.Engine,
     smart_pointers.EnginePtr,

     interfaces.C,

     Checks;


procedure Tester
--
--  A smart pointer: the functions of the class which it points to are reached
--  through it, it shares its object with its copies, and frees it with the last.
--
is
   use smart_pointers,
       smart_pointers.Binding,
       interfaces.C,
       Checks;

begin
   check (engines_alive = 0,                              "there are no engines at the start");

   declare
      First : aliased EnginePtr.Item := EnginePtr.construct (100);
   begin
      check (engines_alive = 1,                           "the pointer has made its engine");
      check (EnginePtr.use_count (First) = 1,             "which it alone uses");

      check (EnginePtr.get_power (First) = 100,           "a function of the engine is called through the pointer");
      EnginePtr.boost (First, 20);
      check (EnginePtr.get_power (First) = 120,           "the engine is changed through the pointer");
      check (EnginePtr.scaled (First, 2) = 240,           "a function with a parameter is called through the pointer");

      check (EnginePtr.dereference (First).power = 120, "the engine itself is reached by the pointer's operator");

      check (power_of (First) = 120,                      "the pointer is passed by value");
      check (EnginePtr.use_count (First) = 1,             "and the copy which C++ made of it is gone");

      declare
         Second : aliased EnginePtr.Item := EnginePtr.construct (First'unchecked_Access);     -- A copy.
      begin
         check (EnginePtr.use_count (First) = 2,          "a copy shares the engine");
         check (engines_alive = 1,                        "there is still one engine");

         EnginePtr.boost (Second, 5);
         check (EnginePtr.get_power (First) = 125,        "a change through the copy is seen through the original");

         EnginePtr.destruct (Second);
      end;

      check (EnginePtr.use_count (First) = 1,             "the copy is destructed");
      check (engines_alive = 1,                           "and the engine remains");

      declare
         Other : aliased EnginePtr.Item := EnginePtr.construct (1);
      begin
         make_engine (300, Other'unchecked_Access);       -- A smart pointer returned by value.

         check (EnginePtr.get_power (Other) = 300,        "a pointer returned by value replaces the object");
         check (engines_alive = 2,                        "the engine it replaced is freed");

         EnginePtr.destruct (Other);
      end;

      EnginePtr.destruct (First);
   end;

   check (engines_alive = 0,                              "the last pointer frees its engine");

   declare
      the_Engine : aliased Engine.Item := Engine.construct (7);
   begin
      check (Engine.scaled (the_Engine, 3) = 21,          "the class is also used with no smart pointer");
      Engine.destruct (the_Engine);
   end;

   finish;
end Tester;
