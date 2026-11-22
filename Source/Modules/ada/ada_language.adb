with
     Transformer,

     ada_Language.c_expression_Resolver,
     ada_Language.source_Generator,
     ada_Language.Forge,

     ada_Utility,
     Logger,

     swig_Core.Binding,
     swigMod.Binding,
     swigMod.Dispatcher,
     swig_Core.Wrapper,

     swigg.Utility,

     DOHs.Binding,
     DOHs.Pointers,

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
         new String'("       -namespace <ns> - Generate wrappers into Ada namespace <ns>"),
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
   function  cpp_Symbol (qualified_Name : in String;   Suffix : in String) return String;
   procedure bind_constructors_of_abstract_Class (Self : access Item;   the_Class : in Node_Pointer);
   procedure bind_other_base_Classes             (Self : access Item;   the_Class : in Node_Pointer);
   procedure add_hidden_Members                  (Self : access Item;   Before    : in Node_Pointer;   of_Class : in Node_Pointer := null);
   function  wrapper_Symbol                      (Self : access Item;   From      : in String) return unbounded_String;
   procedure bind_unnamed_nested_Classes         (Self : access Item;   the_Class : in Node_Pointer;   outer_Name : in String;   cpp_Name : in String);
   function  member_Variable                     (Self : access Item;   the_Node  : in Node_Pointer;   the_Name   : in String) return c_Variable.view;

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
   begin
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
      is_Constant   : constant Boolean :=  SwigType_isConst (the_swig_Type) /= 0;
      value_Text    : constant String  :=  Attribute (the_Node, "value");
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
              and then new_Variable.my_Type.is_a_standard_Integer
            then
               begin
                  new_Variable.Value := +Image (resolved_c_integer_Expression (Self, +value_Text,
                                                                                     Self.integer_symbol_value_Map,
                                                                                     Self.current_class_namespace_Prefix));
               exception
                  when others =>
                     null;     -- The value is not an integer expression, so the constant is imported.
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
            end if;

            --  A variable in a namespace is imported by its C++ symbol.
            --
            if         new_Variable.Value = ""
              and then ada.Strings.fixed.Index (full_Name, "::") /= 0
            then
               new_Variable.link_Symbol := +cpp_Symbol (full_Name, Suffix => "E");
            end if;
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

      if    Self.getCurrentClass /= null
        and Self.cplus_Mode      /= swigMod.Dispatcher.Public
      then
         return SWIG_NOWRAP;
      end if;

      Self.current_c_Node := doh_Node (the_Node);
      locate (doh_Node (the_Node));

      declare
         the_Name          : unbounded_String := +Attribute (the_Node, "sym:name");        -- Will be null string for an anonymous enum.
         the_doh_swig_Type : SwigType_Pointer := SwigType_Pointer (doh_Copy (DOH_Pointer (doh_swig_Type)));
      begin
         dlog ("the_Name: '" & the_Name & "'");

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

         new_c_Enum := c_type.new_Enum (Namespace => Self.current_c_Namespace,
                                        Name      => the_Name);
         Self.register (new_c_Enum,
                        doh_SwigType (the_doh_swig_Type));

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

      Status := swigMod.Language.item (Self.all).enumDeclaration (the_Node);     -- Process each enum element (ie the enum literals).

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
      symName  : constant unbounded_String := +Attribute (the_Node, "sym:name");

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

      Storage         : constant String  := Attribute (the_Node, "storage");
      Value           : constant String  := Attribute (the_Node, "value");
      is_Virtual      : constant Boolean := Storage = "virtual";
      is_Pure         : constant Boolean := Value   = "0";
      is_pure_Virtual : constant Boolean := is_Pure and is_Virtual;

      overriding_Value : constant Node_Pointer := get_Attribute (the_Node, "override");

      function is_Overriding return Boolean
      --
      --  Only the first virtual base class of a class is kept as its parent, so a function which overrides
      --  one from another base class has nothing to override in the Ada binding.
      --
      is
         function owner_is_among_Bases (the_Class : in c_Type.view;   Owner        : in String;
                                                                      parents_only : in Boolean) return Boolean
         is
            Bases : constant c_Type.Vector := the_Class.base_Classes;
         begin
            for Each of Bases
            loop
               if        not parents_only
                 or else Each.is_Virtual
               then
                  if        Each.Name = Owner
                    or else owner_is_among_Bases (Each, Owner, parents_only)
                  then
                     return True;
                  end if;

                  exit when parents_only;     -- Only the first virtual base class is the parent.
               end if;
            end loop;

            return False;
         end owner_is_among_Bases;

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
         then
            return "";
         else   -- The class is named as C++ knows it ('Base< int >'), which for a template instance is not the name it is bound by.
            return String'(+doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (Self.getCurrentClass, "name"))))) & "::";
         end if;
      end get_Namespace;

      Namespace : constant String := get_Namespace;
   begin
      indent_Log;
      dlog (+"");
      dlog (+"memberFunctionHandler");

      Self.current_c_Node := doh_Node (the_Node);
      locate (doh_Node (the_Node));

      set_Attribute (the_Node, "name", Namespace & function_Name);

      Status := swigMod.Language.item (Self.all).memberFunctionHandler (the_Node);

      declare
         the_new_Function : c_Function.view;
      begin
         the_new_Function := Self.new_c_Function (doh_Node (the_Node),
                                                  +Attribute (the_Node, "sym:name"),
                                                  Self.current_c_Class.nameSpace.all'Access,
                                                  is_Destructor => False,
                                                  is_Overriding => is_Overriding);

         if c_Function."/=" (the_new_Function, null)     -- No function is made for an overload which cannot be told apart in Ada.
         then
            Self.prior_c_Declaration := the_new_Function.all'Access;
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
      the_Node : doh_Node renames N;

      swig_Type          :          SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (get_Attribute (the_Node, "type"))));
      swig_Type_is_array : constant Boolean          := SwigType_isArray   (swig_Type) /= 0;
      is_Pointer         : constant Boolean          := SwigType_isPointer (swig_Type) /= 0;
      variable_Name      : constant unbounded_String := +Attribute (the_Node, "sym:name");

      function has_virtual_Base return Boolean
      is
         Bases : constant c_Type.Vector := Self.current_c_Class.base_Classes;
      begin
         return (for some Each of Bases => Each.is_Virtual);
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
           and then not check_Attribute (the_Node, "access", "private")     -- No wrapper is made for a private member.
         then
            declare
               Status : C.int with Unreferenced;
            begin
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

      declare
         use swigg.Utility;
         use type C.int;

         the_swig_Type :          SwigType_Pointer := SwigType_Pointer (doh_Copy (DOH_Pointer (the_swigType)));
         is_Constant   : constant Boolean          := SwigType_isConst (the_swig_Type) /= 0;
         value_Text    : constant String           := Attribute (the_Node, "value");
         class_Name    : constant String           := +DOH_Pointer (get_Attribute (Self.getCurrentClass, "name"));
         the_Symbol    : constant String           := cpp_Symbol (class_Name & "::" & to_String (variable_Name), Suffix => "E");

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
               if new_Variable.my_Type.is_a_standard_Integer
               then
                  new_Variable.Value := +Image (resolved_c_integer_Expression (Self, +value_Text,
                                                                                     Self.integer_symbol_value_Map,
                                                                                     Self.current_class_namespace_Prefix));

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
   is
      pragma Unreferenced (Self, N);
   begin
      return SWIG_OK;     -- Do nothing, since public/protected/private is ignored in Ada,
                          -- so 'using::' clauses are irrelevant (ie the 'used' members are already available).
   end usingDeclaration;



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



   function member_Variable (Self : access Item;   the_Node : in Node_Pointer;   the_Name : in String) return c_Variable.view
   --
   --  Makes a member variable from the node of its declaration, for a member which the core does not hand on.
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
                           the_Member : constant c_Variable.view := member_Variable (Self, the_Child, Attribute (the_Child, "name"));
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
   --  The first base class of a class which has virtual functions becomes the parent of its Ada type. Any
   --  other base class is a component of the Ada record, which may be storage alone: where the Ada type has a
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
                  if         Self.name_Map_of_c_type.Element (+base_Name).is_Virtual
                    and then not parent_Found
                  then
                     parent_Found := True;     -- The parent, which Ada reaches by a view conversion.
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



   function cpp_Symbol (qualified_Name : in String;   Suffix : in String) return String
   is separate;



   function returns_a_cpp_constructed_Type (Self : access Item;   the_Node : in doh_Node) return Boolean
   --
   --  True when the function of the node returns, by value, a type which C++ constructs.
   --
   is
      use swigg.Utility;
      use type C.int;

      the_swig_Type : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (get_Attribute (the_Node, "type"))));
   begin
      if get_Attribute (the_Node, "type") = null
      then
         return False;
      end if;

      declare
         Pad : doh_swigType := doh_Item (the_swig_Type);
      begin
         strip_all_Qualifiers (Pad);
      end;

      if        SwigType_isPointer   (the_swig_Type) /= 0
        or else SwigType_isReference        (the_swig_Type) /= 0
        or else SwigType_isrvalue_reference (the_swig_Type) /= 0
        or else SwigType_isArray     (the_swig_Type) /= 0
        or else not Self.swig_type_Map_of_c_type.contains (+doh_Item (the_swig_Type))
      then
         return False;
      end if;

      return Self.swig_type_Map_of_c_type.Element (+doh_Item (the_swig_Type)).is_constructed_by_Cpp;
   end returns_a_cpp_constructed_Type;



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



   function demand_c_Type_for (Self : access Item;   swig_Type : in doh_swigType) return c_Type.view
   is
      the_Type : c_Type.view;

   begin
      the_Type := Self.swig_type_Map_of_c_type.Element (+swig_Type);
      return the_Type;

   exception
      when constraint_Error =>   -- No element in map.
         --  The type may name a template instance with the default arguments of its template given.
         --
         declare
            the_Name : constant String := +swig_Type;
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
            end loop;
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
         the_Module.define (Named, Self.Package_standard);

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
