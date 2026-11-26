with
     li_std_pair_using.Binding,
     li_std_pair_using.StringStringPair,
     li_std_pair_using.StringIntPair,

     swig.std_Strings,
     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'li_std_pair_using' of upstream's suite, after its Python test: pairs of strings, named through a 'using'
--  declaration of the pair and of the string, and typedefs of the string, by its own name and by that which the
--  declaration brings in, which a function takes and returns within a pair, by value.
--
is
   use li_std_pair_using,
       li_std_pair_using.Binding,
       swig.std_Strings,
       interfaces.C,
       Checks;

   One     : aliased std_String := to_std_String (to_C ("one"));
   Uno     : aliased std_String := to_std_String (to_C ("numero uno"));
   Two     : aliased std_String := to_std_String (to_C ("two"));

   the_One : aliased StringStringPair.Item := StringStringPair.construct (One, Uno);
   the_Two : aliased StringIntPair   .Item := StringIntPair   .construct (Two, 2);
   Bounced : aliased StringStringPair.Item;

   --  'typedef string Streeng;', after 'using std::string;', is the string (until 2026-11-26 it was an address).
   --
   a_Streeng : aliased li_std_pair_using.Streeng := to_std_String (to_C ("streeng"));
begin
   check (to_Ada (the_One.first) = "one" and to_Ada (the_One.second) = "numero uno",     "a pair of strings");
   check (to_Ada (the_Two.first) = "two" and the_Two.second = 2,                         "a pair of a string and a number, named through 'using'");

   bounce (the_One, Bounced'unchecked_Access);
   check (to_Ada (Bounced.first) = "one" and to_Ada (Bounced.second) = "numero uno",     "a pair which is passed and returned by value");

   check (to_Ada (a_Streeng) = "streeng",                                                "a typedef of the string which 'using' brings in");

   destruct (a_Streeng);
   StringStringPair.destruct_0 (Bounced);
   StringIntPair   .destruct_0 (the_Two);
   StringStringPair.destruct_0 (the_One);
   destruct (Two);
   destruct (Uno);
   destruct (One);

   finish;
end Tester;
