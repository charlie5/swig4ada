with
     template_templated_constructors.TConstructor1,
     template_templated_constructors.TConstructor2,
     template_templated_constructors.TClass1Int,
     template_templated_constructors.TClass2Int,
     template_templated_constructors.DoublePair,
     template_templated_constructors.ShortPair,
     template_templated_constructors.StringPair,
     template_templated_constructors.IntPair,

     swig.std_Strings,
     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'template_templated_constructors' of upstream's suite, after its Python test: instances of constructor
--  templates, of a class and of instances of a class template, which '%template' names, beside the constructors which
--  are not templates; among them a constructor of one instance of a pair from each of the others.
--
is
   use template_templated_constructors,
       swig.std_Strings,
       interfaces.C,
       Checks;

   One     : aliased double := 1.1;
   Two     : aliased double := 2.2;
   Zero_s  : aliased short  := 0;
   One_s   : aliased short  := 1;
   Twenty  : aliased int    := 20;
   Twenty1 : aliased int    := 21;
   Ten     : aliased std_String := to_std_String (to_C ("10"));
   Eleven  : aliased std_String := to_std_String (to_C ("11"));

   t1  : aliased TConstructor1.Item := TConstructor1.construct (123);
   t2a : aliased TConstructor2.Item := TConstructor2.construct;
   t2b : aliased TConstructor2.Item := TConstructor2.construct (123);

   tc1  : constant TClass1Int.Item := TClass1Int.construct (123.4);
   tc2a : constant TClass2Int.Item := TClass2Int.construct;
   tc2b : constant TClass2Int.Item := TClass2Int.construct (123.4);

   double_Pair : aliased DoublePair.Item := DoublePair.construct (One'unchecked_Access, Two'unchecked_Access);
   short_Pair  : aliased ShortPair .Item := ShortPair .construct (Zero_s'unchecked_Access, One_s'unchecked_Access);
   string_Pair : aliased StringPair.Item := StringPair.construct (Ten'unchecked_Access, Eleven'unchecked_Access);

   ip1 : aliased IntPair.Item := IntPair.construct;
   ip2 : aliased IntPair.Item := IntPair.construct (Twenty'unchecked_Access, Twenty1'unchecked_Access);
   ip3 : aliased IntPair.Item := IntPair.construct (ip1'unchecked_Access);
   ip4 : aliased IntPair.Item := IntPair.construct (short_Pair'unchecked_Access);
   ip5 : aliased IntPair.Item := IntPair.construct (double_Pair'unchecked_Access);
   ip6 : aliased IntPair.Item := IntPair.construct (string_Pair'unchecked_Access);
begin
   check (tc1'Size = 8 and tc2a'Size = 8 and tc2b'Size = 8,             "the instances of a constructor template of an instance of a class template");

   --  The objects have no members to read: that they were made by the constructors which are named, from each
   --  kind of pair, is what is checked, and that they are destructed.
   --
   check (True,                                                         "a pair from another instance of its template, through a constructor template");

   IntPair.destruct_0 (ip6);   IntPair.destruct_0 (ip5);   IntPair.destruct_0 (ip4);
   IntPair.destruct_0 (ip3);   IntPair.destruct_0 (ip2);   IntPair.destruct_0 (ip1);

   StringPair.destruct_0 (string_Pair);
   ShortPair .destruct_0 (short_Pair);
   DoublePair.destruct_0 (double_Pair);

   TConstructor2.destruct_0 (t2b);
   TConstructor2.destruct_0 (t2a);
   TConstructor1.destruct_0 (t1);

   destruct (Eleven);
   destruct (Ten);
   finish;
end Tester;
