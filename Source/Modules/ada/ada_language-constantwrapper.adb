separate (ada_Language)


overriding
function constantWrapper (Self : access Item;
                          N    : in     Node_Pointer) return C.int
is
   the_Node       : Node_Pointer renames N;

   the_Name       : constant unbounded_String := +Attribute (the_Node, "sym:name");
   the_swigType   : constant SwigType_Pointer := SwigType_Pointer (get_Attribute (the_Node, "type"));

   the_Type       : c_Type.view;
   new_c_Constant : c_Variable.view;

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
                        declare
                           the_String : constant String := Attribute (the_Node, "stringval");
                           Result     : unbounded_String;
                        begin
                           for Each of the_String
                           loop
                              if Each = '"'
                              then
                                 append (Result, """""");
                              elsif Each < ' ' or else Each >= Character'Val (127)
                              then
                                 append (Result, """ & Character'Val (" & ada.Strings.fixed.Trim (Natural'Image (Character'Pos (Each)), ada.Strings.Left) & ") & """);
                              else
                                 append (Result, Each);
                              end if;
                           end loop;

                           return to_String (Result);
                        end;
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

      value_Text : unbounded_String := +literal_Text;
   begin
      dlog ("value_Text => '" & value_Text & "'");

      if        (         Index (value_Text, "&")  = 1
                 and then Index (value_Text, "::") > 0)
        or else Index (String'(+DOH_Pointer (the_swigType)), "m(") = 1
      then   -- A pointer to a member of a class, for which Ada has no counterpart.
         warn (not_Bound, "Unable to bind the constant '" & the_Name & "', as its value is a pointer to a class member.");
         unindent_Log;

         return SWIG_OK;
      end if;

      if         Index (value_Text, "&") = 1
        and then Index (String'(+DOH_Pointer (the_swigType)), "p.f(") /= 1
      then   -- The address of an object ('%constant Type1* T = &an_Object;'), which is no static value in Ada.
         warn (not_Bound, "Unable to bind the constant '" & the_Name & "', as its value is the address of an object.");
         unindent_Log;

         return SWIG_OK;
      end if;

      if        the_Type.is_constructed_by_Cpp
        or else the_Type.Name = "std::string"
      then   -- An object which C++ constructs: it has no value which Ada can give, and a constant made by a directive has no symbol.
         warn (not_Bound, "Unable to bind the constant '" & the_Name & "', as its type is one which C++ constructs.");
         unindent_Log;

         return SWIG_OK;
      end if;

      if the_Type.c_type_Kind in c_Type.c_Class
      then   -- A structure or a class, whose value is an object of C ('%constant Type1 T = an_Object;').
         warn (not_Bound, "Unable to bind the constant '" & the_Name & "', as its value is an object.");
         unindent_Log;

         return SWIG_OK;
      end if;

      if not (        new_c_Constant.my_Type.qualified_Name = "Character"
              or else new_c_Constant.my_Type.qualified_Name = "char*")
      then   -- Is numeric.
         declare
            the_Value : gmp.discrete.Integer;
         begin
            the_Value := resolved_c_integer_Expression (Self,
                                                        Value_Text,
                                                        Self.integer_symbol_value_Map,
                                                        Self.current_class_namespace_Prefix);
            if        value_Text = "true"
              or else value_Text = "false"
              or else (         Index (value_Text, "sizeof(") = 1
                       and then Index (value_Text, ")")       = Length (value_Text)
                       and then Self.name_Map_of_c_type.contains (unbounded_Slice (value_Text, 8, Length (value_Text) - 1)))
            then
               null;   -- The source generator gives these in terms of Ada, so the text is kept.

            elsif Slice (value_Text, 1, 2) = "0x"
            then
               value_Text := +hex_Image (the_Value);

            elsif Slice (value_Text, 1, 1) = "0"
            then
               value_Text := +oct_Image (the_Value);

            else
               value_Text := +Image (the_Value);
            end if;

            Self.integer_symbol_value_Map.insert (the_Name, the_Value);

         exception
            when others =>
               declare
                  use swigg.Utility;

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

               begin
                  strip_c_integer_literal_qualifiers_in (value_Text);

                  if Index (value_Text, "<=>") /= 0
                  then   -- A three way comparison, whose result is no number.
                     warn (not_Bound, "Unable to bind the constant '" & the_Name & "', as its value is a three way comparison.");
                     unindent_Log;

                     return SWIG_OK;
                  end if;

                  if        the_Type.Name = "float"
                    or else the_Type.Name = "double"
                  then
                     if         Length (value_Text) >= 2                                              -- A suffix which says
                       and then Element (value_Text, Length (value_Text))     in 'f' | 'F' | 'l' | 'L'   -- that a literal is a
                       and then Element (value_Text, Length (value_Text) - 1) in '0' .. '9' | '.'        -- 'float' ('4.0f').
                       and then Index (value_Text, "0x") = 0
                     then
                        delete (value_Text, Length (value_Text), Length (value_Text));
                     end if;

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

                     --  A number which the type cannot hold ('#define HUGE_VAL 1.0e10000', which C takes
                     --  as infinity) is no static value in Ada, and the constant is left out.
                     --
                     declare
                        the_Text : constant String := to_String (value_Text);
                        Too_Big  :          Boolean := False;
                     begin
                        if         the_Text /= ""
                          and then (for all Each of the_Text => Each in '0' .. '9' | '.' | 'e' | 'E' | '+' | '-')
                        then
                           begin
                              Too_Big := abs Long_Long_Float'Value (the_Text) > (if the_Type.Name = "float" then Long_Long_Float (interfaces.C.C_float'Last)
                                                                                                            else Long_Long_Float (interfaces.C.double 'Last));
                           exception
                              when Constraint_Error =>
                                 Too_Big := True;
                           end;
                        end if;

                        if Too_Big
                        then
                           warn (not_Bound, "Unable to bind the constant '" & the_Name & "', as its value (" & the_Text
                                          & ") is beyond the range of its type.");
                           unindent_Log;
                           return SWIG_OK;
                        end if;
                     end;

                  elsif the_Type.Name = "char"
                  then
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

                     elsif Slice (value_Text, 1, 1) = "\"
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

                  end if;

                  if         the_Type.is_a_Number
                    and then Index (value_Text, "interfaces.c.") = 0
                    and then not is_plain_Expression (to_String (value_Text))
                  then
                     warn (not_Bound, "Unable to bind the constant '" & the_Name & "', as its value (" & value_Text
                                    & ") is not one which Ada can state.");
                     unindent_Log;
                     return SWIG_OK;
                  end if;

                  new_c_Constant.Value := value_Text;
               end;
         end;
      end if;

      new_c_Constant.Value := value_Text;
      Self.current_Module.C.new_c_Variables   .append (new_c_Constant);
      Self.current_Module.C.new_c_Declarations.append (new_c_Constant.all'Access);
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
