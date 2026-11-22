with
     static_members.Counter,
     static_members.Point,
     static_members.Widget,
     static_members.Dial,
     static_members.Shelf,
     static_members.int_Pool,

     interfaces.C.Strings,
     swig,

     Checks;


procedure Tester
--
--  Static member variables: of each kind of type, constants,
--  and in classes of several kinds.
--
is
   use static_members,
       interfaces.C,
       Checks;

   use type Counter.Mode,
            Counter.Pointer,
            Point.Pointer;

begin
   kinds_of_type :
   declare
      the_Counter : aliased Counter.Item := Counter.construct;
   begin
      check (Counter.total = 1,                                     "C++ changes a static member, which Ada reads");
      Counter.total := 10;
      check (Counter.read_total = 10,                               "and C++ sees what Ada writes to it");

      check (Counter.rate = 1.5,                                    "a real number");

      check (Counter.history (1) = 8,                               "an array");
      Counter.history (2) := 90;
      check (Counter.read_history (2) = 90,                         "which Ada changes");

      check (String'(Strings.Value (Counter.label)) = "counter",    "a string");
      check (Counter.origin.x = 3 and Counter.origin.y = 4,         "a structure");
      check (Counter.target /= null and then Counter.target.y = 4,  "a pointer to a structure");

      check (Counter.the_mode = Counter.Down,                       "an enumeration of the class");
      Counter.the_mode := Counter.Up;
      check (Counter.mode_number = 0,                               "which Ada changes");

      check (Counter.first = null,                                  "a pointer to the class itself, which is null at first");
      Counter.adopt (the_Counter'unchecked_Access);
      check (Counter.first = the_Counter'unchecked_Access,          "and which C++ sets");
      check (Counter.first.id = 1,                                  "and Ada reads through");
   end kinds_of_type;

   constants :
   begin
      check (Counter.limit = 16,                                    "a constant with a value, which has no symbol");
      check (Counter.big_limit = 1_048_576,                         "one whose value is an expression");
      check (Counter.start = Counter.Down,                    "a constant of an enumeration has its value");
      check (Counter.enabled /= swig.bool'Val (0),            "and one which is a truth value");
      check (Counter.mark = 'M',                              "and one which is a character");
      check (Counter.unset = 99,                                    "a constant whose value is given elsewhere");
   end constants;

   kinds_of_class :
   declare
      the_Dial : aliased Dial.Item;
   begin
      check (Widget.made = 1 and Dial.dials = 1,                    "in a class with virtual functions, and one derived from it");

      Shelf.capacity := Shelf.capacity + 2;
      check (Shelf.read_capacity = 42,                              "in a class of a namespace");

      int_Pool.size := 12;
      check (int_Pool.read_size = 12,                               "in a template instance");

      Dial.destruct_0 (the_Dial);
   end kinds_of_class;

   finish;
end Tester;
