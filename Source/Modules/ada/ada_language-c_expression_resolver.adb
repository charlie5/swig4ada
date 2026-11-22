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
      --  tell from the call of a function, as it knows no types. The name is removed here, where they are known.
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
                 and then is_a_Type (Slice (Pad, From, Last))
               then
                  delete (Pad, From, After - 1);
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
