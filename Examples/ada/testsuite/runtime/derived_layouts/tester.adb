with
     derived_layouts.Binding,
     derived_layouts.Base,
     derived_layouts.Derived,
     derived_layouts.PlainDerived,
     derived_layouts.Further,
     derived_layouts.Flagged,
     derived_layouts.Hiding,
     derived_layouts.Both,
     derived_layouts.OnGuarded,
     derived_layouts.OnEnded,
     derived_layouts.OnCopied,
     derived_layouts.OnEmpty,
     derived_layouts.OnOnEmpty,

     interfaces.C,

     Checks;


procedure Tester
--
--  Classes derived from classes with no virtual functions. C++ places the members of such a class in the
--  unused tail of its base, unless the base is a plain structure. Each is made by C++ and read by Ada,
--  changed by Ada and read by C++, and its size is compared.
--
is
   use derived_layouts,
       derived_layouts.Binding,
       interfaces.C,
       Checks;

   function bytes (Bits : in Natural) return int
   is (int (Bits / 8));

begin
   in_the_tail_of_a_base :
   declare
      the_Derived : aliased Derived.Item := Derived.construct;
   begin
      check (bytes (Derived.Item'Object_Size) = size_of_derived,    "a class whose members begin in the tail of its base has the size of C++");
      check (the_Derived.d = 'd',                                   "the member in the tail of the base");
      check (the_Derived.s = 7 and the_Derived.e = 9,               "and the members after it");

      check (Derived.as_Base (the_Derived).i = 1,                   "a member of the base, reached by a pointer to the base");
      check (base_value (Derived.as_Base (the_Derived)) = 1,        "which C++ takes");

      the_Derived.s                     := 20;
      Derived.as_Base (the_Derived).i   := 5;
      check (Derived.sum (the_Derived) = 5 + 20 + 9 + 100 + 1000,   "C++ reads what Ada wrote to each");
   end in_the_tail_of_a_base;

   after_a_plain_base :
   declare
      the_Plain : aliased PlainDerived.Item;
   begin
      check (bytes (PlainDerived.Item'Object_Size) = size_of_plain, "a class derived from a plain structure has the size of C++");

      fill_plain (the_Plain'unchecked_Access);
      check (the_Plain.Plain.i = 1 and the_Plain.Plain.c = 'c',     "the base is a component, as its tail is not used");
      check (the_Plain.d = 'd' and the_Plain.e = 9,                 "and the members follow the whole of it");

      the_Plain.d := 'x';
      check (plain_sum (the_Plain'unchecked_Access) = 1 + 9 + 100 + 1000,   "C++ reads what Ada wrote");
   end after_a_plain_base;

   a_further_level :
   declare
      the_Further : aliased Further.Item := Further.construct;
   begin
      check (bytes (Further.Item'Object_Size) = size_of_further,    "a class derived from a derived class has the size of C++");
      check (the_Further.f = 'f' and the_Further.g = 'g',           "its own members");
      check (the_Further.Derived.e = 9,                             "a member of its base, which has no unused tail");
      check (Derived.as_Base (the_Further.Derived).c = 'c',         "and of the base of that");

      the_Further.g := 'x';
      check (Further.sum (the_Further) = 1 + 7 + 9 + 100 + 1000 + 10_000,   "C++ reads what Ada wrote");
   end a_further_level;

   bit_fields_in_the_tail :
   declare
      the_Flagged : aliased Flagged.Item := Flagged.construct;
   begin
      check (bytes (Flagged.Item'Object_Size) = size_of_flagged,    "bit-fields in the tail of a base: the size");
      check (the_Flagged.on = 1 and the_Flagged.level = 9,          "and the bit-fields");
      check (the_Flagged.after = 33,                                "and the member after them");

      the_Flagged.level := 2;
      check (Flagged.sum (the_Flagged) = 1 + 1 + 2 + 33,            "which C++ reads");
   end bit_fields_in_the_tail;

   an_ignored_member_in_the_tail :
   declare
      the_Hiding : aliased Hiding.Item := Hiding.construct;
   begin
      check (bytes (Hiding.Item'Object_Size) = size_of_hiding,      "an ignored member in the tail of a base: the size");
      check (the_Hiding.shown = 'v' and the_Hiding.last = 5,        "and the members after it");

      the_Hiding.shown := 'w';
      check (Hiding.sum (the_Hiding) = 5 + 100 + 1000,              "which C++ reads, with the ignored member untouched");
   end an_ignored_member_in_the_tail;

   two_bases :
   declare
      the_Both : aliased Both.Item := Both.construct;
   begin
      check (bytes (Both.Item'Object_Size) = size_of_both,          "a class with two bases has the size of C++");
      check (the_Both.q = 'q' and the_Both.r = 4,                   "its own members, the first in the tail of the second base");
      check (Both.as_Base (the_Both).i = 1,                         "the first base");
      check (Both.as_Other (the_Both).o = 3 and Both.as_Other (the_Both).p = 'p',   "the second base, which begins in the tail of the first");
      check (other_value (Both.as_Other (the_Both)) = 3,            "and which C++ takes");

      Both.as_Other (the_Both).o := 30;
      the_Both.r                 := 40;
      check (Both.sum (the_Both) = 1 + 30 + 40 + 100 + 1000,        "C++ reads what Ada wrote");
   end two_bases;

   other_kinds_of_base :
   declare
      On_Guarded : aliased OnGuarded.Item;
      On_Ended   : aliased OnEnded.Item;
      On_Copied  : aliased OnCopied.Item;
   begin
      check (bytes (OnGuarded.Item'Object_Size) = size_of_on_guarded,   "a base with a member which is not public: the size");
      check (bytes (OnEnded  .Item'Object_Size) = size_of_on_ended,     "a base with a destructor: the size");
      check (bytes (OnCopied .Item'Object_Size) = size_of_on_copied,    "a base with a copy constructor: the size");

      On_Guarded.d := char'Val (3);   On_Guarded.e := 4;
      On_Ended  .d := char'Val (5);   On_Ended  .e := 6;
      On_Copied .d := char'Val (7);   On_Copied .e := 8;

      check (guarded_d (On_Guarded'unchecked_Access) = 7,           "C++ reads the members in the tail of the first");
      check (ended_d   (On_Ended  'unchecked_Access) = 11,          "and of the second");
      check (copied_d  (On_Copied 'unchecked_Access) = 15,          "and of the third");
   end other_kinds_of_base;

   a_base_with_no_members :
   declare
      the_Object : aliased OnOnEmpty.Item;
   begin
      check (bytes (OnEmpty  .Item'Object_Size) = size_of_on_empty,     "a base with no members takes no room");
      check (bytes (OnOnEmpty.Item'Object_Size) = size_of_on_on_empty,  "and a class derived from one derived from it has the size of C++");

      OnOnEmpty.as_OnEmpty (the_Object).i := 10;
      OnOnEmpty.as_OnEmpty (the_Object).c := char'Val (2);
      the_Object.d                        := char'Val (3);
      check (empty_sum (the_Object'unchecked_Access) = 15,          "whose members C++ reads where Ada wrote them");
   end a_base_with_no_members;

   finish;
end Tester;
