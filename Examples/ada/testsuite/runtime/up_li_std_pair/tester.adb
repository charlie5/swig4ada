with
     li_std_pair.Binding,
     li_std_pair.IntPair,
     li_std_pair.PairTest,
     li_std_pair.Holder,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'li_std_pair' of upstream's suite, after its Python test: a pair of the standard library, which
--  is returned by value, by pointer and by reference, and passed in each of those ways. In Ada a pair
--  is a record of its two members.
--
is
   use li_std_pair,
       li_std_pair.Binding,
       interfaces.C,
       Checks;

   by_Value     : aliased  IntPair.Item    := makeIntPair         (7, 6);
   by_Constant  : constant IntPair.Pointer := makeIntPairConstRef (7, 6);
   by_Pointer   : constant IntPair.Pointer := makeIntPairPtr      (7, 6);
   by_Reference : constant IntPair.Pointer := makeIntPairRef      (7, 6);
begin
   check (by_Value.first = 7 and by_Value.second = 6,               "a pair which is returned by value");
   check (by_Constant.first = 7 and by_Constant.second = 6,         "by a reference to a constant");
   check (by_Pointer.first = 7 and by_Pointer.second = 6,           "by a pointer");
   check (by_Reference.first = 7 and by_Reference.second = 6,       "by a reference");

   check (product1 (by_Value) = 42,                                 "a pair which is passed by value");
   check (product2 (by_Value'unchecked_Access) = 42,                "by a reference");
   check (product1 (by_Pointer.all) = 42,                           "one which C++ holds, by value");
   check (product2 (by_Pointer) = 42,                               "by a reference");
   check (product3 (by_Pointer) = 42,                               "and by a pointer");

   declare
      Made : constant IntPair.Item := IntPair.construct (3, 4);
   begin
      check (Made.first = 3 and Made.second = 4,                    "a pair which Ada constructs");
   end;

   declare
      the_Holder : constant Holder.Item   := Holder.construct (11);
      the_Pair   : constant PairTest.Item := PairTest.construct (the_Holder, 5);
      Returned   : constant PairTest.Item := pair1 (the_Pair);
   begin
      check (Returned.first.number = 11 and Returned.second = 5,     "a pair of a class and a number, passed and returned by value");
   end;

   finish;
end Tester;
