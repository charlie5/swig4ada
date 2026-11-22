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
      (+"sizeof(double) * 2",                                    16)
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
   end names;

   refusals :
   begin
      check (is_Refused ("UNKNOWN + 1"),                                          "a name which is not known is refused");
      check (is_Refused ("x"),                                                    "as is a lone letter, which is a name and no character");
      check (is_Refused ("4 <=> 2"),                                              "a three way comparison is refused");
      check (is_Refused ("1 ? 2 : 3"),                                            "as is a conditional expression");
      check (is_Refused ("1.5 + 2"),                                              "and a real number");
   end refusals;

   finish;
end expressions_Test;
