with
     directives.Binding,
     directives.Sensor,
     directives.Reading,

     swig,
     interfaces.C,

     Checks;


procedure Tester
--
--  Directives which change a binding: '%rename', '%ignore', '%immutable',
--  '%apply', '%inline' and '%constant', and names which Ada cannot use as they are.
--
is
   use directives,
       directives.Binding,
       interfaces.C,
       Checks;

   use type swig.bool;

begin
   renamed :
   declare
      the_Sensor : aliased Sensor.Item := Sensor.construct (4);
      Larger     : aliased Sensor.Item := Sensor.construct (9);
   begin
      check (new_name (1) = 2,                                      "a function which is renamed");
      check (Sensor.sample (the_Sensor) = 40,                       "a member function which is renamed");
      check (Sensor.less_than (the_Sensor, Larger'unchecked_Access) = swig.bool'Val (1),   "an operator which is given a name");
      check (Sensor.element (the_Sensor, 3) = 7,                    "the index operator");
      check (Sensor.negated (the_Sensor).id = -4,                   "an operator which returns the class by value");
   end renamed;

   ignored :
   declare
      the_Sensor  : aliased Sensor.Item  := Sensor.construct (7);
      the_Reading : aliased Reading.Item := (raw => 1, hidden_detail_storage => 0, value => 2.5);
   begin
      --  An ignored member is absent from the binding, but its storage remains,
      --  so that the members which follow it are where C++ has them.
      --
      check (Sensor.sample (the_Sensor) = 70,                       "C++ sets a member which follows an ignored one");
      check (Sensor.get_Last (the_Sensor) = 70,                     "and reads it back");
      check (the_Sensor.last = 70,                                  "and Ada reads it where C++ has it");
      check (the_Reading.value = 2.5,                               "a structure with an ignored member");
      check (SHOWN_LIMIT = 6,                                       "a constant beside one which is ignored");
   end ignored;

   names :
   declare
      the_Sensor : aliased Sensor.Item := Sensor.construct (1);
   begin
      check (a_end (2) = 4,                                         "a function whose name is a reserved word of Ada");
      check (a_leading (2) = 6,                                     "a name which begins with an underscore");
      check (trailing_a (2) = 8,                                    "a name which ends with one");
      check (double_a_under (2) = 10,                               "a name with two together");
      check (Sensor.the_begin (the_Sensor) = 1,                     "a member function whose name is a reserved word");
      check (Sensor.the_type (the_Sensor) = 2,                      "and another");
   end names;

   others_directives :
   declare
      Sum, Product : aliased int;
      Data         : aliased swig.unsigned_char_Array := [10, 20, 200];
   begin
      check (added_here (1) = 101,                                  "a function which the interface file adds");
      check (ANSWER = 42,                                           "a constant which the interface file adds");

      output_pair (6, Sum'unchecked_Access, Product'unchecked_Access);
      check (Sum = 12 and Product = 36,                             "results through pointers, and a parameter named 'in'");

      check (sum_bytes (Data (0)'unchecked_Access, 3) = 230,        "a parameter whose typemap is applied from another type");
      check (checked (5) = 5,                                       "a plain function among them");
   end others_directives;

   finish;
end Tester;
