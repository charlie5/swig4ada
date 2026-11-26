with
     c_Expressions;


package body ada_Language.c_expression_Resolver
is

   function resolved_c_integer_Expression (Self            : access Item;
                                           the_Expression  : in     unbounded_String;
                                           known_Symbols   : in     ada_Language.symbol_value_maps.Map;
                                           Namespace       : in     unbounded_String) return gmp.discrete.Integer
   is
      --  A type of the module which is followed by brackets is a cast ('mytype (10)'), which the evaluator cannot
      --  tell from the call of a function, as it knows no types but the standard ones of C, which are left to it
      --  ('short (70000)', 'unsigned int(-1)'). Where it is a typedef of a standard type ('byte_t', of 'unsigned
      --  char'), it is written as a cast to that type in brackets ('(unsigned char) (300)'), which the evaluator
      --  applies; a cast in brackets to a typedef ('(byte_t) 301') is written so too. Any other type is removed.
      --  (Until 2026-11-26 every such type was removed, and 'short (70000)' was 70000.)
      --
      use type c_Type.a_c_type_Kind;

      Pad  : unbounded_String := the_Expression;
      From : Positive         := 1;

      function is_name_Character (the_Character : in Character) return Boolean
      is (the_Character in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | ':');

      function is_a_Type (Name : in String) return Boolean
      is
         function is_Known (Key : in unbounded_String) return Boolean
         is (         Self.swig_type_Map_of_c_type.contains (Key)
             and then Self.swig_type_Map_of_c_type.Element (Key).c_type_Kind in c_Type.Typedef | c_Type.standard_c_Type | c_Type.Enum);
      begin
         return is_Known (+Name) or else is_Known (Namespace & Name);
      end is_a_Type;

      function is_a_Standard (Name : in String) return Boolean
      is (         Self.swig_type_Map_of_c_type.contains (+Name)
          and then Self.swig_type_Map_of_c_type.Element (+Name).c_type_Kind = c_Type.standard_c_Type);

      function standard_Name (Name : in String) return String
      --
      --  The name of the standard type of C which the type of the module so named stands for, or "".
      --
      is
         Key : constant unbounded_String := (if Self.swig_type_Map_of_c_type.contains (+Name) then +Name else Namespace & Name);
      begin
         if not Self.swig_type_Map_of_c_type.contains (Key)
         then
            return "";
         end if;

         declare
            the_Type : constant c_Type.view := Self.swig_type_Map_of_c_type.Element (Key);
            the_Base : constant c_Type.view := (if the_Type.c_type_Kind = c_Type.Typedef then the_Type.ultimate_base_Type else the_Type);
         begin
            return (if         the_Base /= null
                      and then the_Base.c_type_Kind = c_Type.standard_c_Type
                    then to_String (the_Base.Name)
                    else "");
         end;
      end standard_Name;

   begin
      while From <= Length (Pad)
      loop
         if         Element (Pad, From) in 'a' .. 'z' | 'A' .. 'Z' | '_'
           and then (From = 1 or else not is_name_Character (Element (Pad, From - 1)))
         then
            declare
               Last  : Positive := From;
               After : Natural;
            begin
               while Last < Length (Pad) and then is_name_Character (Element (Pad, Last + 1))
               loop
                  Last := Last + 1;
               end loop;

               After := Last + 1;

               while After <= Length (Pad) and then Element (Pad, After) = ' '
               loop
                  After := After + 1;
               end loop;

               if         After <= Length (Pad)
                 and then Element (Pad, After) = '('
                 and then is_a_Standard (Slice (Pad, From, Last))
               then   -- Which the evaluator applies itself, by its whole name ('unsigned int(-1)', whose 'int' was taken
                  From := Last + 1;     -- for a type of its own until later on 2026-11-26, and the value was -1).

               elsif      After <= Length (Pad)
                 and then Element (Pad, After) = '('
                 and then is_a_Type (Slice (Pad, From, Last))
               then
                  declare
                     Standard : constant String := standard_Name (Slice (Pad, From, Last));
                  begin
                     if Standard = ""
                     then
                        delete (Pad, From, After - 1);
                     else
                        replace_Slice (Pad, From, After - 1, "(" & Standard & ") ");
                        From := From + Standard'Length + 3;
                     end if;
                  end;

               elsif      From > 1                                                                         -- A typedef in brackets,
                 and then Element (Pad, From - 1) = '('                                                    -- which the evaluator
                 and then After <= Length (Pad)                                                            -- does not know.
                 and then Element (Pad, After) = ')'
                 and then Self.swig_type_Map_of_c_type.contains (+Slice (Pad, From, Last))
                 and then Self.swig_type_Map_of_c_type.Element (+Slice (Pad, From, Last)).c_type_Kind = c_Type.Typedef
                 and then standard_Name (Slice (Pad, From, Last)) /= ""
               then
                  declare
                     Standard : constant String := standard_Name (Slice (Pad, From, Last));
                  begin
                     replace_Slice (Pad, From, Last, Standard);
                     From := From + Standard'Length;
                  end;
               else
                  From := Last + 1;
               end if;
            end;
         else
            From := From + 1;
         end if;
      end loop;

      return c_Expressions.Value_of (Pad, known_Symbols, Namespace);
   end resolved_c_integer_Expression;



   function resolved_sizeof_Expression (Self            : access Item;
                                        expression_Type : in     unbounded_String;
                                        known_Symbols   : in     symbol_value_maps.Map;
                                        Namespace       : in     unbounded_String) return Natural
   is
      pragma Unreferenced (Self);
   begin
      return c_Expressions.sizeof_Value (expression_Type, known_Symbols, Namespace);
   end resolved_sizeof_Expression;

end ada_Language.c_expression_Resolver;
