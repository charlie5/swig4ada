with
     preproc.Binding,
     preproc.TypeNameTraits,

     interfaces.C.Strings,

     ada.Text_IO,
     ada.Command_Line;


procedure Tester
--
--  Constants which the preprocessor makes: by '#define', by joining
--  and quoting its arguments, and by expressions of each operator.
--
is
   use preproc,
       preproc.Binding,
       interfaces.C,
       ada.Text_IO;

   Failures : Natural := 0;


   procedure check (Condition : in Boolean;   What : in String)
   is
   begin
      if Condition
      then
         put_Line ("   ok      " & What);
      else
         put_Line ("   FAILED  " & What);
         Failures := Failures + 1;
      end if;
   end check;


   function "+" (From : in Strings.chars_ptr) return String
   renames Strings.Value;

begin
   check (+SLASHSLASH = "//",                           "a string which looks like a comment");
   check (+a5 = "helloworld" and +C1 = "hello",         "strings made by joining and quoting arguments");
   check (b5 = 7 and d5 = 123 and ALONG_NAME = 42,      "numbers made by macros");
   check (c6 = 30 and d6 = 30,                          "expressions of other constants");

   check (A1 = 3 and A2 = -1 and A3 = 30 and A4 = 0,    "sum, difference, product and quotient");
   check (A5_UC = 0 and A6_UC = 45_056,                 "shifts");
   check (A7 = 12 and A8 = 31 and A9 = 3,               "and, or and exclusive or");
   check (A10 = 1 and A11 = 1 and A12 = -23 and A13 = 0,   "the logical operators and complement");

   check (EMBEDDED_DEFINE = 44 and EMBEDDED_SWIG_CONSTANT = 55,   "constants defined within a structure");
   check (ONE_UC = 1 and two = 2 and three = 3,         "constants defined by way of other macros");

   check (hello0 = 0 and hello1 = 1 and hello2 = 2,     "functions which a macro declares");
   check (f (7) = 7,                                    "a function with a parameter named 'min'");

   check (endif = 1 and define = 1 and defined = 1,     "variables with the names of preprocessor directives");
   check (test (5) = 5,                                 "and a parameter with one");
   check (method ((val => 9)) = 9,                      "a structure which a macro declares, passed by value");

   if Failures /= 0
   then
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
end Tester;
