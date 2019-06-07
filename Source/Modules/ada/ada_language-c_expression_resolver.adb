with
     GMP.discrete,

     ada_Utility,

     ada.Strings.Maps,
     ada.Characters.handling,
     ada.Containers.Vectors;


package body ada_Language.c_expression_Resolver
is
   use ada_Utility,
       ada.Strings,
       ada.Strings.Maps,
       ada.Characters.Handling,
       ada.Containers;


   function "+" (Self : in String) return unbounded_String
     renames to_unbounded_String;



   function resolved_sizeof_Expression (Self            : access Item;
                                        expression_Type : in     unbounded_String;
                                        known_Symbols   : in     symbol_value_maps.Map;
                                        Namespace       : in     unbounded_String) return Natural
   is
      the_type_Text    : unbounded_String := expression_Type;
      array_Multiplier : Positive         := 1;

      required_sizeof_not_defined : exception;

   begin
      replace_All (the_type_Text,  "&", "");    -- Strip references, since they have no impact on size.

      --  Calculate array_Multiplier.
      --
      while Tail (the_type_Text, 1) = "]"
      loop
         delete (the_type_Text,  Length (the_type_Text), Length (the_type_Text));

         declare
            Start           : constant Positive         := Index           (the_type_Text,  "[",        going => Backward);
            array_size_Text : constant unbounded_String := unbounded_Slice (the_type_Text,  Start + 1,  Length (the_type_Text));
            array_Size      : constant Natural          := Natural         (Value (resolved_c_integer_Expression (self,  array_size_Text, known_Symbols, Namespace)));
         begin
            array_Multiplier := array_Multiplier * array_Size;

            delete (the_type_Text,  Start,  Length (the_type_Text));
         end;
      end loop;

      if Tail (the_type_Text, 1) = "*"
      then
         return system.Address'Size / system.storage_Unit * array_Multiplier;
      end if;

      declare
         new_expression_Type : Unbounded_String := expression_Type;
      begin
         ada.strings.Unbounded.Replace_Element (Source => new_expression_Type,
                                                Index  => Index (new_expression_Type, " "),
                                                By     => '_');

         if contains (known_Symbols,  "sizeof_" & new_expression_Type)
         then
            return Natural (Value (Element (known_Symbols,  "sizeof_" & new_expression_Type)));
         else
            log ( "Cannot determine size of " & new_expression_Type);
            log (+"Please add the following line to your swig interface file ('.i'), where <n> is the appropriate size");
            log ( "%constant   int   sizeof_" & new_expression_Type & " = <n>;");

            raise required_sizeof_not_defined;
         end if;
      end;
   end resolved_sizeof_Expression;



   type element_Kind is (Unknown, Operator, Value);

   type an_Element (Kind : element_Kind := Unknown) is
      record
         case Kind is
            when Unknown =>
               null;
            when Operator =>
               Code  : unbounded_String;
            when Value =>
               Value          : discrete.Integer;
               type_Qualifier : unbounded_String := to_unbounded_String ("I");  -- 'I' represents default C Int
         end case;
      end record;

   package element_Vectors is new ada.containers.Vectors (Positive, an_Element);   use element_Vectors;



   function resolved_c_integer_Expression (Self           : access Item;
                                           the_Expression : in     unbounded_String;
                                           known_Symbols  : in     symbol_value_maps.Map;
                                           Namespace      : in     unbounded_String) return discrete.Integer
   is

      procedure resolve_c_integer_Expression_recursive (Expression_pad   : access unbounded_String;
                                                        known_Symbols    : in     symbol_value_maps.Map;
                                                        is_Single        : in     Boolean;
                                                        expression_Value :    out discrete.Integer;
                                                        expression_Type  :    out unbounded_String)
      is

         procedure reduce_unary (the_Vector    : in out element_Vectors.Vector;
                                 for_Operation : in     String)
         is
            Cursor      : element_Vectors.Cursor := First (the_Vector);
            the_Element : an_Element;
         begin
            while has_Element (Cursor)
            loop
               the_Element := Element (Cursor);

               if         the_Element.Kind = Operator
                 and then the_Element.Code = for_Operation
               then
                  if        Cursor                           = First (the_Vector)
                    or else Element (Previous (Cursor)).Kind = Operator
                  then
                     if    for_Operation = "+"
                     then
                        replace_Element (the_Vector, Cursor, (Kind           => Value,
                                                              Value          => Element (Next (Cursor)).Value,
                                                              type_Qualifier => Element (Next (Cursor)).type_Qualifier));
                        delete (the_Vector, to_Index (Next (Cursor)));     -- nb: 'Cursor' is not ambiguous after this delete  (see RM A.18.2 219/2)

                     elsif for_Operation = "-"
                     then
                        replace_Element (the_Vector, Cursor, (Kind           => Value,
                                                              Value          => -Element (Next (Cursor)).Value,
                                                              type_Qualifier => Element (Next (Cursor)).type_Qualifier));
                        delete (the_Vector, to_Index (Next (Cursor)));     -- nb: 'Cursor' is not ambiguous after this delete  (see RM A.18.2 219/2)

                     elsif for_Operation = "!"
                     then
                        replace_Element (the_Vector, Cursor, (Kind           => Value,
                                                              Value          => (if Element (Next (Cursor)).Value = to_Integer (0)
                                                                                 then to_Integer (1)
                                                                                 else to_Integer (0)),
                                                              type_Qualifier => Element (Next (Cursor)).type_Qualifier));
                        delete (the_Vector, to_Index (Next (Cursor)));     -- nb: 'Cursor' is not ambiguous after this delete  (see RM A.18.2 219/2)

                     elsif for_Operation = "~"
                     then
                        declare
                           next_Element       :          an_Element       := Element (Next (Cursor));
                           next_Element_value : constant discrete.Integer := next_Element.Value;

                        begin
                           next_Element.Value := not next_Element_Value;

                           replace_Element (the_Vector, Cursor, (Kind           => Value,
                                                                 Value          => next_Element.Value,
                                                                 type_Qualifier => next_Element.type_Qualifier));
                           delete (the_Vector, to_Index (Next (Cursor)));     -- nb: 'Cursor' is not ambiguous after this delete  (see RM A.18.2 219/2)
                        end;
                     end if;
                  end if;
               end if;

               next (Cursor);
            end loop;

         end reduce_unary;


         procedure reduce (the_Vector    : in out element_Vectors.Vector;
                           for_Operation : in     String)
         is
            Cursor      : element_Vectors.Cursor := First (the_Vector);
            the_Element : an_Element;
         begin
            while has_Element (Cursor)
            loop
               the_Element := Element (Cursor);

               if         the_Element.Kind = Operator
                 and then the_Element.Code = for_Operation
               then
                  declare
                     procedure cull_value_Elements_and_restart_Cursor
                     is
                     begin
                        delete (the_Vector, to_Index (Next     (Cursor)));     -- nb: 'Cursor' is not ambiguous after this delete (see RM A.18.2 219/2)
                        delete (the_Vector, to_Index (Previous (Cursor)));     --     'Cursor' is ambiguous after this delete

                        Cursor := First (the_Vector);                          --      so we restart it.
                     end cull_value_Elements_and_restart_Cursor;

                  begin
                     if    for_Operation = "+"
                     then
                        replace_Element (the_Vector, Cursor, (Kind           => Value,
                                                              Value          => Element (Previous (Cursor)).Value + Element (Next (Cursor)).Value,
                                                              type_Qualifier => Element (Next (Cursor)).type_Qualifier));  -- tbd: determine and use correct C type promotion.
                        cull_value_Elements_and_restart_Cursor;

                     elsif for_Operation = "-"
                     then
                        replace_Element (the_Vector, Cursor, (Kind           => Value,
                                                              Value          => Element (Previous (Cursor)).Value - Element (Next (Cursor)).Value,
                                                              type_Qualifier => Element (Next (Cursor)).type_Qualifier));

                        cull_value_Elements_and_restart_Cursor;

                     elsif for_Operation = "*"
                     then
                        replace_Element (the_Vector, Cursor, (Kind           => Value,
                                                              Value          => Element (Previous (Cursor)).Value * Element (Next (Cursor)).Value,
                                                              type_Qualifier => Element (Next (Cursor)).type_Qualifier));

                        cull_value_Elements_and_restart_Cursor;

                     elsif for_Operation = "|"
                     then

                        replace_Element (the_Vector, Cursor, (Kind           => Value,
                                                              Value          => Element (Previous (Cursor)).Value  or  Element (Next (Cursor)).Value,
                                                              type_Qualifier => Element (Next (Cursor)).type_Qualifier));
                        cull_value_Elements_and_restart_Cursor;

                     elsif for_Operation = "&&"
                     then
                        replace_Element (the_Vector, Cursor, (Kind           => Value,
                                                              Value          => (if     Element (Previous (Cursor)).Value /= to_Integer (0)
                                                                                    and Element (Next     (Cursor)).Value /= to_Integer (0)
                                                                                 then to_Integer (1)
                                                                                 else to_Integer (0)),
                                                              type_Qualifier => Element (Next (Cursor)).type_Qualifier));
                        cull_value_Elements_and_restart_Cursor;
                     elsif for_Operation = "||"
                     then
                        replace_Element (the_Vector, Cursor, (Kind           => Value,
                                                              Value          => (if    Element (Previous (Cursor)).Value /= to_Integer (0)
                                                                                    or Element (Next     (Cursor)).Value /= to_Integer (0)
                                                                                 then to_Integer (1)
                                                                                 else to_Integer (0)),
                                                              type_Qualifier => Element (Next (Cursor)).type_Qualifier));
                        cull_value_Elements_and_restart_Cursor;

                     elsif for_Operation = "&"
                     then
                        replace_Element (the_Vector, Cursor, (Kind           => Value,
                                                              Value          => Element (Previous (Cursor)).Value  and  Element (Next (Cursor)).Value,
                                                              type_Qualifier => Element (Next (Cursor)).type_Qualifier));
                        cull_value_Elements_and_restart_Cursor;

                     elsif for_Operation = "^"
                     then
                        replace_Element (the_Vector, Cursor, (Kind  => Value,
                                                              Value => Element (Previous (Cursor)).Value  xor  Element (Next (Cursor)).Value,
                                                              type_Qualifier => Element (Previous (Cursor)).type_Qualifier));
                        cull_value_Elements_and_restart_Cursor;

                     elsif for_Operation = "/"
                     then
                        replace_Element (the_Vector, Cursor, (Kind  => Value,
                                                              Value => Element (Previous (Cursor)).Value / Element (Next (Cursor)).Value,
                                                              type_Qualifier => Element (Next (Cursor)).type_Qualifier));

                        cull_value_Elements_and_restart_Cursor;

                     elsif for_Operation = "<<"
                     then
                        replace_Element (the_Vector, Cursor, (Kind  => Value,
                                                              Value => Element (Previous (Cursor)).Value  *  to_Integer (2) ** Value (Element (Next (Cursor)).Value),
                                                              type_Qualifier => Element (Previous (Cursor)).type_Qualifier));

                        cull_value_Elements_and_restart_Cursor;

                     elsif for_Operation = ">>"
                     then
                        replace_Element (the_Vector, Cursor, (Kind  => Value,
                                                              Value => Element (Previous (Cursor)).Value  /  to_Integer (2) ** Value (Element (Next (Cursor)).Value),
                                                              type_Qualifier => Element (Previous (Cursor)).type_Qualifier));

                        cull_value_Elements_and_restart_Cursor;

                     else
                        next (Cursor);
                     end if;
                  end;

               else
                  next (Cursor);
               end if;

            end loop;
         end reduce;


         function Result_of (the_Vector : access element_Vectors.Vector) return an_Element
         is
            Pad : element_Vectors.Vector renames the_Vector.all;
         begin
            reduce_unary (Pad, for_operation => "!");    -- nb: These must be done in C's order of precedence (todo: check the order here is correct!)
            reduce_unary (Pad, for_operation => "+");    -- nb: These must be done in C's order of precedence (todo: check the order here is correct!)
            reduce_unary (Pad, for_operation => "-");
            reduce_unary (Pad, for_operation => "~");

            reduce       (Pad, for_operation => "<<");
            reduce       (Pad, for_operation => ">>");

            reduce       (Pad, for_operation => "|");
            reduce       (Pad, for_operation => "&");
            reduce       (Pad, for_operation => "&&");
            reduce       (Pad, for_operation => "||");
            reduce       (Pad, for_operation => "^");

            reduce       (Pad, for_operation => "*");
            reduce       (Pad, for_operation => "/");
            reduce       (Pad, for_operation => "+");
            reduce       (Pad, for_operation => "-");

            if Length (Pad) = 1
            then
               return Element (First (Pad));
            else
               log (+"C expression evaluation failed !");
               raise Constraint_Error;
            end if;
         end Result_of;

         the_Elements : aliased element_Vectors.Vector;

      begin
--           log ("'resolved_c_integer_Expression_recursive'   ~   Expression_pad: '" & Expression_pad.all & "'");

         while Length (Expression_pad.all) > 0
         loop
--              log ("Self: '" & Expression_pad.all & "'");

            if Element (Expression_pad.all, 1) = ' '
            then
               delete (Expression_pad.all,  1, 1);

            elsif      Length (Expression_pad.all)                 >= 3
              and then to_Upper (Slice (Expression_pad.all, 1, 3))  = "ULL"
            then
               delete (Expression_pad.all,  1, 3);
               declare
                  Prior : an_Element := last_Element (the_Elements);
               begin
                  Prior.type_Qualifier := to_unbounded_String ("ULL");
                  replace_Element (the_Elements, Last (the_Elements), Prior);
               end;

            elsif      Length (Expression_pad.all)                 >= 2
              and then to_Upper (Slice (Expression_pad.all, 1, 2))  = "UL"
            then
               delete (Expression_pad.all,  1, 2);
               declare
                  Prior : an_Element := last_Element (the_Elements);
               begin
                  Prior.type_Qualifier := to_unbounded_String ("UL");
                  replace_Element (the_Elements, Last (the_Elements), Prior);
               end;

            elsif      not is_Single
              and then     to_Upper (Element (Expression_pad.all, 1)) = 'L'
            then
               delete (Expression_pad.all,  1, 1);
               declare
                  Prior : an_Element := last_Element (the_Elements);
               begin
                  Prior.type_Qualifier := to_unbounded_String ("L");
                  replace_Element (the_Elements, Last (the_Elements), Prior);
               end;

            elsif      not is_Single
              and then     to_Upper (Element (Expression_pad.all, 1)) = 'U'
            then
               delete (Expression_pad.all,  1, 1);
               declare
                  Prior : an_Element := last_Element (the_Elements);
               begin
                  Prior.type_Qualifier := to_unbounded_String ("U");
                  replace_Element (the_Elements, Last (the_Elements), Prior);
               end;

            elsif Element (Expression_pad.all, 1) = '('
            then
               delete (Expression_pad.all,  1, 1);
               declare
                  expression_Value : discrete.Integer;
                  expression_Type  : unbounded_String;
               begin
                  resolve_c_integer_Expression_recursive (Expression_pad, known_Symbols, is_Single, expression_Value, expression_Type);
                  append (the_Elements,  (kind           => Value,
                                          value          => expression_Value,
                                          type_Qualifier => expression_Type));
               end;

            elsif Element (Expression_pad.all, 1) = '!'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  (kind  => Operator,
                                       code  => +"!"));

            elsif Element (Expression_pad.all, 1) = '+'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  (kind  => Operator,
                                       code  => +"+"));

            elsif Element (Expression_pad.all, 1) = '-'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  (kind  => Operator,
                                       code  => +"-"));

            elsif Element (Expression_pad.all, 1) = '~'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  (kind  => Operator,
                                       code  => +"~"));


            elsif Element (Expression_pad.all, 1) = '*'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  (kind  => Operator,
                                       code  => +"*"));


            elsif Element (Expression_pad.all, 1) = '/'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  (kind  => Operator,
                                       code  => +"/"));

            elsif Length (Expression_pad.all) >= 2 and then Slice (Expression_pad.all, 1, 2) = "||"
            then
               delete (Expression_pad.all,  1, 2);
               append (the_Elements,  (kind  => Operator,
                                       code  => +"||"));

            elsif Element (Expression_pad.all, 1) = '|'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  (kind  => Operator,
                                       code  => +"|"));

            elsif Length (Expression_pad.all) >= 2 and then Slice (Expression_pad.all, 1, 2) = "&&"
            then
               delete (Expression_pad.all,  1, 2);
               append (the_Elements,  (kind  => Operator,
                                       code  => +"&&"));

            elsif Element (Expression_pad.all, 1) = '&'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  (kind  => Operator,
                                       code  => +"&"));

            elsif Element (Expression_pad.all, 1) = '^'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  (kind  => Operator,
                                       code  => +"^"));

            elsif      Length (Expression_pad.all)       >= 7
              and then Slice  (Expression_pad.all, 1, 7)  = "sizeof("
            then
               delete (Expression_pad.all,  1, 7);
               declare
                  Last         : constant Positive         := Index (Expression_pad.all, ")");
                  sizeof_Slice : constant unbounded_String := unbounded_Slice (Expression_pad.all,  1,  Last - 1);
               begin
                  append (the_Elements,  (kind  => Value,
                                          value => to_Integer (Long_Long_Integer (resolved_sizeof_Expression (Self,
                                                                                                              sizeof_Slice,
                                                                                                              known_Symbols,
                                                                                                              Namespace))),
                                          others => <>));
                  delete (Expression_pad.all,  1, Last);
               end;

            elsif      Length (Expression_pad.all)       >= 2
              and then Slice  (Expression_pad.all, 1, 2)  = "<<"
            then
               delete (Expression_pad.all,  1, 2);
               append (the_Elements,  (kind  => Operator,
                                       code  => +"<<"));

            elsif      Length (Expression_pad.all)       >= 2
              and then Slice  (Expression_pad.all, 1, 2)  = ">>"
            then
               delete (Expression_pad.all,  1, 2);
               append (the_Elements,  (kind  => Operator,
                                       code  => +">>"));

            elsif Element (Expression_pad.all, 1) = ')'
            then
               delete (Expression_pad.all,  1, 1);
               exit;                                                  -- nb: exit loop to allow recursion to end.

            elsif      Length (Expression_pad.all)       >= 2         -- handle hex numbers
              and then Slice  (Expression_pad.all, 1, 2)  = "0x"      --
            then
               declare
                  First : Natural;
                  Last  : Natural;
               begin
                  find_Token (Expression_pad.all, to_Set ("0123456789xABCDEFabcdef"), Inside,  First, Last);

                  append (the_Elements,  (kind  => Value,
                                          value => to_Int (Slice (Expression_pad.all,  First, Last)),
                                          others => <>));
                  delete (Expression_pad.all,  First, Last);
               end;

            elsif Slice (Expression_pad.all,  1, 1) (1) in '0' .. '9'
            then   -- Handle decimal and octal numbers.
               declare
                  First : Natural;
                  Last  : Natural;
               begin
                  find_Token (Expression_pad.all, to_Set ("0123456789"), Inside,  First, Last);

                  append (the_Elements,  (kind  => Value,
                                          value => to_Int (Slice (Expression_pad.all,  First, Last)),
                                          others => <>));
                  delete (Expression_pad.all,  First, Last);
               end;

            elsif     Length  (Expression_pad.all)    = 1
              or else Element (Expression_pad.all, 2) = ' '          -- nb: This disallows symbol identifiers of length 1.
            then
               begin
                  if Element (Expression_pad.all, 1) in '0' .. '9'
                  then
                     append (the_Elements,  (kind  => Value,
                                             value => to_Int (Expression_pad.all),
                                             others => <>));
                  else
                     append (the_Elements,  (kind  => Value,
                                             value => to_Integer (Character'Pos (Element (Expression_pad.all, 1))),
                                             others => <>));
                  end if;

                  delete (Expression_pad.all,  1, 1);
               end;

            else  -- Should be a symbol identifier.
               declare
                  First      : Natural;
                  Last       : Natural;
                  the_Symbol : unbounded_String;
               begin
                  find_Token (Expression_pad.all, to_Set ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789"), Inside,  First, Last);
                  the_Symbol := unbounded_Slice (Expression_pad.all,  First, Last);
                  begin
                     append (the_Elements,  (kind  => Value,
                                             value => Element (known_Symbols,  Namespace & the_Symbol),
                                             others => <>));
                  exception
                     when Constraint_Error => -- Key not found, so try without namespace.
                        append (the_Elements,  (kind  => Value,
                                                value => Element (known_Symbols,  the_Symbol),
                                                others => <>));
                  end;
                  delete (Expression_pad.all,  First, Last);
               end;
            end if;
         end loop;

         declare
            the_Result : constant an_Element := Result_of (the_Elements'Access);
         begin
            expression_Value := the_Result.Value;
            expression_Type  := the_Result.type_Qualifier;
         end;
      end resolve_c_integer_Expression_recursive;


      the_expression_Pad   : aliased  unbounded_String := the_Expression;
      is_Single            : constant Boolean          := Length (the_Expression) = 1;

      the_expression_Value :          discrete.Integer;
      the_expression_Type  :          unbounded_String;

   begin
      resolve_c_integer_Expression_recursive (the_expression_Pad'Access, known_Symbols,
                                              is_Single,
                                              the_expression_Value, the_expression_Type);
      return the_expression_Value;
   end resolved_c_integer_Expression;


end ada_Language.c_expression_Resolver;
