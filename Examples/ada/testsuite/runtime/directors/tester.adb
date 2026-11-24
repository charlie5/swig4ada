with
     directors.Binding,
     directors.Speaker.Director,
     directors.Voice,

     Speakers,

     swig.std_Strings,
     interfaces.C,

     Checks;


procedure Tester
--
--  Directors: virtual functions which Ada cannot call through the vtable of their class (they return, by value, a
--  class which C++ constructs, or take a plain structure by value), overridden in Ada through the director of the
--  class, and called by C++.
--
is
   use directors,
       directors.Binding,
       swig.std_Strings,
       interfaces.C,
       Checks;

   Word   : aliased std_String := to_std_String (to_C ("hi"));
   Result : aliased std_String;

begin
   the_Director :
   declare
      the_Plain : aliased Speaker.Director.Item;     -- Which does what the class does.
   begin
      say (the_Plain'unchecked_Access, Word'unchecked_Access, Result'unchecked_Access);
      check (to_Ada (Result) = "hi!",                                       "a director which is not overridden does what its class does");

      say_n (the_Plain'unchecked_Access, 2, Result'unchecked_Access);
      check (to_Ada (Result) = "aa",                                        "an overload too");

      label_of (the_Plain'unchecked_Access, Result'unchecked_Access);
      check (to_Ada (Result) = "speaker",                                   "and one which returns a class which C++ constructs");

      check (sum_of (the_Plain'unchecked_Access, 3, 4) = 7,                 "and one which takes a plain structure by value");
      check (level_of (the_Plain'unchecked_Access) = 1,                     "an object of the director is constructed by the constructor which takes nothing");

      Speaker.reveal (the_Plain, Result'unchecked_Access);
      check (to_Ada (Result) = "hidden",                                    "a protected function");

      Speaker.destruct_0 (Speaker.Item (the_Plain));
   end the_Director;

   another_Constructor :
   declare
      the_Loud : aliased Speaker.Director.Item := Speaker.Director.construct (5);
   begin
      check (level_of (the_Loud'unchecked_Access) = 5,                      "and by another constructor of its class");
      Speaker.destruct_0 (Speaker.Item (the_Loud));
   end another_Constructor;

   overridden_in_Ada :
   declare
      the_Parrot : aliased Speakers.Parrot;
   begin
      say (the_Parrot'unchecked_Access, Word'unchecked_Access, Result'unchecked_Access);
      check (to_Ada (Result) = "polly says hi",                             "C++ calls the function of Ada which overrides one that returns a string");
      check (the_Parrot.Calls = 1,                                          "with the object of Ada");

      say_n (the_Parrot'unchecked_Access, 3, Result'unchecked_Access);
      check (to_Ada (Result) = "squawk 3",                                  "and an overload of it");

      label_of (the_Parrot'unchecked_Access, Result'unchecked_Access);
      check (to_Ada (Result) = "speaker and parrot",                        "one which returns a class, and calls what the class does");

      check (sum_of (the_Parrot'unchecked_Access, 3, 4) = 12,               "one which takes a plain structure by value");
      check (level_of (the_Parrot'unchecked_Access) = 9,                    "a function which Ada calls through the vtable is overridden as before");

      Speaker.reveal (the_Parrot, Result'unchecked_Access);
      check (to_Ada (Result) = "parrot secret",                             "a protected function");

      check (fixed_of (the_Parrot'unchecked_Access) = 7,                    "one whose result has no constructor which takes nothing is not overridden");

      Speaker.speak (the_Parrot, Word'unchecked_Access, Result'unchecked_Access);
      check (to_Ada (Result) = "polly says hi" and the_Parrot.Calls = 2,    "Ada calls it through the class-wide function, which makes the virtual call");

      Speaker.destruct_0 (Speaker.Item (the_Parrot));
   end overridden_in_Ada;

   of_an_abstract_Class :
   declare
      the_Choir : aliased Speakers.Choir;
   begin
      introduce (the_Choir'unchecked_Access, Result'unchecked_Access);
      check (to_Ada (Result) = "I am choir",                                "the director of an abstract class, whose pure function Ada defines");
      check (pitch_of (the_Choir'unchecked_Access) = 440,                   "beside one which Ada calls through the vtable");

      directors.Voice.destruct_0 (directors.Voice.Item (the_Choir));
   end of_an_abstract_Class;

   of_a_derived_Class :
   declare
      the_Chatter : aliased Speakers.Chatter;
   begin
      say (the_Chatter'unchecked_Access, Word'unchecked_Access, Result'unchecked_Access);
      check (to_Ada (Result) = "chatter says hi",                           "the director of a derived class lets Ada override a function which it inherits");

      accent_of (the_Chatter'unchecked_Access, Result'unchecked_Access);
      check (to_Ada (Result) = "broad",                                     "and one of its own");

      label_of (the_Chatter'unchecked_Access, Result'unchecked_Access);
      check (to_Ada (Result) = "speaker",                                   "and one which is not overridden does what the base does");

      check (level_of (the_Chatter'unchecked_Access) = 3,                   "which the constructor of the class set up");
      Speaker.destruct_0 (Speaker.Item (the_Chatter));
   end of_a_derived_Class;

   destruct (Result);
   destruct (Word);
   finish;
end Tester;
