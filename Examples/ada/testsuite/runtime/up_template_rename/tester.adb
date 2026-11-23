with
     template_rename.iFoo,
     template_rename.dFoo,

     interfaces.C,

     Checks;


procedure Tester
--
--  The case 'template_rename' of upstream's suite, after its Python test: functions of a class
--  template are renamed, some in every instance and some in one alone.
--
is
   use template_rename,
       interfaces.C,
       Checks;

   the_iFoo : aliased iFoo.Item;
   the_dFoo : aliased dFoo.Item;
begin
   check (iFoo.blah_test  (the_iFoo, 4) = 4,   "a function which is renamed in every instance");
   check (iFoo.spam_test  (the_iFoo, 5) = 5,   "one which is renamed in this instance alone");
   check (iFoo.groki_test (the_iFoo, 6) = 6,   "and one which has a name of its own in this instance");

   check (dFoo.blah_test  (the_dFoo, 7) = 7,   "the first, in the other instance");
   check (dFoo.spam       (the_dFoo, 8) = 8,   "the second, which keeps its name there");
   check (dFoo.grok_test  (the_dFoo, 9) = 9,   "and the third, by the name which every instance has");

   finish;
end Tester;
