with
     ada_Utility,
     Logger,

     ada.Strings.Maps,
     ada.Characters.handling,
     ada.Containers.Vectors,
     interfaces.C,
     System;


package body c_Expressions
is
   use ada_Utility,
       Logger,
       ada.Strings,
       ada.Strings.Maps,
       ada.Characters.Handling,
       ada.Containers;


   use symbol_value_Maps;

   package C renames interfaces.C;

   function "+" (Self : in String) return unbounded_String
     renames to_unbounded_String;


   ------------------------------
   --- sizeof_Value
   --

   function sizeof_Value (expression_Type : in unbounded_String;
                          known_Symbols   : in symbol_value_Maps.Map;
                          Namespace       : in unbounded_String) return Natural
   is
      the_type_Text    : unbounded_String := expression_Type;
      array_Multiplier : Positive         := 1;

      required_sizeof_not_defined : exception;


      function standard_c_type_Size (the_Type : in String) return Natural
      --
      --  The size of a standard C type, or 0 when 'the_Type' is not one. The size is that of the machine on
      --  which the binding is generated, which is taken to be the machine on which the binding is used.
      --
      is
         Unit : constant := C.char'Size;
      begin
         if    the_Type in "char"  | "signed char" | "unsigned char" | "bool"                                 then   return 1;
         elsif the_Type in "short" | "signed short" | "unsigned short" | "short int" | "unsigned short int"   then   return C.short'Size / Unit;
         elsif the_Type in "int"   | "signed int"   | "unsigned int"   | "unsigned"  | "signed"               then   return C.int'Size   / Unit;
         elsif the_Type in "long"  | "signed long"  | "unsigned long"  | "long int"  | "unsigned long int"    then   return C.long'Size  / Unit;
         elsif the_Type in "long long" | "unsigned long long" | "long long int" | "unsigned long long int"    then   return long_long_Integer'Size / Unit;
         elsif the_Type =  "float"                                                                            then   return C.C_float'Size     / Unit;
         elsif the_Type =  "double"                                                                           then   return C.double'Size      / Unit;
         elsif the_Type =  "long double"                                                                      then   return C.long_double'Size / Unit;
         elsif the_Type =  "wchar_t"                                                                          then   return C.wchar_t'Size     / Unit;
         elsif the_Type =  "size_t"                                                                           then   return C.size_t'Size      / Unit;
         else                                                                                                        return 0;
         end if;
      end standard_c_type_Size;

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
            array_Size      : constant Natural          := Natural         (Value (Value_of (array_size_Text, known_Symbols, Namespace)));
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
         new_expression_Type :          Unbounded_String := expression_Type;
         space_Index         : constant Integer          := Index (new_expression_Type, " ");
      begin
         if space_Index > 0
         then
            ada.strings.Unbounded.Replace_Element (Source => new_expression_Type,
                                                   Index  => space_Index,
                                                   By     => '_');
         end if;

         if contains (known_Symbols,  "sizeof_" & new_expression_Type)
         then
            return Natural (Value (Element (known_Symbols,  "sizeof_" & new_expression_Type)));

         elsif standard_c_type_Size (to_String (the_type_Text)) /= 0
         then
            return standard_c_type_Size (to_String (the_type_Text)) * array_Multiplier;
         else
            log (+"Cannot determine size of " & new_expression_Type);
            log ("Please add the following line to your swig interface file ('.i'), where <n> is the appropriate size");
            log ( "%constant   int   sizeof_" & new_expression_Type & " = <n>;");

            raise required_sizeof_not_defined with "sizeof_" & to_String (new_expression_Type);
         end if;
      end;
   end sizeof_Value;




   ---------------------------------
   --- Value_of
   --

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





   --  The value of an expression is worked out from its elements, which are values and operators in the order in which
   --  they are written. An expression within brackets has been worked out already, and is one value here.
   --
   --  The operators are applied as C applies them: those of one sign first (which bind most tightly, and from the right),
   --  and then each level of those of two operands in turn, from the left within a level.
   --

   function is_Unary (the_Vector : in element_Vectors.Vector;   Index : in Positive) return Boolean
   --
   --  True for an operator which has no value to its left, and so applies to the value which follows it.
   --
   is
      the_Element : constant an_Element := the_Vector (Index);
   begin
      return          the_Element.Kind = Operator
             and then (the_Element.Code in +"!" | +"~" | +"+" | +"-")
             and then (       Index = the_Vector.first_Index
                       or else the_Vector (Index - 1).Kind = Operator);
   end is_Unary;



   procedure reduce_Unaries (the_Vector : in out element_Vectors.Vector)
   is
      Index : Natural := the_Vector.last_Index;
   begin
      while Index >= the_Vector.first_Index     -- From the right, so that '-~1' applies '~' first.
      loop
         if         is_Unary (the_Vector, Index)
           and then Index < the_Vector.last_Index
           and then the_Vector (Index + 1).Kind = Value
         then
            declare
               the_Code  : constant String     := to_String (the_Vector (Index).Code);
               the_Value : constant an_Element := the_Vector (Index + 1);
            begin
               the_Vector.replace_Element (Index, (Kind           => Value,
                                                   Value          => (if    the_Code = "-" then -the_Value.Value
                                                                      elsif the_Code = "~" then not the_Value.Value
                                                                      elsif the_Code = "!" then (if the_Value.Value = to_Integer (0) then to_Integer (1)
                                                                                                                                     else to_Integer (0))
                                                                      else                      the_Value.Value),
                                                   type_Qualifier => the_Value.type_Qualifier));
               the_Vector.delete (Index + 1);
            end;
         end if;

         Index := Index - 1;
      end loop;
   end reduce_Unaries;



   function Applied (the_Code : in String;   Left, Right : in an_Element) return an_Element
   --
   --  The value of an operator of two operands.
   --
   is
      function as_Truth (the_Truth : in Boolean) return discrete.Integer
      is (if the_Truth then to_Integer (1) else to_Integer (0));

      L    : discrete.Integer renames Left .Value;
      R    : discrete.Integer renames Right.Value;
      Zero : constant discrete.Integer := to_Integer (0);
   begin
      if    the_Code = "*"  then return (Value, L * R,                   Right.type_Qualifier);     -- tbd: determine and use correct C type promotion.
      elsif the_Code = "/"  then return (Value, L / R,                   Right.type_Qualifier);
      elsif the_Code = "%"  then return (Value, L - (L / R) * R,         Right.type_Qualifier);     -- The remainder of a division which rounds towards zero, as '/' does.
      elsif the_Code = "+"  then return (Value, L + R,                   Right.type_Qualifier);
      elsif the_Code = "-"  then return (Value, L - R,                   Right.type_Qualifier);
      elsif the_Code = "<<" then return (Value, L * to_Integer (2) ** discrete.Value (R),   Left.type_Qualifier);
      elsif the_Code = ">>" then return (Value, div (L,                  to_Integer (2) ** discrete.Value (R),     -- A right shift rounds down, where '/' rounds
                                                     Round => Down),     Left.type_Qualifier);                     -- towards zero ('-9 >> 1' is -5).
      elsif the_Code = "<"  then return (Value, as_Truth (L < R),        null_unbounded_String);     -- A comparison is 1 where it holds, and 0 where it does not.
      elsif the_Code = ">"  then return (Value, as_Truth (R < L),        null_unbounded_String);
      elsif the_Code = "<=" then return (Value, as_Truth (not (R < L)),  null_unbounded_String);
      elsif the_Code = ">=" then return (Value, as_Truth (not (L < R)),  null_unbounded_String);
      elsif the_Code = "==" then return (Value, as_Truth (L = R),        null_unbounded_String);
      elsif the_Code = "!=" then return (Value, as_Truth (not (L = R)),  null_unbounded_String);
      elsif the_Code = "&"  then return (Value, L and R,                 Right.type_Qualifier);
      elsif the_Code = "^"  then return (Value, L xor R,                 Left .type_Qualifier);
      elsif the_Code = "|"  then return (Value, L or  R,                 Right.type_Qualifier);
      elsif the_Code = "&&" then return (Value, as_Truth (L /= Zero and R /= Zero),   Right.type_Qualifier);
      elsif the_Code = "||" then return (Value, as_Truth (L /= Zero or  R /= Zero),   Right.type_Qualifier);
      else
         raise Constraint_Error with "'" & the_Code & "' is not an operator which is worked out.";
      end if;
   end Applied;



   type Level is array (Positive range <>) of unbounded_String;     -- The operators of one level of precedence.

   procedure reduce (the_Vector : in out element_Vectors.Vector;   the_Level : in Level)
   --
   --  Applies the operators of one level of precedence, from the left.
   --
   is
      Index : Positive := the_Vector.first_Index;
   begin
      while Index <= the_Vector.last_Index
      loop
         if         the_Vector (Index).Kind = Operator
           and then (for some Each of the_Level => the_Vector (Index).Code = Each)
           and then Index > the_Vector.first_Index
           and then Index < the_Vector.last_Index
           and then the_Vector (Index - 1).Kind = Value
           and then the_Vector (Index + 1).Kind = Value
         then
            the_Vector.replace_Element (Index - 1, Applied (to_String (the_Vector (Index).Code),
                                                            Left  => the_Vector (Index - 1),
                                                            Right => the_Vector (Index + 1)));
            the_Vector.delete (Index, Count => 2);     -- The operator and its right operand: the next operator is now at 'Index'.
         else
            Index := Index + 1;
         end if;
      end loop;
   end reduce;



   function Result_of (the_Vector : access element_Vectors.Vector) return an_Element
   is
      Pad : element_Vectors.Vector renames the_Vector.all;
   begin
      reduce_Unaries (Pad);

      reduce (Pad, [+"*",  +"/",  +"%"]);     -- In C's order of precedence.
      reduce (Pad, [+"+",  +"-"]);
      reduce (Pad, [+"<<", +">>"]);
      reduce (Pad, [+"<",  +"<=", +">", +">="]);
      reduce (Pad, [+"==", +"!="]);
      reduce (Pad, [1 => +"&"]);
      reduce (Pad, [1 => +"^"]);
      reduce (Pad, [1 => +"|"]);
      reduce (Pad, [1 => +"&&"]);
      reduce (Pad, [1 => +"||"]);

      if Length (Pad) = 1
      then
         return Element (First (Pad));
      else
         dlog (+"C expression evaluation failed !");
         raise Constraint_Error with "C expression evaluation failed.";
      end if;
   end Result_of;





   function without_Casts (the_Expression : in String;
                           known_Symbols  : in symbol_value_Maps.Map;
                           Namespace      : in unbounded_String) return String
   --
   --  The expression less its casts, which do not change the value of a constant that is worked out here:
   --  '(mytype) 10', 'static_cast< mytype >(10)' and 'int (10)' are each '10' (the last within its brackets).
   --  A name which is followed by brackets is taken for a cast only where it is a standard type: 'factorial (5)'
   --  is a call, whose value is not known, and stays as it is.
   --
   is
      type Names is array (Positive range <>) of unbounded_String;

      named_Casts    : constant Names := [+"static_cast", +"reinterpret_cast", +"const_cast"];
      standard_Types : constant Names := [+"unsigned long long", +"unsigned long", +"unsigned short", +"unsigned char",     -- The longer names first.
                                          +"unsigned int",       +"long long",     +"signed char",    +"long double",
                                          +"unsigned",           +"long",          +"short",          +"int",
                                          +"char",               +"bool",          +"size_t",         +"double",
                                          +"float"];

      Pad : unbounded_String := +the_Expression;

      function is_name_Character (the_Character : in Character) return Boolean
      is (the_Character in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_');

      function next_Significant (From : in Positive) return Natural
      --
      --  The place of the first character at or after 'From' which is no space, or 0.
      --
      is
      begin
         for Each in From .. Length (Pad)
         loop
            if Element (Pad, Each) /= ' '
            then
               return Each;
            end if;
         end loop;

         return 0;
      end next_Significant;

      function follows_sizeof (Place : in Positive) return Boolean
      --
      --  The bracket at 'Place' is that of 'sizeof', whose operand is a type and no cast.
      --
      is
         Before : Natural := Place - 1;
      begin
         while Before >= 1 and then Element (Pad, Before) = ' '
         loop
            Before := Before - 1;
         end loop;

         return Before >= 6 and then Slice (Pad, Before - 5, Before) = "sizeof";
      end follows_sizeof;

   begin
      --  The named casts: the name and its type are removed, which leaves the operand in its brackets.
      --
      for Each of named_Casts
      loop
         loop
            declare
               First : constant Natural := Index (Pad, to_String (Each));
               Open  :          Natural;
               Depth :          Natural := 0;
               Close :          Natural := 0;
            begin
               exit when First = 0;

               Open := next_Significant (First + Length (Each));
               exit when Open = 0 or else Element (Pad, Open) /= '<';

               for Place in Open .. Length (Pad)
               loop
                  if    Element (Pad, Place) = '<' then   Depth := Depth + 1;
                  elsif Element (Pad, Place) = '>' then   Depth := Depth - 1;
                  end if;

                  if Depth = 0
                  then
                     Close := Place;
                     exit;
                  end if;
               end loop;

               exit when Close = 0;
               delete (Pad, First, Close);
            end;
         end loop;
      end loop;

      --  A standard type which is followed by brackets ('int (10)'): the name is removed.
      --
      for Each of standard_Types
      loop
         declare
            From : Positive := 1;
         begin
            loop
               declare
                  First : constant Natural := (if From > Length (Pad) then 0 else Index (Pad, to_String (Each), From));
                  After :          Natural;
               begin
                  exit when First = 0;

                  After := next_Significant (First + Length (Each));

                  if         After /= 0
                    and then Element (Pad, After) = '('
                    and then (First = 1 or else not is_name_Character (Element (Pad, First - 1)))
                  then
                     delete (Pad, First, After - 1);
                  else
                     From := First + 1;
                  end if;
               end;
            end loop;
         end;
      end loop;

      --  A type in brackets which is followed by an operand ('(mytype) 10'). A name which is a known constant is no type.
      --
      declare
         From : Positive := 1;
      begin
         loop
            declare
               Open  : constant Natural := (if From > Length (Pad) then 0 else Index (Pad, "(", From));
               Close :          Natural;
               After :          Natural;
            begin
               exit when Open = 0;

               Close := Index (Pad, ")", Open);
               exit when Close = 0;

               After := (if Close = Length (Pad) then 0 else next_Significant (Close + 1));

               declare
                  the_Name : constant String := to_String (Trim (unbounded_Slice (Pad, Open + 1, Close - 1), ada.Strings.Both));
               begin
                  if         the_Name /= ""
                    and then the_Name (the_Name'First) in 'a' .. 'z' | 'A' .. 'Z' | '_'
                    and then (for all Char of the_Name => is_name_Character (Char) or else Char in ' ' | ':')
                    and then After /= 0
                    and then (is_name_Character (Element (Pad, After)) or else Element (Pad, After) in '(' | ''')
                    and then not known_Symbols.contains (+the_Name)
                    and then not known_Symbols.contains (Namespace & the_Name)
                    and then not follows_sizeof (Open)
                  then
                     delete (Pad, Open, Close);
                  else
                     From := Open + 1;
                  end if;
               end;
            end;
         end loop;
      end;

      --  'sizeof' may be written with a space before its bracket.
      --
      loop
         declare
            Place : constant Natural := Index (Pad, "sizeof (");
         begin
            exit when Place = 0;
            delete (Pad, Place + 6, Place + 6);
         end;
      end loop;

      return to_String (Pad);
   end without_Casts;



   function Value_of (the_Expression : in unbounded_String;
                      known_Symbols  : in symbol_value_Maps.Map;
                      Namespace      : in unbounded_String) return discrete.Integer
   is

      procedure resolve_c_integer_Expression_recursive (Expression_pad   : access unbounded_String;
                                                        known_Symbols    : in     symbol_value_maps.Map;
                                                        is_Single        : in     Boolean;
                                                        expression_Value :    out discrete.Integer;
                                                        expression_Type  :    out unbounded_String)
      is
         the_Elements : aliased element_Vectors.Vector;


         function follows_a_Value return Boolean
         --
         --  A 'U' or 'L' is the suffix of an integer literal only when it follows a value. Otherwise
         --  it begins an identifier (as in 'llast').
         --
         is
         begin
            return         not the_Elements.is_Empty
                  and then the_Elements.last_Element.Kind = Value;
         end follows_a_Value;

      begin
         --  log ("'resolved_c_integer_Expression_recursive'   ~   Expression_pad: '" & Expression_pad.all & "'");

         while Length (Expression_pad.all) > 0
         loop
            --  log ("Self: '" & Expression_pad.all & "'");

            if Element (Expression_pad.all, 1) = ' '
            then
               delete (Expression_pad.all,  1, 1);

            elsif      Length (Expression_pad.all)                 >= 3
              and then to_Upper (Slice (Expression_pad.all, 1, 3))  = "ULL"
              and then follows_a_Value
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
              and then follows_a_Value
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
              and then     follows_a_Value
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
              and then     follows_a_Value
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
                  append (the_Elements,  an_Element'(kind           => Value,
                                                     value          => expression_Value,
                                                     type_Qualifier => expression_Type));
               end;

            elsif      Length (Expression_pad.all) >= 3
              and then Slice  (Expression_pad.all, 1, 3) = "<=>"
            then
               raise Constraint_Error with "A three way comparison has no value which is an integer.";

            elsif      Length (Expression_pad.all) >= 2
              and then Slice  (Expression_pad.all, 1, 2) in "<=" | ">=" | "==" | "!="
            then   -- A comparison, which is 1 or 0.
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => unbounded_Slice (Expression_pad.all, 1, 2)));
               delete (Expression_pad.all,  1, 2);

            elsif      Element (Expression_pad.all, 1) in '<' | '>'
              and then not (         Length (Expression_pad.all) >= 2
                            and then Element (Expression_pad.all, 2) = Element (Expression_pad.all, 1))     -- Not a shift.
            then
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => unbounded_Slice (Expression_pad.all, 1, 1)));
               delete (Expression_pad.all,  1, 1);

            elsif Element (Expression_pad.all, 1) = '!'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => +"!"));

            elsif Element (Expression_pad.all, 1) = '+'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => +"+"));

            elsif Element (Expression_pad.all, 1) = '-'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => +"-"));

            elsif Element (Expression_pad.all, 1) = '~'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => +"~"));


            elsif Element (Expression_pad.all, 1) = '*'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => +"*"));


            elsif Element (Expression_pad.all, 1) = '/'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => +"/"));

            elsif Element (Expression_pad.all, 1) = '%'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => +"%"));

            elsif Length (Expression_pad.all) >= 2 and then Slice (Expression_pad.all, 1, 2) = "||"
            then
               delete (Expression_pad.all,  1, 2);
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => +"||"));

            elsif Element (Expression_pad.all, 1) = '|'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => +"|"));

            elsif Length (Expression_pad.all) >= 2 and then Slice (Expression_pad.all, 1, 2) = "&&"
            then
               delete (Expression_pad.all,  1, 2);
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => +"&&"));

            elsif Element (Expression_pad.all, 1) = '&'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => +"&"));

            elsif Element (Expression_pad.all, 1) = '^'
            then
               delete (Expression_pad.all,  1, 1);
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => +"^"));

            elsif      Length (Expression_pad.all)       >= 7
              and then Slice  (Expression_pad.all, 1, 7)  = "sizeof("
            then
               delete (Expression_pad.all,  1, 7);

               declare
                  Last         : constant Positive         := Index (Expression_pad.all, ")");
                  sizeof_Slice : constant unbounded_String := unbounded_Slice (Expression_pad.all,  1,  Last - 1);
               begin
                  append (the_Elements,  an_Element'(kind  => Value,
                                                     value => to_Integer (Long_Long_Integer (sizeof_Value (sizeof_Slice,
                                                                                                           known_Symbols,
                                                                                                           Namespace))),
                                                     others => <>));
                  delete (Expression_pad.all,  1, Last);
               end;

            elsif      Length (Expression_pad.all)       >= 2
              and then Slice  (Expression_pad.all, 1, 2)  = "<<"
            then
               delete (Expression_pad.all,  1, 2);
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => +"<<"));

            elsif      Length (Expression_pad.all)       >= 2
              and then Slice  (Expression_pad.all, 1, 2)  = ">>"
            then
               delete (Expression_pad.all,  1, 2);
               append (the_Elements,  an_Element'(kind  => Operator,
                                                  code  => +">>"));

            elsif Element (Expression_pad.all, 1) = ')'
            then
               delete (Expression_pad.all,  1, 1);
               exit;                                                  -- nb: Exit loop to allow recursion to end.

            elsif        (         Length (Expression_pad.all) >= 3                  -- A character ('A', '\n', L'\0'),
                            and then Element (Expression_pad.all, 1) = ''')            -- which is the number of its position.
                 or else (         Length (Expression_pad.all) >= 4
                          and then Element (Expression_pad.all, 1) = 'L'
                          and then Element (Expression_pad.all, 2) = ''')
            then
               declare
                  First    : constant Positive := (if Element (Expression_pad.all, 1) = 'L' then 3 else 2);     -- Follows the opening quote.
                  Last     : Natural  := First;
                  Position : Long_Long_Integer;
               begin
                  if Element (Expression_pad.all, First) = '\'
                  then   -- An escape.
                     Last := First + 1;

                     case Element (Expression_pad.all, Last)
                     is
                        when 'a'    => Position := 7;
                        when 'b'    => Position := 8;
                        when 't'    => Position := 9;
                        when 'n'    => Position := 10;
                        when 'v'    => Position := 11;
                        when 'f'    => Position := 12;
                        when 'r'    => Position := 13;
                        when 'e'    => Position := 27;

                        when '0' .. '7' =>     -- Octal digits.
                           Position := 0;
                           Last     := Last - 1;

                           while Element (Expression_pad.all, Last + 1) in '0' .. '7'
                           loop
                              Last     := Last + 1;
                              Position := Position * 8 + Character'Pos (Element (Expression_pad.all, Last)) - Character'Pos ('0');
                           end loop;

                        when 'x' =>            -- Hexadecimal digits.
                           Position := 0;

                           while Element (Expression_pad.all, Last + 1) in '0' .. '9' | 'a' .. 'f' | 'A' .. 'F'
                           loop
                              Last     := Last + 1;
                              Position := Position * 16 + Long_Long_Integer'Value ("16#" & Element (Expression_pad.all, Last) & "#");
                           end loop;

                        when others => Position := Character'Pos (Element (Expression_pad.all, Last));     -- A quote, or the like.
                     end case;
                  else
                     Position := Character'Pos (Element (Expression_pad.all, First));
                  end if;

                  if Element (Expression_pad.all, Last + 1) /= '''
                  then
                     raise Constraint_Error with "A character of several characters is not worked out within an expression.";
                  end if;

                  append (the_Elements,  an_Element'(Kind   => Value,
                                                     Value  => to_Integer (Position),
                                                     others => <>));
                  delete (Expression_pad.all,  1, Last + 1);
               end;

            elsif      Length (Expression_pad.all)       >= 3         -- A binary number ('0b110', of C++14).
              and then Slice  (Expression_pad.all, 1, 2) in "0b" | "0B"
              and then Element (Expression_pad.all, 3)   in '0' | '1'
            then
               declare
                  Last  : Natural           := 2;
                  Total : Long_Long_Integer := 0;
               begin
                  while      Last < Length (Expression_pad.all)
                    and then Element (Expression_pad.all, Last + 1) in '0' | '1' | '''     -- A quote may separate the digits.
                  loop
                     Last := Last + 1;

                     if Element (Expression_pad.all, Last) /= '''
                     then
                        Total := Total * 2 + (if Element (Expression_pad.all, Last) = '1' then 1 else 0);
                     end if;
                  end loop;

                  append (the_Elements,  an_Element'(Kind  => Value,
                                                     Value => to_Integer (Total),
                                                     others => <>));
                  delete (Expression_pad.all,  1, Last);
               end;

            elsif      Length (Expression_pad.all)       >= 2         -- Handle hex numbers.
              and then Slice  (Expression_pad.all, 1, 2)  = "0x"      --
            then
               declare
                  First : Natural;
                  Last  : Natural;
               begin
                  find_Token (Expression_pad.all, to_Set ("0123456789xABCDEFabcdef"), Inside,  First, Last);

                  append (the_Elements,  an_Element'(Kind  => Value,
                                                     Value => to_Int (Slice (Expression_pad.all,  First, Last)),
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

                  append (the_Elements,  an_Element'(Kind  => Value,
                                                     Value => to_Int (Slice (Expression_pad.all,  First, Last)),
                                                     others => <>));
                  delete (Expression_pad.all,  First, Last);
               end;

            else  -- Should be a symbol identifier. (A character is written within quotes, and is dealt with above: a lone
                  -- letter was once taken for one, which gave the name of a function, or of another constant, a value.)
               declare
                  First      : Natural;
                  Last       : Natural;
                  the_Symbol : unbounded_String;
               begin
                  --  A name may be given with its scope ('RayPacketData::Size', as the core writes the dimension of an
                  --  array which is a member of the class), so the scope operator is part of it.
                  --
                  find_Token (Expression_pad.all, to_Set ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789:"), Inside,  First, Last);
                  the_Symbol := unbounded_Slice (Expression_pad.all,  First, Last);

                  if        the_Symbol = "true"
                    or else the_Symbol = "false"
                  then   -- The C++ boolean literals.
                     append (the_Elements,  an_Element'(Kind   => Value,
                                                        Value  => to_Integer (if the_Symbol = "true" then 1 else 0),
                                                        others => <>));
                  else
                     declare
                        --  The name is sought within the namespace, then as it is written, and then by its last part,
                        --  as a literal of an enumeration is known by its own name whatever scope it is named with.
                        --
                        Colons : constant Natural          := Index (the_Symbol, "::", Going => ada.Strings.Backward);
                        Plain  : constant unbounded_String := (if Colons = 0 then the_Symbol
                                                               else unbounded_Slice (the_Symbol, Colons + 2, Length (the_Symbol)));
                        Key    : constant unbounded_String := (if    known_Symbols.contains (Namespace & the_Symbol) then Namespace & the_Symbol
                                                               elsif known_Symbols.contains (the_Symbol)             then the_Symbol
                                                               elsif known_Symbols.contains (Namespace & Plain)      then Namespace & Plain
                                                               else  Plain);
                     begin
                        append (the_Elements,  an_Element'(kind  => Value,
                                                           value => Element (known_Symbols, Key),     -- Raises where the name is not known.
                                                           others => <>));
                     end;
                  end if;

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


      the_expression_Pad   : aliased  unbounded_String := +without_Casts (to_String (the_Expression), known_Symbols, Namespace);
      is_Single            : constant Boolean          := Length (the_Expression) = 1;

      the_expression_Value :          discrete.Integer;
      the_expression_Type  :          unbounded_String;

   begin
      resolve_c_integer_Expression_recursive (the_expression_Pad'Access,
                                              known_Symbols,
                                              is_Single,
                                              the_expression_Value,
                                              the_expression_Type);
      return the_expression_Value;
   end Value_of;


end c_Expressions;
