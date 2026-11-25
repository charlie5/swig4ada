with
     Transformer,

     ada_Language.c_expression_Resolver,
     ada_Language.source_Generator,
     ada_Language.Forge,

     ada_Utility,
     cpp_Mangling,
     Logger,

     swig_Core.Binding,
     swigMod.Binding,
     swigMod.Dispatcher,
     swig_Core.Wrapper,

     swigg.Utility,

     DOHs.Binding,
     DOHs.Pointers,
     DOHs.const_String_or_char_ptr,

     ada.Containers.Vectors,
     ada.Strings.fixed,
     ada.Strings.Maps,
     ada.Text_IO,
     ada.Exceptions,

     interfaces.c.Strings;


package body ada_Language
is
   use ada_Language.c_expression_Resolver,

       c_Parameter,

       ada_Variable,
       ada_Utility,
       Logger,

       swig_Core,
       swig_Core.Binding,
       swig_Core.Pointers.C_Node_Pointers,
       swigMod.Binding,
       swigMod.Dispatcher,

       DOHs.Pointers,
       DOHs.Binding,

       interfaces.c.Strings,

       ada.Strings,
       ada.Strings.fixed,
       ada.Containers,
       ada.Text_IO;


   -----------
   --- Globals
   --

   usage_help_Text : constant array (1 .. 4) of access String
     := [new String'("Ada Options (available with -ada)"),
         new String'("       -debug-log      - Write a record of what the module does to 'swig4ada-debug.log'"),
         new String'("       -namespace <package> - Make the packages of the module children of <package>, which must exist"),
         new String'("       -no-check-layout - Check the layout of a class, when the wrapper is compiled, only where its record is laid out here")];

   NL : constant String := new_line_Token;


   -- This provides the ada_Language object to the (c-side) swig 'main' function.
   --
   function swig_ada return system.Address
   is
      the_ada_Language : ada_Language.view;
   begin
      the_ada_Language := Forge.construct;
      return the_ada_Language.all'Address;
   end swig_ada;


   ------------
   --- Warnings
   --

   procedure locate (the_Node : in doh_Node)
   --
   --  Notes where the declaration which is now being read is, for a warning about it.
   --
   is
      use type DOH_Pointer;

      the_File : constant DOH_Pointer := DohGetfile (DOH_Pointer (the_Node));
   begin
      if the_File /= null
      then
         Logger.locate (File   => +the_File,
                        Line   => Natural (DohGetline (DOH_Pointer (the_Node))),
                        Filter => Attribute (Node_Pointer (the_Node), "feature:warnfilter"));
      end if;
   end locate;



   procedure report (Number : in Positive;   File    : in String;
                                             Line    : in Natural;
                                             Message : in String;
                                             Filter  : in String)
   --
   --  Gives a warning to the swig core, which prints it unless it has been turned off.
   --
   is
      the_Text   : unbounded_String;
      the_Format : chars_ptr;
   begin
      for Each of Message
      loop
         append (the_Text, (if Each = '%' then "%%" else [Each]));     -- The text is taken as a format.
      end loop;

      the_Format := new_String (to_String (the_Text) & ASCII.LF);

      if Filter /= ""
      then
         Swig_warnfilter (const_String (-Filter), 1);     -- Those which the interface file has turned off for the declaration.
      end if;

      Swig_warning (C.int (Number),
                    const_String (-File),
                    C.int (Line),
                    the_Format);
      if Filter /= ""
      then
         Swig_warnfilter (const_String (-Filter), 0);
      end if;

      free (the_Format);
   end report;



   -----------
   --- Utility
   --

   function  is_a_function_Pointer (swig_Type : in doh_swigType) return Boolean;
   function  returns_a_cpp_constructed_Type (Self : access Item;   the_Node : in doh_Node) return Boolean;

   function is_declared_Virtual (the_Node : in Node_Pointer) return Boolean
   is (ada.Strings.fixed.Index (Attribute (the_Node, "storage"), "virtual") /= 0);
   --
   --  True for a member which is declared virtual. Its storage may name more than that ('virtual constexpr', of
   --  C++20), so it is not compared with the one word. (Until 2026-11-23 it was, and a class whose one virtual
   --  function was such a destructor was bound as a record with no tag, smaller than its class.)

   function  is_called_through_its_Wrapper (Self : access Item;   the_Node : in Node_Pointer) return Boolean;

   function  cpp_Symbol (qualified_Name : in String;   Suffix : in String) return String
     renames cpp_Mangling.Symbol;
   function  variable_Suffix (swig_Type : in String) return String;
   function  character_Value (Position  : in String) return String;
   function  without_leading_Qualifiers (swig_Type : in String) return String;
   function  smart_Pointer_Words (type_Name : in String) return Natural;
   function  as_Ada_string_Text  (the_String : in String) return String;
   procedure bind_constructors_of_abstract_Class (Self : access Item;   the_Class : in Node_Pointer);
   procedure bind_the_Director                   (Self : access Item;   the_Class : in Node_Pointer);
   procedure bind_other_base_Classes             (Self : access Item;   the_Class : in Node_Pointer);
   procedure add_hidden_Members                  (Self : access Item;   Before    : in Node_Pointer;   of_Class : in Node_Pointer := null);
   procedure add_hidden_Virtuals                 (Self : access Item;   Before    : in Node_Pointer);
   function  wrapper_Symbol                      (Self : access Item;   From      : in String) return unbounded_String;
   procedure bind_unnamed_nested_Classes         (Self : access Item;   the_Class : in Node_Pointer;   outer_Name : in String;   cpp_Name : in String);
   function  member_Variable                     (Self : access Item;   the_Node  : in Node_Pointer;   the_Name   : in String;
                                                                         in_Scope  : in Node_Pointer := null) return c_Variable.view;

   procedure register_Mirror (Self : access Item;   proxy_Name              : in unbounded_String;
                                                    the_c_Type              : in c_Type.view;
                                                    the_swig_Type           : in doh_swigType;
                                                    create_array_Type       : in Boolean := True;
                                                    add_level_3_Indirection : in Boolean := False);

   procedure freshen_current_module_Package (Self : access Item;   for_Node : in doh_Node);


   --------------
   --- Operations
   --

   overriding
   procedure main (Self : in out Item;
                   argC : in     C.int;
                   argV : in     swig.pointers.chars_ptr_Pointer)
   is
      use type C.int;
      Each : C.int := 0;

      --  The parser keeps a nested class with no name for this module, which binds it itself (see
      --  'bind_unnamed_nested_Classes'), though the other nested classes are moved out beside their class.
      --
      keep_unnamed_nested_Classes : C.int with Import, Convention => C, External_Name => "cparse_keep_unnamed_nested";

      --  And a private nested class, which is bound for its shape (see 'keep_the_shape_of_hidden_nested_Classes').
      --
      keep_private_nested_Classes : C.int with Import, Convention => C, External_Name => "cparse_keep_private_nested";
   begin
      keep_unnamed_nested_Classes := 1;
      keep_private_nested_Classes := 1;

      indent_Log;
      log ("");
      log ("Parsing C headers.");

      dlog (+"");
      dlog (+"Main");

      SWIG_library_directory (new_String ("ada"));

      --  Parse the command line.
      --
      while Each < argC
      loop
         declare
            the_Command : constant String := Value (String_in (argV, Each));
         begin
            if the_Command = "-namespace"
            then
               if Each + 1 < argC
               then
                  Swig_mark_arg (Each);
                  Swig_mark_arg (Each + 1);

                  --  The packages of the module, and of those which it imports, are children of the package which is named.
                  --
                  Self.Package_namespace := ada_Package.new_ada_Package (Name   => Value (String_in (argV, Each + 1)),
                                                                         Parent => Self.Package_standard);

                  Each := Each + 1;            -- Skip the next argument, as it has just been used.
               else
                  swig_arg_Error;
               end if;

            elsif the_Command = "-noproxy"
            then
               swig_mark_Arg (Each);

            elsif the_Command = "-check-layout"     -- The default.
            then
               Self.all_layout_Checks := True;
               swig_mark_Arg (Each);

            elsif the_Command = "-debug-log"
            then
               Logger.open_debug_Log;
               swig_mark_Arg (Each);

            elsif the_Command = "-no-check-layout"
            then
               Self.all_layout_Checks := False;
               swig_mark_Arg (Each);

            elsif the_Command = "-c++"
            then
               Self.in_CPP_mode := True;
               swig_mark_Arg (Each);

            elsif the_Command = "-help"
            then
               for Each in usage_help_Text'Range
               loop
                  put_Line (usage_help_Text (Each).all);
               end loop;
            end if;

            Each := Each + 1;
         end;
      end loop;

      declare
         Unused : Hash_Pointer := Preprocessor_define (const_String (-"SWIGAda 1"),  0) with Unreferenced;     -- Add a symbol to the parser for conditional compilation.
         Unused_3 : Hash_Pointer := (if Standard'Address_Size = 64 and then interfaces.C.long'Size = 64     -- The library's 'stdint.i' takes the sizes
                                     then Preprocessor_define (const_String (-"SWIGWORDSIZE64 1"),  0)     -- of the integer types from this.
                                     else null) with Unreferenced;
         Unused_2 : Hash_Pointer := Preprocessor_define (const_String (-"SWIGADA 1"),  0) with Unreferenced;   -- The usual upper case form, as the library files test for.
      begin
         swig_config_File (const_String (-"ada.swg"));
         Logger.Reporter_is (report'Access);
      end;

      Self.allow_Overloading;
      Self.allow_protected_and_private_Members;

      unindent_Log;
   end main;



   overriding
   function top (Self : access Item;
                 N    : in     Node_Pointer) return C.int
   is separate;




   procedure process_all_Modules (Self : in out ada_Language.item)
   is separate;




   procedure prune_unknown_C_Types (Self : in out Item)
   is separate;



   ---------------------------------------
   -- Handlers for Specific C Declarations
   --

   overriding
   function typemapDirective (Self : access Item;
                              N    : in     Node_Pointer) return C.int
   is
      the_Node   :          Node_Pointer renames N;
      the_Method : constant unbounded_String := +Attribute (the_Node, "method");
      the_Code   : constant unbounded_String := +Attribute (the_Node, "code");
   begin
      indent_Log;

      if the_Method = "adatype_new"
      then
         declare
            Pattern      : Node_Pointer    := Node_Pointer (doh_ParmList (first_Child (the_Node)));
            pattern_Type : unbounded_String;
            pattern_Name : unbounded_String;
            new_Key      : unbounded_String;
         begin
            while exists (doh_Item (Pattern))
            loop
               pattern_Type := +Attribute (get_Attribute (Pattern, "pattern"), "type");
               pattern_Name := +Attribute (get_Attribute (Pattern, "pattern"), "name");

               new_Key := pattern_Type;

               if pattern_Name /= ""
               then                      -- TODO: Investigate and document what this is for.
                  append (new_Key, " " & pattern_Name);
               end if;

               Self.c_type_Map_of_ada_type.insert (Self.swig_type_Map_of_c_type.Element (Key => pattern_Type),
                                                   Self.name_Map_of_ada_type   .Element (Key => the_Code));
               Pattern := next_Sibling (Pattern);
            end loop;
         end;
      end if;

      unindent_Log;
      return swigMod.Language.item (Self.all).typemapDirective (the_Node);
   end typemapDirective;



   overriding
   function moduleDirective (Self : access Item;
                             N    : in     Node_Pointer) return C.int
   is
      pragma Unreferenced (Self);
      the_Node :          Node_Pointer renames N;
      the_Name : constant unbounded_String  := +Attribute (the_Node, "name");
   begin
      indent_Log;
      dlog (+"");
      dlog (+"moduleDirective: '" & to_String (the_Name) & "'");

      unindent_Log;
      return SWIG_OK;
   end moduleDirective;



   overriding
   function includeDirective (Self : access Item;
                              N    : in     Node_Pointer) return C.int
   is
      Status : C.int with Unreferenced;
   begin
      indent_Log;

      Status := swigMod.Language.item (Self.all).includeDirective (n);
      unindent_Log;

      return SWIG_OK;
   end includeDirective;



   overriding
   function namespaceDeclaration (Self : access Item;
                                  N    : in Node_Pointer) return C.int
   is
      the_Node :          Node_Pointer renames N;
      the_Name : constant unbounded_String := +Attribute (the_Node, "name");
      Status   :          C.int with Unreferenced;
   begin
      indent_Log;
      dlog (+"");
      dlog (+"namespaceDeclaration: '" & to_String (the_Name) & "'");

      if the_Name /= ""
      then
         Self.add_Namespace (Named => the_Name);
      end if;

      Status := swigMod.Language.item (Self.all).namespaceDeclaration (the_Node);

      unindent_Log;
      return SWIG_OK;
   end namespaceDeclaration;



   overriding
   function classForwardDeclaration (Self : access Item;
                                     N    : in     Node_Pointer) return C.int
   is
      the_Node       :          Node_Pointer renames N;

      the_class_Name : constant String       := Attribute    (the_Node, "name");                   -- Swig 'forward declaration' nodes do not have a 'type'
                                                                                                   -- attribute, so we are using 'name' instead.

      --  A class which is declared in a namespace ('namespace cv { class Mat; }') is named without it here, but
      --  with it wherever it is used ('cv::Mat') and where it is defined, so it is made known by its full name.
      --
      function scope_of_the_Class return String
      is
         use type DOHs.Pointers.DOH_Pointer;
      begin
         if         Self.in_cpp_Mode
           and then ada.Strings.fixed.Index (the_class_Name, "::") = 0
           and then DOH_Pointer (Swig_symbol_qualified (the_Node)) /= null
         then
            return +DOH_Pointer (Swig_symbol_qualified (the_Node));
         else
            return "";
         end if;
      end scope_of_the_Class;

      the_Scope      : constant String       := scope_of_the_Class;
      the_bound_Name : constant String       := (if the_Scope /= "" and then Attribute (the_Node, "sym:name") /= ""
                                                 then Attribute (the_Node, "sym:name")
                                                 else the_class_Name);
      node_Type      : constant doh_swigType := (if the_Scope = "" then doh_swigType (get_Attribute (the_Node, "name"))
                                                                   else doh_swigType (to_Doh (the_Scope & "::" & the_class_Name)));
      Kind           : constant String       := Attribute    (the_Node, "kind");
      is_a_Struct    : constant Boolean      := Kind = "struct";

      new_c_Class    :          c_Type.view;

   begin
      indent_Log;
      dlog (+"");
      dlog (+"'ClassforwardDeclaration'   node_Type: '" & String'(+node_Type) & "'");

      Self.current_c_Node := doh_Node (the_Node);
      locate (doh_Node (the_Node));

      if Self.swig_type_Map_of_c_type.contains (+node_Type)
      then
         unindent_Log;
         return SWIG_OK;     -- The class has already been partially or fully declared, so do nothing.

      else
         --  The class is named as it is bound, which a '%rename' may have changed ('TagLib::FLAC::File' as 'FLACFile').
         --
         if is_a_Struct
         then   new_c_Class := c_Type.new_opaque_Struct    (Namespace => Self.current_c_nameSpace, Name => +the_bound_Name);
         else   new_c_Class := c_Type.new_incomplete_Class (Namespace => Self.current_c_nameSpace, Name => +the_bound_Name);
         end if;

         Self.register (new_c_Class, node_Type);
      end if;

      freshen_current_module_Package (Self, the_Node);     -- Old.
      Self.prior_c_Declaration := new_c_Class.all'Access;

      unindent_Log;
      return SWIG_OK;
   end classForwardDeclaration;



   overriding
   function nativeDirective (Self : access Item;
                             N    : in Node_Pointer) return C.int
   is
      the_Node  :          Node_Pointer renames N;
      wrap_Name : constant String_Pointer    := String_Pointer (get_Attribute (the_Node, "wrap:name"));
      Status    :          C.int with Unreferenced;

      use type C.int;
   begin
      indent_Log;
      dlog (+"");
      dlog (+"'nativeDirective'");

      if Self.addSymbol (wrap_Name, the_Node) = 0
      then
         return SWIG_ERROR;
      end if;

      if get_Attribute (the_Node, "type") /= null
      then
         Swig_save_1   (new_String ("nativeWrapper"),  the_Node,  new_String ("name"));
         set_Attribute (the_Node,                      "name",    wrap_Name);

         Self.native_function_Flag := True;
         Status                    := functionWrapper (Self, the_Node);     -- Delegate to functionWrapper.
         Swig_restore (the_Node);
         Self.native_function_Flag := False;
      else
         dlog (+"No return type for node: '" & String'(+doh_Item (wrap_Name)));
      end if;

      unindent_Log;
      return SWIG_OK;
   end nativeDirective;



   overriding
   function functionWrapper (Self : access Item;
                             N    : in     Node_Pointer) return C.int
   is separate;



   overriding
   function globalVariableHandler (Self : access Item;
                                   N    : in     Node_Pointer) return C.int
   is
      use swigg.Utility;
      use type C.int;

      the_Node      : Node_Pointer renames n;

      the_Name      : unbounded_String := +Attribute (the_Node, "sym:name");
      the_swig_Type : SwigType_Pointer :=  SwigType_Pointer (doh_Copy (DOH_Pointer (get_Attribute (the_Node, "type"))));
      is_Pointer    : constant Boolean :=  SwigType_isPointer (the_swig_Type) /= 0;

      full_Name     : constant String  :=  Attribute (the_Node, "name");                           -- With its namespaces.
      is_Constant   : constant Boolean :=          SwigType_isConst (the_swig_Type) /= 0
                                           or else ada.Strings.fixed.Index (Attribute (the_Node, "storage"), "constexpr") /= 0;
      value_Text    : constant String  :=  Attribute (the_Node, "value");
      type_Text     : constant String  := +DOH_Pointer (the_swig_Type);
      Storage       : constant String  :=  Attribute (the_Node, "storage");

      --  An array of constants is constant too ('const char name [8]', which swig writes 'a(8).q(const).char').
      --
      is_constant_Array : constant Boolean :=          type_Text'Length > 2
                                              and then type_Text (type_Text'First .. type_Text'First + 1) = "a("
                                              and then ada.Strings.fixed.Index (type_Text, ").q(const).") /= 0;

      has_no_Symbol : constant Boolean :=         ada.Strings.fixed.Index (Storage, "static") /= 0
                                          or else (         Self.in_cpp_Mode
                                                   and then (is_Constant or is_constant_Array)
                                                   and then ada.Strings.fixed.Index (Storage, "extern") = 0);
   begin
      indent_Log;
      dlog (+"");
      dlog (+"'globalvariableHandler'");

      Self.current_c_Node := doh_Node (the_Node);
      locate (doh_Node (the_Node));
      freshen_current_module_Package (Self, the_Node);

      strip_Namespaces     (the_Name);
      strip_all_qualifiers (DOH_Pointer (the_swig_Type));

      declare
         use c_Variable;
         new_Variable : constant c_Variable.view := new_c_Variable (Name    => the_Name,
                                                                    of_Type => null);
      begin
         new_Variable.is_Static        := True;
         new_Variable.is_class_Pointer := is_Pointer;                                         -- TODO: Simplify these 'is_pointer' variables.
         new_Variable.is_Pointer       :=        SwigType_isReference        (the_swig_Type) /= 0
                                          or else SwigType_isrvalue_reference (the_swig_Type) /= 0;     -- An rvalue reference ('T&&') is bound as a reference is.

         if swigtype_isArray (the_swig_Type) /= 0
         then
            Self.add_array_Bounds_to (new_Variable,
                                      DOH_Pointer (the_swig_Type));
         end if;

         declare
            Pad                : constant doh_swigType     := doh_Copy (DOH_Pointer (the_swig_Type));
            the_swig_type_Name : constant unbounded_String := strip_array_Bounds (Pad);
         begin
            dlog (+ "the_swig_type: '"
                 & String' (+doh_Item (the_swig_Type))
                 & "'   type name: '"
                 & to_String (the_swig_type_Name)
                 & "'");
            new_Variable.my_Type := Self.demand_c_Type_for (doh_swigType (to_Doh (to_String (the_swig_type_Name))));     -- An unknown type is pruned later.
         end;

         if Self.in_cpp_Mode
         then
            --  A constant with a value ('const int Size = 2;') has no symbol in C++, so it is given its value.
            --
            if         is_Constant
              and then value_Text /= ""
              and then new_Variable.array_Bounds.is_Empty
              and then (        new_Variable.my_Type.is_an_Integer
                        or else to_String (new_Variable.my_Type.Name) in "bool" | "signed char" | "unsigned char")     -- Which are numbers too.
            then
               declare
                  the_Value : gmp.discrete.Integer;
               begin
                  the_Value          := resolved_c_integer_Expression (Self, +value_Text,
                                                                             Self.integer_symbol_value_Map,
                                                                             Self.current_class_namespace_Prefix);     -- Which may raise.
                  new_Variable.Value := +Image (the_Value);

                  --  For a later constant whose value names this one ('const unsigned parse_default = parse_cdata |
                  --  parse_escapes;'), as the value of a '#define' is kept. (Until 2026-11-24 it was not, and such a
                  --  constant was left out.)
                  --
                  if not Self.integer_symbol_value_Map.contains (new_Variable.Name)
                  then
                     Self.integer_symbol_value_Map.insert (new_Variable.Name, the_Value);
                  end if;
               exception
                  when others =>
                     null;     -- The value is not an integer expression, so the constant is imported.
               end;

            elsif      is_Constant
              and then value_Text /= ""
              and then new_Variable.array_Bounds.is_Empty
              and then to_String (new_Variable.my_Type.Name) = "char"
            then   -- A character is given by its position.
               begin
                  new_Variable.Value := +character_Value (Image (resolved_c_integer_Expression (Self, +value_Text,
                                                                                                          Self.integer_symbol_value_Map,
                                                                                                          Self.current_class_namespace_Prefix)));
               exception
                  when others =>
                     null;
               end;

            elsif      is_Constant
              and then value_Text /= ""
              and then new_Variable.array_Bounds.is_Empty
              and then new_Variable.my_Type.is_a_standard_Real
            then
               begin
                  new_Variable.Value := +ada.Strings.fixed.Trim (Long_Float'Image (Long_Float'Value (value_Text)), ada.Strings.Both);
               exception
                  when others =>
                     null;     -- The value is not a plain number.
               end;

            --  A constant pointer to a string literal ('const char* const Message = "...";', of which yaml-cpp's
            --  'ErrorMsg' has 55) is given the text, as a '#define' of a string is. (Until 2026-11-25 it was left out,
            --  as it has no symbol.)
            --
            elsif      is_Constant
              and then get_Attribute (the_Node, "stringval") /= null
              and then new_Variable.array_Bounds.is_Empty
              and then to_String (new_Variable.my_Type.Name) = "char*"
            then
               new_Variable.Value           := +as_Ada_string_Text (Attribute (the_Node, "stringval"));
               new_Variable.is_empty_String := Attribute (the_Node, "stringval") = "";
            end if;

            --  A variable which is 'static', or constant and not 'extern', has no symbol outside its own file,
            --  so it cannot be imported. Where it has no value which is worked out, it is left out.
            --
            if         new_Variable.Value = ""
              and then has_no_Symbol
            then
               warn (not_Bound, "Unable to bind the variable '" & to_String (the_Name) & "', which has no symbol outside its file, being 'static' or constant, and no value which can be worked out.");
               unindent_Log;
               return SWIG_OK;
            end if;

            --  A variable in a namespace is imported by its C++ symbol.
            --
            if         new_Variable.Value = ""
              and then ada.Strings.fixed.Index (full_Name, "::") /= 0
            then
               new_Variable.link_Symbol := +cpp_Symbol (full_Name, Suffix => variable_Suffix (type_Text));

               --  A variable of the standard library ('std::cout'), whose namespace is abbreviated.
               --
               if         new_Variable.link_Symbol = ""
                 and then full_Name'Length > 5
                 and then full_Name (full_Name'First .. full_Name'First + 4) = "std::"
                 and then ada.Strings.fixed.Index (full_Name, "::", From => full_Name'First + 5) = 0
               then
                  new_Variable.link_Symbol := +(  "_ZSt" & ada.Strings.fixed.Trim (Natural'Image (full_Name'Length - 5), ada.Strings.Left)
                                                & full_Name (full_Name'First + 5 .. full_Name'Last));
               end if;

            elsif      new_Variable.Value = ""
              and then variable_Suffix (type_Text) /= "E"
            then   -- A variable in no namespace is not mangled, but for the tag of a string.
               new_Variable.link_Symbol := +("_Z" & ada.Strings.fixed.Trim (Natural'Image (full_Name'Length), ada.Strings.Left) & full_Name & "B5cxx11");

            elsif      new_Variable.Value = ""
              and then full_Name /= to_String (the_Name)
            then   -- The symbol is the name which the library knows the variable by, which a '%rename' does not change.
               new_Variable.link_Symbol := +full_Name;
            end if;

         elsif has_no_Symbol
         then   -- In C a constant has a symbol, and a 'static' variable has none.
            warn (not_Bound, "Unable to bind the variable '" & to_String (the_Name) & "', which is 'static' and so has no symbol outside its file.");
            unindent_Log;
            return SWIG_OK;

         elsif full_Name /= to_String (the_Name)
         then
            new_Variable.link_Symbol := +full_Name;
         end if;

         Self.Module_top.C.new_c_Variables.append (new_Variable);

         unindent_Log;
         return SWIG_OK;
      end;
   end globalVariableHandler;



   overriding
   function enumDeclaration (Self : access Item;
                             N    : in     Node_Pointer) return C.int
   is
      the_Node      : Node_Pointer renames N;
      doh_swig_Type : SwigType_Pointer := SwigType_Pointer (get_Attribute (the_Node, "enumtype"));
      new_c_Enum    : c_Type.view;
      Status        : C.int with Unreferenced;
   begin
      indent_Log;
      dlog (+"");
      dlog (+"enumDeclaration - '" & String' (+DOH_Pointer (doh_swig_Type)) & "'");

      --  An enumeration of a class which is not public is bound all the same (until 2026-11-24 it was passed over): a
      --  member of the class of its type was then of a type which is not known, and was left out, so that the record
      --  was smaller than its class (jsoncpp's 'Reader::Token', with a member of its private 'TokenType'). It declares
      --  nothing which can be called.
      --
      Self.current_c_Node := doh_Node (the_Node);
      locate (doh_Node (the_Node));

      declare
         the_Name          : unbounded_String := +Attribute (the_Node, "sym:name");        -- Will be null string for an anonymous enum.
         the_doh_swig_Type : SwigType_Pointer := SwigType_Pointer (doh_Copy (DOH_Pointer (doh_swig_Type)));
      begin
         dlog ("the_Name: '" & the_Name & "'");

         --  The core gives an enumeration of a class which is not public no 'sym:name', as it is not wrapped: it is
         --  named by its own name, and is no anonymous enumeration.
         --
         if         the_Name = ""
           and then Self.getCurrentClass /= null
           and then Self.cplus_Mode      /= swigMod.Dispatcher.Public
           and then Attribute (the_Node, "name") /= ""
           and then Attribute (the_Node, "unnamed") = ""
         then
            the_Name := +Attribute (the_Node, "name");
         end if;

         if the_Name = ""
         then
            Self.anonymous_c_enum_Count := Self.anonymous_c_enum_Count + 1;
            the_Name                    := "anonymous_enum_" & (+Image (Self.anonymous_c_enum_Count));
            the_doh_swig_Type           := SwigType_Pointer (to_Doh (to_String (the_Name)));

         elsif          Length (the_Name) >= 8
               and then Slice  (the_Name, 1, 8) = "$unnamed"
         then
            Self.anonymous_c_enum_Count := Self.anonymous_c_enum_Count + 1;
            the_doh_swig_Type           := SwigType_Pointer (to_Doh (to_String (the_Name)));
            the_Name                    := "anonymous_enum_" & (+Image (Self.anonymous_c_enum_Count));
         end if;

         dlog (  "the_Name: '"
              & the_Name
              & "'   the_doh_swig_Type: '"
              & String' (+DOH_Pointer (the_doh_swig_Type))
              & "'");

         --  The enumeration may have been used before it is declared, and then made a type which is not known: a
         --  member of a class whose type is an enumeration of a structure nested in it (yaml-cpp's '_Tag', whose
         --  'type' is a '_Tag::Type::value'), as the core moves the nested structure out after the class. The type
         --  becomes the enumeration, as one which is used ahead of its class becomes the class. (Until 2026-11-25 it
         --  stayed not known, as a swig type is registered once, and the member was left out.)
         --
         declare
            use type c_Type.a_c_type_Kind;
            Key : constant unbounded_String := +doh_Item (the_doh_swig_Type);
         begin
            if         Self.swig_type_Map_of_c_type.contains (Key)
              and then Self.swig_type_Map_of_c_type.Element  (Key).c_type_Kind = c_Type.Unknown
            then
               new_c_Enum     := Self.swig_type_Map_of_c_type.Element (Key);
               new_c_Enum.all := c_Type.Enum_construct (nameSpace => Self.current_c_Namespace,
                                                        Name      => the_Name);
               Self.add_new_c_Type (new_c_Enum);     -- Moved after its class, whose package must come first, as 'register'
                                                     -- does nothing for a swig type which it has; and so are the types which
                                                     -- were made with it.
               --  Those types are named after the enumeration, as 'register' would have named them, and the enumeration
               --  and they are known by their names. (A first form of this step left them their names of the type which
               --  was not known, 'Tree<(int)>::types[]', by which no lookup found them, and the run ended.)
               --
               if not Self.name_Map_of_c_type.contains (the_Name)
               then
                  Self.name_Map_of_c_type.insert (the_Name, new_c_Enum);
               end if;

               declare
                  type Prefix_array is array (Positive range <>) of unbounded_String;
                  Prefixes : constant Prefix_array := [+"a.", +"p.", +"a.p.", +"p.p."];
                  Suffixes : constant Prefix_array := [+"[]", +"*",  +"*[]",  +"**"];
               begin
                  for Each in Prefixes'Range
                  loop
                     if Self.swig_type_Map_of_c_type.contains (Prefixes (Each) & Key)
                     then
                        declare
                           the_Type : constant c_Type.view      := Self.swig_type_Map_of_c_type.Element (Prefixes (Each) & Key);
                           its_Name : constant unbounded_String := the_Name & Suffixes (Each);
                        begin
                           the_Type.Name_is (its_Name);

                           if not Self.name_Map_of_c_type.contains (its_Name)
                           then
                              Self.name_Map_of_c_type.insert (its_Name, the_Type);
                           end if;

                           Self.add_new_c_Type (the_Type);
                        end;
                     end if;
                  end loop;
               end;
            else
               new_c_Enum := c_type.new_Enum (Namespace => Self.current_c_Namespace,
                                              Name      => the_Name);
            end if;
         end;

         Self.register (new_c_Enum,
                        doh_SwigType (the_doh_swig_Type));

         --  The innermost namespace of an enumeration which is in no class, by which it is named where another of the
         --  top package has its name.
         --
         if Self.getCurrentClass = null
         then
            declare
               Scope : constant String := +doh_Item (Swig_symbol_qualified (the_Node));
               Last  : constant Natural := ada.Strings.fixed.Index (Scope, "::", Going => ada.Strings.Backward);
            begin
               new_c_Enum.enum_Scope_is (+(if Last = 0 then Scope else Scope (Last + 2 .. Scope'Last)));
            end;
         end if;

         --  An enumeration which names its underlying type is of the size of that type.
         --
         if get_Attribute (the_Node, "enumbase") /= null
         then
            declare
               the_Base : constant String := +doh_Item (SwigType_typedef_resolve_all (SwigType_Pointer (get_Attribute (the_Node, "enumbase"))));
            begin
               new_c_Enum.enum_Size_is (if    the_Base in "char"  | "signed char" | "unsigned char"  | "bool"               then  8
                                        elsif the_Base in "short" | "unsigned short"                                        then 16
                                        elsif the_Base in "long"  | "unsigned long" | "long long" | "unsigned long long"    then 64
                                        else  0);
            end;
         end if;

         Self.current_c_Enum        := new_c_Enum;
         Self.last_c_enum_rep_Value := -1;
      end;


      --  old ...
      --

      freshen_current_module_Package (Self, doh_Node (the_Node));


      if String' (+DOH_Pointer (doh_swig_Type)) = "enum "
      then   -- Handle anonymous enums.
         Self.anonymous_enum_Count := Self.anonymous_enum_Count + 1;

         declare
            new_enum_Name : constant String := "anonymous_enum_" & Image (Self.anonymous_enum_Count);
         begin
            set_Attribute (the_Node,  "type",     "enum " & new_enum_Name);
            set_Attribute (the_Node,  "sym:name", new_enum_Name);
            set_Attribute (the_Node,  "name",     new_enum_Name);
            set_Attribute (the_Node,  "enumtype", new_enum_Name);

            doh_swig_Type := SwigType_Pointer (get_Attribute (the_Node, "enumtype"));
         end;
      end if;

      --  The core's handler passes over an enumeration of a class which is not public, so its literals are given to
      --  the module's handler here.
      --
      if         Self.getCurrentClass /= null
        and then Self.cplus_Mode      /= swigMod.Dispatcher.Public
      then
         declare
            the_Literal : Node_Pointer := first_Child (the_Node);
         begin
            while the_Literal /= null
            loop
               if Attribute (the_Literal, "nodeType") = "enumitem"
               then
                  Status := Self.enumvalueDeclaration (the_Literal);
               end if;

               the_Literal := next_Sibling (the_Literal);
            end loop;
         end;
      else
         Status := swigMod.Language.item (Self.all).enumDeclaration (the_Node);     -- Process each enum element (ie the enum literals).
      end if;

      --  new ...
      --
      Self.current_c_Enum      := null;
      Self.prior_c_Declaration := new_c_Enum.all'Access;

      unindent_Log;
      return SWIG_OK;
   end enumDeclaration;



   overriding
   function enumvalueDeclaration (Self : access Item;
                                  N    : in     Node_Pointer) return C.int
   is
      the_Node : Node_Pointer         renames N;
      symName  : constant unbounded_String := (if Attribute (the_Node, "sym:name") /= ""      -- A literal of an enumeration which
                                               then +Attribute (the_Node, "sym:name")          -- is not public has no 'sym:name'.
                                               else +Attribute (the_Node, "name"));

      --  old ...
      --
      value_Text : aliased unbounded_String := +Attribute (the_Node, "feature:ada:constvalue");   -- Check for the %adaconstvalue feature.

   begin
      indent_Log;
      dlog (+"");
      dlog (+"enumvalueDeclaration - '" & Attribute (the_Node, "name") & "'");

      --  new ...
      --
      declare
         enum_value_Text : constant unbounded_String := +Attribute (the_Node, "enumvalue");
      begin
         if enum_value_Text = ""
         then
            Self.last_c_enum_rep_Value := Self.last_c_enum_rep_Value + 1;

         else
            begin
               Self.last_c_enum_rep_Value := Value (resolved_c_integer_Expression (Self, enum_value_Text,
                                                                                         Self.integer_symbol_value_Map,
                                                                                         Self.current_class_namespace_Prefix));
            exception
               when constraint_Error =>
                  --  Such as a value which depends upon a template parameter. The next value is used, as it is for a literal
                  --  given no value, which keeps the literals of the enumeration distinct.
                  --
                  Self.last_c_enum_rep_Value := Self.last_c_enum_rep_Value + 1;

                  warn (Value, "Unable to evaluate the value '" & enum_value_Text & "' of the enumeration literal '" & symName
                             & "', which is given the value" & Self.last_c_enum_rep_Value'Image & ".");
            end;
         end if;

         if not Self.integer_symbol_value_Map.contains (symName)     -- A literal of the same name may belong to an enumeration of another scope.
         then
            insert (Self.integer_symbol_value_Map, symName, to_Integer (Self.last_c_enum_rep_Value));
         end if;

         Self.current_c_Enum.add_Literal (Name  => symName,
                                          Value => to_Integer (Self.last_c_enum_rep_Value));
      end;

      --  old ...
      --
      if    Self.getCurrentClass /= null
        and Self.cplus_mode      /= swigMod.Dispatcher.Public
      then
         return SWIG_NOWRAP;
      end if;  -- TODO: redundant (ie check is done in parent node) ?

      if value_Text = "" then
         value_Text := +Attribute (the_Node, "enumvalue");
      end if;

      if get_Attribute (parent_Node (the_Node), "enumvalues") = null
      then
         set_Attribute (parent_Node (the_Node), "enumvalues", +symname);
      end if;

      --  new ...
      --
      unindent_Log;
      return SWIG_OK;
   end enumvalueDeclaration;



   overriding
   function constantWrapper (Self : access Item;
                             N    : in     Node_Pointer) return C.int
   is separate;



   overriding
   function classHandler (Self : access Item;
                          N    : in Node_Pointer) return C.int
   is separate;



   overriding
   function memberFunctionHandler (Self : access Item;
                                   N    : in     Node_Pointer) return C.int
   is
      the_Node        :          Node_Pointer renames N;
      Status          :          C.int with Unreferenced;
      function_Name   : constant String  := Attribute (the_Node, "name");

      Value           : constant String  := Attribute (the_Node, "value");
      is_Virtual      : constant Boolean := is_declared_Virtual (the_Node);
      is_Pure         : constant Boolean := Value   = "0";
      is_pure_Virtual : constant Boolean := is_Pure and is_Virtual;

      overriding_Value : constant Node_Pointer := get_Attribute (the_Node, "override");

      function owner_is_among_Bases (the_Class : in c_Type.view;   Owner        : in String;
                                                                   parents_only : in Boolean) return Boolean
      is
         Bases : constant c_Type.Vector := the_Class.base_Classes;
      begin
         if parents_only
         then   -- The parent of the Ada type, and the parents of that.
            declare
               the_Parent : constant c_Type.view := the_Class.ada_Parent;
            begin
               return          the_Parent /= null
                      and then (        the_Parent.Name = Owner
                                or else owner_is_among_Bases (the_Parent, Owner, parents_only));
            end;
         end if;

         for Each of Bases
         loop
            if        Each.Name = Owner
              or else owner_is_among_Bases (Each, Owner, parents_only)
            then
               return True;
            end if;
         end loop;

         return False;
      end owner_is_among_Bases;


      function is_Overriding return Boolean
      --
      --  Only the first virtual base class of a class is kept as its parent, so a function which overrides
      --  one from another base class has nothing to override in the Ada binding.
      --
      is
      begin
         if        overriding_Value = null
           or else Self.current_c_Class.base_Classes.is_Empty     -- Such as a smart pointer, which is given the functions of the class it points to.
         then
            return False;
         end if;

         declare
            Owner : constant String := Attribute (parent_Node (overriding_Value), "sym:name");
         begin
            return        owner_is_among_Bases (Self.current_c_Class, Owner, parents_only => True)
                  or else not owner_is_among_Bases (Self.current_c_Class, Owner, parents_only => False);     -- The owner is not known by this name.
         end;
      end is_Overriding;

      function get_Namespace return String
      is
      begin
         if        is_pure_Virtual
           or else C."/=" (Self.is_smart_Pointer, 0)               -- The function of the pointee has its class name already.
           or else Attribute (the_Node, "feature:extend") /= ""    -- A function added by '%extend' is not a member, and is called by a name which the core makes.
           or else Self.following_a_using_Declaration              -- A function of a base class is called as one of this class, which dispatches where it is virtual.
           or else is_called_through_its_Wrapper (Self, the_Node)  -- Whose function of the wrapper makes the virtual call.
           or else (         is_declared_Virtual (the_Node)     -- The form of a virtual function with a default argument left out is
                    and then get_Attribute (the_Node, "defaultargs") /= null)     -- not virtual in Ada, so the wrapper makes the virtual call.
         then
            return "";
         else   -- The class is named as C++ knows it ('Base< int >'), which for a template instance is not the name it is bound by.
            return String'(+doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (Self.getCurrentClass, "name"))))) & "::";
         end if;
      end get_Namespace;

      function virtual_in_a_Base (the_Class : in Node_Pointer) return Node_Pointer
      --
      --  The virtual function of the name and the parameters of this one which a base class of the class, or
      --  one of those, has. Null where there is none.
      --
      is
         use type DOH_Pointer;
         use type C.int;

         function plain (Name : in String) return String
         is
            Colons : constant Natural := ada.Strings.fixed.Index (Name, "::", Going => ada.Strings.Backward);
         begin
            return (if Colons = 0 then Name else Name (Colons + 2 .. Name'Last));
         end plain;

         function resolved (the_Function : in Node_Pointer) return String
         is
         begin
            return (if get_Attribute (the_Function, "decl") = null then ""
                    else +doh_Item (SwigType_typedef_resolve_all (SwigType_Pointer (get_Attribute (the_Function, "decl")))));
         end resolved;

         Bases : constant DOH_Pointer := DOH_Pointer (get_Attribute (the_Class, "allbases"));
      begin
         if Bases = null
         then
            return null;
         end if;

         for Each in 0 .. DohLen (Bases) - 1
         loop
            declare
               the_Base   : constant Node_Pointer := Node_Pointer (DohGetitem (Bases, Each));
               the_Member :          Node_Pointer := first_Child (the_Base);
            begin
               while the_Member /= null
               loop
                  if         Attribute (the_Member, "nodeType") = "cdecl"
                    and then plain (Attribute (the_Member, "name")) = plain (function_Name)     -- The name of a member which has been dealt with is qualified.
                    and then resolved (the_Member)              = resolved (the_Node)     -- A parameter may be named by a typedef in one of them.
                    and then is_declared_Virtual (the_Member)
                  then
                     return the_Member;
                  end if;

                  the_Member := next_Sibling (the_Member);
               end loop;

               if virtual_in_a_Base (the_Base) /= null
               then
                  return virtual_in_a_Base (the_Base);
               end if;
            end;
         end loop;

         return null;
      end virtual_in_a_Base;

      function overrides_in_the_Parents return Boolean
      --
      --  True where a class which the Ada type is derived from has a virtual function of the name and the
      --  parameters of this one, whether or not the core says that this one overrides.
      --
      is
         Overridden : constant Node_Pointer := virtual_in_a_Base (Self.getCurrentClass);
      begin
         return          Overridden /= null
                and then owner_is_among_Bases (Self.current_c_Class,
                                               Attribute (parent_Node (Overridden), "sym:name"),
                                               parents_only => True);
      end overrides_in_the_Parents;

      through_its_Wrapper : constant Boolean := is_called_through_its_Wrapper (Self, the_Node);
      Namespace           : constant String  := get_Namespace;
   begin
      indent_Log;
      dlog (+"");
      dlog (+"memberFunctionHandler");

      Self.current_c_Node := doh_Node (the_Node);
      locate (doh_Node (the_Node));

      --  A class with an 'operator->' is a smart pointer, which the core gives every function of the class which it
      --  points to, those which that class inherits among them. C++ inherits no 'operator=': a class has one of its
      --  own, which hides those of its bases, so that one which the class pointed to has from a base is called on
      --  that class and does not compile (yaml-cpp's iterator, which points to an 'iterator_value', derived from a
      --  'Node' whose instances of 'operator=<T>' the interface names). An assignment through a smart pointer is
      --  left out, as the module does not know which class the function is a member of; the object is assigned
      --  through its own class.
      --
      if         C."/=" (Self.is_smart_Pointer, 0)
        and then ada.Strings.fixed.Index (function_Name, "operator =") = 1
      then
         unindent_Log;
         return SWIG_OK;
      end if;

      if not Self.following_a_using_Declaration     -- Whose functions are no members of the class, and have no place among them.
      then
         add_hidden_Virtuals (Self, before => the_Node);
      end if;

      set_Attribute (the_Node, "name", Namespace & function_Name);

      Status := swigMod.Language.item (Self.all).memberFunctionHandler (the_Node);

      if check_Attribute (the_Node, "access", "private")
      then
         --  No wrapper is made for a private function, so it cannot be called from Ada. (Until 2026-11-23 it was
         --  declared all the same, and imported the function of the wrapper which happened to be made before it.)
         --  What is done depends on its place in the vtable:
         --
         --  - One which is not virtual has none, and is left out.
         --  - A virtual one which overrides nothing has a place of its own, which is held.
         --  - One which overrides a function that is not pure needs nothing: that function has the place, and a
         --    call of it dispatches here.
         --  - One which overrides a pure virtual function is declared, as the Ada type would else be abstract, and
         --    imports no function. It is reached by a dispatching call alone.
         --
         --  The core does not say of a private function that it overrides, so the base classes are looked through.
         --
         if         is_declared_Virtual (the_Node)
           and then get_Attribute (the_Node, "defaultargs") = null
           and then Attribute (the_Node, "feature:extend")  = ""
         then
            declare
               Overridden : constant Node_Pointer := (if is_Overriding then overriding_Value
                                                                       else virtual_in_a_Base (Self.getCurrentClass));
            begin
               if Overridden = null
               then
                  declare
                     the_Placeholder : constant c_Function.view := c_Function.new_c_Function (+function_Name,
                                                                                              Self.name_Map_of_c_type.Element (+"void"));
                  begin
                     the_Placeholder.Parameters.append (c_Parameter.new_c_Parameter (the_Name => +"Self",
                                                                                     the_Type => Self.current_c_Class.all'Access));
                     the_Placeholder.is_Virtual     := True;
                     the_Placeholder.is_Abstract    := False;     -- A class which defines it does so privately too, as a rule, which adds
                     the_Placeholder.is_Placeholder := True;      -- nothing to the binding: were this abstract, that class would be so in Ada.

                     Self.current_c_Class.nameSpace.add (the_Placeholder.all'Access);
                  end;

               elsif      Attribute (Overridden, "abstract") /= ""
                 and then not check_Attribute (Overridden, "access", "private")     -- One which is private is not declared, and so not abstract in Ada.
               then
                  declare
                     the_new_Function : constant c_Function.view := Self.new_c_Function (doh_Node (the_Node),
                                                                                         +Attribute (the_Node, "sym:name"),
                                                                                         Self.current_c_Class.nameSpace.all'Access,
                                                                                         is_Destructor => False,
                                                                                         is_Overriding => True);
                  begin
                     if c_Function."/=" (the_new_Function, null)
                     then
                        the_new_Function.link_Symbol := +"unbound";
                     end if;
                  end;
               end if;
            end;
         end if;

         unindent_Log;
         return SWIG_OK;
      end if;

      declare
         the_new_Function : c_Function.view;
      begin
         the_new_Function := Self.new_c_Function (doh_Node (the_Node),
                                                  +Attribute (the_Node, "sym:name"),
                                                  Self.current_c_Class.nameSpace.all'Access,
                                                  is_Destructor => False,
                                                  is_Overriding =>          is_Overriding
                                                                   and then get_Attribute (the_Node, "defaultargs") = null     -- Only the form of all its arguments is virtual.
                                                                   and then not Self.following_a_using_Declaration             -- Nor is a function which a 'using' declaration names.
                                                                   and then not through_its_Wrapper                            -- Nor one which Ada cannot call through the vtable.
                                                                   and then Attribute (the_Node, "feature:extend") = ""        -- A function which '%extend' adds is no member, and
                                                                   and then Attribute (overriding_Value, "feature:extend") = "");     -- neither overrides nor is overridden.

         if         through_its_Wrapper
           and then not Self.current_c_Class.has_an_unknown_Base      -- Whose places are not known, so none can be held.
           and then not is_Overriding                                 -- One which overrides a function of the parent of the Ada type has its place.
           and then not overrides_in_the_Parents                      -- The core does not say so of a function which is not public.
           and then get_Attribute (the_Node, "defaultargs") = null     -- C++ has one virtual function, that of all its arguments.
           and then Attribute (the_Node, "feature:extend")  = ""
         then
            --  The function is no primitive, and its place in the vtable is held. The place holder is not abstract:
            --  a class which defines the function adds no primitive either, and would else be abstract in Ada.
            --
            declare
               the_Placeholder : constant c_Function.view := c_Function.new_c_Function (+function_Name,
                                                                                        Self.name_Map_of_c_type.Element (+"void"));
            begin
               the_Placeholder.Parameters.append (c_Parameter.new_c_Parameter (the_Name => +"Self",
                                                                               the_Type => Self.current_c_Class.all'Access));
               the_Placeholder.is_Virtual     := True;
               the_Placeholder.is_Placeholder := True;

               Self.current_c_Class.nameSpace.add (the_Placeholder.all'Access);
            end;
         end if;

         if c_Function."/=" (the_new_Function, null)     -- No function is made for an overload which cannot be told apart in Ada.
         then
            Self.prior_c_Declaration := the_new_Function.all'Access;

         elsif      is_declared_Virtual (the_Node)
           and then get_Attribute (the_Node, "override")    = null
           and then get_Attribute (the_Node, "defaultargs") = null
           and then Attribute (the_Node, "feature:extend")  = ""
         then
            --  Such an overload is a virtual function of C++ all the same, and has its place in the vtable. Its place
            --  holder is not abstract, though the function is pure: a class which defines the function cannot have it
            --  told apart either, so that its definition is left out, and the class would else be abstract in Ada
            --  (Bullet's 'btCollisionDispatcher', of the two 'getInternalManifoldPool' of 'btDispatcher', one 'const').
            --
            declare
               the_Placeholder : constant c_Function.view := c_Function.new_c_Function (+function_Name,
                                                                                        Self.name_Map_of_c_type.Element (+"void"));
            begin
               the_Placeholder.Parameters.append (c_Parameter.new_c_Parameter (the_Name => +"Self",
                                                                               the_Type => Self.current_c_Class.all'Access));
               the_Placeholder.is_Virtual     := True;
               the_Placeholder.is_Placeholder := True;

               Self.current_c_Class.nameSpace.add (the_Placeholder.all'Access);
            end;
         end if;
      end;

      unindent_Log;
      return SWIG_OK;
   end memberFunctionHandler;



   overriding
   function staticMemberFunctionHandler (Self : access Item;
                                         N    : in     Node_Pointer) return C.int
   is
      the_Node    : Node_Pointer renames N;
      Status      : C.int with Unreferenced;
      member_Name : constant String := Attribute (the_Node, "sym:name");     -- The base handler gives the node the name of its wrapper.
   begin
      indent_Log;
      dlog (+"");
      dlog (+"'staticMemberFunctionHandler'");

      Self.current_c_Node := doh_Node (the_Node);
      locate (doh_Node (the_Node));

      Self.static_Flag := True;
      Status := swigMod.Language.item (Self.all).staticMemberFunctionHandler (the_Node);

      --  A static member function is a function of the package of its class, with no 'Self' parameter.
      --
      if         not Self.c_class_Stack.is_Empty
        and then get_Attribute (the_Node, "overload:ignore") = null
      then
         declare
            the_new_Function : c_Function.view;
         begin
            the_new_Function := Self.new_c_Function (doh_Node (the_Node),
                                                     +member_Name,
                                                     Self.current_c_Class.nameSpace.all'Access,
                                                     is_Destructor => False);

            if c_Function."/=" (the_new_Function, null)
            then
               Self.prior_c_Declaration := the_new_Function.all'Access;
            end if;
         end;
      end if;

      Self.static_Flag := False;

      unindent_Log;
      return SWIG_OK;
   end staticMemberFunctionHandler;



   overriding
   function constructorHandler (Self : access Item;
                                N    : in     Node_Pointer) return C.int
   is separate;



   overriding
   function destructorHandler (Self : access Item;
                               N    : in     Node_Pointer) return C.int
   is separate;



   overriding
   function memberVariableHandler (Self : access Item;
                                   N    : in Node_Pointer) return C.int
   is
      use swigg.Utility;
      use type C.int;
      use type swig_Module.swig_Module_view;
      the_Node : doh_Node renames N;

      swig_Type          :          SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (get_Attribute (the_Node, "type"))));
      swig_Type_is_array : constant Boolean          := SwigType_isArray   (swig_Type) /= 0;
      is_Pointer         : constant Boolean          := SwigType_isPointer (swig_Type) /= 0;
      variable_Name      : constant unbounded_String := +Attribute (the_Node, "sym:name");

      function has_virtual_Base return Boolean
      --
      --  Whether the Ada type of the class has a parent, so that the record is a type extension.
      --
      is
         use type c_Type.view;
      begin
         return Self.current_c_Class.ada_Parent /= null;
      end has_virtual_Base;

   begin
      indent_Log;
      dlog (+"");
      dlog ("'memberVariableHandler':    Name => " & variable_Name & "     swig_Type: '" & String' (+doh_Item (swig_Type)));

      strip_all_Qualifiers (doh_Item (swig_Type));
      Self.current_c_Node := doh_Node (the_Node);
      locate (doh_Node (the_Node));

      if         Self.is_smart_Pointer = 0                       -- Don't add a new member variable during smart pointer resolution.
        and then Attribute (the_Node, "feature:extend") = ""     -- Nor one added by '%extend', which is not a data member of the class.
      then
         declare
            use c_Variable;
            new_Variable : c_Variable.view;
            bit_Field    : constant String := Attribute (the_Node, "bitfield");
         begin
            add_hidden_Members (Self, before => the_Node);

            if swig_Type_is_array
            then
               declare
                  unconstrained_array_swigType : constant unbounded_String := strip_array_Bounds (doh_Copy (doh_Item (swig_Type)));
               begin
                  new_Variable := new_c_Variable (variable_Name,
                                                  Self.demand_c_Type_for (doh_swigType (to_Doh (to_String (unconstrained_array_swigType)))));
               end;
            else
               new_Variable := new_c_Variable (variable_Name,
                                               Self.demand_c_Type_for (doh_SwigType (swig_Type)));
            end if;

            new_Variable.is_Static        := False;
            new_Variable.is_class_Pointer := is_Pointer;

            --  A member whose type is a typedef of a smart pointer of the standard library is noted, as the prune step
            --  knows such a pointer by the name of its type, which it sees no further than the typedef (yaml-cpp's
            --  'Node::m_pMemory', a 'shared_memory_holder').
            --
            if smart_Pointer_Words (+doh_Item (swig_Type)) = 0
            then
               new_Variable.smart_Words := smart_Pointer_Words (+doh_Item (SwigType_typedef_resolve_all (swig_Type)));
            end if;

            if bit_Field /= ""
            then
               new_Variable.bit_Field := Integer (Value (resolved_c_integer_Expression (Self, +bit_Field,
                                                                                               Self.integer_symbol_value_Map,
                                                                                               Self.current_class_namespace_Prefix)));

            elsif      Attribute (the_Node, "access") not in "private" | "protected"
              and then SwigType_isReference        (swig_Type) = 0
              and then SwigType_isrvalue_reference (swig_Type) = 0
            then   -- The wrapper file can ask where the member is.
               new_Variable.member_Name := +Attribute (the_Node, "name");
            end if;

            if swig_Type_is_Array
            then
               Self.add_array_Bounds_to (new_Variable, doh_SwigType (swig_Type));
            end if;

            if Self.in_cpp_Mode
            then
               Self.current_c_Class.add_Component (new_Variable);
            else   -- In C the core gives the members out of their order, where some are declared with a structure which has no name.
               new_Variable.Line := Natural (DohGetline (DOH_Pointer (the_Node)));
               Self.current_c_Class.add_Component_in_Order (new_Variable);
            end if;
         end;

         --  A class which is derived from a virtual class is a type extension in Ada, whose components begin after the
         --  whole of the parent. C++ begins the members of the derived class in the unused tail of its base class, where
         --  they fit, so a component may not be where its member is. Such a member is therefore read and written through
         --  functions of the wrapper, and its component only reserves storage (see the transformer).
         --
         if         Self.in_cpp_Mode
           and then has_virtual_Base
           and then not check_Attribute (the_Node, "access", "private")     -- No wrapper is made for a private member,
           and then Self.current_Module = Self.Module_top'Access            -- nor for one of a class of an imported module.
         then
            declare
               Status : C.int with Unreferenced;
            begin
               --  A member of a class which cannot be assigned (whose assignment operator is private or deleted) is
               --  read and not written. The core says so of the member (its 'allocate' step marks it immutable) where
               --  it has met that class first, which it has not where the class is a template instance named after the
               --  class of the member ('DynArray<const char*, 10> _stack;' of tinyxml2's 'XMLPrinter', and the
               --  '%template' after the header): the set function then assigned through an operator which is declared
               --  and never defined, and a program did not link.
               --
               declare
                  Resolved  : constant SwigType_Pointer := SwigType_typedef_resolve_all (swig_Type);
                  the_Class : constant Node_Pointer     := (if SwigType_type (Resolved) = T_USER
                                                            then Swig_symbol_clookup (DOHs.const_String_or_char_ptr.Item (Resolved), null)
                                                            else null);
               begin
                  if         the_Class /= null
                    and then Attribute (the_Class, "nodeType") = "class"
                    and then Attribute (the_Class, "allocate:noassign") /= ""
                  then
                     set_Attribute (the_Node, "feature:immutable", "1");
                  end if;
               end;

               Self.accessor_member_Name  := variable_Name;
               Self.variable_wrapper_flag := True;

               Status := swigMod.Language.item (Self.all).memberVariableHandler (the_Node);

               Self.variable_wrapper_flag := False;
               Self.accessor_member_Name  := null_unbounded_String;
            end;
         end if;
      end if;

      unindent_Log;
      return SWIG_OK;
   end memberVariableHandler;



   overriding
   function nestedClassesSupport (Self : access Item) return swigMod.Language.NestedClassSupport
   is
      pragma Unreferenced (Self);
   begin
      return swigMod.Language.NCS_None;
   end nestedClassesSupport;



   overriding
   function staticMemberVariableHandler (Self : access Item;
                                         N    : in Node_Pointer) return C.int
   is
      the_Node      :          doh_Node    renames  N;
      the_swigType  : constant doh_SwigType     :=  doh_SwigType (get_Attribute (the_Node, "type"));
      variable_Name : constant unbounded_String := +Attribute (the_Node, "sym:name");

      use type swig_Module.swig_Module_view;
   begin
      indent_Log;
      dlog (+"");
      dlog (+"'staticMemberVariableHandler':    Name => " & variable_Name & "   swig_type: " & to_String (the_swigType));

      Self.current_c_Node := doh_Node (the_Node);
      locate (doh_Node (the_Node));

      --  A static member variable is a variable of the package of its class, imported by its C++ symbol. One which is
      --  constant and has a value ('static const int Size = 4;') need have no symbol, and is given its value.
      --
      if        not Self.in_cpp_Mode
        or else Self.getCurrentClass = null
        or else Self.current_Module /= Self.Module_top'Access
        or else Attribute (the_Node, "access") in "private" | "protected"
      then
         unindent_Log;
         return SWIG_OK;
      end if;

      --  One which the interface file adds with '%extend' is not a variable: it is a pair of functions, and has no symbol.
      --
      if Attribute (the_Node, "feature:extend") /= ""
      then
         warn (not_Bound, "Unable to bind the static member variable '" & variable_Name & "', which is added by '%extend' and is no variable of C++.");
         unindent_Log;
         return SWIG_OK;
      end if;

      declare
         use swigg.Utility;
         use type C.int;

         the_swig_Type :          SwigType_Pointer := SwigType_Pointer (doh_Copy (DOH_Pointer (the_swigType)));
         is_Constant   : constant Boolean          :=         SwigType_isConst (the_swig_Type) /= 0
                                                      or else ada.Strings.fixed.Index (Attribute (the_Node, "storage"), "constexpr") /= 0;
         value_Text    : constant String           := Attribute (the_Node, "value");
         class_Name    : constant String           := +DOH_Pointer (get_Attribute (Self.getCurrentClass, "name"));

         --  The symbol is made from the name which C++ knows the variable by, which a '%rename' does not change.
         --
         the_Symbol    : constant String           := cpp_Symbol (class_Name & "::" & Attribute (the_Node, "name"),
                                                                  Suffix => variable_Suffix (+DOH_Pointer (the_swigType)));

         new_Variable  : constant c_Variable.view  := c_Variable.new_c_Variable (Name    => variable_Name,
                                                                                 of_Type => null);
      begin
         new_Variable.is_Static        := True;
         new_Variable.is_class_Pointer := SwigType_isPointer   (the_swig_Type) /= 0;
         new_Variable.is_Pointer       :=        SwigType_isReference        (the_swig_Type) /= 0
                                          or else SwigType_isrvalue_reference (the_swig_Type) /= 0;     -- An rvalue reference ('T&&') is bound as a reference is.
         new_Variable.owner_Class      := Self.current_c_Class;

         strip_all_qualifiers (DOH_Pointer (the_swig_Type));

         if SwigType_isArray (the_swig_Type) /= 0
         then
            Self.add_array_Bounds_to (new_Variable,
                                      DOH_Pointer (the_swig_Type));
         end if;

         new_Variable.my_Type := Self.demand_c_Type_for (doh_swigType (to_Doh (to_String (strip_array_Bounds (doh_Copy (DOH_Pointer (the_swig_Type)))))));

         if         is_Constant
           and then value_Text /= ""
           and then new_Variable.array_Bounds.is_Empty
         then
            begin
               if        new_Variable.my_Type.is_an_Integer
                 or else to_String (new_Variable.my_Type.Name) in "bool" | "signed char" | "unsigned char"     -- Which are numbers too.
               then
                  new_Variable.Value := +Image (resolved_c_integer_Expression (Self, +value_Text,
                                                                                     Self.integer_symbol_value_Map,
                                                                                     Self.current_class_namespace_Prefix));

               elsif to_String (new_Variable.my_Type.Name) = "char"
               then   -- A character is given by its position.
                  new_Variable.Value := +character_Value (Image (resolved_c_integer_Expression (Self, +value_Text,
                                                                                                          Self.integer_symbol_value_Map,
                                                                                                          Self.current_class_namespace_Prefix)));

               elsif c_Type."=" (new_Variable.my_Type.c_type_Kind, c_Type.Enum)
               then   -- A value of an enumeration is given by its number ('static const Colour first = Red;'), where that is not negative.
                  declare
                     --  The value is most often a literal of the enumeration, which may be named with its scope ('Counter::Down').
                     --
                     Colons      : constant Natural := ada.Strings.fixed.Index (value_Text, "::", Going => ada.Strings.Backward);
                     the_Literal : constant String  := (if Colons = 0 then value_Text else value_Text (Colons + 2 .. value_Text'Last));
                     is_Found    :          Boolean := False;
                  begin
                     for Each of new_Variable.my_Type.Literals
                     loop
                        if Each.Name = the_Literal
                        then
                           new_Variable.Value := +Image (Each.Value);
                           is_Found           := True;
                        end if;
                     end loop;

                     if not is_Found
                     then
                        new_Variable.Value := +Image (resolved_c_integer_Expression (Self, +value_Text,
                                                                                           Self.integer_symbol_value_Map,
                                                                                           Self.current_class_namespace_Prefix));
                     end if;

                     if not (for all Each of to_String (new_Variable.Value) => Each in '0' .. '9')
                     then   -- A negative number is not one which is given by its position, so the constant is imported.
                        new_Variable.Value := null_unbounded_String;
                     end if;
                  end;

               elsif new_Variable.my_Type.is_a_standard_Real
               then
                  new_Variable.Value := +ada.Strings.fixed.Trim (Long_Float'Image (Long_Float'Value (value_Text)), ada.Strings.Both);
               end if;
            exception
               when others =>
                  null;     -- The value is not a plain number, so the constant is imported.
            end;
         end if;

         if new_Variable.Value = ""
         then
            if the_Symbol = ""
            then
               warn (not_Bound, "Unable to bind the static member variable '" & variable_Name & "' of class '" & class_Name
                              & "', as its C++ symbol cannot be made.");
               unindent_Log;
               return SWIG_OK;
            end if;

            new_Variable.link_Symbol := +the_Symbol;
         end if;

         Self.Module_top.C.new_c_Variables.append (new_Variable);
      end;

      unindent_Log;
      return SWIG_OK;
   end staticMemberVariableHandler;



   overriding
   function memberConstantHandler (Self : access Item;
                                   N    : in     Node_Pointer) return C.int
   is
      the_Node : doh_Node renames N;
      Status   : C.int    with Unreferenced;
   begin
      indent_Log;
      dlog (+"");
      dlog (+"'memberConstantHandler'");

      Self.current_c_Node := doh_Node (the_Node);
      locate (doh_Node (the_Node));

      Self.wrapping_member_Flag := True;
      Status := swigMod.Language.item (Self.all).memberConstantHandler (the_node);
      Self.wrapping_member_Flag := False;

      unindent_Log;
      return SWIG_OK;
   end memberConstantHandler;



   overriding
   function insertDirective (Self : access Item;
                             N    : in     Node_Pointer) return C.int
   is
      the_Node :          doh_Node renames N;
      the_Code : constant doh_swigType  := doh_swigType (get_Attribute (the_Node, "code"));
      Status   :          C.int;
   begin
      indent_Log;
      dlog (+"");
      dlog (+"'insertDirective'");

      doh_replace_all (the_Code, -"$module",  -Self.Module_core.Name);
      Status := swigMod.Language.item (Self.all).insertDirective (the_Node);

      unindent_Log;
      return Status;
   end insertDirective;



   overriding
   function usingDeclaration (Self : access Item;
                              N    : in     Node_Pointer) return C.int
   --
   --  A 'using' declaration in a class names a function of a base class as one of the class itself ('using
   --  Foo::test;'), and the core gives the function with it, once for each overload which the class does not hide.
   --
   --  Where the base is the parent of the Ada type, or a parent of that, the function is there already: a virtual
   --  one is inherited, and any other takes an object of the class as it takes one of its base. Nothing is done.
   --
   --  Any other base is a part of the record (a base with no virtual function, or a second base with them), whose
   --  functions are reached through 'as_<base>'. The function is then bound as one of the class, as C++ has it.
   --  It is never virtual in Ada, as it has no place in the vtable of the class: its wrapper makes the call, which
   --  dispatches where the function is virtual in C++.
   --
   is
      use type C.int;

      the_Node : Node_Pointer renames N;

      function Owner return c_Type.view
      --
      --  The class which the function is of, where it is known.
      --
      is
         used_Name : constant String  := Attribute (the_Node, "uname");
         Colons    : constant Natural := ada.Strings.fixed.Index (used_Name, "::", Going => ada.Strings.Backward);
      begin
         if Colons <= used_Name'First
         then
            return null;
         end if;

         declare
            class_Name : constant unbounded_String := +used_Name (used_Name'First .. Colons - 1);
         begin
            if Self.swig_type_Map_of_c_type.contains (class_Name)
            then
               return Self.swig_type_Map_of_c_type.Element (class_Name);

            elsif Self.name_Map_of_c_type.contains (class_Name)
            then
               return Self.name_Map_of_c_type.Element (class_Name);
            else
               return null;
            end if;
         end;
      end Owner;

      function is_reached_by_Parents (the_Owner : in c_Type.view) return Boolean
      --
      --  True where the owner is the parent of the Ada type of the current class, or a parent of that (see
      --  'c_Type.ada_Parent').
      --
      is
         the_Class : c_Type.view := Self.current_c_Class;
      begin
         loop
            declare
               the_Parent : constant c_Type.view := (if the_Class.is_Virtual then the_Class.ada_Parent else null);
            begin

               if the_Parent = null
               then
                  return False;

               elsif the_Parent = the_Owner
               then
                  return True;
               end if;

               the_Class := the_Parent;
            end;
         end loop;
      end is_reached_by_Parents;

      the_Owner : c_Type.view;
      the_Child : Node_Pointer;
      Status    : C.int with Unreferenced;

   begin
      if        not Self.in_cpp_Mode
        or else Self.c_class_Stack.is_Empty
        or else Self.getCurrentClass = null
        or else Attribute (the_Node, "access") in "private" | "protected"
      then
         return SWIG_OK;
      end if;

      the_Owner := Owner;

      if        the_Owner = null
        or else the_Owner.c_type_Kind not in c_Type.c_Class
        or else is_reached_by_Parents (the_Owner)
      then
         return SWIG_OK;
      end if;

      add_hidden_Virtuals (Self, before => the_Node);

      Self.following_a_using_Declaration := True;
      the_Child                          := first_Child (the_Node);

      while the_Child /= null
      loop
         begin
            --  Only a function is followed: a member variable which is named so is in the base, where it is. The
            --  declarator of a function begins with its qualifier where it has one ('q(const).f().'), so it is asked
            --  of the core. (Until 2026-11-24 it was taken to begin 'f(', and a constant function was passed over.)
            --
            if         Attribute (the_Child, "nodeType") = "cdecl"
              and then get_Attribute (the_Child, "decl") /= null
              and then SwigType_isfunction (SwigType_Pointer (get_Attribute (the_Child, "decl"))) /= 0
              and then Attribute (the_Child, "feature:ignore") = ""
            then
               declare
                  the_Copy : constant DOH_Pointer := doh_Copy (DOH_Pointer (the_Child));     -- As the core does: the function becomes one of this class.
                  Unused   : C.int with Unreferenced;
               begin
                  Unused := DohSetattr (the_Copy, DOH_Pointer (to_Doh ("parentNode")), DOH_Pointer (Self.getCurrentClass));
                  Status := Self.emit_one (Node_Pointer (the_Copy));
               end;
            end if;
         end;

         the_Child := next_Sibling (the_Child);
      end loop;

      Self.following_a_using_Declaration := False;

      return SWIG_OK;
   end usingDeclaration;



   function as_a_standard_String (Name : in String) return String
   --
   --  The name with each instance of 'std::basic_string' of 'char' or 'wchar_t' given as the class which the module
   --  knows it by, 'std::string' or 'std::wstring' ('std::basic_string<(wchar_t)>', with its traits and allocator or
   --  without them, as pugixml names its strings). Until 2026-11-25 such a name was not known: pugixml's 'string_t' was
   --  an opaque type, and 'as_utf8', which returns one by value, a function which returned it as a plain record.
   --
   is
      type Spelling is record
         Template : unbounded_String;
         Class    : unbounded_String;
      end record;

      Spellings : constant array (1 .. 4) of Spelling
        := [(+"std::basic_string<(char,std::char_traits<(char)>,std::allocator<(char)>)>",          +"std::string"),
            (+"std::basic_string<(wchar_t,std::char_traits<(wchar_t)>,std::allocator<(wchar_t)>)>", +"std::wstring"),
            (+"std::basic_string<(char)>",                                                          +"std::string"),
            (+"std::basic_string<(wchar_t)>",                                                       +"std::wstring")];

      Result : unbounded_String := +Name;
   begin
      for Each of Spellings
      loop
         loop
            declare
               First : constant Natural := ada.Strings.unbounded.Index (Result, to_String (Each.Template));
            begin
               exit when First = 0;
               ada.Strings.unbounded.replace_Slice (Result, First, First + Length (Each.Template) - 1, to_String (Each.Class));
            end;
         end loop;
      end loop;

      return to_String (Result);
   end as_a_standard_String;



   overriding
   function typedefHandler (Self : access Item;
                            N    : in     Node_Pointer) return C.int
   is separate;


   -----------
   --- Utility
   --

   function wrapper_Symbol (Self : access Item;   From : in String) return unbounded_String
   --
   --  Makes the name of a function which the module adds to the wrapper file, from text which holds the name of a class.
   --  Whatever cannot be part of an identifier becomes an underscore, so two names may come out alike (those of the
   --  template instances 'X<(7 >= 4)>' and 'X<(7 <= 4)>', say): a name which is taken is given a number.
   --
   is
      the_Symbol : unbounded_String := +From;
      Count      : Positive         := 1;
   begin
      for Each in 1 .. Length (the_Symbol)
      loop
         if Element (the_Symbol, Each) not in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_'
         then
            replace_Element (the_Symbol, Each, '_');
         end if;
      end loop;

      declare
         Base : constant unbounded_String := the_Symbol;
      begin
         while Self.wrapper_Symbols.contains (the_Symbol)
         loop
            Count      := Count + 1;
            the_Symbol := Base & "_" & ada.Strings.fixed.Trim (Positive'Image (Count), ada.Strings.Left);
         end loop;
      end;

      Self.wrapper_Symbols.insert (the_Symbol);
      return the_Symbol;
   end wrapper_Symbol;



   function member_Variable (Self : access Item;   the_Node : in Node_Pointer;   the_Name : in String;
                                                   in_Scope : in Node_Pointer := null) return c_Variable.view
   --
   --  Makes a member variable from the node of its declaration, for a member which the core does not hand on. Its type
   --  is as it is written, which the core has not qualified: where that is not known, it is qualified in the scope of
   --  the class which is given ('Storage' of an anonymous union of 'Holder', which is 'Holder::Storage').
   --
   is
      use swigg.Utility;
      use type C.int;

      the_swig_Type :          SwigType_Pointer := SwigType_Pointer (doh_Copy (DOH_Pointer (get_Attribute (the_Node, "type"))));
      bit_Field     : constant String           := Attribute (the_Node, "bitfield");
      new_Variable  :          c_Variable.view;
   begin
      if         get_Attribute (the_Node, "decl") /= null
        and then Attribute (the_Node, "decl") /= ""
      then
         SwigType_push (the_swig_Type, String_Pointer (get_Attribute (the_Node, "decl")));
      end if;

      strip_all_qualifiers (DOH_Pointer (the_swig_Type));

      if         in_Scope /= null
        and then get_Attribute (in_Scope, "symtab") /= null
        and then not Self.swig_type_Map_of_c_type.contains (+doh_Item (SwigType_base (the_swig_Type)))
      then
         declare
            Qualified : constant SwigType_Pointer := Swig_symbol_type_qualify (the_swig_Type, Symtab_Pointer (get_Attribute (in_Scope, "symtab")));
         begin
            --  The class may be declared after the one which holds it, as the core moves a nested class out after
            --  its outer class: the type which is made for it here is then the one which the class becomes.
            --
            if +doh_Item (SwigType_base (Qualified)) /= +doh_Item (SwigType_base (the_swig_Type))
            then
               the_swig_Type := Qualified;
            end if;
         end;
      end if;

      if SwigType_isArray (the_swig_Type) /= 0
      then
         new_Variable := c_Variable.new_c_Variable (+the_Name,
                                                    Self.demand_c_Type_for (doh_swigType (to_Doh (to_String (strip_array_Bounds (doh_Copy (DOH_Pointer (the_swig_Type))))))));
         Self.add_array_Bounds_to (new_Variable, doh_SwigType (the_swig_Type));
      else
         new_Variable := c_Variable.new_c_Variable (+the_Name,
                                                    Self.demand_c_Type_for (doh_SwigType (the_swig_Type)));
      end if;

      new_Variable.is_class_Pointer := SwigType_isPointer (the_swig_Type) /= 0;

      if bit_Field /= ""
      then
         new_Variable.bit_Field := Integer (Value (resolved_c_integer_Expression (Self, +bit_Field,
                                                                                        Self.integer_symbol_value_Map,
                                                                                        Self.current_class_namespace_Prefix)));
      end if;

      return new_Variable;
   end member_Variable;



   procedure bind_unnamed_nested_Classes (Self : access Item;   the_Class : in Node_Pointer;   outer_Name : in String;   cpp_Name : in String)
   --
   --  A nested class or union with no name ('union { long l; double d; } val;') is left out by the core, in C++, and its
   --  members with it. The parser keeps each on the node of the outer class, with the names of the members which are
   --  declared with it. Each is given a class of its own, named '<outer>_<member>' as the core names one in C (or
   --  '<outer>_anonymous_<n>', where no member is declared with it, as for an anonymous union), whose name is noted
   --  on its node for 'add_hidden_Members', which gives the outer class its members.
   --
   --  This is called before the outer class is made the current class, so that the new class is declared beside it.
   --
   is
      use type C.int;
   begin
      if get_Attribute (the_Class, "unnamed_nested") = null
      then
         return;
      end if;

      declare
         the_Nested : constant doh_List := doh_List (get_Attribute (the_Class, "unnamed_nested"));
      begin
         for i in 1 .. DohLen (the_Nested)
         loop
            declare
               the_Node     : constant Node_Pointer := Node_Pointer (DohGetitem (the_Nested, i - 1));
               the_Declared : constant doh_List     := doh_List (get_Attribute (the_Node, "unnamed_nested:members"));
               first_Member : constant String       := (if DohLen (the_Declared) > 0 then +DohGetitem (the_Declared, 0) else "");
               member_Name  : constant String       := (if first_Member = "" then ""
                                                        else first_Member (first_Member'First .. ada.Strings.fixed.Index (first_Member, "|") - 1));
               the_Name     : constant String       := (if member_Name = "" then outer_Name & "_anonymous_" & ada.Strings.fixed.Trim (C.int'Image (i), ada.Strings.Left)
                                                                            else outer_Name & "_" & member_Name);
               the_cpp_Name : constant String       := (if member_Name = "" or else cpp_Name = "" then ""
                                                        else "decltype (" & cpp_Name & "::" & member_Name & ")");
               new_c_Class  :          c_Type.view;
               the_Child    :          Node_Pointer := first_Child (the_Node);
            begin
               if not Self.name_Map_of_c_type.contains (+the_Name)
               then
                  bind_unnamed_nested_Classes (Self, the_Node, the_Name, the_cpp_Name);     -- Those within it.

                  new_c_Class := c_Type.new_c_Class (Namespace => Self.current_c_Namespace,
                                                     Name      => +the_Name);
                  Self.register (new_c_Class,
                                 doh_SwigType (to_Doh (the_Name)));

                  if Attribute (the_Node, "kind") = "union"
                  then
                     new_c_Class.is_Union;
                  end if;

                  new_c_Class.nameSpace.models_cpp_class_Type (new_c_Class);

                  if         Self.in_cpp_Mode
                    and then the_cpp_Name /= ""
                    and then Attribute (the_Node, "access") not in "private" | "protected"
                    and then first_Member (first_Member'Last) = '|'     -- The member is of the class itself, not a pointer to it or an array of it.
                  then
                     new_c_Class.layout_Name_is (+the_cpp_Name);
                  end if;

                  --  Its members, with those of the classes with no name which are nested in it. (They are added in the order
                  --  of their declarations, with any of the latter after the member variables: a union is unaffected by this.)
                  --
                  Self.c_class_Stack.append (new_c_Class);

                  while the_Child /= null
                  loop
                     if         Attribute (the_Child, "nodeType") = "cdecl"
                       and then Attribute (the_Child, "name")    /= ""
                       and then Attribute (the_Child, "storage") not in "static" | "typedef" | "friend" | "extern"
                       and then (        get_Attribute (the_Child, "decl") = null
                                 or else SwigType_isfunction (SwigType_Pointer (get_Attribute (the_Child, "decl"))) = 0)
                     then
                        declare
                           the_Member : constant c_Variable.view := member_Variable (Self, the_Child, Attribute (the_Child, "name"),
                                                                                    in_Scope => the_Class);
                        begin
                           if Attribute (the_Child, "bitfield") = ""
                           then
                              the_Member.member_Name := +Attribute (the_Child, "name");
                           end if;

                           new_c_Class.add_Component (the_Member);
                        end;
                     end if;

                     the_Child := next_Sibling (the_Child);
                  end loop;

                  add_hidden_Members (Self, before => null, of_Class => the_Node);
                  Self.c_class_Stack.delete_Last;

                  set_Attribute (doh_Node (the_Node), "ada:type_name", the_Name);
               end if;
            end;
         end loop;
      end;
   end bind_unnamed_nested_Classes;



   procedure add_hidden_Members (Self : access Item;   Before : in Node_Pointer;   of_Class : in Node_Pointer := null)
   is separate;



   procedure bind_other_base_Classes (Self : access Item;   the_Class : in Node_Pointer)
   --
   --  A base class of a class which has virtual functions becomes the parent of its Ada type (see 'c_Type.ada_Parent').
   --  Any other base class is a component of the Ada record, which may be storage alone: where the Ada type has a
   --  parent, or where C++ places members in the unused tail of the base class.
   --
   --  Each such base class is given a function, 'as_<base>', which returns a pointer to the part of the object
   --  which is that base class, so that its members can be reached and it can be given to C++.
   --
   is
      use type C.int;
      use type swig_Module.swig_Module_view;

      the_Bases    : constant c_Type.Vector := Self.current_c_Class.base_Classes;
      parent_Found :          Boolean       := False;
   begin
      if        not Self.in_cpp_Mode
        or else Self.current_Module /= Self.Module_top'Access
        or else get_Attribute (the_Class, "bases") = null
      then
         return;
      end if;

      declare
         the_cpp_Class : constant String   := +doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (the_Class, "name"))));
         base_List     : constant doh_List := doh_List (get_Attribute (the_Class, "bases"));     -- Those which are public: a wrapper cannot reach the others.
      begin
         for i in 1 .. DohLen (base_List)
         loop
            declare
               the_Base  : constant Node_Pointer := Node_Pointer (DohGetitem (base_List, i - 1));
               base_Name : constant String       := Attribute (the_Base, "sym:name");
            begin
               if         Self.name_Map_of_c_type.contains (+base_Name)
                 and then the_Bases.contains (Self.name_Map_of_c_type.Element (+base_Name))
                 and then Self.name_Map_of_c_type.contains (+base_Name & "*")
               then
                  if         Self.name_Map_of_c_type.Element (+base_Name) = Self.current_c_Class.ada_Parent
                    and then not parent_Found
                  then
                     parent_Found := True;     -- The parent, which Ada reaches by a view conversion. (A base which the class
                                               -- inherits virtually is none, unless it is nearly empty: see 'c_Type.ada_Parent'.)
                  else
                     declare
                        the_cpp_Base : constant String  := +doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (the_Base, "name"))));
                        the_Symbol   : constant unbounded_String := wrapper_Symbol (Self, "ada_base_" & the_cpp_Class & "_" & the_cpp_Base);

                        the_Function : constant c_Function.view
                          := c_Function.new_c_Function (+("as_" & base_Name),
                                                        Self.name_Map_of_c_type.Element (+base_Name & "*"));
                     begin

                        print_to (DOH_Pointer (Self.f_Ada),   "extern ""C"" " & the_cpp_Base & " * " & to_String (the_Symbol)
                                                            & " (" & the_cpp_Class & " * self)"                             & NL
                                                            & "{"                                                           & NL
                                                            & "  return self;"                                              & NL
                                                            & "}"                                                           & NL & NL);

                        the_Function.Parameters.append (c_Parameter.new_c_Parameter (the_Name => +"Self",
                                                                                     the_Type => Self.current_c_Class.all'Access));
                        the_Function.link_Symbol       := the_Symbol;
                        the_Function.access_Mode       := c_Function.public_Access;
                        the_Function.returns_an_Access := True;

                        Self.current_c_Class.nameSpace.add (the_Function.all'Access);
                     end;
                  end if;
               end if;
            end;
         end loop;
      end;
   end bind_other_base_Classes;



   procedure bind_constructors_of_abstract_Class (Self : access Item;   the_Class : in Node_Pointer)
   is separate;

   procedure bind_the_Director (Self : access Item;   the_Class : in Node_Pointer)
   is separate;



   procedure add_hidden_Virtuals (Self : access Item;   Before : in Node_Pointer)
   --
   --  A tagged type of convention CPP has a place in its vtable for each of its primitive subprograms, in the order
   --  of their declaration, and that order must be the one in which C++ lays out the virtual functions of the class.
   --  So a virtual function which the core does not hand on must still have a place: one which the interface file
   --  ignores, one which is deleted, and a virtual destructor which is not public. For each of those of the current
   --  class which come before the given member (or all that remain, when it is null), a function is added which only
   --  holds the place ('is_Placeholder'), and which the transformer makes a primitive 'unbound_virtual_<n>'.
   --
   --  A function which overrides takes the place of the one which it overrides, and needs none.
   --
   is
      the_Class : constant Node_Pointer := Self.getCurrentClass;
      the_Child :          Node_Pointer;

      procedure hold_a_Place (For_the : in String;   is_Abstract : in Boolean)
      is
         the_Function : constant c_Function.view := c_Function.new_c_Function (+For_the,
                                                                               Self.name_Map_of_c_type.Element (+"void"));
      begin
         the_Function.Parameters.append (c_Parameter.new_c_Parameter (the_Name => +"Self",
                                                                      the_Type => Self.current_c_Class.all'Access));
         the_Function.is_Virtual     := True;
         the_Function.is_Abstract    := is_Abstract;
         the_Function.is_Placeholder := True;

         Self.current_c_Class.nameSpace.add (the_Function.all'Access);
      end hold_a_Place;

      function a_Base_has_a_virtual_Destructor return Boolean
      --
      --  Whether the parent of the Ada type has a virtual destructor, whose places a destructor here overrides.
      --
      is
         use type c_Type.view;
         the_Parent : constant c_Type.view := Self.current_c_Class.ada_Parent;
      begin
         return          the_Parent /= null
                and then the_Parent.has_virtual_Destructor;
      end a_Base_has_a_virtual_Destructor;

   begin
      if        the_Class = null
        or else not Self.in_cpp_Mode
        or else Self.c_class_Stack.is_Empty
      then
         return;
      end if;

      --  Begin after the member up to which this has been done already.
      --
      the_Child := (if Self.virtuals_placed_upto = null then first_Child (the_Class)
                                                        else next_Sibling (Self.virtuals_placed_upto));

      if         Self.virtuals_placed_upto /= null
        and then Self.virtuals_placed_upto = Before
      then
         return;
      end if;

      while the_Child /= null
        and then the_Child /= Before
      loop
         declare
            Kind       : constant String  := Attribute (the_Child, "nodeType");
            is_Virtual : constant Boolean := ada.Strings.fixed.Index (Attribute (the_Child, "storage"), "virtual") /= 0;
            is_Hidden  : constant Boolean :=        Attribute (the_Child, "feature:ignore") /= ""
                                            or else Attribute (the_Child, "delete")         /= "";
         begin
            if         Kind = "cdecl"
              and then is_Virtual
              and then is_Hidden
              and then get_Attribute (the_Child, "override") = null
              and then get_Attribute (the_Child, "defaultargs") = null
            then
               hold_a_Place (Attribute (the_Child, "name"), is_Abstract => Attribute (the_Child, "abstract") /= "");

            elsif      Kind = "destructor"
              and then is_Virtual
              and then (is_Hidden or else Attribute (the_Child, "access") in "protected" | "private")
              and then not Self.destructor_is_Bound
              and then not a_Base_has_a_virtual_Destructor
            then
               Self.current_c_Class.has_virtual_Destructor;
               --  They have the names of a destructor which is bound, so that the destructor of a derived class,
               --  which may be public, overrides them. They are not to be called, as no place holder is.
               --
               hold_a_Place ("destruct_0", is_Abstract => False);     -- The destructor of the complete object,
               hold_a_Place ("destruct",   is_Abstract => False);     -- and the one which frees it too.
               Self.destructor_is_Bound := True;
            end if;
         end;

         Self.virtuals_placed_upto := the_Child;
         the_Child                 := next_Sibling (the_Child);
      end loop;

      if Before /= null
      then
         Self.virtuals_placed_upto := Before;
      end if;
   end add_hidden_Virtuals;



   function variable_Suffix (swig_Type : in String) return String
   --
   --  The end of the C++ symbol of a variable of the given type. GNU libstdc++ marks its strings with an 'ABI tag',
   --  which the symbol of a variable whose type has a string in it then bears ('_ZN9Structure4nameB5cxx11E').
   --
   is
   begin
      if        ada.Strings.fixed.Index (swig_Type, "std::string")       /= 0
        or else ada.Strings.fixed.Index (swig_Type, "std::wstring")      /= 0
        or else ada.Strings.fixed.Index (swig_Type, "std::basic_string") /= 0
      then
         return "B5cxx11E";
      else
         return "E";
      end if;
   end variable_Suffix;



   function without_all_Qualifiers (swig_Type : in String) return String
   --
   --  The swig type with each qualifier taken off but those within the arguments of a template, as a type is entered
   --  ('strip_all_qualifiers' of 'swigg.Utility', which 'register' applies).
   --
   is
      the_Type : doh_swigType := doh_swigType (doh_Copy (doh_Item (to_Doh (swig_Type))));
   begin
      swigg.Utility.strip_all_qualifiers (the_Type);
      return +the_Type;
   end without_all_Qualifiers;



   function without_leading_Qualifiers (swig_Type : in String) return String
   --
   --  The swig type less the qualifiers which it begins with ('q(const).Foo' is 'Foo'), and no others.
   --
   is
      First : Positive := swig_Type'First;
   begin
      while First + 1 <= swig_Type'Last and then swig_Type (First .. First + 1) = "q("
      loop
         declare
            Close : constant Natural := ada.Strings.fixed.Index (swig_Type, ").", From => First);
         begin
            exit when Close = 0;
            First := Close + 2;
         end;
      end loop;

      return swig_Type (First .. swig_Type'Last);
   end without_leading_Qualifiers;



   function smart_Pointer_Words (type_Name : in String) return Natural
   --
   --  The number of addresses which an object of the type takes, where it is a smart pointer of the standard library
   --  (as GNU libstdc++ has it): one for a 'std::unique_ptr' with the default deleter, two for a 'std::shared_ptr'
   --  or a 'std::weak_ptr'. It is none for any other type.
   --
   is
      function is_an_Instance_of (Template : in String) return Boolean
      --
      --  Whether the type is an instance of the template with one argument ('std::unique_ptr<(X)>').
      --
      is
         Prefix : constant String  := Template & "<(";
         Depth  :          Integer := 0;
      begin
         if        type_Name'Length <= Prefix'Length + 2
           or else type_Name (type_Name'First .. type_Name'First + Prefix'Length - 1) /= Prefix
           or else type_Name (type_Name'Last - 1 .. type_Name'Last)                  /= ")>"
         then
            return False;
         end if;

         for Each of type_Name (type_Name'First + Prefix'Length .. type_Name'Last - 2)
         loop
            case Each
            is
               when '(' | '<' => Depth := Depth + 1;
               when ')' | '>' => Depth := Depth - 1;
               when ','       => if Depth = 0 then return False; end if;     -- A second argument, such as a deleter.
               when others    => null;
            end case;
         end loop;

         return Depth = 0;
      end is_an_Instance_of;

   begin
      if is_an_Instance_of ("std::unique_ptr")
      then
         return 1;

      elsif        is_an_Instance_of ("std::shared_ptr")
           or else is_an_Instance_of ("std::weak_ptr")
      then
         return 2;
      end if;

      return 0;
   end smart_Pointer_Words;



   function as_Ada_string_Text (the_String : in String) return String
   --
   --  The text which a C string stands for (the core's 'stringval'), written so as to stand between the quotes of an
   --  Ada string literal: a quote is doubled, and a control character is joined in by its position.
   --
   is
      Result : unbounded_String;
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
   end as_Ada_string_Text;



   function character_Value (Position : in String) return String
   --
   --  A constant of type 'char' as Ada states it, given the number which C gives it. A negative
   --  number ('const char c = -110;') is the character which has its bits.
   --
   is
      the_Position : constant Long_Long_Integer := Long_Long_Integer'Value (Position) mod 256;
   begin
      return "interfaces.c.char'Val (" & ada.Strings.fixed.Trim (the_Position'Image, ada.Strings.Left) & ")";
   end character_Value;



   function returns_a_cpp_constructed_Type (Self : access Item;   the_Node : in doh_Node) return Boolean
   --
   --  True when the function of the node returns, by value, a type which C++ constructs.
   --
   is
      use type C.int;
      use type c_Type.a_c_type_Kind;

      the_swig_Type : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (get_Attribute (the_Node, "type"))));
   begin
      if get_Attribute (the_Node, "type") = null
      then
         return False;
      end if;

      declare
         --  The type less the qualifiers of the result itself, which make no difference ('const Foo f ();'). Those within
         --  it are part of the type ('vector<shared_ptr<const Foo>>' is another type than one of 'Foo'). Until
         --  2026-11-22 the type was looked up with its qualifiers, and a constant result was missed. A standard string is
         --  sought as the class which the module knows it by, where it is named as an instance of its template (pugixml's
         --  'as_wide', of 'std::basic_string<wchar_t>'; see 'as_a_standard_String').
         --
         Pad : constant doh_swigType := doh_swigType (to_Doh (as_a_standard_String (without_leading_Qualifiers (+doh_Item (the_swig_Type)))));
      begin
         if        SwigType_isPointer          (SwigType_Pointer (Pad)) /= 0
           or else SwigType_isReference        (SwigType_Pointer (Pad)) /= 0
           or else SwigType_isrvalue_reference (SwigType_Pointer (Pad)) /= 0
           or else SwigType_isArray            (SwigType_Pointer (Pad)) /= 0
         then
            return False;
         end if;

         --  A type which is found and is not known (as 'demand_c_Type_for' makes one), or a typedef of one (yaml-cpp's
         --  'const_iterator', a 'using' of an instance which is named later), says nothing: it is sought as below.
         --
         if         Self.swig_type_Map_of_c_type.contains (+Pad)
           and then Self.swig_type_Map_of_c_type.Element  (+Pad).c_type_Kind /= c_Type.Unknown
           and then not (         Self.swig_type_Map_of_c_type.Element (+Pad).c_type_Kind = c_Type.Typedef
                         and then Self.swig_type_Map_of_c_type.Element (+Pad).ultimate_base_Type /= null
                         and then Self.swig_type_Map_of_c_type.Element (+Pad).ultimate_base_Type.c_type_Kind = c_Type.Unknown)
         then
            return Self.swig_type_Map_of_c_type.Element (+Pad).is_constructed_by_Cpp;
         end if;

         --  The type may be named through a typedef which the module has not been given ('std::pair<String,Streeng>',
         --  where each is a typedef of 'std::string'), as 'demand_c_Type_for' allows. Until 2026-11-23 such a result
         --  was missed, and the function was bound as an Ada function.
         --
         declare
            Resolved : constant unbounded_String := +without_leading_Qualifiers (+doh_Item (SwigType_typedef_resolve_all (SwigType_Pointer (Pad))));
            --
            --  Less its qualifiers, as the name may stand for a type which has one ('value_type' of an
            --  'iterator_base<const iterator_value>').

         begin
            if         Self.swig_type_Map_of_c_type.contains (Resolved)
              and then Self.swig_type_Map_of_c_type.Element  (Resolved).c_type_Kind /= c_Type.Unknown
            then
               return Self.swig_type_Map_of_c_type.Element (Resolved).is_constructed_by_Cpp;
            end if;

            --  An instance of a class template which is named by '%template' after the function (a 'std::vector' of a
            --  structure of the class, which can only be named once the class is declared: jsoncpp's
            --  'getStructuredErrors') is not yet known. The template tells where it declares a destructor which is not
            --  defaulted, as then each of its instances is a class which C++ constructs (a container of the library).
            --  Until 2026-11-24 such a function was bound as an Ada function which returned the limited type.
            --
            if SwigType_istemplate (SwigType_Pointer (to_Doh (to_String (Resolved)))) /= 0
            then
               declare
                  Prefix       : constant String       := +doh_Item (SwigType_templateprefix (SwigType_Pointer (to_Doh (to_String (Resolved)))));
                  the_Name     : constant String       := (if         Prefix'Length > 0
                                                             and then Prefix (Prefix'Last) = '<'
                                                           then Prefix (Prefix'First .. Prefix'Last - 1)
                                                           else Prefix);
                  the_Template : constant Node_Pointer := Swig_symbol_clookup (DOHs.const_String_or_char_ptr.Item (to_Doh (the_Name)), null);

                  function is_constructed (the_Class : in Node_Pointer) return Boolean
                  --
                  --  Whether the declarations of a class template (or of a partial specialisation of one) make each of
                  --  its instances a class which C++ constructs.
                  --
                  is
                     the_Child : Node_Pointer := first_Child (the_Class);

                     function in_the_Template (the_Type : in SwigType_Pointer) return SwigType_Pointer
                     --
                     --  The type of a member of the template as it is written within the template ('shared_memory_holder'),
                     --  qualified in the scope of the template, as the core is otherwise asked of it in the current scope.
                     --
                     is
                     begin
                        if get_Attribute (the_Class, "symtab") /= null
                        then
                           return Swig_symbol_type_qualify (the_Type, Symtab_Pointer (get_Attribute (the_Class, "symtab")));
                        else
                           return the_Type;
                        end if;
                     end in_the_Template;

                  begin
                     while the_Child /= null
                     loop
                        if         Attribute (the_Child, "nodeType")       = "destructor"
                          and then Attribute (the_Child, "value")         /= "default"
                          and then Attribute (the_Child, "value")         /= "delete"
                          and then Attribute (the_Child, "feature:extend")  = ""
                        then
                           return True;
                        end if;

                        --  Likewise where it has a member which is a smart pointer of the standard library, as written or
                        --  through a typedef, whose destructor is not trivial (yaml-cpp's 'iterator_base', which holds a
                        --  'shared_memory_holder', and which 'Node::begin' returns before the interface can name it).
                        --
                        if         Attribute (the_Child, "nodeType") = "cdecl"
                          and then Attribute (the_Child, "decl")     = ""
                          and then Attribute (the_Child, "storage") /= "static"
                          and then get_Attribute (the_Child, "type") /= null
                          and then (        smart_Pointer_Words (without_leading_Qualifiers (Attribute (the_Child, "type"))) > 0
                                    or else smart_Pointer_Words (without_leading_Qualifiers (+doh_Item (SwigType_typedef_resolve_all
                                                                                                           (in_the_Template (SwigType_Pointer (get_Attribute (the_Child, "type")))))))
                                            > 0)
                        then
                           return True;
                        end if;

                        the_Child := next_Sibling (the_Child);
                     end loop;

                     return False;
                  end is_constructed;

               begin
                  if         the_Template /= null
                    and then Attribute (the_Template, "nodeType")      = "template"
                    and then Attribute (the_Template, "templatetype") in "class" | "classforward"     -- Which is declared alone.
                  then
                     if first_Child (the_Template) /= null
                     then
                        return is_constructed (the_Template);
                     end if;

                     --  A template which is declared alone ('template <typename> class function;') has its instances from
                     --  its partial specialisations ('function<RET(ARGS...)>', of 'std_function.i'), which tell where each
                     --  of them does: where they differ, which applies is not worked out here.
                     --
                     declare
                        use type DOH_Pointer;
                        Partials : constant DOH_Pointer := DOH_Pointer (get_Attribute (the_Template, "partials"));
                     begin
                        if         Partials /= null
                          and then DohLen (Partials) > 0
                        then
                           for Each in 0 .. DohLen (Partials) - 1
                           loop
                              declare
                                 the_Partial : constant Node_Pointer     -- Which is named within the scope of the template.
                                   := Swig_symbol_clookup (DOHs.const_String_or_char_ptr.Item (get_Attribute (Node_Pointer (DohGetitem (Partials, Each)),
                                                                                                              "templcsymname")),
                                                           Symtab_Pointer (get_Attribute (the_Template, "sym:symtab")));
                              begin
                                 if        the_Partial = null
                                   or else not is_constructed (the_Partial)
                                 then
                                    return False;
                                 end if;
                              end;
                           end loop;

                           return True;
                        end if;
                     end;
                  end if;
               end;
            end if;

            return False;
         end;
      end;
   end returns_a_cpp_constructed_Type;



   function is_called_through_its_Wrapper (Self : access Item;   the_Node : in Node_Pointer) return Boolean
   --
   --  True for a virtual function which Ada cannot call through the vtable, as a dispatching call does: the
   --  arguments of such a call go to the C++ function as Ada passes them, and C++ takes them otherwise.
   --
   --  - A function which returns, by value, a class that C++ constructs takes a hidden pointer to the result
   --    ahead of 'this', where the binding has its 'Result' parameter last.
   --  - A function which takes a plain structure by value takes the structure itself, where Ada passes a
   --    record by reference. So does one which takes a pointer to a class member, which Ada takes for a record.
   --
   --  Such a function is no primitive of the Ada type. It is a function of the class-wide type, whose function
   --  of the wrapper makes the virtual call, and a place holder has its place in the vtable (as for the forms of
   --  a function with a default argument). Ada overrides it through a director alone (see 'bind_the_Director'). (Until 2026-11-23 it was a primitive:
   --  LevelDB's 'DB::Put', which returns a 'Status', was called with its arguments each in the place of another.)
   --
   is
      use type C.int;
      the_Parameter : Node_Pointer := get_Attribute (the_Node, "parms");
   begin
      if        not is_declared_Virtual (the_Node)
        or else Attribute (the_Node, "nodeType") = "destructor"     -- Which is bound by its symbols, and is no function of the wrapper.
      then
         return False;
      end if;

      if returns_a_cpp_constructed_Type (Self, doh_Node (the_Node))
      then
         return True;
      end if;

      --  Nor can Ada call through the vtable a function of a class with a base class which SWIG was never shown
      --  ('class xpath_exception : public std::exception'): the places which the virtual functions of that base
      --  take are not known, so neither is the place of this one.
      --
      if         not Self.c_class_Stack.is_Empty
        and then Self.current_c_Class.has_an_unknown_Base
      then
         return True;
      end if;

      while the_Parameter /= null
      loop
         if get_Attribute (the_Parameter, "type") /= null
         then
            declare
               the_Type : constant String           := without_leading_Qualifiers (Attribute (the_Parameter, "type"));
               Pad      : constant SwigType_Pointer := SwigType_Pointer (to_Doh (the_Type));
            begin
               if SwigType_ismemberpointer (SwigType_typedef_resolve_all (Pad)) /= 0     -- A typedef of one too.
               then
                  return True;     -- A pointer to a class member, which C++ takes by value and Ada passes as a record, by reference.
               end if;

               if         SwigType_isPointer          (Pad) = 0
                 and then SwigType_isReference        (Pad) = 0
                 and then SwigType_isrvalue_reference (Pad) = 0
                 and then SwigType_isArray            (Pad) = 0
               then
                  declare
                     use type c_Type.a_c_type_Kind;

                     Resolved : constant unbounded_String := +doh_Item (SwigType_typedef_resolve_all (Pad));
                     Found    :          c_Type.view      := (if    Self.swig_type_Map_of_c_type.contains (+the_Type) then Self.swig_type_Map_of_c_type.Element (+the_Type)
                                                              elsif Self.swig_type_Map_of_c_type.contains (Resolved)  then Self.swig_type_Map_of_c_type.Element (Resolved)
                                                              else  null);
                  begin
                     while Found /= null
                       and then Found.c_type_Kind = c_Type.Typedef
                     loop
                        Found := Found.base_Type;
                     end loop;

                     if         Found /= null
                       and then Found.c_type_Kind = c_Type.c_Class
                       and then not Found.is_constructed_by_Cpp
                     then
                        return True;
                     end if;
                  end;
               end if;
            end;
         end if;

         the_Parameter := next_Sibling (the_Parameter);
      end loop;

      return False;
   end is_called_through_its_Wrapper;



   function is_a_function_Pointer (swig_Type : in doh_swigType) return Boolean
   is
      the_swig_Type : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (swig_Type));
      use type C.int;
   begin
      return     SwigType_isPointer  (the_swig_Type)                        /= 0
        and then SwigType_isFunction (SwigType_del_Pointer (the_swig_Type)) /= 0;
   end is_a_function_Pointer;



   procedure log (the_Map : symbol_value_Maps.Map)
   is
      Cursor : symbol_value_Maps.Cursor := the_Map.First;
   begin
      while has_Element (Cursor)
      loop
         dlog (+"Symbol => '" & Key (Cursor) & "'   Value => '" & Image (Element (Cursor)) & "'");
         next (Cursor);
      end loop;
   end log;

   pragma Unreferenced (log);



   procedure add_new_c_Type (Self : access Item;   new_Type : c_Type.view)
   is
      the_current_Module : constant swig_Module.swig_Module_view := Self.current_Module;
   begin
      --  A type which was made, not known, before its declaration, and which the declaration has taken over, is moved
      --  to the place of a new type, after the class which declares it, whose package must be made first.
      --
      if the_current_Module.C.new_c_Types.contains (new_Type)
      then
         the_current_Module.C.new_c_Types.delete (the_current_Module.C.new_c_Types.find_Index (new_Type));

         declare
            Place : constant Natural := the_current_Module.C.new_c_Declarations.find_Index (new_Type.all'Access);
         begin
            if Place /= 0
            then
               the_current_Module.C.new_c_Declarations.delete (Place);
            end if;
         end;
      end if;

      the_current_Module.C.new_c_Types       .append (new_Type);
      the_current_Module.C.new_c_Declarations.append (new_Type.all'Access);
   end add_new_c_Type;



   procedure register (Self : access Item;   the_c_Type              : in c_Type.view;
                                             to_swig_Type            : in doh_swigType;
                                             is_core_C_type          : in Boolean := False;
                                             create_array_Type       : in Boolean := True;
                                             add_level_3_Indirection : in Boolean := False)
   is separate;



   procedure register_Mirror (Self : access Item;   proxy_Name              : in unbounded_String;
                                                    the_c_Type              : in c_Type.view;
                                                    the_swig_Type           : in doh_swigType;
                                                    create_array_Type       : in Boolean := True;
                                                    add_level_3_Indirection : in Boolean := False)
   is
      pragma Unreferenced (add_level_3_Indirection);
   begin
      do_c_Type:
      begin
         Self.swig_type_Map_of_c_type.insert (+the_swig_Type, the_c_Type);
         Self.     name_Map_of_c_type.insert (proxy_Name,     the_c_Type);
      end do_c_Type;


      do_level_1_indirection:
      declare
      begin
         if create_array_Type
         then       -- Add associated array.
            declare
               array_swigType : constant doh_swigType := doh_swigType (to_DOH ("a." & (+the_swig_Type)));
               my_array_Type  : constant c_Type.view  := Self.name_Map_of_c_type.Element (the_c_Type.Name & "[]");
            begin
               Self.swig_type_Map_of_c_type.insert (+array_swigType,   my_array_Type);
               Self.     name_Map_of_c_type.insert (proxy_Name & "[]", my_array_Type);
            end;
         end if;

         declare    -- Add associated pointer.
            pointer_swigType : constant doh_swigType := doh_SwigType (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type))));
            my_view_Type     : constant c_Type.view  := Self.name_Map_of_c_type.Element (the_c_Type.Name & "*");
         begin
            Self.swig_type_Map_of_c_type.insert (+pointer_swigType, my_view_Type);
            Self.     name_Map_of_c_type.insert (proxy_Name & "*",  my_view_Type);

            declare -- Register pointer to 'const'.
               the_pointer_to_const_swigType : constant doh_swigType
                 := doh_SwigType (swigtype_add_Pointer (swigtype_add_Qualifier (SwigType_Pointer (doh_copy (the_swig_Type)),
                                                                               const_String (to_Doh ("const")))));
            begin
               Self.swig_type_Map_of_c_type.insert (+the_pointer_to_const_swigType, my_view_Type);
               Self.     name_Map_of_c_type.insert ("const " & proxy_Name & "*",    my_view_Type);
            end;

            declare -- Add associated reference.
               reference_swigType : constant doh_swigType := doh_SwigType (SwigType_add_reference (SwigType_Pointer (doh_copy (the_swig_Type))));
            begin
               Self.swig_type_Map_of_c_type.insert (+reference_swigType, my_view_Type);
               Self.     name_Map_of_c_type.insert (proxy_Name & "&",    my_view_Type);

               declare -- Register reference to 'const'.
                  the_reference_to_const_swigType : constant doh_swigType
                    := doh_SwigType (SwigType_add_reference (swigtype_add_Qualifier (SwigType_Pointer (doh_copy (the_swig_Type)),
                                                                                     const_String (to_Doh ("const")))));
               begin
                  Self.swig_type_Map_of_c_type.insert (+the_reference_to_const_swigType, my_view_Type);
                  Self.     name_Map_of_c_type.insert ("const " & proxy_Name & "&",      my_view_Type);
               end;
            end;
         end;
      end do_level_1_indirection;


      do_level_2_indirection:
      begin
         if create_array_Type
         then      -- Add associated array.
            declare
               array_of_pointers_swigType : constant doh_swigType
                 := doh_SwigType (to_DOH ("a." & (+doh_Item (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type)))))));
               my_view_array_Type         : constant c_Type.view := Self.name_Map_of_c_type.Element (the_c_Type.Name & "*[]");
            begin
               Self.swig_type_Map_of_c_type.insert (+array_of_pointers_swigType,
                                                    my_view_array_Type);
            end;
         end if;

         declare   -- Add pointer pointer.
            pointer_to_pointer_swigType : constant doh_swigType
              := doh_SwigType (swigtype_add_Pointer (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type)))));
            my_view_view_Type           : constant c_Type.view := Self.name_Map_of_c_type.Element (the_c_Type.Name & "**");
         begin
            Self.swig_type_Map_of_c_type.insert (+pointer_to_pointer_swigType,
                                                 my_view_view_Type);
         end;
      end do_level_2_indirection;

   end register_mirror;



   procedure associate (Self : access Item;   the_Ada : in ada_Type.view;
                                              with_C  : in c_Type  .view)
   is
   begin
      Self.c_type_Map_of_ada_type.insert (with_C, the_Ada);
   end associate;



   function current_Module (Self : access Item) return swig_Module.swig_Module_view
   is
      the_Module : swig_Module.swig_Module_view;
   begin
      if Self.current_c_Node /= null
      then
         declare
            the_Node         : doh_Node  renames Self.current_c_Node;
            the_Parent       : doh_Node  :=      parent_Node (the_Node);
            parent_node_Type : unbounded_String;
         begin
            while the_Parent /= null
            loop
               parent_node_Type := +node_Type (the_Parent);

               if parent_node_Type = "import"
               then
                  declare
                     parent_module_Name : constant String := Attribute (the_Parent, "module");
                  begin
                     if parent_module_Name = ""
                     then   -- A file imported without a module name has no binding of its own in which its
                            -- declarations could be found, so they are bound along with those of the main module.
                        the_Module := Self.Module_top'Access;
                     else
                        the_Module := Self.demand_Module (+parent_module_Name);
                     end if;

                     exit;
                  end;

               elsif parent_node_Type = "top"
               then
                  the_Module := Self.Module_top'Access;
                  exit;
               end if;

               the_Parent := parent_Node (the_Parent);
            end loop;
         end;

      else
         the_Module := Self.Module_core'Access;
      end if;

      return the_Module;
   end current_Module;



   function fetch_ada_Type (Self : access Item;   Named : in unbounded_String) return ada_Type.view
   is
   begin
      return Self.name_Map_of_ada_type.Element (Named);
   end fetch_ada_Type;



   function fetch_c_Type (Self : access Item;   Named : in unbounded_String) return c_Type.view
   is
   begin
      return Self.name_Map_of_c_type.Element (Named);
   end fetch_c_Type;



   function known_in_another_template_Form (Self : access Item;   Named : in unbounded_String) return c_Type.view
   --
   --  The type of a name which holds a template instance in one of its two forms, with the default arguments of its
   --  template given or without them, where the module knows the type by the other form; null where it does not. (The
   --  name is an unbounded string, as a primitive of the type, which is of convention CPP, is given a 'String' with no
   --  bounds.)
   --
   is
      the_Name : constant String := to_String (Named);
   begin
      for Each in 1 .. Natural (Self.template_full_Forms.Length)
      loop
         declare
            full_Form : constant String  := Self.template_full_Forms.Element (Each);
            First     : constant Natural := ada.Strings.fixed.Index (the_Name, full_Form);
         begin
            if First /= 0
            then
               declare
                  plain_Name : constant unbounded_String := +(  the_Name (the_Name'First .. First - 1)
                                                              & Self.template_plain_Forms.Element (Each)
                                                              & the_Name (First + full_Form'Length .. the_Name'Last));
               begin
                  if Self.swig_type_Map_of_c_type.contains (plain_Name)
                  then
                     return Self.swig_type_Map_of_c_type.Element (plain_Name);
                  end if;
               end;
            end if;
         end;

         --  Likewise the other way about: an instance which was first used by its full name is known by that.
         --
         declare
            plain_Form : constant String  := Self.template_plain_Forms.Element (Each);
            First      : constant Natural := ada.Strings.fixed.Index (the_Name, plain_Form);
         begin
            if First /= 0
            then
               declare
                  full_Name : constant unbounded_String := +(  the_Name (the_Name'First .. First - 1)
                                                             & Self.template_full_Forms.Element (Each)
                                                             & the_Name (First + plain_Form'Length .. the_Name'Last));
               begin
                  if Self.swig_type_Map_of_c_type.contains (full_Name)
                  then
                     return Self.swig_type_Map_of_c_type.Element (full_Name);
                  end if;
               end;
            end if;
         end;
      end loop;

      --  The name may hold an instance with some of the default arguments given and not others (the copy
      --  constructor of a vector of vectors, whose own allocator the core gives and not that of the vector within
      --  it). With all of them given, as the full form of an instance is made, the full form is found in it.
      --
      declare
         all_Defaults : constant String := +doh_Item (Swig_symbol_template_deftype (SwigType_Pointer (to_Doh (the_Name)), null));
      begin
         if all_Defaults /= the_Name
         then
            for Each in 1 .. Natural (Self.template_full_Forms.Length)
            loop
               declare
                  full_Form : constant String  := Self.template_full_Forms.Element (Each);
                  First     : constant Natural := ada.Strings.fixed.Index (all_Defaults, full_Form);
               begin
                  if First /= 0
                  then
                     declare
                        plain_Name : constant unbounded_String := +(  all_Defaults (all_Defaults'First .. First - 1)
                                                                    & Self.template_plain_Forms.Element (Each)
                                                                    & all_Defaults (First + full_Form'Length .. all_Defaults'Last));
                     begin
                        if Self.swig_type_Map_of_c_type.contains (plain_Name)
                        then
                           return Self.swig_type_Map_of_c_type.Element (plain_Name);
                        end if;
                     end;
                  end if;
               end;
            end loop;
         end if;
      end;

      return null;
   end known_in_another_template_Form;



   function demand_c_Type_for (Self : access Item;   swig_Type : in doh_swigType) return c_Type.view
   is
      use type C.int;
      the_Type : c_Type.view;

   begin
      --  A pointer to a class member ('m(Shape).f(void).double', 'm(Shape).int') is one of the two types of 'swig'
      --  for them, by whether its member is a function.
      --
      declare
         Plain : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (to_Doh (without_leading_Qualifiers (+swig_Type)))));
      begin
         if SwigType_ismemberpointer (Plain) /= 0
         then
            declare
               Member : constant String_Pointer := SwigType_pop (Plain) with Unreferenced;     -- 'm(Shape).'.
            begin
               return Self.fetch_c_Type (+(if SwigType_isfunction (Plain) /= 0 then "member_function_Pointer" else "member_data_Pointer"));
            end;
         end if;
      end;

      the_Type := Self.swig_type_Map_of_c_type.Element (+swig_Type);
      return the_Type;

   exception
      when constraint_Error =>   -- No element in map.
         --  It may name a standard string as an instance of its template (see 'as_a_standard_String').
         --
         declare
            the_String : constant String := as_a_standard_String (+swig_Type);
         begin
            if         the_String /= String'(+swig_Type)
              and then Self.swig_type_Map_of_c_type.contains (+the_String)
            then
               return Self.swig_type_Map_of_c_type.Element (+the_String);
            end if;
         end;

         --  The type may name a template instance with the default arguments of its template given.
         --
         declare
            in_its_other_Form : constant c_Type.view := Self.known_in_another_template_Form (+String'(+swig_Type));
         begin
            if in_its_other_Form /= null
            then
               return in_its_other_Form;
            end if;
         end;

         --  A name which is written from the outermost scope ('::FooType') is that of the type with no such mark.
         --
         declare
            the_Name : constant String  := +swig_Type;
            Colons   : constant Natural := ada.Strings.fixed.Index (the_Name, "::");
         begin
            if         Colons /= 0
              and then (        Colons = the_Name'First
                        or else the_Name (Colons - 1) = '.')
              and then Self.swig_type_Map_of_c_type.contains (+(the_Name (the_Name'First .. Colons - 1) & the_Name (Colons + 2 .. the_Name'Last)))
            then
               return Self.swig_type_Map_of_c_type.Element (+(the_Name (the_Name'First .. Colons - 1) & the_Name (Colons + 2 .. the_Name'Last)));
            end if;
         end;

         --  A type of the C library which is named in the namespace 'std' ('std::size_t', 'std::int32_t', as the C++
         --  headers have them) is the type itself, where that is a number which the module knows, or one of the
         --  library's types of numbers (whose names end in '_t'). (Until 2026-11-25
         --  it was not known: yaml-cpp's 'ostream_wrapper' lost four of its members so.)
         --
         declare
            the_Name : constant String  := +swig_Type;
            First    : constant Natural := ada.Strings.fixed.Index (the_Name, "std::");
         begin
            if         First /= 0
              and then (        First = the_Name'First
                        or else the_Name (First - 1) = '.')
              and then ada.Strings.fixed.Index (the_Name (First + 5 .. the_Name'Last), "::") = 0
              and then Self.swig_type_Map_of_c_type.contains (+the_Name (First + 5 .. the_Name'Last))
              and then (        Self.swig_type_Map_of_c_type.Element (+the_Name (First + 5 .. the_Name'Last)).is_a_Number
                        or else ada.Strings.fixed.Tail (the_Name, 2) = "_t")      -- 'ptrdiff_t', 'int32_t' ...
              and then Self.swig_type_Map_of_c_type.contains (+(the_Name (the_Name'First .. First - 1) & the_Name (First + 5 .. the_Name'Last)))
            then
               return Self.swig_type_Map_of_c_type.Element (+(the_Name (the_Name'First .. First - 1) & the_Name (First + 5 .. the_Name'Last)));
            end if;
         end;

         --  A pointer or reference to, or an array of, a type which is not known yet (a class which is used ahead
         --  of its declaration): the type itself is made, not known, with its pointer and array types, so that
         --  they are those of the class once it is declared. Without this the pointer alone was made, and stayed
         --  unknown when the class came.
         --
         declare
            the_Name : constant String  := +swig_Type;
            First    :          Natural := the_Name'First;
         begin
            loop
               if    First + 1 <= the_Name'Last and then the_Name (First .. First + 1) in "p." | "r." | "z."
               then
                  First := First + 2;

               elsif First + 1 <= the_Name'Last and then the_Name (First .. First + 1) = "q("
               then
                  declare
                     Close : constant Natural := ada.Strings.fixed.Index (the_Name, ").", From => First);
                  begin
                     exit when Close = 0;
                     First := Close + 2;
                  end;
               else
                  exit;
               end if;
            end loop;

            if         First > the_Name'First
              and then First <= the_Name'Last
              and then ada.Strings.fixed.Index (the_Name (First .. the_Name'Last), "(") /= First + 1     -- Not a function, an array or a member pointer.
            then
               declare
                  the_Base : constant c_Type.view := Self.demand_c_Type_for (doh_swigType (to_Doh (the_Name (First .. the_Name'Last)))) with Unreferenced;
               begin
                  if Self.swig_type_Map_of_c_type.contains (+swig_Type)
                  then
                     return Self.swig_type_Map_of_c_type.Element (+swig_Type);
                  end if;
               end;
            end if;
         end;

         --  A name which the module has not been given may be a typedef which the core can follow: one which a
         --  'using' declaration brings into another namespace ('using Foo::Integer;'), or one of a class template.
         --  The type is then the one which the name stands for.
         --
         declare
            Resolved : constant String := +doh_Item (SwigType_typedef_resolve_all (SwigType_Pointer (swig_Type)));
         begin
            if         Resolved /= String'(+swig_Type)
              and then Self.swig_type_Map_of_c_type.contains (+Resolved)
            then
               return Self.swig_type_Map_of_c_type.Element (+Resolved);

            --  The name may stand for a type with a qualifier, which makes no difference to a value of it (a typedef
            --  of a template parameter, 'iterator_base<const iterator_value>::value_type').
            --
            elsif      Resolved /= String'(+swig_Type)
              and then without_leading_Qualifiers (Resolved) /= Resolved
              and then Self.swig_type_Map_of_c_type.contains (+without_leading_Qualifiers (Resolved))
            then
               return Self.swig_type_Map_of_c_type.Element (+without_leading_Qualifiers (Resolved));

            --  The core may give an instance within the name with the default arguments of its template, where the
            --  module knows it without them ('__normal_iterator<node**, std::vector<node*, std::allocator<node*> > >',
            --  through a typedef of 'std::vector<node*>').
            --
            elsif      Resolved /= String'(+swig_Type)
              and then Self.known_in_another_template_Form (+Resolved) /= null
            then
               return Self.known_in_another_template_Form (+Resolved);

            --  A qualifier within it, as a typedef of a template instance whose argument is a pointer gives (Bullet's
            --  'btAlignedAllocator<const T*, 16>::reference', which is 'r.p.q(const).T'), makes no other type of it
            --  here, as a type is entered with its qualifiers taken off ('register'). (Until 2026-11-25 such a typedef
            --  was not known, and the functions of the allocators which used one were left out.)
            --
            elsif      Resolved /= String'(+swig_Type)
              and then Self.swig_type_Map_of_c_type.contains (+without_all_Qualifiers (Resolved))
            then
               the_Type := Self.swig_type_Map_of_c_type.Element (+without_all_Qualifiers (Resolved));
               Self.swig_type_Map_of_c_type.insert (+String'(+swig_Type), the_Type);     -- A later step may seek it by this name (the
               return the_Type;                                                         -- resolution of the function pointers).
            end if;
         end;

         --  A template instance which a template names with the typedefs of its arguments resolved ('aiMatrix4x4t<(float)>',
         --  as a constructor of Assimp's 'aiMatrix3x3t' names it) may be known by a name which has them ('aiMatrix4x4t<
         --  (ai_real)>', which a typedef named first): the type of that name is it, and it is entered by this one too.
         --  (Until 2026-11-25 a second type was made, which stayed one that is not known when the class took over the
         --  first, and the functions which took it were left out.)
         --
         declare
            the_Name  : constant String := +swig_Type;
            Found_Key :          unbounded_String;
         begin
            if         ada.Strings.fixed.Index (the_Name, "<(") /= 0
              and then (the_Name'Length < 2 or else the_Name (the_Name'First + 1) /= '.')     -- Not 'p.', 'r.', 'a.' ...
            then
               for Cursor in Self.swig_type_Map_of_c_type.Iterate
               loop
                  declare
                     use swig_type_Maps_of_c_type;
                     the_Key : constant String := to_String (Key (Cursor));
                  begin
                     if         ada.Strings.fixed.Index (the_Key, "<(") /= 0
                       and then the_Key /= the_Name
                       and then not (the_Key'Length > 2 and then the_Key (the_Key'First + 1) = '.')
                       and then String'(+doh_Item (SwigType_typedef_resolve_all (SwigType_Pointer (to_Doh (the_Key))))) = the_Name
                     then
                        the_Type  := Element (Cursor);
                        Found_Key := Key (Cursor);
                        exit;
                     end if;
                  end;
               end loop;

               if the_Type /= null
               then   -- Once the map is no longer being walked, with the forms which were made with the type.
                  declare
                     type Prefix_array is array (Positive range <>) of unbounded_String;
                     Prefixes : constant Prefix_array := [+"", +"a.", +"p.", +"a.p.", +"p.p.", +"r.", +"r.q(const).", +"p.q(const).", +"z."];
                  begin
                     for Prefix of Prefixes
                     loop
                        if         Self.swig_type_Map_of_c_type.contains (Prefix & Found_Key)
                          and then not Self.swig_type_Map_of_c_type.contains (Prefix & the_Name)
                        then
                           Self.swig_type_Map_of_c_type.insert (Prefix & the_Name, Self.swig_type_Map_of_c_type.Element (Prefix & Found_Key));
                        end if;
                     end loop;
                  end;

                  return the_Type;
               end if;
            end if;
         end;

         if the_Type = null
         then   -- C type has not yet been declared, so create it as an 'unknown' C type.
            the_Type := c_type.new_unknown_Type;        -- 'Unknown' type is a mutable variant record, so it can be morphed.

            the_Type.nameSpace_is (Self.current_c_Namespace);
            the_Type.Name_is      (+swig_Type);

            Self.register (the_Type, swig_Type);
         end if;

         return the_Type;
   end demand_c_Type_for;



   function demand_Module (Self : access Item;   Named : in unbounded_String) return swig_Module.swig_Module_view
   is
      the_Module : swig_Module.swig_Module_view;
   begin
      the_Module := Self.name_Map_of_module.Element (Named);
      return the_Module;

   exception
      when constraint_Error =>   -- No element in map.
         the_Module := new swig_Module.item;
         the_Module.define (Named, (if ada_Package."=" (Self.Package_namespace, null) then Self.Package_standard
                                                                     else Self.Package_namespace));

         Self.name_Map_of_module.insert (Named, the_Module);
         Self.new_Modules       .append (the_Module);

         return the_Module;
   end demand_Module;



   function current_c_Namespace (Self : access Item) return c_nameSpace.view
   is
   begin
      return Self.c_namespace_Stack.last_Element;
   end current_c_Namespace;



   function current_c_Class (Self : access Item) return c_Type.view
   is
   begin
      return Self.c_class_Stack.last_Element;
   end current_c_Class;



   function to_Descriptor (Self : access Item;   swig_Type : in doh_swigType) return unbounded_String
   is
      the_Name       : constant unbounded_String := Self.my_stripped (swig_Type);
      the_Descriptor :          unbounded_String := class_Prefix_in (the_Name);
   begin
      if the_Descriptor = "" then
         the_Descriptor := the_Name;
      end if;

      replace_All (the_Descriptor,  ").",  "_ret_");
      replace_All (the_Descriptor,  "f(",  "f_");
      replace_All (the_Descriptor,  "p.",  "p_");
      replace_All (the_Descriptor,  "r.",  "r_");
      replace_All (the_Descriptor,  ",",   "_");

      replace_All (the_Descriptor,  ".",   "_");

      replace_All (the_Descriptor,  "<",   "_");
      replace_All (the_Descriptor,  ">",   "");
      replace_All (the_Descriptor,  "(",   "");
      replace_All (the_Descriptor,  ")",   "");
      replace_All (the_Descriptor,  " ",   "");

      return the_Descriptor;
   end to_Descriptor;



   function my_stripped (Self : access Item;   swig_Type : in doh_swigType) return unbounded_String
   is
      use swigg.Utility;
      stripped_swig_Type : unbounded_String := +doh_Item (SwigType_strip_qualifiers (SwigType_Pointer (swig_Type)));
   begin
      strip_enum_Prefix                     (stripped_swig_Type);
      strip_leading_global_namespace_Prefix (stripped_swig_Type);   -- TODO: Add this below in demand_Type also ?!

      --  Strip namespace Prefix, if any.
      --
      declare
         Cursor : namespace_Sets.Cursor := First (Self.a_Namespaces);
      begin
         while has_Element (Cursor)   -- Loop til there are no more namespaces left.
         loop
            declare
               the_Namespace   : constant String  := to_String (Element (Cursor)) & "::";
               namespace_Index : constant Natural := Index (stripped_swig_Type, the_Namespace);
            begin
               if namespace_Index /= 0
               then
                  delete (stripped_swig_Type, namespace_Index, namespace_Index + the_Namespace'Length - 1);
                  Cursor := First (Self.a_Namespaces);  -- Restart.
               else
                  next (Cursor);
               end if;
            end;
         end loop;
      end;

      --  Strip array bounds, if any.
      --
      declare
         bounds_Start : Natural;
         bounds_End   : Natural;
      begin
         loop
            bounds_Start := Index (stripped_swig_Type, "a(");
            exit when bounds_Start = 0;                              -- Loop until there are no more array bounds left.
            bounds_End   := Index (stripped_swig_Type, ")", from => bounds_Start);

            delete (stripped_swig_Type, bounds_Start + 1, bounds_End);
         end loop;
      end;

      return stripped_swig_Type;
   end my_stripped;



   function current_class_namespace_Prefix (Self : access Item) return unbounded_String
   is
   begin
      if Self.c_class_Stack.Is_Empty
      then
         return null_unbounded_String;
      else
         declare
            Name : constant String := +Self.c_class_Stack.last_Element.Name;
         begin
            if Name = "std"
            then
               return null_unbounded_String;
            else
               return +Name & "::";
            end if;
         end;
      end if;
   end current_class_namespace_Prefix;



   procedure add_Namespace (Self : access Item;   Named : in unbounded_String)
   is
   begin
      insert (Self.a_Namespaces, Named);

   exception
      when constraint_Error => dlog ("attempt to add namespace '" & Named & "' twice ... ignoring !");
   end add_Namespace;



   function get_overloaded_Name (for_Node : in doh_Node) return String
   is
      the_Name : constant String := Attribute (for_Node, "sym:name");
   begin
      if get_Attribute (for_Node, "sym:overloaded") /= null
      then
         return the_Name & Attribute (for_Node, "sym:overname");       -- Add overload suffix.
      else
         return the_Name;
      end if;
   end get_overloaded_Name;



   function main_Package (Self : access Item) return ada_Package.view
   is
   begin
      return Self.Module_top.Ada.Package_top;
   end main_Package;



   function to_ada_subProgram (Self : access Item;   the_c_Function : in c_Function.view) return ada_subProgram.View
   is
      use ada.Exceptions;

      the_ada_subProgram : ada_subProgram.view;
   begin
      the_ada_subProgram := new_ada_subProgram (ada_Utility.to_ada_Identifier (the_c_Function.Name),
                                                Self.c_type_Map_of_ada_type.Element (the_c_Function.return_Type));
      the_ada_subProgram.link_Symbol        := the_c_Function.link_Symbol;
      the_ada_subProgram.is_in_Wrapper      := the_c_Function.is_in_Wrapper;
      the_ada_subProgram.constructor_Symbol := the_c_Function.constructor_Symbol;
      the_ada_subProgram.is_Virtual         := the_c_Function.is_Virtual;
      the_ada_subProgram.is_Abstract        := the_c_Function.is_Abstract;
      the_ada_subProgram.is_Overriding      := the_c_Function.is_Overriding;
      the_ada_subProgram.is_Constructor     := the_c_Function.is_Constructor;
      the_ada_subProgram.is_Destructor      := the_c_Function.is_Destructor;

      the_ada_subProgram.director_Symbol      := the_c_Function.director_Symbol;
      the_ada_subProgram.director_is_Abstract := the_c_Function.director_is_Abstract;

      return the_ada_subProgram;

   exception
      when E : constraint_Error =>
         dlog ("");
         dlog ("********************************************************");
         dlog ("ada_Language.to_ada_subProgram");
         dlog (exception_Information (E));
         dlog ("c_Function name:        '" & the_c_Function.Name             & "'");
         dlog ("c_Function return type: '" & the_c_Function.return_Type.Name & "'");
         dlog ("*********************************************************");
         dlog ("");

         raise;
   end to_ada_subProgram;



   function to_ada_Variable (Self : access Item;   the_c_Variable : in c_Variable.view) return ada_Variable.view
   is
      use ada.Exceptions;

      the_ada_variable : ada_Variable.view;
   begin
      the_ada_variable := new_ada_Variable (ada_Utility.to_ada_Identifier       (the_c_Variable.Name),
                                            Self.c_type_Map_of_ada_type.Element (the_c_Variable.my_Type),
                                            the_c_Variable.Value);

      for i in 1 .. Integer (the_c_Variable.array_Bounds.Length)
      loop
         the_ada_Variable.array_Bounds.append (the_c_Variable.array_Bounds.Element (i));
      end loop;

      --  The symbol of a variable is its C name, which its Ada name may differ from (a variable 'Abstract' is 'the_Abstract').
      --
      the_ada_Variable.bit_Field         := the_c_Variable.bit_Field;
      the_ada_Variable.member_Name       := the_c_Variable.member_Name;
      the_ada_Variable.is_anonymous_Bits := the_c_Variable.is_anonymous_Bits;
      the_ada_Variable.is_empty_String   := the_c_Variable.is_empty_String;
      the_ada_Variable.from_Wrapper      := the_c_Variable.from_Wrapper;

      the_ada_Variable.link_Symbol := (if the_c_Variable.link_Symbol /= "" then the_c_Variable.link_Symbol
                                                                           else the_c_Variable.Name);

      return the_ada_Variable;

   exception
      when E : constraint_Error =>
         dlog ("");
         dlog ("********************************************************");
         dlog ("ada_Language.to_ada_Variable");
         dlog (exception_Information (E));
         dlog ("c_Variable name: '" & the_c_Variable.Name         & "'");
         dlog ("c_Variable type: '" & the_c_Variable.my_Type.Name & "'");
         dlog ("*********************************************************");
         dlog ("");

         raise;
   end to_ada_Variable;



   function makeParameterName (parameter_List : in doh_parmList;
                               the_Parameter  : in doh_Parm;
                               arg_num        : in Integer) return String
   is
      the_Name  : constant String       := Attribute (Node_Pointer (the_Parameter), "name");
      Count     :          Natural      := 0;
      Parameter :          doh_parmList := parameter_List;
   begin
      --  Use C parameter name unless it is a duplicate or an empty parameter name.
      --
      while exists (Parameter)
      loop
         if the_Name = Attribute (Node_Pointer (Parameter), "name")
         then
            Count := Count + 1;
         end if;

         Parameter := doh_parmList (next_Sibling (Node_Pointer (Parameter)));
      end loop;

      if the_Name = ""  or  Count > 1
      then
         if Count = 1
         then
            return the_Name & "arg_1";     -- The only parameter with no name, which has always been named so.
         else
            return the_Name & "arg_" & Trim (Integer'Image (arg_num + 1), ada.strings.Left);     -- By its place, so that two such names differ.
         end if;
      else
         return the_Name;
      end if;
   end makeParameterName;



   procedure freshen_current_module_Package (Self : access Item;   for_Node : in doh_Node)
   is
      pragma Unreferenced (Self);
   begin
      null; -- TODO: Self.current_module_Package := Self.old_fetch_Package (named => current_module_Name);
   end freshen_current_module_Package;



   function to_c_Parameters (Self : access Item;   swig_Parameters : in doh_ParmList) return c_parameter.Vector
   is
      the_C_Parameters : c_parameter.Vector;
   begin
      -- Attach the non-standard typemaps to the parameter list.
      --
      Swig_typemap_attach_parms (const_String (-"in"),               ParmList_Pointer (swig_Parameters), null);
      Swig_typemap_attach_parms (const_String (-"adatype"),          ParmList_Pointer (swig_Parameters), null);
      Swig_typemap_attach_parms (const_String (-"adain"),            ParmList_Pointer (swig_Parameters), null);
      Swig_typemap_attach_parms (const_String (-"imtype"),           ParmList_Pointer (swig_Parameters), null);
      Swig_typemap_attach_parms (const_String (-"link_symbol_code"), ParmList_Pointer (swig_Parameters), null);

      declare
         the_Parameter : Node_Pointer := Node_Pointer (swig_Parameters);
         Index         : Integer      := 0;
         use type C.int;
      begin
         emit_mark_varargs (ParmList_Pointer (swig_Parameters));

         while the_Parameter /= null
         loop
            if check_Attribute (the_Parameter, "varargs:ignore", "1")
            then
               the_Parameter := next_Sibling (the_parameter);                          -- Ignored varargs.

            elsif check_Attribute (the_Parameter, "tmap:in:numinputs", "0")
            then
               the_Parameter := get_Attribute (the_Parameter, "tmap:in:next");         -- Ignored parameters.

            else
               if not (Self.variable_wrapper_flag  and  Index = 0)
               then   -- Ignore the 'this' argument for variable wrappers.
                  declare
                     use c_Parameter.Vectors,
                         swigg.Utility;

                     param_swigType : SwigType_Pointer :=SwigType_Pointer (doh_Copy (doh_Item (get_Attribute (the_parameter, "type"))));
                  begin
                     strip_all_qualifiers (doh_Item (param_swigType));

                     --  A pointer or reference whose typemap takes the value itself ('double *INPUT' of 'typemaps.i', which
                     --  says so by the attribute 'byvalue') is a parameter of the type which is pointed to.
                     --
                     if Attribute (the_Parameter, "tmap:in:byvalue") /= ""
                     then
                        if SwigType_isreference (param_swigType) /= 0
                        then
                           param_swigType := SwigType_del_reference (param_swigType);

                        elsif SwigType_ispointer (param_swigType) /= 0
                        then
                           param_swigType := SwigType_del_pointer (param_swigType);
                        end if;

                        strip_all_qualifiers (doh_Item (param_swigType));
                     end if;

                     if not (String'(+doh_Item (param_swigType)) = "")     -- Guard against an empty parameter list.
                     then
                        dlog ("to_c_Parameters ~ param_swigType: '" & to_String (doh_Item (param_swigType)) & "'");

                        strip_all_qualifiers (doh_swigType (param_swigType));

                        if SwigType_isarray (param_swigType) /= 0
                        then   -- Transform the C array to its equivalent C pointer.
                           param_swigType := SwigType_del_array   (param_swigType);
                           param_swigType := SwigType_add_pointer (param_swigType);
                        end if;

                        declare
                           parameter_Name : constant unbounded_String
                             := to_unbounded_String (makeParameterName (swig_Parameters,
                                                                        doh_Parm (the_Parameter),
                                                                        Index));
                           new_Parameter : c_Parameter.view;
                        begin
                           new_Parameter := new_c_Parameter (parameter_Name,
                                                             Self.demand_c_Type_for (doh_Item (param_swigType)));

                           new_Parameter.link_symbol_Code := +Attribute (the_Parameter, "tmap:link_symbol_code");
                           new_Parameter.is_Pointer       :=         SwigType_isreference        (param_swigType) /= 0
                                                             or else SwigType_isrvalue_reference (param_swigType) /= 0
                                                             or else SwigType_ispointer   (param_swigType) /= 0;

                           dlog (  "adding new parameter => " & new_Parameter.Name
                                & "   type => "               & new_parameter.my_type.name
                                & "   is pointer => "         & new_parameter.is_Pointer'Image);

                           append (the_C_Parameters, new_Parameter);
                        end;
                     end if;
                  end;
               end if;

               the_Parameter := get_Attribute (the_Parameter, "tmap:in:next");
            end if;

            Index := Index + 1;
         end loop;
      end;

      return the_C_Parameters;
   end to_c_Parameters;



   function to_ada_Parameters (Self : access Item;   the_c_Parameters : in c_Parameter.Vector) return ada_Parameter.vector
   is
      use c_Parameter.Vectors;

      the_ada_Parameters : ada_Parameter.vector;
      Cursor             : c_Parameter.Cursor := the_C_Parameters.First;
      the_c_Parameter    : c_Parameter.view;
   begin
      while has_Element (Cursor)
      loop
         the_c_Parameter := Element (Cursor);

         declare
            use ada.Exceptions;
            the_ada_Parameter : ada_Parameter.view;
         begin
            the_ada_Parameter := new_ada_Parameter (the_c_Parameter.Name,
                                                    Self.c_type_Map_of_ada_type.Element (the_c_Parameter.my_Type));
            the_ada_Parameters.append (the_ada_Parameter);
         exception
            when E : constraint_Error =>
               dlog ("");
               dlog ("********************************************************");
               dlog (exception_Information (E));
               dlog ("c_Parameter name: '" & the_c_Parameter.Name         & "'");
               dlog ("c_Parameter type: '" & the_c_Parameter.my_Type.Name & "'");
               dlog ("*********************************************************");
               dlog ("");

               raise;
         end;

         next (Cursor);
      end loop;

      return the_ada_Parameters;
   end to_ada_Parameters;



   function new_c_Function (Self : access Item;   the_Node       : in doh_Node;
                                                  function_Name  : in unbounded_String;
                                                  nameSpace      : in c_nameSpace.view;
                                                  is_Destructor  : in Boolean;
                                                  is_Constructor : in Boolean := False;
                                                  is_Overriding  : in Boolean := False) return c_Function.view
   is separate;



   procedure add_array_Bounds_to (Self : access Item;   the_Variable   : in c_Variable.view;
                                                        from_swig_Type : in doh_swigType)
   is
      use c_Variable.array_bounds_Vectors;

      swig_Type_copy  : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (from_swig_Type));
      the_Array       : constant SwigType_Pointer := SwigType_pop_Arrays (swig_Type_copy);
      dimension_Count : constant C.int            := SwigType_array_nDim (the_Array);

      array_dimension_Expression : aliased unbounded_String;
      resolved_array_Dimension   :         Integer;

      use type C.int;
   begin
      for i in 1 .. dimension_Count
      loop
         array_dimension_Expression := +doh_Item (SwigType_array_getdim (the_Array, i - 1));

         if array_dimension_Expression = ""
         then
            resolved_array_Dimension := 0;
         else
            begin
               resolved_array_Dimension := Integer (Value (resolved_c_integer_Expression (Self, array_dimension_Expression,
                                                                                                Self.integer_symbol_value_Map,
                                                                                                Self.current_class_namespace_Prefix)));
            exception
               when others =>   -- Such as a dimension which depends upon a template parameter, or the size of a string literal.
                  resolved_array_Dimension := 0;

                  warn (Value, "Unable to evaluate the array dimension '" & array_dimension_Expression & "' of '" & the_Variable.Name
                             & "', whose length is taken to be unknown.");
            end;
         end if;

         append (the_Variable.array_Bounds, resolved_array_Dimension - 1);
      end loop;
   end add_array_Bounds_to;


end ada_Language;
