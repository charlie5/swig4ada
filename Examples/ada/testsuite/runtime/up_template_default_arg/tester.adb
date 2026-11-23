with
     template_default_arg.Binding,
     template_default_arg.Hello_int,
     template_default_arg.Foo_int,
     template_default_arg.Foo_Z_8,
     template_default_arg.X_int,
     template_default_arg.X_longlong,
     template_default_arg.X_Foo_Z_8,
     template_default_arg.Y_unsigned,

     interfaces.C.Strings,
     swig,

     Checks;


procedure Tester
--
--  The case 'template_default_arg' of upstream's suite, after its Python test: class and function
--  templates whose parameters have default arguments, and member functions of them with default
--  arguments of their own. A function with a default argument is a function of each number of
--  arguments which a call may have.
--
is
   use template_default_arg,
       template_default_arg.Binding,
       interfaces.C,
       interfaces.C.Strings,
       Checks;

   the_Hello : aliased Hello_int.Item := Hello_int.construct;
   Hi        :         chars_ptr      := new_String ("hi");
   One       : aliased int            := 1;
begin
   Hello_int.foo (the_Hello, Hello_int.the_hi);
   Hello_int.foo (the_Hello);
   check (True,                                           "a function whose default argument is a value of an enumeration of its class");

   members_with_default_Arguments :
   declare
      the_X       : aliased X_int.Item      := X_int.construct;
      the_Y       : aliased Y_unsigned.Item := Y_unsigned.construct;
      Two_hundred : aliased int             := 200;
      Twenty      : aliased int             := 20;
      Y_hundreds  : aliased unsigned        := 200;
      Y_twenty    : aliased unsigned        := 20;
   begin
      check (X_int.meth (the_X, 20.0, Two_hundred'unchecked_Access) = 200,   "a member function with both of its arguments");
      check (X_int.meth (the_X, Twenty'unchecked_Access).all = 20,           "its overload of the one argument");
      check (X_int.meth (the_X).all = 0,                                     "and that with the default argument of the type of the template");

      check (Y_unsigned.meth (the_Y, 20.0, Y_hundreds'unchecked_Access) = 200,   "the same of an instance by the default argument of its template");
      check (Y_unsigned.meth (the_Y, Y_twenty'unchecked_Access).all = 20,        "its overload");
      check (Y_unsigned.meth (the_Y).all = 0,                                    "and its default");
   end members_with_default_Arguments;

   constructors_with_default_Arguments :
   declare
      use type Foo_Z_8.Pointer;

      Many : aliased swig.long_long   := 200;
      x1   : aliased X_longlong.Item := X_longlong.construct;
      x2   : aliased X_longlong.Item := X_longlong.construct (20.0);
      x3   : aliased X_longlong.Item := X_longlong.construct (20.0, Many'unchecked_Access);
      fz   : aliased Foo_Z_8.Item    := Foo_Z_8.construct;
      xz   : aliased X_Foo_Z_8.Item  := X_Foo_Z_8.construct;
   begin
      check (X_longlong.meth (x1).all = 0 and X_longlong.meth (x2).all = 0 and X_longlong.meth (x3).all = 0,
             "a class is constructed with each number of the arguments of its constructor");
      check (X_Foo_Z_8.meth (xz, fz'unchecked_Access) /= null,   "an instance whose argument is an instance with a default argument of its own");
   end constructors_with_default_Arguments;

   function_templates :
   declare
      the_Foo : aliased Foo_int.Item := Foo_int.construct;
   begin
      check (ott (the_Foo) = 30,                           "a function template of a class");
      check (ott = 10,                                     "one with every argument left to its default");
      check (ott (int'(1)) = 10,                           "with one given");
      check (ott (int'(1), One'unchecked_Access) = 10,     "and with both");
      check (ott (Hi) = 20,                                "one which takes a string, with the others left to their defaults");
      check (ott (Hi, 1) = 20,                             "with one more given");
      check (ott (Hi, 1, One'unchecked_Access) = 20,       "and with them all");
      check (ottstring (the_Hello, Hi) = 40,               "one of a class and a string");
      check (ottstring (the_Hello) = 40,                   "with the string left to its default");
      check (ottint (the_Hello, 1) = 50,                   "one of a class and an integer");
      check (ottint (the_Hello) = 50,                      "with the integer left to its default");
      check (ott (the_Hello, double'(1.0)) = 60,           "one of a class and a real number");
      check (ott (the_Hello) = 60,                         "with the real number left to its default");
   end function_templates;

   free (Hi);
   finish;
end Tester;
