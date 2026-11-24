with
     nested.Binding,
     nested.Engine,
     nested.Gauge,
     nested.Reading,
     nested.Pump,
     nested.Pump_Gauge,
     nested.Lexeme,
     nested.Holder,

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

   --  The class holds the structure which it returns, and the structure holds an enumeration of the class.
   --  (The two packages would need each other, so the enumeration is declared in the top package.)
   --
   check (the_Engine.last.speed = 120,                     "a member which is the nested structure");
   check (the_Engine.last.state = Engine.Running,          "whose member is an enumeration of the class");

   the_Engine.last.state := Engine.Idle;
   check (as_number (the_Engine.last.state) = 3,           "which C++ reads after Ada has set it");

   --  Members whose types are nested and have no name. (The interface file asks for nested classes to be flattened.)
   --
   check (the_Engine.sensor.raw = 77,                      "a member which is a union with no name");
   check (the_Engine.range_of.low = -5 and the_Engine.range_of.high = 5,   "and one which is a structure with no name");

   the_Engine.range_of.high := 10;
   check (Engine.span (the_Engine) = 10 + 5 + 77,          "which C++ reads after Ada has set it");

   declare
      the_Gauge : constant Gauge.Pointer := Engine.get_gauge (the_Engine);
   begin
      check (Gauge.doubled (the_Gauge.all) = 100,          "a function of a nested class, reached by a pointer");
      check (gauge_value (the_Gauge) = 50,                 "a pointer to a nested class is passed to C++");
   end;

   a_nested_class_of_a_name_which_is_taken :
   declare
      the_Pump  : aliased Pump.Item := Pump.construct;
      its_Gauge : aliased Pump_Gauge.Item := Pump.read_gauge (the_Pump);
   begin
      --  'Pump::Gauge' cannot be the package 'Gauge', which is that of 'Engine::Gauge', so it is named after its class too.
      --
      check (its_Gauge.pressure = 2.5,                             "a nested class whose name is taken by another is bound under its own");
      check (the_Pump.gauge.pressure = 2.5,                        "and is the type of a member of the class which holds it");
      check (pressure_of (its_Gauge'unchecked_Access) = 2.5,       "and of a parameter");
   end a_nested_class_of_a_name_which_is_taken;

   private_nested_Types :
   declare
      the_Lexeme : aliased Lexeme.Item := Lexeme.construct;
      the_Holder : aliased Holder.Item := Holder.construct;
   begin
      --  A member whose type is a private enumeration of its class, and an anonymous union one of whose members names a
      --  private structure of the class by its plain name: neither was bound, and each record lost the member.
      --
      check (Lexeme.Item'Size / 8 = size_of_lexeme,                "a class with a member of a private enumeration has the size of its class");
      check (Lexeme.size (the_Lexeme) = 3,                         "and C++ finds the member after it");
      Lexeme.make_number (the_Lexeme);
      check (Lexeme.kind_of (the_Lexeme) = 1,                      "and the member itself");

      check (Holder.Item'Size / 8 = size_of_holder,                "a class with an anonymous union of a private structure has the size of its class");
      check (Holder.policy (the_Holder) = 4,                       "and C++ finds the structure");
      check (Holder.count_of (the_Holder) = 9,                     "and the member after the union");
   end private_nested_Types;

   finish;
end Tester;
