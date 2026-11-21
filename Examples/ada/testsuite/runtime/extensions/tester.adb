with
     extensions.Binding,
     extensions.Vec,
     extensions.Stack,
     extensions.Circle,
     extensions.Token,

     swig.Exceptions,
     interfaces.C,

     Checks;


procedure Tester
--
--  Members which the interface file adds to a class with '%extend': a constructor, functions,
--  a static function and overloads, of a structure, a class and a class in a namespace.
--  Also a function with an '%exception', which returns by value a class with no assignment.
--
is
   use extensions,
       extensions.Binding,
       interfaces.C,
       Checks;

   use type swig.bool;

   function is_True (Value : in swig.bool) return Boolean
   is (Value /= swig.bool'Val (0));

begin
   a_structure :
   declare
      A : aliased Vec.Item := Vec.construct (3.0, 4.0);     -- A constructor which was added.
      B : aliased Vec.Item := Vec.construct (1.0, 2.0);
   begin
      check (A.x = 3.0 and A.y = 4.0,                     "a constructor which was added sets the members");
      check (Vec.dot (A, B'unchecked_Access) = 11.0,      "a function which was added, with a parameter of the type");

      declare
         C : constant Vec.Item := Vec.scaled (A, 2.0);
         U : constant Vec.Item := Vec.unit_x;
      begin
         check (C.x = 6.0 and C.y = 8.0,                  "a function which was added and returns the type by value");
         check (U.x = 1.0 and U.y = 0.0,                  "a static function which was added");
      end;
   end a_structure;

   a_class :
   declare
      the_Stack : aliased Stack.Item := Stack.construct;
   begin
      check (is_True (Stack.is_empty (the_Stack)),        "a function which was added, on an empty stack");

      Stack.push       (the_Stack, 5);
      Stack.push_twice (the_Stack, 7);

      check (Stack.size (the_Stack) = 3,                  "a procedure which was added has pushed twice");
      check (Stack.top  (the_Stack) = 7,                  "a function which was added reads the top");
      check (Stack.size (the_Stack) = 3,                  "and leaves the stack as it was");
      check (not is_True (Stack.is_empty (the_Stack)),    "the stack is no longer empty");
   end a_class;

   a_class_in_a_namespace :
   declare
      the_Circle : aliased Circle.Item := Circle.construct (2.0);
   begin
      check (Circle.area (the_Circle) = 12.0,             "a function which was added to a class in a namespace");
      check (Circle.area (the_Circle, 0.5) = 6.0,         "its overload");
   end a_class_in_a_namespace;

   a_function_with_an_exception_handler :
   declare
      the_Token : aliased Token.Item;
   begin
      checked_token (42, the_Token'unchecked_Access);
      check (Token.get (the_Token) = 42,                  "a class with no assignment is returned by value");
      check (not swig.Exceptions.is_Pending,              "and no exception is pending");

      checked_token (-1, the_Token'unchecked_Access);
      check (swig.Exceptions.pending_Message = "a token cannot be negative",   "the handler records the exception which C++ threw");
      check (Token.get (the_Token) = 42,                  "and the object of the caller is unchanged");

      swig.Exceptions.clear;
      Token.destruct (the_Token);
   end a_function_with_an_exception_handler;

   finish;
end Tester;
