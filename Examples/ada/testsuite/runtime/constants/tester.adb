with
     constants.Binding,
     constants.Limits,
     constants.Packet,

     swig,
     interfaces.C.Strings,

     Checks;


procedure Tester
--
--  Constants made by '#define' and by 'const', and enumerations:
--  plain, anonymous, used as flags, scoped, of one byte and nested in a class.
--
is
   use constants,
       constants.Binding,
       interfaces.C,
       Checks;

   use type swig.bool,
            Limits.Kind;

   True : constant swig.bool := swig.bool'Val (1);

begin
   defined_constants :
   begin
      check (COUNT = 12,                                            "an integer");
      check (SCALE = 2.5,                                           "a real number");
      check (String'(Strings.Value (NAME)) = "constants",           "a string");
      check (LETTER = 'x',                                          "a character");
      check (the_FLAGS = 19 and SHIFTED = 64,                       "expressions of bits");
      check (NEGATIVE = -7,                                         "a negative number");
      check (DERIVED = 25,                                          "an expression of another constant");
      check (limit = 100,                                           "a 'const int', which has no symbol in C++");
      check (epsilon = 0.25,                                        "a 'const double'");
   end defined_constants;

   plain_enumerations :
   declare
      the_Level : aliased Level := Low;
   begin
      check (level_number (Low) = -1 and level_number (Top) = 11,   "literals with a negative value, and one which follows a value");
      check (raise_level (Middle) = High,                           "an enumeration is passed and returned");

      set_level (the_Level'unchecked_Access, High);
      check (the_Level = High,                                      "and set through a pointer");

      top_level (the_Level'unchecked_Access);
      check (the_Level = Top,                                       "and through a reference");

      check (anonymous_five'Enum_Rep = 5,                           "an enumeration with no name");
   end plain_enumerations;

   flags :
   begin
      check (can (the_All, Write) = True,                           "a literal whose value is an expression of the others");
      check (can (Read,    Write) /= True,                          "literals used as flags");
   end flags;

   scoped_enumerations :
   begin
      check (mode_number (Automatic) = 7,                           "a literal of an 'enum class' is passed");
      check (next_mode (Off) = On,                                  "and returned");
   end scoped_enumerations;

   small_enumerations :
   declare
      the_Packet : aliased Packet.Item;
   begin
      check (small_number (Huge) = 200,                             "an enumeration of one byte is passed");

      packet_fill (the_Packet'unchecked_Access);
      check (the_Packet.first = Huge and the_Packet.second = Tiny,  "members of an enumeration of one byte");
      check (the_Packet.length = 5,                                 "and the member which follows them");

      the_Packet.second := Huge;
      check (packet_sum (the_Packet'unchecked_Access) = 405,        "C++ reads what Ada wrote to one");
   end small_enumerations;

   nested :
   begin
      check (Limits.clamp (100) = 64,                               "a static function of a class");
      check (Limits.kind_of (100) = Limits.Hard,                    "which returns an enumeration of the class");
      check (kind_number (Limits.Hard) = 3,                         "whose literal has a value of its own");
   end nested;

   written_constants :
   begin
      check (String'(Strings.Value (QUOTED)) = "a ""quoted"" word",                   "a string which holds quotes");
      check (String'(Strings.Value (QUOTED)) = Strings.Value (quoted_text),           "is the string which C++ has");

      check (String'(Strings.Value (TABBED)) = "one" & Character'Val (9) & "two",     "a string which holds an escape");
      check (String'(Strings.Value (TABBED)) = Strings.Value (tabbed_text),           "is the string which C++ has");

      check (BINARY = 10,                                           "a binary number");
      check (PACKED = 16#6162#,                                     "an expression of characters and shifts");
      check (LETTER_SUM = 67,                                       "a character which is added to");
      check (COMPARED = True,                                       "a comparison");
      check (REMAINDER = 2,                                         "a remainder");

      check (IN_ORDER    = 9  and c_in_order    = 9,                "operators of one level are applied from the left, as C applies them");
      check (SUM_SHIFTED = 24 and c_sum_shifted = 24,               "a sum is made before it is shifted");
      check (AND_THEN_OR = 10 and c_and_then_or = 10,               "'and' binds more tightly than 'or'");
      check (TWICE_MINUS = 5  and c_twice_minus = 5,                "a sign is applied to a sign");

      check (OCTAL       = 493 and c_octal     = 493,               "a number which begins with a zero is octal");
      check (OCTAL_SUM   = 9   and c_octal_sum = 9,                 "within an expression too");
      check (Octals'Enum_Rep (Eighth) = 8 and octal_mark = 8,       "and as the value of an enumeration");
      check (Octals'Enum_Rep (Ninth) = 9 and Octals'Enum_Rep (Sixteenth) = 16,   "whose next literal follows it");
   end written_constants;

   real_constants :
   begin
      check (CAST_SEVENTH   = c_cast_seventh,                       "an expression of 'float' with a cast is the 'float' which C++ has");
      check (DOUBLE_SEVENTH = c_double_seventh,                     "and one of 'double' the 'double'");
      check (real_more      = c_real_more,                          "a constant of a typedef of 'float' which names another");
      check (float_seventh  = c_float_seventh,                      "a 'float' worked out in 'float'");
      check (interfaces.C.C_float (DOUBLE_SEVENTH) /= c_cast_seventh,
             "which is not the 'double' rounded once");
   end real_constants;

   integer_casts :
   begin
      check (CAST_TRUNCATED = 4 and CAST_TRUNCATED = c_cast_truncated,                      "a real number cast to an integer is truncated");
      check (CAST_ALL_ONES = 4294967295 and CAST_ALL_ONES = c_cast_all_ones,                "-1 cast to 'unsigned' is the largest");
      check (int (CAST_BYTE) = 44 and int (CAST_BYTE) = c_cast_byte,                       "a cast to 'unsigned char' is modulo its size");
      check (int (CAST_SIGNED_BYTE) = -56 and int (CAST_SIGNED_BYTE) = c_cast_signed_byte, "and one to 'signed char' within its range");
      check (named_all_ones = 4294967295 and named_all_ones = c_named_all_ones,            "a cast which is named");
      check (int (call_short) = 4465 and int (call_short) = c_call_short,                 "and one in the form of a call");
      check (call_unsigned = 4294967295 and call_unsigned = c_call_unsigned,               "of a type of two words");
      check (int (call_byte) = 44 and int (call_byte) = c_call_byte,                      "a cast to a typedef of an integer type");
      check (byte_sum = 46 and byte_sum = c_cast_byte_sum,                                "in brackets too");

      --  A '#define' of a cast is of the type of the cast, where its operand has a sign ('Size is that of no named number).
      --
      check (CAST_ALL_ONES'Size    = interfaces.C.unsigned'Size,                         "a '#define' of a cast is of its type");
      check (CAST_SHORT_MINUS = -1 and CAST_SHORT_MINUS = c_cast_short_minus
             and CAST_SHORT_MINUS'Size = interfaces.C.short'Size,                         "and with a minus");
      check (CAST_LONG_NOT = -1    and CAST_LONG_NOT = c_cast_long_not
             and CAST_LONG_NOT'Size    = interfaces.C.long'Size,                          "and with a complement");
      check (CAST_NOT_ZERO = 1     and CAST_NOT_ZERO = c_cast_not_zero
             and CAST_NOT_ZERO'Size    = interfaces.C.unsigned'Size,                      "and with a negation");
   end integer_casts;

   character_enumerations :
   begin
      check (mark_number (Comma) = 44 and mark_number (Capital) = 65,   "an enumeration whose values are characters");
      check (mark_number (Newline) = 10,                            "one of which is an escape");
      check (mark_number (After) = 66,                              "a literal which follows a character");
      check (mark_number (Escaped) = 68,                            "and one which is an expression of a character");
      check (mark_of (',') = Comma and mark_of ('B') = After,       "C++ returns the literal of a character");
   end character_enumerations;

   finish;
end Tester;
