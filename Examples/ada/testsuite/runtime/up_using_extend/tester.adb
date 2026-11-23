with
     using_extend.FooBar,

     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'using_extend' of upstream's suite, after its Python test: a class names, by 'using'
--  declarations, the functions of two base classes, some of which were added by '%extend'.
--
is
   use using_extend,
       interfaces.C,
       interfaces.C.Strings,
       Checks;

   the_FooBar : aliased FooBar.Item;
   Hello      :         chars_ptr := new_String ("hello");
begin
   check (FooBar.blah (the_FooBar, int'(3)) = 3,                         "a function of the first base, of an integer");
   check (FooBar.blah (the_FooBar, double'(3.5)) = 3.5,                  "one of the second base, of a real number");
   check (String'(Value (FooBar.blah (the_FooBar, Hello))) = "hello",    "one of the first base, of a string");
   check (FooBar.blah (the_FooBar, int'(3), int'(4)) = 7,                "one which was added to the first base, of two integers");
   check (FooBar.blah (the_FooBar, double'(3.5), double'(7.5)) = 11.0,   "one which was added to the second base, of two real numbers");
   check (FooBar.duh  (the_FooBar, 3) = 3,                               "and one which was added and named by another name");

   free (Hello);
   finish;
end Tester;
