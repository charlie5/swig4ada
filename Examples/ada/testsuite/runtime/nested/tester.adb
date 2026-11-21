with
     nested.Binding,
     nested.Engine,
     nested.Gauge,
     nested.Reading,

     interfaces.C,

     Checks;


procedure Tester
--
--  Declarations which are nested in a class: an enumeration,
--  typedefs, a structure and a class.
--
is
   use nested,
       nested.Binding,
       interfaces.C,
       Checks;

   use type Engine.State;

   the_Engine : aliased Engine.Item := Engine.construct;
begin
   check (the_Engine.state = Engine.Off,                   "a member whose type is a nested enumeration");
   check (the_Engine.gauge.value = 50,                     "a member whose type is a nested class");

   Engine.start (the_Engine);
   check (Engine.the_mode (the_Engine) = Engine.Idle,         "a function which returns a typedef of the nested enumeration");
   check (as_number (Engine.Idle) = 3,                     "a literal of the nested enumeration with a value of its own");

   Engine.run (the_Engine, 120);
   check (the_Engine.speed = 120,                          "a parameter whose type is a nested typedef");

   declare
      the_Reading : constant Reading.Item := Engine.read (the_Engine);
   begin
      check (the_Reading.speed = 120,                      "a nested structure is returned by value");
      check (the_Reading.state = Engine.Running,           "with its member of the nested enumeration type");
      check (as_number (the_Reading.state) = 4,            "whose literal follows one with a value of its own");
      check (reading_total (the_Reading) = 124,            "and the nested structure is passed by value");
   end;

   declare
      the_Gauge : constant Gauge.Pointer := Engine.get_gauge (the_Engine);
   begin
      check (Gauge.doubled (the_Gauge.all) = 100,          "a function of a nested class, reached by a pointer");
      check (gauge_value (the_Gauge) = 50,                 "a pointer to a nested class is passed to C++");
   end;

   finish;
end Tester;
