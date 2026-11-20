with
     overloads.Binding,
     overloads.Money,

     swig,
     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  Overloaded functions, constructors and member functions, default
--  arguments, operators given a name, and a static member function.
--
is
   use overloads,
       overloads.Binding,
       interfaces.C,
       Checks;

   use type swig.bool;

   function is_True (Value : in swig.bool) return Boolean
   is (Value /= swig.bool'Val (0));

   Text : Strings.chars_ptr := Strings.new_String ("text");

begin
   check (describe (int'(7))    = 1,     "the overload which takes an int");
   check (describe (double'(7.0)) = 2,   "the overload which takes a double");
   check (describe (Text)       = 3,     "the overload which takes a string");
   check (describe (1, 2)       = 4,     "the overload which takes two ints");

   check (scale (5)        = 51,         "a call which uses both default arguments");
   check (scale (5, 2)     = 11,         "a call which uses one default argument");
   check (scale (5, 2, 3)  = 13,         "a call which uses no default argument");

   declare
      A : aliased Money.Item := Money.construct;
      B : aliased Money.Item := Money.construct (3);
      C : aliased Money.Item := Money.construct (3, 50);
   begin
      check (A.cents = 0,                "the constructor with no parameter");
      check (B.cents = 300,              "the constructor with one parameter");
      check (C.cents = 350,              "the constructor with two parameters");

      Money.add (A, 2);
      check (A.cents = 200,              "the member overload with one parameter");

      Money.add (A, 1, 25);
      check (A.cents = 325,              "the member overload with two parameters");

      Money.add (A, B'unchecked_Access);
      check (A.cents = 625,              "the member overload which takes an object");

      check (Money.plus (B, C'unchecked_Access).cents = 650,           "an operator which returns its class");
      check (is_True (Money.equals (B, B'unchecked_Access)),           "the equality operator, where equal");
      check (not is_True (Money.equals (B, C'unchecked_Access)),       "the equality operator, where not");
      check (is_True (Money.less_than (B, C'unchecked_Access)),        "the ordering operator");

      check (Money.of_cents (1234).cents = 1234,                       "a static member function");
   end;

   Strings.free (Text);
   finish;
end Tester;
