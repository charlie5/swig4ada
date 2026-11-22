with
     varargs.Binding,
     varargs.Foo,
     varargs.VarargConstructor,

     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'varargs' of upstream's suite, after its Python test: functions and constructors which take a
--  variable number of arguments. Ada gives those which are named, and those which '%varargs' names.
--
is
   use varargs,
       varargs.Binding,
       interfaces.C.Strings,
       Checks;

   function "=" (Left : in chars_ptr;   Right : in String) return Boolean
   is (String'(Value (Left)) = Right);

   Hello     : chars_ptr := new_String ("Hello");
   Hey       : chars_ptr := new_String ("Hey there");
   Greetings : chars_ptr := new_String ("Greetings");

   --  'VarargConstructor' keeps a copy of its string and has no destructor, so the copy is never freed. That
   --  is the input's own doing, and the check for leaks is told to pass over it.
   --
   procedure pass_over_Leaks   with Import, Convention => C, External_Name => "__lsan_disable";
   procedure look_for_Leaks    with Import, Convention => C, External_Name => "__lsan_enable";

   function new_Constructed return VarargConstructor.Item
   is
   begin
      pass_over_Leaks;

      return Result : constant VarargConstructor.Item := VarargConstructor.construct (Hey)
      do
         look_for_Leaks;
      end return;
   end new_Constructed;

   the_Constructed : aliased VarargConstructor.Item := new_Constructed;
   the_Foo         : aliased Foo.Item               := Foo.construct (Greetings);
begin
   check (test (Hello) = "Hello",                       "a function of a variable number of arguments, called with those which are named");

   check (the_Constructed.str = "Hey there",            "a constructor of a variable number of arguments");
   check (the_Foo.str = "Greetings",                    "of a second class");
   check (Foo.test (the_Foo, Hello) = "Hello",          "a member function of a variable number of arguments");

   check (test_def (Hello, 1) = "Hello",                "one argument of the variable ones is named by the interface file");
   check (test_def (Hello)    = "Hello",                "and may be left out");

   check (test_plenty (Hello)       = "Hello",          "two are named, and neither is given");
   check (test_plenty (Hello, 1)    = "Hello",          "one is given");
   check (test_plenty (Hello, 1, 2) = "Hello",          "both are given");

   Foo.destruct_0 (the_Foo);

   free (Hello);
   free (Hey);
   free (Greetings);

   finish;
end Tester;
