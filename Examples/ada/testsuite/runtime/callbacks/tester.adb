with
     callbacks.Binding,
     callbacks.Sample,
     callbacks.Listener,
     callbacks.Handlers,
     callbacks.Button,
     callbacks.Measure,
     callbacks.Pair,
     callbacks.Reader,

     ada_Functions,

     interfaces.C,

     Checks;


procedure Tester
--
--  Functions of Ada which C++ calls: given as parameters, kept in a
--  structure and kept by a class. And a C++ function which Ada is given.
--
is
   use callbacks,
       callbacks.Binding,
       interfaces.C,
       Checks;

   use type Measure.Item;

begin
   parameters :
   declare
      the_Samples  : aliased Sample.Item_Array := [(id => 1, value => 1.0),
                                                   (id => 2, value => 2.5)];
      the_Total    : aliased int := 0;
      the_Listener : aliased Listener.Item;
   begin
      check (measure_all (ada_Functions.weigh'Access, the_Samples (0)'unchecked_Access, 2) = 35.0,
             "a function which takes a pointer to a structure");

      visit_range (ada_Functions.collect'Access, 1, 4, the_Total'Address);
      check (the_Total = 10,                                        "a procedure which is given a context");

      check (name_it (ada_Functions.length_of'Access) = 8,          "a function which takes a string");
      check (made_value (ada_Functions.make'Access, 3) = 3.5,       "a function which returns a structure by value");

      notify (ada_Functions.tell'Access, the_Listener'unchecked_Access, 6);
      check (the_Listener.heard = 6,                                "a procedure which takes a pointer to a class");

      update (ada_Functions.reset'Access, the_Samples (1)'unchecked_Access);
      check (the_Samples (1).id = 0,                                "a procedure which takes a reference");

      Listener.destruct_0 (the_Listener);
   end parameters;

   members :
   declare
      the_Handlers : aliased Handlers.Item := (measure => ada_Functions.weigh'Access,
                                               namer   => ada_Functions.length_of'Access);
      the_Sample   : aliased Sample.Item   := (id => 1, value => 2.0);
   begin
      check (use_handlers (the_Handlers'unchecked_Access, the_Sample'unchecked_Access) = 24.0,
             "functions which are members of a structure");
   end members;

   results :
   declare
      the_Sample  : aliased  Sample.Item  := (id => 1, value => 4.0);
      the_Doubler : constant Measure.Item := doubler;
   begin
      check (the_Doubler /= null,                                   "C++ returns a pointer to one of its functions");
      check (the_Doubler (the_Sample'unchecked_Access) = 8.0,       "which Ada calls");
      check (measure_all (the_Doubler, the_Sample'unchecked_Access, 1) = 8.0,   "and gives back to C++");
   end results;

   kept_by_a_class :
   declare
      the_Button : aliased Button.Item := Button.construct;
      the_Total  : aliased int         := 0;
   begin
      Button.press (the_Button);
      check (the_Total = 0,                                         "a class with no function connected calls none");

      Button.connect (the_Button, ada_Functions.collect'Access, the_Total'Address);
      Button.press (the_Button);
      Button.press (the_Button);
      check (the_Total = 5,                                         "a class calls the function which it has kept");
      check (the_Button.presses = 3,                                "and its own member is kept up");
   end kept_by_a_class;

   pointers_to_Members :
   declare
      the_Pair : aliased Pair.Item := (first => 3, second => 4);
   begin
      check (read (the_Pair'unchecked_Access, pick (1)) = 4,      "a pointer to a member variable, from C++ and given back");
      check (read (the_Pair'unchecked_Access, pick (0)) = 3,      "and another");
      check (call_on (the_Pair'unchecked_Access, summer) = 7,     "a pointer to a constant member function");

      declare
         the_Reader : aliased Reader.Item;
      begin
         check (Reader.apply (the_Reader'unchecked_Access, the_Pair'unchecked_Access, pick (1)) = 40,   "given to a virtual function, which is called through the wrapper");
         Reader.destruct_0 (the_Reader);
      end;
   end pointers_to_Members;

   finish;
end Tester;
