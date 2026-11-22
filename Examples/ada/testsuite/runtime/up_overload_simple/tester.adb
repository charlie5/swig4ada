with
     overload_simple.Binding,
     overload_simple.Foo,
     overload_simple.Bar,
     overload_simple.Spam,
     overload_simple.ClassA,

     swig,
     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  The case 'overload_simple' of upstream's suite, after its Python test: functions, member functions,
--  static member functions and constructors which are overloaded on the type of one parameter. Ada
--  chooses among them by the type of the argument, as C++ does.
--
is
   use overload_simple,
       overload_simple.Binding,
       interfaces.C,
       interfaces.C.Strings,
       Checks;

   function "=" (Left : in chars_ptr;   Right : in String) return Boolean
   is (String'(Value (Left)) = Right);

   Hello   : chars_ptr := new_String ("hello");
   a_Foo   : aliased overload_simple.Foo.Item;
   a_Bar   : aliased Bar.Item;
   a_Void  : constant swig.void_ptr := malloc_void (32);
   a_Spam  : aliased Spam.Item;
   a_Class : aliased ClassA.Item;
begin
   check (Binding.foo (int'(3))                = "foo:int",        "a function of an int");
   check (Binding.foo (double'(3.0))           = "foo:double",     "of a double");
   check (Binding.foo (Hello)                  = "foo:char *",     "of a string");
   check (Binding.foo (a_Foo'unchecked_Access) = "foo:Foo *",      "of a pointer to a class");
   check (Binding.foo (a_Bar'unchecked_Access) = "foo:Bar *",      "of a pointer to another");
   check (Binding.foo (a_Void)                 = "foo:void *",     "of a pointer to 'void'");

   check (Spam.foo (a_Spam, int'(3))                = "foo:int",        "a member function of an int");
   check (Spam.foo (a_Spam, double'(3.0))           = "foo:double",     "of a double");
   check (Spam.foo (a_Spam, Hello)                  = "foo:char *",     "of a string");
   check (Spam.foo (a_Spam, a_Foo'unchecked_Access) = "foo:Foo *",      "of a pointer to a class");
   check (Spam.foo (a_Spam, a_Bar'unchecked_Access) = "foo:Bar *",      "of a pointer to another");
   check (Spam.foo (a_Spam, a_Void)                 = "foo:void *",     "of a pointer to 'void'");

   check (Spam.bar (int'(3))                = "bar:int",        "a static member function of an int");
   check (Spam.bar (double'(3.0))           = "bar:double",     "of a double");
   check (Spam.bar (Hello)                  = "bar:char *",     "of a string");
   check (Spam.bar (a_Foo'unchecked_Access) = "bar:Foo *",      "of a pointer to a class");
   check (Spam.bar (a_Bar'unchecked_Access) = "bar:Bar *",      "of a pointer to another");
   check (Spam.bar (a_Void)                 = "bar:void *",     "of a pointer to 'void'");

   declare
      none      : constant Spam.Item := Spam.construct;
      of_Int    : constant Spam.Item := Spam.construct (int'(3));
      of_Double : constant Spam.Item := Spam.construct (double'(3.4));
      of_String : constant Spam.Item := Spam.construct (Hello);
      of_Foo    : constant Spam.Item := Spam.construct (a_Foo'unchecked_Access);
      of_Bar    : constant Spam.Item := Spam.construct (a_Bar'unchecked_Access);
      of_Void   : constant Spam.Item := Spam.construct (a_Void);
   begin
      check (none     .the_type = "none",       "a constructor with no argument");
      check (of_Int   .the_type = "int",        "of an int");
      check (of_Double.the_type = "double",     "of a double");
      check (of_String.the_type = "char *",     "of a string");
      check (of_Foo   .the_type = "Foo *",      "of a pointer to a class");
      check (of_Bar   .the_type = "Bar *",      "of a pointer to another");
      check (of_Void  .the_type = "void *",     "of a pointer to 'void'");
   end;

   check (ClassA.method1 (a_Class) = 0 and ClassA.method1 (a_Class, 1) = 1,     "a member function which is overloaded on the number of its arguments");

   check (fid (int'(3),      double'(3.0)) = "fid:intdouble",        "a function of an int and a double");
   check (fid (double'(3.0), int'(3))      = "fid:doubleint",        "of a double and an int");
   check (fid (double'(3.0), double'(3.0)) = "fid:doubledouble",     "of two doubles");
   check (fid (int'(3),      int'(3))      = "fid:intint",           "of two ints");

   free_void (a_Void);
   free (Hello);

   finish;
end Tester;
