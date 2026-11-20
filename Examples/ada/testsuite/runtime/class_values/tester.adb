with
     class_values.Binding,
     class_values.Buffer,

     swig.std_Strings,
     interfaces.C,

     Checks;


procedure Tester
--
--  A class which declares a destructor, a copy constructor and an assignment, and has a string as a member.
--
is
   use class_values,
       class_values.Binding,
       swig.std_Strings,
       interfaces.C,
       Checks;

   A : aliased Buffer.Item := Buffer.construct (4);
   B : aliased Buffer.Item;                             -- Constructed by C++, with its default constructor.
   C : aliased Buffer.Item;
begin
   check (A.count = 4,                 "a constructor with a parameter sets the count");
   check (Buffer.sum (A) = 6,          "a member function reads the items");
   check (to_Ada (A.label) = "sized",  "a string member reads back");

   check (B.count = 1,                 "an object with no initial value is default constructed");
   check (to_Ada (B.label) = "default","the default constructor sets the string member");

   make_buffer (10, B'unchecked_Access);                -- A function which returns the class by value.
   check (B.count = 10,                "a function result replaces the object");
   check (Buffer.sum (B) = 45,         "the items of the result are those which C++ made");
   check (to_Ada (B.label) (1 .. 4) = "made", "the string member of the result is that which C++ made");

   Buffer.doubled (A, C'unchecked_Access);              -- A member which returns its class by value.
   check (C.count = 8,                 "a member function result replaces the object");
   check (Buffer.sum (C) = 28,         "the items of the member function result");

   check (total (B) = 45,              "a class passed by value");
   check (Buffer.sum (B) = 45,         "the object passed by value is unchanged");

   Buffer.destruct (A);
   Buffer.destruct (B);
   Buffer.destruct (C);

   finish;
end Tester;
