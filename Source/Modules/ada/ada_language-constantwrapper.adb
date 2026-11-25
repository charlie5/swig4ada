separate (ada_Language)


overriding
function constantWrapper (Self : access Item;
                          N    : in     Node_Pointer) return C.int
--
--  Makes a constant of the C model from a constant of the interface file ('#define', '%constant', an enumeration
--  item). Its value is worked out where it can be, is otherwise given as it is written where that is an expression
--  of Ada, and failing that the constant is left out, with a warning.
--
is
   the_Node       : Node_Pointer renames N;

   the_Name       : constant unbounded_String := +Attribute (the_Node, "sym:name");
   the_swigType   : constant SwigType_Pointer := SwigType_Pointer (get_Attribute (the_Node, "type"));

   the_Type       : c_Type.view;
   new_c_Constant : c_Variable.view;


   function literal_Text return String
   --
   --  The value of a character or a string literal is held as C source, with its quotes ('x', "xyzzy", L"wide").
   --  What is wanted here is the text between the quotes, with its escapes as they are written.
   --
   is
      the_Value : constant String := Attribute (the_Node, "value");
      First     :          Natural := the_Value'First;
      Last      :          Natural := the_Value'Last;
   begin
      if         get_Attribute (the_Node, "stringval") = null     -- Which the core gives to a literal alone,
        and then not (         the_Value'Length in 4 .. 6         -- but not to one of several characters ('ab').
                      and then the_Value (First) = '''
                      and then the_Value (Last)  = '''
                      and then (for all Each of the_Value (First + 1 .. Last - 1) => Each not in ''' | '\'))
      then
         return the_Value;
      end if;

      while      Last - First >= 3                         -- A literal may be within brackets: (';').
        and then the_Value (First) = '('
        and then the_Value (Last)  = ')'
      loop
         First := First + 1;
         Last  := Last  - 1;
      end loop;

      if         Last > First
        and then the_Value (Last) in ''' | '"'
      then
         for Each in First .. Last - 1
         loop
            if the_Value (Each) = the_Value (Last)
            then
               declare
                  the_Text : constant String := the_Value (Each + 1 .. Last - 1);
               begin
                  --  A string is given as the text which it stands for, as its source may hold escapes, or be a raw
                  --  string literal. It is written so as to stand between the quotes of an Ada string literal: a
                  --  quote is doubled, and a control character is joined in by its position.
                  --
                  if         the_Value (Last) = '"'
                    and then get_Attribute (the_Node, "stringval") /= null
                    and then Each = First     -- Not a wide string (L"..."), which is left as it is written.
                  then
                     return as_Ada_string_Text (Attribute (the_Node, "stringval"));
                  end if;

                  --  A character literal of several characters ('ab') is an 'int' in C, in which GCC and
                  --  swig place the first character highest.
                  --
                  if         the_Value (Last) = '''
                    and then the_Text'Length in 2 .. 4
                    and then (for all Each of the_Text => Each /= '\')
                  then
                     declare
                        Packed : Long_Long_Integer := 0;
                     begin
                        for Each of the_Text
                        loop
                           Packed := Packed * 256 + Character'Pos (Each);
                        end loop;

                        return ada.Strings.fixed.Trim (Packed'Image, ada.Strings.Left);
                     end;
                  end if;

                  return the_Text;
               end;
            end if;
         end loop;
      end if;

      return the_Value;
   end literal_Text;



   function is_plain_Expression (the_Text : in String) return Boolean
   --
   --  A number whose value could not be worked out is given as it is written, which serves where it is made of
   --  numbers and of the constants of the module alone. Anything else is not an expression of Ada.
   --
   is
      Cursor : Natural := the_Text'First;
   begin
      if the_Text = ""
      then
         return False;
      end if;

      while Cursor <= the_Text'Last
      loop
         if the_Text (Cursor) in 'a' .. 'z' | 'A' .. 'Z' | '_'
         then   -- A name, which must be that of a constant with a value.
            declare
               Last : Natural := Cursor;
            begin
               while      Last < the_Text'Last
                 and then the_Text (Last + 1) in 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9'
               loop
                  Last := Last + 1;
               end loop;

               if not (for some Each of Self.current_Module.C.new_c_Variables =>          Each.Name   = the_Text (Cursor .. Last)
                                                                                  and then Each.Value /= "")
               then
                  return False;
               end if;

               Cursor := Last + 1;
            end;

         elsif the_Text (Cursor) in '0' .. '9'
         then   -- A number, with whatever letters it holds.
            if         Cursor < the_Text'Last
              and then the_Text (Cursor) = '0'
              and then the_Text (Cursor + 1) in 'x' | 'X' | 'b' | 'B'
            then
               return False;     -- A hexadecimal or binary number is not written so in Ada.
            end if;

            while      Cursor <= the_Text'Last
              and then the_Text (Cursor) in 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' | '.' | '#'
            loop
               Cursor := Cursor + 1;
            end loop;

         elsif the_Text (Cursor) in '+' | '-' | '*' | '/' | '(' | ')' | ' ' | '.'
         then
            Cursor := Cursor + 1;

         else
            return False;
         end if;
      end loop;

      return True;
   end is_plain_Expression;



   function Reason_to_leave_out (value_Text : in unbounded_String) return String
   --
   --  Why a constant of this type and value has no counterpart in Ada, or "" where it may have one.
   --
   is
      the_swig_Text : constant String := +DOH_Pointer (the_swigType);
   begin
      if        (         Index (value_Text, "&")  = 1
                 and then Index (value_Text, "::") > 0)
        or else Index (the_swig_Text, "m(") = 1
      then
         return "its value is a pointer to a class member";

      elsif      Index (value_Text, "&") = 1
        and then Index (the_swig_Text, "p.f(") /= 1
      then   -- '%constant Type1* T = &an_Object;', which is no static value in Ada.
         return "its value is the address of an object";

      elsif     the_Type.is_constructed_by_Cpp
        or else the_Type.Name = "std::string"
      then   -- It has no value which Ada can give, and a constant made by a directive has no symbol.
         return "its type is one which C++ constructs";

      elsif the_Type.c_type_Kind in c_Type.c_Class
      then   -- '%constant Type1 T = an_Object;'.
         return "its value is an object";

      else
         return "";
      end if;
   end Reason_to_leave_out;



   function Evaluated (value_Text : in unbounded_String;   the_Value : out gmp.discrete.Integer) return Boolean
   --
   --  True where the value is an integer expression which can be worked out.
   --
   is
   begin
      the_Value := resolved_c_integer_Expression (Self,
                                                  value_Text,
                                                  Self.integer_symbol_value_Map,
                                                  Self.current_class_namespace_Prefix);
      return True;

   exception
      when others =>     -- The resolver raises for whatever it cannot work out.
         return False;
   end Evaluated;



   function evaluated_as_Real (value_Text : in unbounded_String;   the_Value : out gmp.discrete.Integer) return Boolean
   --
   --  True where the value of a constant of an integer type is an expression which has real numbers in it, which a
   --  cast makes an integer ('((int) 2.5 * 2)', which the core types as an 'int'), and which can be worked out: as C
   --  works it out, and truncated, as C converts it. (Until 2026-11-26 such a constant was left out.)
   --
   is
      function Cast_to (type_Name : in String) return c_Expressions.a_Cast
      is (cast_to_Type (Self, type_Name));

      the_Real : Long_Float;
   begin
      --  It may raise, and so is worked out here, and not in the declarations, whose exceptions the handler below
      --  would not catch.
      --
      the_Real := c_Expressions.real_Value_of (to_String (value_Text),
                                               Self.real_symbol_value_Map,
                                               Self.integer_symbol_value_Map,
                                               Self.current_class_namespace_Prefix,
                                               Cast_to'Access).Value;

      if abs the_Real >= 2.0 ** 63
      then
         return False;
      end if;

      the_Value := gmp.discrete.to_Integer (long_long_Integer (Long_Float'Truncation (the_Real)));
      return True;

   exception
      when others =>
         return False;
   end evaluated_as_Real;



   function as_written_in_Ada (value_Text : in unbounded_String;   the_Value : in gmp.discrete.Integer) return unbounded_String
   --
   --  The text of an integer value which has been worked out: in the base in which the constant is written.
   --
   is
   begin
      if        value_Text = "true"
        or else value_Text = "false"
        or else (         Index (value_Text, "sizeof(") = 1
                 and then Index (value_Text, ")")       = Length (value_Text)
                 and then Self.name_Map_of_c_type.contains (unbounded_Slice (value_Text, 8, Length (value_Text) - 1)))
      then
         return value_Text;     -- The source generator gives these in terms of Ada, so the text is kept.

      elsif      Length (value_Text) >= 2
        and then Slice (value_Text, 1, 2) = "0x"
      then
         return +hex_Image (the_Value);

      elsif      Length (value_Text) >= 2     -- A single digit is the same in any base.
        and then Element (value_Text, 1) = '0'
      then
         return +oct_Image (the_Value);

      else
         return +Image (the_Value);
      end if;
   end as_written_in_Ada;



   function is_a_plain_Number (the_Text : in String) return Boolean
   --
   --  Whether the text is a number alone, with a sign or within brackets ('(6.0221367e23)', '-1.5').
   --
   is
      First : Positive := the_Text'First;
      Last  : Natural  := the_Text'Last;
   begin
      loop
         while First <= Last and then the_Text (First) in ' ' | '+' | '-' loop   First := First + 1;   end loop;
         while Last >= First and then the_Text (Last)  =  ' '             loop   Last  := Last  - 1;   end loop;

         exit when not (    First < Last
                        and then the_Text (First) = '('
                        and then the_Text (Last)  = ')');
         First := First + 1;
         Last  := Last  - 1;
      end loop;

      declare
         the_Number : Long_Float with Unreferenced;
      begin
         the_Number := Long_Float'Value (the_Text (First .. Last));
         return True;
      exception
         when Constraint_Error =>
            return False;
      end;
   end is_a_plain_Number;



   procedure make_Real (value_Text : in out unbounded_String)
   --
   --  Makes a real literal of C one of Ada.
   --
   is
      use swigg.Utility;
   begin
      --  The suffix which says that a literal is a 'float' ('4.0f'), of each literal of an expression ('((3.14f)*2.0f)',
      --  of Assimp's 'AI_MATH_TWO_PI_F'; until 2026-11-25 only that of the last was taken off, and the spec did not
      --  compile). A hexadecimal literal, whose digits may be letters, is left as it is.
      --
      declare
         the_Text : constant String := to_String (value_Text);
         Result   : unbounded_String;
         is_Hex   : Boolean         := False;     -- Within a hexadecimal literal.
      begin
         for Each in the_Text'Range
         loop
            if         Each < the_Text'Last
              and then the_Text (Each) = '0'
              and then the_Text (Each + 1) in 'x' | 'X'
              and then (Each = the_Text'First or else the_Text (Each - 1) not in '0' .. '9' | '.')
            then
               is_Hex := True;
            elsif the_Text (Each) not in '0' .. '9' | 'a' .. 'f' | 'A' .. 'F' | 'x' | 'X' | '.'
            then
               is_Hex := False;
            end if;

            if         not is_Hex
              and then the_Text (Each) in 'f' | 'F' | 'l' | 'L'
              and then Each > the_Text'First
              and then the_Text (Each - 1) in '0' .. '9' | '.'
              and then (Each = the_Text'Last or else the_Text (Each + 1) not in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_')
            then
               null;     -- The suffix.
            else
               append (Result, the_Text (Each));
            end if;
         end loop;

         value_Text := Result;
      end;

      replace_Integer_with_Float (value_Text);

      if         Length (value_Text) >= 2
        and then Element (value_Text, Length (value_Text)) = '.'                  -- A real literal of C may end with
        and then Element (value_Text, Length (value_Text) - 1) in '0' .. '9'      -- its point ('12.'), and one of Ada
      then                                                                         -- may not.
         append (value_Text, "0");
      end if;

      declare     -- A real number with an exponent and no point ('10E1') is an integer in Ada.
         the_Text : constant String  := to_String (value_Text);
         Exponent : constant Natural := ada.Strings.fixed.Index (the_Text, ada.Strings.Maps.to_Set ("eE"));
      begin
         if         Exponent > the_Text'First
           and then ada.Strings.fixed.Index (the_Text, ".") = 0
           and then (for all Each of the_Text (the_Text'First .. Exponent - 1) => Each in '0' .. '9')
           and then (for all Each of the_Text (Exponent + 1 .. the_Text'Last)  => Each in '0' .. '9' | '+' | '-')
         then
            value_Text := +(the_Text (the_Text'First .. Exponent - 1) & ".0" & the_Text (Exponent .. the_Text'Last));
         end if;
      end;
   end make_Real;



   function is_beyond_its_Type (value_Text : in unbounded_String) return Boolean
   --
   --  True for a number which the type cannot hold ('#define HUGE_VAL 1.0e10000', which C takes
   --  as infinity), and which is no static value in Ada.
   --
   is
      the_Text : constant String := to_String (value_Text);
   begin
      if         the_Text /= ""
        and then (for all Each of the_Text => Each in '0' .. '9' | '.' | 'e' | 'E' | '+' | '-')
      then
         return abs Long_Long_Float'Value (the_Text) > (if the_Type.Name = "float" then Long_Long_Float (interfaces.C.C_float'Last)
                                                                                   else Long_Long_Float (interfaces.C.double 'Last));
      else
         return False;
      end if;

   exception
      when Constraint_Error =>
         return True;
   end is_beyond_its_Type;



   procedure make_Character (value_Text : in out unbounded_String)
   --
   --  Gives a character which is written as an escape by its position. One which is two
   --  escapes is a wide character, and the constant is then of that type.
   --
   is
   begin
      if    value_Text = "\a"  then value_Text := +"interfaces.c.char'Val (07)";
      elsif value_Text = "\b"  then value_Text := +"interfaces.c.char'Val (08)";
      elsif value_Text = "\e"  then value_Text := +"interfaces.c.char'Val (27)";
      elsif value_Text = "\f"  then value_Text := +"interfaces.c.char'Val (12)";
      elsif value_Text = "\n"  then value_Text := +"interfaces.c.char'Val (10)";
      elsif value_Text = "\r"  then value_Text := +"interfaces.c.char'Val (13)";
      elsif value_Text = "\t"  then value_Text := +"interfaces.c.char'Val (09)";
      elsif value_Text = "\v"  then value_Text := +"interfaces.c.char'Val (11)";
      elsif value_Text = "\\"  then value_Text := +"interfaces.c.char'Val (92)";
      elsif value_Text = "\'"  then value_Text := +"interfaces.c.char'Val (39)";
      elsif value_Text = "\""" then value_Text := +"interfaces.c.char'Val (34)";
      elsif value_Text = "\?"  then value_Text := +"interfaces.c.char'Val (63)";

      elsif      Length (value_Text) >= 1
        and then Element (value_Text, 1) = '\'
      then
         if         Length (value_Text) >= 5
           and then Slice  (value_Text, 5, 5) = "\"
         then
            the_Type       := Self.swig_type_Map_of_c_type.Element (+"wchar_t");
            new_c_Constant := c_variable.new_c_Variable (Name    => the_Name,
                                                         of_Type => the_Type);

            value_Text := +"interfaces.c.wchar_t'Val (8#" & Slice (value_Text, 2, Length (value_Text) - 4) & "# * 256 + "
                                                   & "8#" & Slice (value_Text, 6, Length (value_Text)    ) & "#)";
         else
            value_Text := +"interfaces.c.char'Val (8#" & Slice (value_Text, 2, Length (value_Text)) & "#)";
         end if;
      end if;
   end make_Character;



   function left_Out (Reason : in String) return C.int
   --
   --  Says why the constant is not bound.
   --
   is
   begin
      warn (not_Bound, "Unable to bind the constant '" & the_Name & "', as " & Reason & ".");
      unindent_Log;

      return SWIG_OK;
   end left_Out;

begin
   indent_Log;
   dlog (+"");
   dlog ("'constantWrapper' -   Name: '"
        & the_Name
        & "'    swigType: '"
        & String'(+DOH_Pointer (the_swigType))
        & "'");

   Self.current_c_Node := doh_Node (the_Node);
   locate (doh_Node (the_Node));
   the_Type            := Self.demand_c_Type_for (doh_swigType (the_swigType));     -- An unknown type is pruned later.
   new_c_Constant      := c_variable.new_c_Variable (Name    => the_Name,
                                                     of_Type => the_Type);
   dlog ("the_Type.Name => '" & the_Type.Name & "'");

   declare
      use swigg.Utility;

      value_Text : unbounded_String := +literal_Text;
      the_Value  : gmp.discrete.Integer;
      the_Reason : constant String  := Reason_to_leave_out (value_Text);
      is_Numeric : constant Boolean := not (        new_c_Constant.my_Type.qualified_Name = "Character"
                                            or else new_c_Constant.my_Type.qualified_Name = "char*");
   begin
      dlog ("value_Text => '" & value_Text & "'");

      if         C."/=" (SwigType_ismemberpointer (the_swigType), 0)
        and then Self.in_cpp_Mode
      then
         --  A pointer to a class member ('%constant double (Shape::*AREAPT) (void) = &Shape::area;') has no value
         --  which Ada can state. The wrapper defines it, as a constant object of C linkage, which Ada imports as a
         --  constant of the type of 'swig' for it (until 2026-11-24 it was left out, and then it was a variable).
         --
         declare
            the_Symbol : constant unbounded_String := wrapper_Symbol (Self, "swig_ada_" & to_String (the_Name));
            the_Type   : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (the_swigType)));
            Unused     :          SwigType_Pointer with Unreferenced;
         begin
            Unused := SwigType_add_qualifier (the_Type, const_String (-"const"));     -- The pointer itself is constant.

            print_to (DOH_Pointer (Self.f_Ada),   "extern " & String'(+doh_Item (SwigType_str (the_Type, const_String (-to_String (the_Symbol)))))
                                                & " = " & to_String (value_Text) & ";" & NL & NL);     -- 'extern', as a constant has no linkage else.
            new_c_Constant.link_Symbol  := the_Symbol;
            new_c_Constant.from_Wrapper := True;
            Self.current_Module.C.new_c_Variables   .append (new_c_Constant);
            Self.current_Module.C.new_c_Declarations.append (new_c_Constant.all'Access);
         end;

      elsif the_Reason /= ""
      then
         return left_Out (the_Reason);

      else
         if         is_Numeric
           and then the_Type.Name /= "char"                -- A character is given as it is written, or by its position.
           and then (        Evaluated (value_Text, the_Value)
                     or else (    the_Type.is_an_Integer
                              and then evaluated_as_Real (value_Text, the_Value)))
         then
            value_Text := as_written_in_Ada (value_Text, the_Value);
            Self.integer_symbol_value_Map.include (the_Name, the_Value);     -- For a later constant whose value names this one.

         elsif is_Numeric
         then   -- The value is given as it is written, where that can be made an expression of Ada.
            strip_c_integer_literal_qualifiers_in (value_Text);

            if Index (value_Text, "<=>") /= 0
            then   -- Whose result is no number.
               return left_Out ("its value is a three way comparison");
            end if;

            if        the_Type.Name = "float"
              or else the_Type.Name = "double"
            then
               declare
                  is_worked_Out : Boolean := False;
                  the_Value     : c_Expressions.a_Real;

                  function Cast_to (type_Name : in String) return c_Expressions.a_Cast
                  is (cast_to_Type (Self, type_Name));
               begin
                  begin     -- It is kept for a later real constant whose value names this one ('const double x = D_EPS * 3;').
                     the_Value     := c_Expressions.real_Value_of (to_String (value_Text),
                                                                   Self.real_symbol_value_Map,
                                                                   Self.integer_symbol_value_Map,
                                                                   Self.current_class_namespace_Prefix,
                                                                   Cast_to'Access);
                     is_worked_Out := True;
                     Self.real_symbol_value_Map.include (the_Name, the_Value);
                  exception
                     when Constraint_Error =>
                        null;
                  end;

                  make_Real (value_Text);

                  --  An expression which is worked out is given its value, as C works it out (each operation in 'float'
                  --  or 'double'), where Ada would work it out exactly and round it once, and takes no integer as an
                  --  operand of a real type ('#define TWICE (EPS * 2)' gave '(1.0e-6*2)', which did not compile, until
                  --  2026-11-25). A number is given as it is written, which both round alike.
                  --
                  if         is_worked_Out
                    and then not is_a_plain_Number (to_String (value_Text))
                  then
                     value_Text := +c_Expressions.real_Image (the_Value.Value);
                  end if;
               end;

               if is_beyond_its_Type (value_Text)
               then
                  return left_Out ("its value (" & to_String (value_Text) & ") is beyond the range of its type");
               end if;

            elsif the_Type.Name = "char"
            then
               make_Character (value_Text);
            end if;

            if         the_Type.is_a_Number
              and then Index (value_Text, "interfaces.c.") = 0
              and then not is_plain_Expression (to_String (value_Text))
            then
               return left_Out ("its value (" & to_String (value_Text) & ") is not one which Ada can state");
            end if;
         end if;

         new_c_Constant.Value           := value_Text;
         new_c_Constant.is_empty_String := value_Text = "" and then not is_Numeric;     -- '#define EMPTY ""'.
         Self.current_Module.C.new_c_Variables   .append (new_c_Constant);
         Self.current_Module.C.new_c_Declarations.append (new_c_Constant.all'Access);
      end if;
   end;

   --  old ...
   --
   declare
      use type C.int;
   begin
      freshen_current_module_Package (Self, the_Node);

      if Self.addSymbol (-the_Name, the_Node) = 0
      then
         return SWIG_ERROR;
      end if;
   end;

   declare
      the_swigType : SwigType_Pointer := SwigType_Pointer (get_Attribute (the_Node, "type"));
      is_enum_item : constant Boolean := String' (+node_Type (the_Node)) = "enumitem";

   begin
      if is_Enum_item
      then   -- Adjust the enum type for the Swig_typemap_lookup.
         the_swigType := SwigType_Pointer (get_Attribute (parent_Node (the_Node),
                                                          "enumtype"));           -- We want the same adatype typemap for all the enum items so we use the enum type (parent node).
         set_Attribute (the_Node, "type", String_Pointer (the_swigType));
      end if;
   end;

   --  new ...
   --
   Self.prior_c_Declaration := new_c_Constant.all'Access;

   unindent_Log;
   return SWIG_OK;
end constantWrapper;
