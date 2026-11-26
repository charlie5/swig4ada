with
     c_Expressions,
     GMP.discrete,

     ada.Strings.unbounded,

     Checks;


procedure expressions_Test
--
--  Works out a table of C expressions, and checks each value against the value which a C compiler gives it.
--
is
   use c_Expressions,
       GMP,
       ada.Strings.unbounded,
       Checks;

   function "+" (Text : in String) return unbounded_String
     renames to_unbounded_String;


   type Row is
      record
         Expression : unbounded_String;
         Value      : Long_Long_Integer;     -- As GCC gives it.
      end record;

   the_Table : constant array (Positive range <>) of Row
     := [
      (+"42",                                                    42),
      (+"0x1F",                                                  31),
      (+"017",                                                   15),
      (+"0b1011",                                                11),
      (+"10U",                                                   10),
      (+"5L",                                                     5),
      (+"0x10UL",                                                16),
      (+"100LL",                                                100),
      (+"'A'",                                                   65),
      (+"'\n'",                                                  10),
      (+"'\0'",                                                   0),
      (+"'\x41'",                                                65),
      (+"'\101'",                                                65),
      (+"L'a'",                                                  97),
      (+"('d' << 24) | ('f' << 16) | ('l' << 8) | 't'",  1684434036),
      (+"~0 & 0xFF",                                            255),
      (+"!5",                                                     0),
      (+"!!5",                                                    1),
      (+"-(-(3))",                                                3),
      (+"(1 + 2) * (3 + 4)",                                     21),
      (+"((((7))))",                                              7),
      (+"1 << 10",                                             1024),
      (+"1024 >> 3",                                            128),
      (+"7 / 2",                                                  3),
      (+"-7 / 2",                                                -3),
      (+"7 % 3",                                                  1),
      (+"-7 % 3",                                                -1),
      (+"-9 >> 1",                                               -5),
      (+"1 - 2 + 3",                                              2),
      (+"10 - 4 - 3",                                             3),
      (+"100 / 10 / 5",                                           2),
      (+"100 / 10 * 5",                                          50),
      (+"2 + 3 * 4",                                             14),
      (+"1 + 2 << 3",                                            24),
      (+"1 << 2 + 3",                                            32),
      (+"6 & 3 | 8",                                             10),
      (+"5 ^ 3 & 1",                                              4),
      (+"1 | 4 ^ 5",                                              1),
      (+"2 < 3 + 1",                                              1),
      (+"1 + 1 == 2",                                             1),
      (+"3 == 3 & 1",                                             1),
      (+"1 < 2 == 1",                                             1),
      (+"1 || 0 && 0",                                            1),
      (+"0 && 0 || 1",                                            1),
      (+"5 != 2 + 3",                                             0),
      (+"6 >= 2 * 3",                                             1),
      (+"3 <= 2",                                                 0),
      (+"4 > 3",                                                  1),
      (+"sizeof(int)",                                            4),
      (+"sizeof(char)",                                           1),
      (+"sizeof(short) + sizeof(long)",                          10),
      (+"sizeof(double) * 2",                                    16),

      --  Casts, which do not change a value that is worked out here.
      --
      (+"(mytype) 10",                                           10),
      (+"(unsigned char) 'A'",                                   65),
      (+"(ns::mytype) (3 + 4)",                                   7),
      (+"static_cast< mytype >(10)",                             10),
      (+"static_cast< std::pair< int, int > >(2) + 1",            3),
      (+"int (7) * 2",                                           14),
      (+"unsigned long (1) << 4",                                16),
      (+"(1 + 2) * 3",                                            9),     -- Brackets which are no cast.
      (+"sizeof (int) * 2",                                       8),     -- Nor is the operand of 'sizeof'.
      (+"(unsigned) -1",                                 4294967295),     -- A cast to an integer type is applied: modulo its size,
      (+"(unsigned) -1 >> 4",                             268435455),     -- before an operator which follows it,
      (+"(unsigned char) 300",                                   44),
      (+"(signed char) 200",                                    -56),     -- into the range of a signed type,
      (+"(unsigned short) (65536 + 3)",                           3),     -- to an operand in brackets,
      (+"(bool) 7",                                               1),     -- and to 'bool', which is 0 or 1;
      (+"static_cast<unsigned> (-1)",                    4294967295),     -- in each of its forms,
      (+"short (70000) + 1",                                   4465),
      (+"static_cast<signed char> (100 + 100)",                 -56)
        ];

   No_Symbols : symbol_value_Maps.Map;


   function Value_of (Expression : in String;   Symbols   : in symbol_value_Maps.Map := No_Symbols;
                                                Namespace : in String                := "") return Long_Long_Integer
   is
   begin
      return discrete.Value (c_Expressions.Value_of (+Expression, Symbols, +Namespace));
   end Value_of;


   function is_Refused (Expression : in String;   Symbols : in symbol_value_Maps.Map := No_Symbols) return Boolean
   --
   --  True where the expression cannot be worked out, which is said by an exception.
   --
   is
      Unused : Long_Long_Integer;
   begin
      Unused := Value_of (Expression, Symbols);
      return False;

   exception
      when others =>
         return True;
   end is_Refused;

begin
   numbers_and_operators :
   begin
      for Each of the_Table
      loop
         declare
            the_Expression : constant String := to_String (Each.Expression);
         begin
            check (Value_of (the_Expression) = Each.Value,
                   the_Expression & " is" & Each.Value'Image);
         exception
            when others =>
               check (False, the_Expression & " is" & Each.Value'Image & " (it was refused)");
         end;
      end loop;
   end numbers_and_operators;

   names :
   declare
      the_Symbols : symbol_value_Maps.Map;
   begin
      the_Symbols.insert (+"COUNT",         discrete.to_Integer (12));
      the_Symbols.insert (+"A",             discrete.to_Integer (5));
      the_Symbols.insert (+"geometry::MAX", discrete.to_Integer (64));
      the_Symbols.insert (+"MAX",           discrete.to_Integer (8));

      check (Value_of ("COUNT * 2 + 1", the_Symbols) = 25,                        "the name of a known value stands for it");
      check (Value_of ("A + A", the_Symbols) = 10,                                "a name of one letter is a name");
      check (Value_of ("(COUNT > 10) + (COUNT % 5)", the_Symbols) = 3,            "a name may be within brackets");
      check (Value_of ("MAX", the_Symbols, Namespace => "geometry::") = 64,       "a name is sought within its namespace first");
      check (Value_of ("COUNT", the_Symbols, Namespace => "geometry::") = 12,     "and then as it is written");
      check (Value_of ("MAX", the_Symbols) = 8,                                   "a name with no namespace is its own");
      check (Value_of ("geometry::MAX * 2", the_Symbols) = 128,                   "a name which is given with its scope is sought as it is written");
      check (Value_of ("Shape::COUNT + 1", the_Symbols) = 13,                     "and then by its last part, as a literal is known by its own name");
      check (Value_of ("Shape::COUNT", the_Symbols, Namespace => "Shape::") = 12, "within its own class too");
      check (Value_of ("(COUNT) - 1", the_Symbols) = 11,                          "a known value in brackets ahead of a sign is no cast");
   end names;

   refusals :
   begin
      check (is_Refused ("UNKNOWN + 1"),                                          "a name which is not known is refused");
      check (is_Refused ("x"),                                                    "as is a lone letter, which is a name and no character");
      check (is_Refused ("4 <=> 2"),                                              "a three way comparison is refused");
      check (is_Refused ("factorial (5)"),                                        "the call of a function is no cast, and is refused");
      check (is_Refused ("1 ? 2 : 3"),                                            "as is a conditional expression");
      check (is_Refused ("1.5 + 2"),                                              "and a real number");
   end refusals;

   reals :
   declare
      the_Reals    : real_value_Maps.Map;
      the_Integers : symbol_value_Maps.Map;

      function real_Value (Expression : in String;   Namespace : in String := "") return Long_Float
      is (real_Value_of (Expression, the_Reals, the_Integers, +Namespace).Value);

      function is_Single (Expression : in String) return Boolean
      is (real_Value_of (Expression, the_Reals, the_Integers, +"").is_Single);

      function is_about (Value : in Long_Float;   Expected : in Long_Float) return Boolean
      is (abs (Value - Expected) <= abs Expected * 1.0e-15);

      function is_refused_as_Real (Expression : in String) return Boolean
      is
         Unused : Long_Float;
      begin
         Unused := real_Value (Expression);
         return False;

      exception
         when Constraint_Error =>
            return True;
      end is_refused_as_Real;

   begin
      the_Reals   .insert (+"EPS",   (1.0e-6, is_Single => False));
      the_Reals   .insert (+"FEPS",  (Long_Float (Float'Value ("1.0e-6")), is_Single => True));     -- Not static (see below).
      the_Integers.insert (+"COUNT", discrete.to_Integer (12));

      --  The values are those which GCC gives.
      --
      check (is_about (real_Value ("0.5"),                          0.5),           "a real number is itself");
      check (is_about (real_Value ("(float) 2.5f"),                 2.5),           "less its cast and its suffix");
      check (is_about (real_Value ("static_cast<double> (1e-6)"),   1.0e-6),        "and a cast which is named");
      check (is_about (real_Value ("1.0 / 3"),                      1.0 / 3.0),     "a division of a real by an integer is real");
      check (is_about (real_Value ("7 / 2 + 0.25"),                 3.25),          "and one of two integers truncates");
      check (is_about (real_Value ("-(2.5 * 2)"),                  -5.0),           "a sign applies to its brackets");
      check (is_about (real_Value ("1 - 2 + 3.0"),                  2.0),           "operators of a level are applied from the left");
      check (is_about (real_Value ("2.0 + 3 * 4"),                 14.0),           "and a product before a sum");
      check (is_about (real_Value ("EPS * 2"),                      2.0e-6),        "a known real stands for its value");
      check (is_about (real_Value ("COUNT / 5.0"),                  2.4),           "as does a known integer");
      check (is_about (real_Value ("Shape::EPS + 1"),               1.000001),      "a name with its scope is sought by its last part");

      check (is_refused_as_Real ("UNKNOWN * 2"),                                    "a name which is not known is refused");
      check (is_refused_as_Real ("pow (2.0, 3)"),                                   "as is the call of a function");
      check (is_refused_as_Real ("0x10 * 1.5"),                                     "and a number which is not decimal");
      check (is_refused_as_Real ("1.0 / 0"),                                        "and a division by zero");
      check (is_refused_as_Real ("(1.0 + 2"),                                       "and a bracket which is not closed");

      declare
         One   : Long_Float := 1.0;     -- Variables, so that each value is worked out at run time, as C works it out.
         Three : Long_Float := 3.0;
         Tenth : Long_Float := 0.1;
      begin
         check (real_Image (0.5) = "5.00000000000000E-01",                          "a value which 15 digits give back has 15");
         check (Long_Float'Value (real_Image (One / Three)) = One / Three,          "a third is given with the digits which give it back");
         check (real_Image (One / Three)'Length > real_Image (0.5)'Length,          "which are more than 15");
         check (Long_Float'Value (real_Image (Tenth * Three)) = Tenth * Three,      "as is three tenths, worked out, which is not 0.3");
      end;

      declare
         One   : Float      := 1.0;     -- As above.
         Three : Float      := 3.0;
         Seven : Float      := 7.0;
         Feps  : Float      := 1.0e-6;
         D_One : Long_Float := 1.0;
         Tenth : Float      := 0.1;     -- A static 'Float'' (0.1)' within a larger expression would not be rounded.
      begin
         check (real_Value ("1.0f / 7 * 3.0f") = Long_Float (One / Seven * Three),  "an expression of floats is worked out in float");
         check (real_Value ("1.0f / 7 * 3.0f") /= Long_Float (Float (D_One / 7.0 * 3.0)),
                "which is not the double rounded once, as GCC gives it (0.428571463, not 0.428571433)");
         check (real_Value ("FEPS * 3") = Long_Float (Feps * Three),                "a known float is a float");
         check (is_Single ("FEPS * 3"),                                             "and so is the result");
         check (not is_Single ("1.0f / 7 * 3.0"),                                   "an operation with a double is in double");
         check (real_Value ("1.0f / 7 * 3.0") = Long_Float (One / Seven) * 3.0,     "of the float which is worked out before it");
         check (real_Value ("0.1f") = Long_Float (Tenth),                           "a literal of float is rounded to float");
         check (not is_Single ("7 / 2"),                                            "and an integer is no float");
      end;

      declare
         One   : Float      := 1.0;     -- As above.
         Three : Float      := 3.0;
         Seven : Float      := 7.0;
         D_One : Long_Float := 1.0;

         function Cast_to (type_Name : in String) return a_Cast
         is (if type_Name = "real" then to_Single else not_a_Type);     -- A typedef of 'float', as a module knows it.

         function cast_Value (Expression : in String) return Long_Float
         is (real_Value_of (Expression, the_Reals, the_Integers, +"", Cast_to'Access).Value);
      begin
         --  The values are those which G++ gives.
         --
         check (real_Value ("(float) 1.0 / 7 * 3.0f")              = Long_Float (One / Seven * Three),  "a cast to float applies to the operand which follows it");
         check (cast_Value ("(real) 1.0 / 7 * 3.0f")               = Long_Float (One / Seven * Three),  "as does a cast to a typedef of float which the module knows");
         check (real_Value ("float (1.0) / 7 * 3.0f")              = Long_Float (One / Seven * Three),  "and one in the form of a call");
         check (real_Value ("static_cast<float> (1.0) / 7 * 3.0f") = Long_Float (One / Seven * Three),  "and one which is named");
         check (real_Value ("(float) (1.0 / 7) * 3.0f")            = Long_Float (Float (D_One / 7.0) * Three),
                "a cast of an expression in brackets rounds it");
         check (real_Value ("(double) 1.0f / 7 * 3.0f")            = D_One / 7.0 * 3.0,                 "a cast to double makes a double");
         check (real_Value ("(int) 2.5 * 2")                       = 4.0,                               "a cast to an integer truncates");
         check (real_Value ("(unsigned long) 7.9 / 2")             = 3.0,                               "and makes an integer, whose division truncates");
         check (real_Value ("(ai_real) 1e-6")                      = 1.0e-6,                            "a cast to a type which is not known leaves the value");
         check (real_Value ("(EPS) * 2")                           = 2.0e-6,                            "a known value in brackets is no cast");
      end;
   end reals;

   finish;
end expressions_Test;
