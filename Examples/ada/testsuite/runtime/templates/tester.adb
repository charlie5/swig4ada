with
     templates.Binding,
     templates.int_Pair,
     templates.double_Pair,
     templates.int_Ring,
     templates.long_Ring_8,
     templates.int_Source,
     templates.int_Source.Guards,
     templates.Counter,
     templates.Counter.Guards,
     templates.whole_Tracked,

     interfaces.C,

     Checks;


procedure Tester
--
--  Templates which a library defines: function templates, a structure, a class with a default
--  argument, and a template with virtual functions which a class is derived from.
--
is
   use templates,
       templates.Binding,
       interfaces.C,
       Checks;

begin
   check (largest_int    (3,   7)   = 7,       "an instance of a function template");
   check (largest_double (2.5, 1.5) = 2.5,     "a second instance of it");

   a_structure :
   declare
      P : aliased int_Pair   .Item := (first => 3,   second => 4);
      Q : aliased double_Pair.Item := (first => 1.5, second => 2.0);
   begin
      check (int_Pair   .sum (P) = 7,          "a member function of a template instance");
      check (double_Pair.sum (Q) = 3.5,        "the same function of a second instance");

      int_Pair.swap (P);
      check (P.first = 4 and P.second = 3,     "a member function which changes the object");
   end a_structure;

   a_class_with_a_default_argument :
   declare
      R : aliased int_Ring   .Item := int_Ring   .construct;
      S : aliased long_Ring_8.Item := long_Ring_8.construct;
      X : aliased int  := 11;
      Y : aliased long := 22;
   begin
      check (int_Ring   .capacity (R) = 4,     "an instance which takes the default argument");
      check (long_Ring_8.capacity (S) = 8,     "an instance which gives the argument");

      int_Ring.put (R, X'unchecked_Access);
      X := 12;
      int_Ring.put (R, X'unchecked_Access);
      check (int_Ring.get (R, 0) = 11 and int_Ring.get (R, 1) = 12,   "elements are stored and read back");

      long_Ring_8.put (S, Y'unchecked_Access);
      check (long_Ring_8.get (S, 0) = 22,      "likewise in the second instance, of another element type");
      check (long_Ring_8.get (S, 7) = 0,       "whose last element is still as it was constructed");
   end a_class_with_a_default_argument;

   check (sources_alive = 0,                   "there are no sources at the start");

   a_virtual_template_instance :
   declare
      the_Source  : aliased int_Source.Item := int_Source.construct;
      the_Counter : aliased Counter   .Item := Counter   .construct;

      source_Guard  : int_Source.Guards.Guard (the_Source 'Access) with Unreferenced;
      counter_Guard : Counter   .Guards.Guard (the_Counter'Access) with Unreferenced;
   begin
      check (sources_alive = 2,                                 "both objects have been constructed");
      check (int_Source.next (the_Source'Access) = 0,           "the virtual function of the template instance");

      check (Counter.next (the_Counter'Access) = 1,             "the overriding function of the derived class");
      check (int_Source.twice (the_Counter'Access) = 5,         "a function of the template which calls the overriding function");
      check (drain (the_Counter'unchecked_Access, 2) = 9,       "C++ dispatches through a pointer to the template instance");
      check (drain (the_Source 'unchecked_Access, 2) = 0,       "and to the template instance itself");
   end a_virtual_template_instance;

   check (sources_alive = 0,                   "the guards have called the destructors of the template instance and of the derived class");

   a_virtual_instance_which_is_not_named_as_Cpp_names_it :
   declare
      the_Tracked : aliased whole_Tracked.Item    := whole_Tracked.construct (5);
      by_Cpp      : constant whole_Tracked.Pointer := new_tracked (8);
   begin
      check (tracked_count = 2,                              "an object is made by Ada, and one by C++");
      check (whole_Tracked.get (the_Tracked'Access) = 5,     "its virtual function is called");
      check (whole_Tracked.get (by_Cpp) = 8,                 "and that of the object which C++ made");

      whole_Tracked.destruct_0 (the_Tracked);
      check (tracked_count = 1,                              "its destructor is called, where its symbol cannot be made from its name");

      whole_Tracked.destruct (by_Cpp.all);
      check (tracked_count = 0,                              "and the destructor which frees an object made by C++");
   end a_virtual_instance_which_is_not_named_as_Cpp_names_it;

   finish;
end Tester;
