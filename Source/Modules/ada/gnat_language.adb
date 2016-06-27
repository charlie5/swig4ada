with
     Transformer,

     gnat_Language.c_expression_Resolver,
     gnat_Language.source_Generator,
     gnat_Language.Forge,

     ada_Utility,

     swigg_Module,
     Dispatcher,
     Wrapper,

     swigg.Utility,
     swig_p_Doh,

     ada.Strings.fixed,
     ada.text_IO,

     interfaces.C,
     interfaces.c.Strings;


package body gnat_Language
is
   use gnat_Language.c_expression_Resolver,

       c_Parameter,

       ada_Package,
       ada_Variable,
       ada_Utility,

       swigg_Module,
       Dispatcher,
       Wrapper,

       interfaces.c.Strings,

       ada.Strings,
       ada.Strings.Fixed,
       ada.Containers,
       ada.text_IO;

   use type swig_p_Doh.item;

   -----------
   --  Globals
   --

   usage_help_Text : constant array (1 .. 3) of access String
     := (new String'("Gnat/Ada Options (available with -gnat)"),
         new String'("       -namespace <nm> - Generate wrappers into Ada namespace <nm>"),
         new String'("       -noproxy        - Generate the low-level functional interface instead of proxy classes"));

   NL : constant String := portable_new_line_Token;


   --  This provides the gnat_Language object to the (c-side) swig 'main' function.
   --
   function swig_gnat return system.Address
   is
      the_gnat_Language : gnat_Language.view;
   begin
      the_gnat_Language := Forge.construct;

      initialize            (the_gnat_Language.all);
      swig_director_connect (the_gnat_Language.all);

      return getCPtr (the_gnat_Language.all);
   end swig_gnat;


   -----------
   --  Utility
   --

   function is_a_function_Pointer (Self : in doh_swigType'Class) return Boolean;

   procedure register_Mirror (Self : access Item'Class;   proxy_Name              : in     unbounded_String;
                                                          the_c_Type              : in     c_Type.view;
                                                          the_swig_Type           : in     doh_swigType'Class;
--                                                            is_core_C_type          : in     Boolean           := False;
                                                          create_array_Type       : in     Boolean           := True;
                                                          add_level_3_Indirection : in     Boolean           := False);

   procedure freshen_current_module_Package (Self : access Item;   for_Node : in doh_Node'Class);


   --------------
   --  Operations
   --

   overriding function  main_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin return True; end main_is_overridden;

   overriding procedure main (Self : in out Item;   argc : in Integer;
                                                    argv : in swig_p_p_char.Item'Class)
   is
      Each : Integer := 0;

   begin
      verbosity_Level := Debug;
--        verbosity_Level := Status;

      indent_Log;
      log (+"",                   Status);
      log (+"Parsing C headers.", Status);

      log (+"");
      log (+"main");
      --  delay 25.0;           -- For debug to allow gdb time to attach.

      SWIG_library_directory (new_String ("gnat"));


      --  Parse the command line
      --
      while Each < argC
      loop
         declare
            the_Command : constant String := Value (String_in (argv, Each));
         begin
            if the_Command = "-namespace"
            then
               if Each + 1 < argC
               then
                  Swig_mark_arg (Each);
                  Swig_mark_arg (Each + 1);

                  Each := Each + 1;            -- Skip the next argument, as it has just been used.
               else
                  Swig_arg_error;
               end if;

            elsif the_Command = "-noproxy"
            then
               Self.proxy_Flag := False;
               Swig_mark_arg (Each);

            elsif the_Command = "-c++"
            then
               Self.in_CPP_mode := True;
               Swig_mark_arg (Each);

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
         Unused : doh_item'Class := Preprocessor_define (-"SWIGGNAT 1", 0);   -- Add a symbol to the parser for conditional compilation.
         pragma Unreferenced (Unused);
      begin
         SWIG_typemap_lang (new_String ("gnat"));                             -- Add typemap definitions.
         SWIG_config_file  (-"gnat.swg");
      end;


      Self.allow_Overloading;
      Self.allow_protected_and_private_Members;

      unindent_Log;
   end main;



   overriding function top_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin return True; end top_is_overridden;

   overriding function top (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      the_Node     :          doh_Node'Class   renames n;
--        options_Node : doh_Node'Class   := get_Attribute (get_Attribute (the_Node, -"module"),    -- get any options set in the module directive
--                                                          -"options");
      module_Name  : constant unbounded_String :=      +get_Attribute (the_Node, -"name");

   begin
      indent_Log;
      log (+"top: processing module: " & module_Name);

      --        -- check options
      --
      --        if exists (options_Node) then
      --           declare
      --              the_Option : doh_Node'Class := get_Attribute (the_Node, -"imclassname");
      --           begin
      --              if exists (the_Option) then
      --                 append (Self.imclass_Name,  to_String (the_Option));      -- tbd: needed ?
      --              end if;
      --           end;
      --        end if;


      --  Initialize all of the output files.
      --
      Self.f_runtime := doh_File (new_File (name => get_Attribute (the_Node, -"outfile"),
                                            mode => new_String ("w")));
      if not exists (Self.f_Runtime)
      then
         log (+"unable to open " & to_String (get_Attribute (the_Node, -"outfile")));
         exit_with_Fail;
      end if;

      Self.f_init     :=       -("");
      Self.f_header   := to_Doh ("");
      Self.f_wrappers := to_Doh ("");
      Self.f_gnat     := to_Doh ("");

      Swig_register_filebyname (-"header",        Self.f_header);              -- Register file targets with the SWIG file handler.
      Swig_register_filebyname (-"wrapper",       Self.f_wrappers);
      Swig_register_filebyname (-"runtime",       Self.f_runtime);
      Swig_register_filebyname (-"init",          Self.f_init);
      Swig_register_filebyname (-"gnat_support",  Self.f_gnat);

      --  Setup the principal namespace and module package names.
      --
      Self.Module_top.define (module_Name, Self.Package_standard);

      --  Print the SWIG banner message.
      --
      Swig_banner (Self.f_runtime);

      --   Convert 'protected' and 'private' member access to public access, within the generated C runtime.
      --   This is to allow access to protected or private copy constructor and is subject to review (tbd).
      --
      print_to (Self.f_header,    "#define protected public");
      print_to (Self.f_header,    "#define private   public");

      --  and destructor, needed by the replacement 'gnat_' constructor.
      print_to (Self.f_wrappers,  "#undef protected");
      print_to (Self.f_wrappers,  "#undef private");

      --  Register names with swig core.
      --
      declare
         wrapper_Name : constant String := "Ada_%f"; -- & to_String (Self.imclass_Name);
      begin
         Swig_name_register (-"wrapper", -wrapper_Name);
         Swig_name_register (-"set",     -"set_%v");
         Swig_name_register (-"get",     -"get_%v");
         Swig_name_register (-"member",  -"%c_%m");
      end;

      print_to (Self.f_wrappers, "#ifdef __cplusplus ");
      print_to (Self.f_wrappers, "extern ""C"" {");
      print_to (Self.f_wrappers, "#endif");

      print_to (Self.f_gnat,     "#ifdef __cplusplus");
      print_to (Self.f_gnat,     "extern ""C"" {");
      print_to (Self.f_gnat,     "#endif");


      --   Do the base Language 'top' to recursively process all nodes.
      --   As each node is processed, the base 'top' will call the relevant
      --   specialised operation in our 'gnat_Language' package.
      --
      do_base_Top (Self.all, the_Node);


      print_to (Self.f_wrappers, "#ifdef __cplusplus");
      print_to (Self.f_wrappers, "}");
      print_to (Self.f_wrappers, "#endif");

      print_to (Self.f_gnat,     "#ifdef __cplusplus");
      print_to (Self.f_gnat,     "}");
      print_to (Self.f_gnat,     "#endif");

      process_all_Modules :
      declare
         procedure process (the_Module : in swig_Module.swig_Module_view)
         is
            new_ada_subPrograms                  : ada_subProgram.vector;
            the_ada_subprogram_Map_of_c_function : swig_Module.ada_subprogram_Maps_of_c_function.Map;
         begin
            transform_unknown_c_Types :
            declare
               use c_type.Vectors;
               Cursor : c_type.Cursor := the_Module.C.new_c_Types.First;

            begin
               while has_Element (Cursor)
               loop
                  declare
                     use c_Type, ada_Type;

                     the_c_Type       : constant c_Type.view        := Element (Cursor);
                     the_doh_swigType : constant doh_Swigtype'Class := to_Doh (to_String (the_c_Type.Name));
                     Pad              :          doh_String'Class   := doh_Copy (the_doh_swigType);
                  begin
                     if the_c_Type.is_Ignored
                     then
                        null;

                     elsif the_c_Type.c_type_Kind = Unknown
                     then
                        if is_a_function_Pointer (the_doh_swigType)
                        then
                           Pad := SwigType_del_pointer (Pad);
                           declare
                              raw_swigType           : constant doh_SwigType'Class := doh_Copy                (Pad);
                              the_Function           : constant doh_SwigType'Class := SwigType_pop_function   (raw_swigType);
                              function_return_Type   : constant doh_SwigType'Class := doh_Copy                (raw_swigType);
                              function_Parameters    : constant doh_ParmList'Class := SwigType_function_parms (the_Function);

                              new_c_Function         :          c_Function.view;
                              new_c_function_Pointer :          c_Type.view;
                           begin
                              new_c_Function            := c_function.new_c_Function   (to_unbounded_String ("anonymous"),
                                                                                        Self.swig_type_Map_of_c_type.Element (+function_return_Type));
                              new_c_Function.Parameters := Self.to_c_Parameters        (function_Parameters);
                              new_c_function_Pointer    := c_type.new_function_Pointer (namespace         => Self.current_c_Namespace,
                                                                                        name              => +the_doh_swigType,
                                                                                        accessed_function => new_c_Function);
                              the_c_Type.all            := new_c_function_Pointer.all;
                           end;

                        else
                           log ("Unable to transform unknown C type: " & the_c_Type.Name);
                           raise Program_Error;
                        end if;
                     end if;
                  end;

                  next (Cursor);
               end loop;
            end transform_unknown_c_Types;

            Transformer.transform (From                           => the_Module.C,
                                   Self                           => Self.all,
                                   name_Map_of_c_type             => Self.name_Map_of_c_type,
                                   name_Map_of_ada_type           => Self.name_Map_of_ada_type,
                                   c_type_Map_of_ada_type         => Self.c_type_Map_of_ada_type,
                                   incomplete_access_to_Type_i_c_pointer_List
                                                                  => Self.incomplete_access_to_Type_i_c_pointer_List,
                                   c_type_Map_of_ada_subprogram   => Self.c_type_Map_of_ada_subprogram,
                                   new_ada_subPrograms            => new_ada_subPrograms,
                                   the_ada_subprogram_Map_of_c_function
                                                                  => the_ada_subprogram_Map_of_c_function,
                                   c_namespace_Map_of_ada_Package => Self.c_namespace_Map_of_ada_Package,

                                   Result                         => the_Module.Ada);
         end process;

      begin
         --  Process imported modules.
         --
         declare
            use swig_Module.module_Vectors;
            Cursor : swig_Module.module_vectors.Cursor := Self.new_Modules.First;
         begin
            while has_Element (Cursor)
            loop
               log ("Tranforming module: '" & Element (Cursor).Name & "'", Status);

               --   Set the 'std' C namespace mapping to this modules top level Ada package.
               --
               Self.c_namespace_Map_of_ada_Package.include (Self.nameSpace_std,
                                                            Element (Cursor).Ada.Package_top);
               process (Element (Cursor));
               next             (Cursor);
            end loop;
         end;

         --  Process the main module.
         --
         log (+"");
         log (+"");
         log (+"");
         log (+"Tranforming the main module.", Status);

         --   Set the 'std' C namespace mapping to our top level module top Ada package.
         --
         Self.c_namespace_Map_of_ada_Package.include (Self.nameSpace_std,
                                                      Self.Module_top.Ada.Package_top);
         process (Self.Module_top'Access);
      end process_all_Modules;


      --  Generate the Ada source files.
      --
      log (+"");
      log (+"Creating source for the main module.", Status);
      gnat_Language.source_Generator.generate (Self);


      --  Generate the C runtime.
      --
      dump                 (Self.f_header,    Self.f_runtime);
      dump                 (Self.f_wrappers,  Self.f_runtime);
      dump                 (Self.f_gnat,      Self.f_runtime);
      Wrapper_pretty_print (Self.f_init,      Self.f_runtime);
      close_File           (Self.f_runtime);

      log (+"");
      log (+"", Status);
      log (+"Ada binding generated.", Status);
      unindent_Log;

      return SWIG_OK;

   exception
      when Aborted =>
         log (+"Aborting !");
         raise;
         return SWIG_ERROR;
   end top;



   ---------------------------------------
   -- Handlers for Specific C Declarations
   --

   overriding function typemapDirective_is_overridden (Self : in Item) return Boolean  is pragma Unreferenced (Self); begin return True; end typemapDirective_is_overridden;

   overriding function typemapDirective (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      the_Node     : doh_Node'Class          renames n;
      --        options_Node : doh_Node'Class   := get_Attribute (get_Attribute (the_Node, -"module"),    -- get any options set in the module directive
      --                                                          -"options");

      the_Method : constant unbounded_String := +get_Attribute (the_Node, -"method");
      the_Code   : constant unbounded_String := +get_Attribute (the_Node, -"code");
--        the_kwargs : constant unbounded_String := +get_Attribute (the_Node, -"kwargs");

   begin
      indent_Log;

      if the_method = "adatype_new"
      then
         declare
            Pattern      : doh_ParmList'Class := first_Child (the_Node);
            pattern_Type : unbounded_String;
            pattern_Name : unbounded_String;
            new_Key      : unbounded_String;

         begin
            while exists (Pattern)
            loop
               pattern_Type := +get_Attribute (get_Attribute (Pattern, -"pattern"), -"type");
               pattern_Name := +get_Attribute (get_Attribute (Pattern, -"pattern"), -"name");

               new_Key := pattern_Type;

               if pattern_Name /= ""
               then                      -- tbd: investigate and document what this is for
                  append (new_Key,  " " & pattern_Name);
               end if;

               Self.c_type_Map_of_ada_type.insert (Self.swig_type_Map_of_c_type.Element (key => pattern_Type),
                                                   Self.name_Map_of_ada_type   .Element (key => the_Code));
               Pattern := next_Sibling (Pattern);
            end loop;
         end;
      end if;

      unindent_Log;
      return do_base_typemapDirective (Self.all, the_Node);
   end typemapDirective;



   overriding
   function moduleDirective_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end moduleDirective_is_overridden;

   overriding
   function moduleDirective (Self : access Item;   n : in     doh_Node'Class) return Integer
   is
      pragma Unreferenced (Self);
      the_Node :          doh_Node'Class    renames n;
      the_Name : constant unbounded_String  :=      +get_Attribute (the_Node, -"name");
   begin
      indent_Log;
      log (+"");
      log (+"moduleDirective: '" & to_String (the_Name) & "'",  Debug);

      unindent_Log;

      return SWIG_OK;
   end moduleDirective;



   overriding
   function includeDirective_is_overridden (Self : in Item) return Boolean   is pragma Unreferenced (Self); begin   return True;   end includeDirective_is_overridden;

   overriding
   function includeDirective (Self : access Item;   n : in  doh_Node'Class) return Integer
   is
   begin
      indent_Log;

      do_base_includeDirective (Self.all, n);
      unindent_Log;

      return SWIG_OK;
   end includeDirective;



   overriding
   function namespaceDeclaration_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end namespaceDeclaration_is_overridden;

   overriding
   function namespaceDeclaration (Self : access Item;   n : in     doh_Node'Class) return Integer
   is
      the_Node :          doh_Node'Class   renames n;
      the_Name : constant unbounded_String :=      +get_Attribute (the_Node, -"name");

   begin
      indent_Log;
      log (+"");
      log (+"namespaceDeclaration: '" & to_String (the_Name) & "'", Debug);

      if the_Name /= ""
      then
         Self.add_Namespace (named => the_Name);
      end if;

      do_base_namespaceDeclaration (Self.all, n);

      unindent_Log;

      return SWIG_OK;
   end namespaceDeclaration;



   overriding
   function classforwardDeclaration_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end classforwardDeclaration_is_overridden;

   overriding
   function classforwardDeclaration (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      the_Node                   :          doh_Node'Class     renames n;

      node_Type                  : constant doh_swigType'Class :=      get_Attribute              (the_Node, -"name");   -- Swig 'forward declaration' nodes do not have a 'type' attribute,
      the_class_Name             : constant String             :=     +get_Attribute              (the_Node, -"name");   -- so we are using 'name' instead.
      is_a_Struct                : constant Boolean            :=      String'(+get_Attribute (the_Node,  -"kind"))  =  "struct";

      new_c_Class                :          c_Type.view;

   begin
      indent_Log;
      log (+"");
      log (+"'ClassforwardDeclaration'   node_Type: '" & String'(+node_Type) & "'");

      Self.current_c_Node := doh_Node (the_Node);

      if Self.swig_type_Map_of_c_type.contains (+node_Type)
      then
         unindent_Log;
         return SWIG_OK; -- class has already been partially or fully declared, so do nothing.

      else
         if is_a_Struct
         then   new_c_Class := c_Type.new_opaque_Struct    (namespace => Self.current_c_nameSpace, name => +the_class_Name);
         else   new_c_Class := c_Type.new_incomplete_Class (namespace => Self.current_c_nameSpace, name => +the_class_Name);
         end if;

         Self.register (new_c_Class, node_Type);
      end if;

      --  old ...
      --
      freshen_current_module_Package (Self, the_Node);

      --  new ...
      --

      Self.prior_c_Declaration := new_c_Class.all'Access;

      unindent_Log;

      return SWIG_OK;
   end classforwardDeclaration;



   overriding
   function nativeDirective_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end nativeDirective_is_overridden;

   overriding
   function nativeDirective (Self : access Item;   n : in     doh_Node'Class) return Integer
   is
      the_Node       :          doh_Node'Class          renames n;
      wrap_Name      : constant doh_String'Class := get_Attribute (the_Node, -"wrap:name");
      Status         :          Integer;
      pragma Unreferenced (Status);

   begin
      indent_Log;
      log (+"");
      log (+"'nativeDirective'");

      if Self.addSymbol (wrap_Name, the_Node) = 0
      then
         return SWIG_ERROR;
      end if;


      if exists (get_Attribute (the_Node, -"type"))
      then
         Swig_save_1   (new_String ("nativeWrapper"),  the_Node,  new_String ("name"));
         set_Attribute (the_Node,                     -"name",    wrap_Name);

         Self.native_function_Flag := True;
         Status                    := functionWrapper (Self, the_Node);     -- Delegate to functionWrapper.
         Swig_restore (the_Node);
         Self.native_function_Flag := False;
      else
         log (+"No return type for node: '" & String'(+wrap_Name));
      end if;

      unindent_Log;

      return SWIG_OK;
   end nativeDirective;



   overriding
   function functionWrapper_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end functionWrapper_is_overridden;

   overriding
   function functionWrapper (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      the_Node : doh_Node'Class   renames n;

   begin
      indent_Log;
      log (+"functionWrapper: '" & to_String ((get_Attribute (the_Node,  -"sym:name"))) & "'");

      Self.current_c_Node := doh_Node (the_Node);

      freshen_current_module_Package (Self, the_Node);

      if check_Attribute (the_Node,  -"access", -"private")
      then     -- Skip private functions (tbd: still needed ?).
         log (+"Skipping private function.");
         unindent_Log;
         return SWIG_OK;
      end if;

      declare
         sym_Name   : constant doh_String'Class   := get_Attribute (the_Node,  -"sym:name");
         swig_Type  : constant doh_swigType'Class := get_Attribute (the_Node,  -"type");

      begin
         if not exists (get_Attribute (the_Node, -"sym:overloaded"))
         then
            if Self.addSymbol (get_Attribute (the_Node, -"sym:name"),  the_Node) = 0
            then
               return SWIG_ERROR;
            end if;
         end if;

         --  The rest of this function deals with generating the intermediary package wrapper function (which wraps
         --  a c/c++ function) and generating the c code. Each Ada wrapper function has a matching c function call.
         --
         declare
            the_function_Wrapper : constant Wrapper.item'Class := newWrapper;
            wrapper_Def          : constant doh_String'Class   := the_function_Wrapper.get_Def;
            wrapper_Code         : constant doh_String'Class   := the_function_Wrapper.get_Code;

            overloaded_Name      :          unbounded_String   := to_unbounded_String  (Self.get_overloaded_Name (the_Node));
            wrapper_Name         : constant String             := +Swig_name_wrapper   (-overloaded_name);

            the_Parameters       : constant doh_parmList'Class := get_Attribute        (the_Node,   -"parms");

            c_return_Type        :          unbounded_String   := +Swig_typemap_lookup (-"ctype",   the_Node,  -"",  null_Wrapper);
            im_return_Type       : constant unbounded_String   := +Swig_typemap_lookup (-"imtype",  the_Node,  -"",  null_Wrapper);

            is_void_return       : constant Boolean            := (c_return_Type = "void");

            the_imclass_Code     :          unbounded_String;     -- tbd: rename better

            Num_arguments        :          Natural            := 0;
            Num_required         :          Natural            := 0;
            pragma Unreferenced (Num_required);

            argout_Code          :          unbounded_String;
            cleanup_Code         :          unbounded_String;

         begin
            Swig_typemap_attach_parms (-"ctype",  the_Parameters, the_function_Wrapper);  -- Attach the non-standard typemaps to the parameter list.
            Swig_typemap_attach_parms (-"imtype", the_Parameters, the_function_Wrapper);  --

            if c_return_Type /= ""
            then
               replace_All (c_return_Type,  "$c_classname", +swig_type);
            else
               log (+"No ctype typemap defined for " & String'(+swig_Type));
            end if;

            if im_return_Type = ""
            then
               log (+"No imtype typemap defined for " & String'(+swig_Type));
            end if;

            if not is_void_return
            then
               Wrapper_add_local_2 (the_function_Wrapper,  -"jresult",
                                                           new_String (to_String (c_return_type)),
                                                           new_String ("jresult"));                     -- Was formerly "jresult = 0".
            end if;

            Print_to (wrapper_Def,  to_String (" DllExport " & c_return_type & " SWIGSTDCALL " & wrapper_Name & " ("));

            Self.current_linkage_Symbol := to_unbounded_String (wrapper_Name);


            emit_parameter_variables (the_Parameters,  the_function_Wrapper);                   -- Emit all local variables for holding arguments.
            emit_return_variable     (the_Node,        swig_Type, the_function_Wrapper);        --
            emit_attach_parmMaps     (the_Parameters,  the_function_Wrapper);                   -- Attach the standard typemaps.


            --  Parameter overloading.
            --
            set_Attribute (the_Node,  -"wrap:parms",  the_Parameters);
            set_Attribute (the_Node,  -"wrap:name",  -wrapper_Name);

            if exists (get_Attribute (the_Node,  -"sym:overloaded"))
            then     -- Wrappers not wanted for some methods where the parameters cannot be overloaded in Ada.
               Swig_overload_check (the_Node);     -- Emit warnings for the few cases that can't be overloaded in Ada and give up on generating wrapper.

               if exists (get_Attribute (the_Node, -"overload:ignore"))
               then
                  unindent_Log;
                  return SWIG_OK;
               end if;
            end if;

            if is_void_return
            then
               append (the_imclass_Code, "  procedure " & overloaded_name);
            else
               append (the_imclass_Code, "  function  " & overloaded_name);
            end if;


            --  Get number of required and total arguments.
            --
            num_arguments := emit_num_arguments (the_Parameters);
            num_required  := emit_num_required  (the_Parameters);

            if num_arguments > 0
            then
               append (the_imclass_Code,  " (");
            end if;

            --  Now walk the function parameter list and generate code to get arguments.
            --
            do_Parameters :
            declare
               the_Parameter : doh_Parm'Class := the_Parameters;
               gen_semicolon : Boolean        := False;
            begin

               for Each in 0 .. Num_arguments - 1
               loop
                  while check_Attribute (the_Parameter,  -"tmap:in:numinputs", -"0")
                  loop   -- tbd: What is this for ?
                     the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");
                  end loop;

                  declare
                     param_swigType : constant doh_swigType'Class :=  get_Attribute (the_Parameter,  -"type");
                     l_Name         : constant doh_String'Class   :=  get_Attribute (the_Parameter,  -"lname");
                     arg            : constant String             :=  "j" & (+l_Name);
                     param_c_Type   :          unbounded_String   := +get_Attribute (the_Parameter, -"tmap:ctype");
                     param_im_Type  : constant String             := +get_Attribute (the_Parameter, -"tmap:imtype");

                  begin
                     if param_c_Type /= ""
                     then
                        replace_All (param_c_Type,  "$c_classname", +param_swigType);
                        replace_All (param_c_Type,  "(", " ");        -- tbd: Hack to remove parentheses from template arguments.
                        replace_All (param_c_Type,  ")", " ");
                     else
                        log (+"No ctype typemap defined for " & String'(+param_swigType));
                     end if;

                     if param_im_Type = ""
                     then
                        log (+"No imtype typemap defined for " & String'(+param_swigType));
                     end if;

                     --  Add parameter to 'intermediary' package sub-program.
                     --
                     if gen_semicolon
                     then
                        append (the_imclass_Code,  ";" & NL);
                     end if;

                     append (the_imclass_Code,  arg & " : " & param_im_Type);

                     if gen_semicolon
                     then
                        Print_to (wrapper_Def,  "," & NL);
                     end if;

                     Print_to (wrapper_Def,  to_String (param_c_Type & " " & arg));     -- Add parameter to C function.
                     gen_semicolon := True;

                     --  Get typemap for this argument.
                     --
                     declare
                        the_typeMap : unbounded_String := +get_Attribute (the_Parameter,  -"tmap:in");
                     begin
                        if the_typeMap /= ""
                        then
                           replace_All (the_typeMap,  "$source",  Arg);          -- deprecated
                           replace_All (the_typeMap,  "$target", +l_Name);       -- deprecated
                           replace_All (the_typeMap,  "$arg",     Arg);          -- deprecated ?
                           replace_All (the_typeMap,  "$input",   Arg);          -- deprecated

                           set_Attribute (the_Parameter,  -"emit:input", -Arg);

                           print_to (wrapper_Code,  the_typeMap & NL);

                           the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");
                        else
                           log (+"Unable to use type " & String'(+param_swigType) & " as a function argument.");
                           the_Parameter := next_Sibling (the_Parameter);
                        end if;
                     end;
                  end;
               end loop;

            end do_Parameters;


            --  Insert cleanup code.
            --
            declare
               the_Parameter : doh_Parm'Class := the_Parameters;
            begin
               while exists (the_Parameter)
               loop
                  declare
                     the_typeMap : unbounded_String := +get_Attribute (the_Parameter,  -"tmap:freearg");
                  begin
                     if the_typeMap /= ""
                     then
                        replace_All (the_typeMap, "$input",  +get_Attribute (the_Parameter, -"emit:input"));
                        append (cleanup_Code,  the_typeMap & NL);

                        the_Parameter := get_Attribute (the_Parameter,  -"tmap:freearg:next");
                     else
                        the_Parameter := next_Sibling (the_Parameter);
                     end if;
                  end;
               end loop;
            end;


            --  Insert argument output code.
            --
            declare
               the_Parameter : doh_Parm'Class := the_Parameters;
            begin
               while exists (the_Parameter)
               loop
                  declare
                     the_typeMap : unbounded_String := +get_Attribute (the_Parameter,  -"tmap:argout");
                  begin
                     if the_typeMap /= ""
                     then
                        replace_All (the_typeMap, "$arg",    +get_Attribute (the_Parameter, -"emit:input"));    -- deprecated ?
                        replace_All (the_typeMap, "$input",  +get_Attribute (the_Parameter, -"emit:input"));
                        replace_All (the_typeMap, "$result", "jresult");

                        append (argout_Code,  the_typeMap & NL);

                        the_Parameter := get_Attribute (the_Parameter,  -"tmap:argout:next");
                     else
                        the_Parameter := next_Sibling (the_Parameter);
                     end if;
                  end;
               end loop;
            end;


            if String'(+node_Type (the_Node)) = "constant"
            then
               Swig_save_1 (to_C ("functionWrapper"),  the_Node,  to_C ("wrap:action"));      -- Wrapping a constant hack; (tbd: this is usual swig hack)

               declare      -- below based on Swig_VargetToFunction()
                  the_Type : constant doh_swigType'Class := Swig_wrapped_var_type (get_Attribute       (the_Node, -"type"),
                                                                                   use_naturalvar_mode (the_Node));
               begin
                  set_Attribute (the_Node,   -"wrap:action",
                                             -String'("result = ("  &  (+SwigType_lstr (the_Type, null_Doh))  &  ") "  &  (+get_Attribute (the_Node, -"value"))  &  ";" & NL));
               end;
            end if;


            --  Determine C type (for contructors)  (tbd: fix/remove this hack).
            --
            declare
               the_Type : constant doh_swigType'Class := doh_copy (get_Attribute (the_Node,  -"type"));
               void     :          doh_Item;
               pragma Unreferenced (void);
            begin
               if SwigType_ispointer (the_Type) /= 0
               then
                  void := doh_Item (SwigType_del_pointer (the_Type));
               end if;

               Self.current_lStr := +doh_copy (SwigType_lstr (the_Type, null_DOH));
            end;


            if not Self.native_function_flag
            then
               --  Now write code to make the function call
               --
               Swig_director_emit_dynamic_cast (n, the_function_Wrapper);   -- tbd: Probably obsolete.

               declare
                  actioncode : constant doh_String'Class := emit_action (n);
                  tm         : constant doh_String       := doh_String (Swig_typemap_lookup_out (-"out", n, -"result", the_function_Wrapper, actioncode));
               begin
                  --  Return value, if necessary.
                  --
                  if Doh_item (tm) /= null_Doh
                  then
                     null;
                  else
                     Swig_warning (WARN_TYPEMAP_OUT_UNDEF,
                                   -Value (get_input_file),
                                   get_line_number,
                                   new_String (  "Unable to use return type" & (+SwigType_str (node_Type (the_Node),  null_Doh))
                                               & " in function "             & (+Get_attribute (n, -"name"))
                                               & ".\n"));
                  end if;
               end;
            end if;


            if String'(+node_Type (the_Node)) = "constant"
            then
               Swig_restore (the_Node);
            end if;

            if not Self.native_function_flag
            then     -- Return 'result' value, if necessary.
               declare
                  the_typeMap : unbounded_String := +Swig_typemap_lookup (-"out", the_Node, -"result", null_Wrapper);
               begin
                  log (+"TYPEMAP");
                  log (the_typeMap);

                  if the_typeMap /= ""
                  then
                     replace_All (the_typeMap, "$result", "jresult");
                     print_to (wrapper_Code,  the_typeMap & NL);

                  elsif not is_void_return
                  then
                     log (+"unable to use return type " & String'(+swig_Type) & " in function " & String'(+get_Attribute (the_Node, -"name")) & NL);
                  end if;
               end;
            end if;


            print_to (wrapper_Code,  argOut_Code);       -- Output argument output code.
            print_to (wrapper_Code,  cleanup_Code);      -- Output cleanup         code.

            if exists (get_Attribute (the_Node, -"feature:new"))
            then   -- Look to see if there is any newfree cleanup code.
               declare
                  the_typeMap : constant unbounded_String := +Swig_typemap_lookup (-"newfree", the_Node, -"result", null_Wrapper);
               begin
                  if the_typeMap /= ""
                  then
                     print_to (wrapper_Code,  the_typeMap & NL);
                  end if;
               end;
            end if;


            if not Self.native_function_flag
            then   -- See if there is any return cleanup code.
               declare
                  the_typeMap : constant unbounded_String :=  +Swig_typemap_lookup (-"ret", the_Node, -"result", null_Wrapper);
               begin
                  if the_typeMap /= ""
                  then
                     --  replace_All (the_typeMap, "$source", "result");   -- deprecated
                     print_to (wrapper_Code,  the_typeMap & NL);
                  end if;
               end;
            end if;


            --  Finish C function and intermediary class function definitions.
            --
            if num_arguments > 0
            then
               append (the_imclass_Code,  ")");
            end if;

            if not is_void_return
            then
               append (the_imclass_Code,  " return " & im_return_Type);
            end if;


            append      (the_imclass_Code,  ";" & NL & NL);
            append      (the_imclass_Code,  "   pragma Import (C, " & overloaded_name & ", ""Ada_");
            replace_All (overloaded_name,   "_SWIG_",  "__SWIG_");
            append      (the_imclass_Code,  overloaded_name & """);" & NL & NL & NL);

            print_to (wrapper_Def,  ")" & NL & "{" & NL);

            if not is_void_return
            then
               print_to (wrapper_Code,  "    return jresult;" & NL);
            end if;


            print_to        (wrapper_Code,  "}" & NL);
            doh_replace_All (wrapper_Code,  -"$cleanup",               -cleanup_Code);                      -- Substitute the cleanup code.
            doh_replace_All (wrapper_Code,  -"SWIG_contract_assert(",  -"SWIG_contract_assert($null, ");    -- Contract macro modification.

            if not is_void_return
            then   doh_replace_All (wrapper_Code,  -"$null",  -"0");
            else   doh_replace_All (wrapper_Code,  -"$null",  -"");
            end if;


            if not Self.native_function_flag
            then
               Wrapper_print (the_function_Wrapper, Self.f_wrappers);      -- Dump the function out.
            end if;

            if    not (     Self.proxy_flag
                       and  Self.is_wrapping_class /= 0)   -- Ignore class member functions.
              and not Self.enum_constant_flag
            then
               declare
                  the_new_Function : c_Function.view; -- := Self.new_c_Function (the_Node,
                                                      --                     +sym_Name,
                                                      --                   current_nameSpace);  -- Self.nameSpace_std);
               begin
                  the_new_Function := Self.new_c_Function (the_Node,
                                                           +sym_Name,
                                                           Self.nameSpace_std);

                  Self.current_Module.C.new_c_Functions   .append (the_new_Function);
                  Self.current_Module.C.new_c_Declarations.append (the_new_Function.all'Access);

                  Self.prior_c_Declaration := the_new_Function.all'Access;
               end;
            end if;

            delWrapper (the_function_Wrapper);
         end;
      end;

      log (+"end functionWrapper");

      unindent_Log;

      return SWIG_OK;
   end functionWrapper;



   overriding
   function globalvariableHandler_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end globalvariableHandler_is_overridden;

   overriding
   function globalvariableHandler (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      use swigg.Utility;

      the_Node           :          doh_Node'Class     renames n;

      the_Name           :          unbounded_String   :=     +get_Attribute      (the_Node,  -"sym:name");
      the_swig_Type      :          doh_swigType'Class :=      doh_Copy           (get_Attribute (the_Node,  -"type"));
      is_Pointer         : constant Boolean            :=      SwigType_ispointer (the_swig_Type) /= 0;

   begin
      indent_Log;
      log (+"");
      log (+"'globalvariableHandler'");

      Self.current_c_Node := doh_Node (the_Node);
      freshen_current_module_Package (Self, the_Node);

      strip_Namespaces       (the_Name);
      strip_all_qualifiers   (the_swig_Type);

      declare
         use c_Variable, c_Variable.array_Bounds_Vectors;

         new_Variable : constant c_Variable.view  := new_c_Variable (name    => the_Name,
                                                                     of_type => null);   -- Self.demand_Type (the_swig_Type));
      begin
         new_Variable.is_Static        := True;
         new_Variable.is_class_Pointer := is_Pointer;                                         -- tbd: simplify these 'is_pointer' variables
         new_Variable.is_Pointer       := SwigType_isreference (the_swig_type) /= 0;

         if swigtype_isArray (the_swig_type) /= 0
         then
            Self.add_array_Bounds_to (new_Variable, the_swig_Type);
         end if;

         declare
            Pad                : constant doh_swigType'Class := doh_Copy (the_Swig_type);
            the_swig_type_Name : constant unbounded_String   := strip_array_Bounds (Pad);
         begin
            log (+"the_swig_type: '" & String'(+the_swig_type) & "'   type name: '" & to_String (the_swig_type_Name) & "'");
            new_Variable.my_Type := Self.swig_type_Map_of_c_type.Element (the_swig_type_Name);
         end;

         Self.Module_top.C.new_c_Variables.append (new_Variable);

         --  tbd: Self.prior_c_Declaration := new_Variable.all'access;

         unindent_Log;

         return SWIG_OK;
      end;
   end globalvariableHandler;



   overriding
   function enumDeclaration_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end enumDeclaration_is_overridden;

   overriding
   function enumDeclaration (Self : access Item;   n : in     doh_Node'Class) return Integer
   is
      use dispatcher.AccessMode;

      the_Node        :          doh_Node    'Class renames  n;
      doh_swig_Type   :          doh_swigType'Class :=       get_Attribute (the_Node,  -"enumtype");

      --  new ...
      --
      new_c_Enum      : c_Type.view;

   begin
      indent_Log;
      log (+"");
      log (+"enumDeclaration - '" & String'(+doh_swig_Type) & "'");

      if    Exists (Self.getCurrentClass)
        and Self.get_cplus_mode /= accessMode.PUBLIC
      then
         return SWIG_NOWRAP;
      end if;

      Self.current_c_Node := doh_Node (the_Node);

      declare
         the_Name          : unbounded_String := +get_Attribute (the_Node,  -"sym:name");   -- nb: Will be null string for an anonymous enum.
         the_doh_swig_Type : doh_swigType     :=  doh_swigType (doh_Copy (doh_swig_Type));

      begin
         log ("the_Name: '" & the_Name & "'");

         if the_Name = ""
         then
            Self.anonymous_c_enum_Count := Self.anonymous_c_enum_Count + 1;
            the_Name                    := "anonymous_enum_" & (+Image (Self.anonymous_c_enum_Count));
            the_doh_swig_Type           := to_Doh (to_String (the_Name));

         elsif          Length (the_Name) >= 8
               and then Slice  (the_Name, 1, 8) = "$unnamed"
         then
            Self.anonymous_c_enum_Count := Self.anonymous_c_enum_Count + 1;
            the_doh_swig_Type           := to_Doh (to_String (the_Name));
            the_Name                    := "anonymous_enum_" & (+Image (Self.anonymous_c_enum_Count));
         end if;

         log ("the_Name: '" & the_Name & "'   the_doh_swig_Type: '" & String' (+the_doh_swig_Type) & "'");

         new_c_Enum := c_type.new_Enum (namespace => Self.current_c_Namespace,
                                        name      => the_Name);
         Self.register (new_c_Enum,
                        the_doh_swig_Type);

         Self.current_c_Enum        := new_c_Enum;
         Self.last_c_enum_rep_value := -1;
      end;


      --  old ...
      --

      Self.enum_rep_clause_required := False;

      freshen_current_module_Package (Self, the_Node);


      if String'(+doh_swig_Type) = "enum "
      then   -- Handle anonymous enums.
         Self.is_anonymous_Enum    := True;
         Self.anonymous_enum_Count := Self.anonymous_enum_Count + 1;

         declare
            new_enum_Name : constant String := "anonymous_enum_" & Image (Self.anonymous_enum_Count);
         begin
            set_Attribute (the_Node,  -"type",      -("enum " & new_enum_Name));
            set_Attribute (the_Node,  -"sym:name",  -new_enum_Name);
            set_Attribute (the_Node,  -"name",      -new_enum_Name);
            set_Attribute (the_Node,  -"enumtype",  -new_enum_Name);

            doh_swig_Type := get_Attribute (the_Node,  -"enumtype");
         end;

      else
         Self.is_anonymous_Enum := False;
      end if;


      do_base_enumDeclaration (Self.all, the_Node);     -- Process each enum element (ie the enum literals).


      --  new ...
      --
      Self.current_c_Enum      := null;
      Self.prior_c_Declaration := new_c_Enum.all'Access;

      unindent_Log;

      return SWIG_OK;
   end enumDeclaration;



   overriding
   function enumvalueDeclaration_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end enumvalueDeclaration_is_overridden;

   overriding
   function enumvalueDeclaration (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      use dispatcher.AccessMode;

      the_Node      :          doh_Node'Class   renames n;
      symname       : constant unbounded_String :=     +get_Attribute (the_Node,  -"sym:name");

      --  old ...
      --
      value_Text    : aliased  unbounded_String := +get_Attribute (the_Node,  -"feature:ada:constvalue");   -- Check for the %adaconstvalue feature.

   begin
      indent_Log;
      log (+"enumvalueDeclaration - '" & String'(+get_Attribute (the_Node, -"name")) & "'");


      --  new ...
      --
      declare
         enum_value_Text : constant unbounded_String := +get_Attribute (the_Node,  -"enumvalue");
      begin
         if enum_value_Text = ""
         then
            Self.last_c_enum_rep_value := Self.last_c_enum_rep_value + 1;

         else
            Self.last_c_enum_rep_value := Value (resolved_c_integer_Expression (Self,  enum_value_Text,
                                                                                       Self.symbol_value_Map,
                                                                                       Self.current_class_namespace_Prefix));
         end if;

         insert (Self.symbol_value_Map,  symName,
                                         to_Integer (Self.last_c_enum_rep_value));

         Self.current_c_Enum.add_Literal (name  => symName,
                                          value => to_Integer (Self.last_c_enum_rep_value));
      end;


      --  old ...
      --
      if    exists (Self.getCurrentClass)
        and Self.get_cplus_mode /= accessMode.PUBLIC
      then
         return SWIG_NOWRAP;
      end if;  -- tbd: redundant (ie check is done in parent node) ?


      if value_Text = "" then
         value_Text := +get_Attribute (the_Node,  -"enumvalue");
      end if;


      if not exists (get_Attribute (parent_Node (the_Node),  -"enumvalues"))
      then
         set_Attribute (parent_Node (the_Node),  -"enumvalues",  -symname);
      end if;


      --  new ...
      --
      unindent_Log;

      return SWIG_OK;
   end enumvalueDeclaration;



   overriding
   function constantWrapper_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end constantWrapper_is_overridden;

   overriding
   function constantWrapper (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      the_Node       :          doh_Node'Class     renames n;

      the_Name       : constant unbounded_String   :=     +get_Attribute (the_Node,  -"sym:name");
      the_swigType   : constant doh_swigType'Class :=      get_Attribute (the_Node,  -"type");

      the_Type       :          c_Type.view;
      new_c_Constant :          c_Variable.view;

   begin
      indent_Log;
      log ("'constantWrapper' -   Name: '" & the_Name & "'    swigType: '" & String'(+the_swigType) & "'");

      Self.current_c_Node := doh_Node (the_Node);
      the_Type            := Self.swig_type_Map_of_c_type.Element (+the_swigType);

      log ("the_Type.Name => '" & the_Type.Name & "'");

      new_c_Constant      := c_variable.new_c_Variable (name    => the_Name,
                                                        of_type => the_Type);
      declare
         value_Text : unbounded_String := +get_Attribute (the_Node,  -"value");
      begin
         log ("VALUE_TEXT '" & value_Text & "'      '" & new_c_Constant.my_Type.qualified_Name & "'");

         if not (        new_c_Constant.my_Type.qualified_Name = "Character"
                 or else new_c_Constant.my_Type.qualified_Name = "char*")
         then   -- is numeric
            declare
               the_Value : gmp.discrete.Integer;
            begin
               the_Value := resolved_c_integer_Expression (Self,
                                                           Value_Text,
                                                           Self.symbol_value_Map,
                                                           Self.current_class_namespace_Prefix);
               if    Slice (value_Text, 1, 2) = "0x"
               then
                  value_Text := +hex_Image (the_Value);

               elsif Slice (value_Text, 1, 1) = "0"
               then
                  value_Text := +oct_Image (the_Value);

               else
                  value_Text := +Image (the_Value);
               end if;

               log ("inserting '" & the_Name & "' into the symbol_value_Map ... value: " & String'(Image (the_Value)));
               insert (Self.symbol_value_Map,  the_Name, the_Value);

            exception
               when others =>
                  declare
                     use swigg.Utility;
                  begin
                     strip_c_integer_literal_qualifiers_in (value_Text);

                     if        the_Type.Name = "float"
                       or else the_Type.Name = "double"
                     then
                        replace_integer_with_float (value_Text);

                     elsif the_Type.Name = "char"
                       and Slice (value_Text, 1, 1) = "\"
                     then
                        value_Text := +"interfaces.c.char'Val (" & Slice (value_Text, 2, Length (value_Text)) & ")";
                     end if;

                     new_c_Constant.Value := value_Text;

                     log ("inserting '" & the_Name & "' into the symbol_value_Map");
                     log (+"   value: '" & String'(Image (the_Value)) & "'");
                     insert (Self.symbol_value_Map,  the_Name, the_Value);
                  end;
            end;
         end if;


         new_c_Constant.Value := value_Text;
         --           Self.name_Map_of_c_type.insert (the_type_Name, new_c_typeDef);
         Self.current_Module.C.new_c_Variables   .append (new_c_Constant);
         Self.current_Module.C.new_c_Declarations.append (new_c_Constant.all'Access);
      end;


      --  old ...
      --
      freshen_current_module_Package (Self, the_Node);

      if Self.addSymbol (-the_Name, the_Node) = 0 then   return SWIG_ERROR;   end if;

      declare
         the_swigType :          doh_swigType'Class := get_Attribute (the_Node,  -"type");
         is_enum_item : constant Boolean            := String'(+node_Type (the_Node)) = "enumitem";

      begin
         if is_enum_item
         then                                                                          -- Adjust the enum type for the Swig_typemap_lookup.
            the_swigType := get_Attribute (parent_Node (the_Node),  -"enumtype");      -- We want the same adatype typemap for all the enum items so we use the enum type (parent node).
            set_Attribute (the_Node,  -"type", the_swigType);
         end if;
      end;

      --  new ...
      --
      Self.prior_c_Declaration := new_c_Constant.all'Access;

      unindent_Log;
      return SWIG_OK;
   end constantWrapper;



   overriding
   function classHandler_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end classHandler_is_overridden;

   overriding
   function classHandler (Self : access Item;   n : in     doh_Node'Class) return Integer
   is
      the_Node       :          doh_Node    'Class renames  n;
      node_Type      : constant doh_swigType'Class :=       get_Attribute (the_Node, -"name");   -- use sym:name ???
      class_Name_Doh : constant doh_swigType'Class :=      get_Attribute (the_Node, -"sym:name");
      class_Name     : constant String             :=      +class_Name_Doh;
      new_c_Class    :          c_Type.view;

   begin
      indent_Log;
      log (+"");
      log (+"classHandler - '" & class_Name & "'    node_Type '" & String' (+node_Type) & "'");

      Self.current_c_Node := doh_Node (the_Node);

      if Self.swig_type_Map_of_c_type.contains (+node_Type)
      then   -- the class has been 'forward' declared
         new_c_Class     := Self.swig_type_Map_of_c_type.Element (+node_Type);                    -- Get the 'opaque' c type.
         new_c_Class.all := c_Type.c_Class_construct (namespace => Self.current_c_Namespace,      -- Morph it to a c class.
                                                      name      => new_c_Class.Name);
      else
         new_c_Class := c_Type.new_c_Class (namespace => Self.current_c_Namespace,
                                            name      => +class_Name);
         Self.register (new_c_Class, node_Type);
      end if;

      if String'(+get_Attribute (the_Node, -"kind")) = "union"
      then
         new_c_Class.is_Union;
      end if;

      Self.c_class_Stack    .append (new_C_Class);
      Self.c_namespace_Stack.append (new_C_Class.nameSpace.all'Access);

      new_c_Class.nameSpace.models_cpp_class_Type (new_c_Class);


      --  old ...
      --

      freshen_current_module_Package (Self, the_Node);

      if Self.proxy_Flag
      then
         if Self.addSymbol (-class_Name, the_Node) = 0
         then
            return SWIG_ERROR;
         end if;

         Self.have_default_constructor_flag := False;
      end if;


      do_base_classHandler (Self.all, the_node);           -- Process all class members.


      if Self.proxy_Flag
      then    -- Handle base classes.
         declare
            base_List     : constant doh_List'Class     := get_Attribute (the_Node, -"allbases"); -- -"bases");
            the_Iterator  : doh_Iterator'Class := doh_First (base_List);

         begin
            while exists (get_Item (the_Iterator))
            loop
               declare
                  base_Name : constant String := +get_Attribute (get_Item (the_Iterator),  -"sym:name");  -- formerly ... getProxyName (c_baseclassname));
               begin
                  Self.current_c_Class.add_Base (Self.name_Map_of_c_type.Element (+base_Name));
                  the_Iterator := doh_Next (the_Iterator);
               end;
            end loop;
         end;
      end if;


      --  new ...
      --
      Self.c_class_Stack    .delete_Last;
      Self.c_namespace_Stack.delete_Last;

      Self.prior_c_Declaration := new_c_Class.all'Access;

      unindent_Log;
      return SWIG_OK;
   end classHandler;



   overriding
   function memberfunctionHandler_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end memberfunctionHandler_is_overridden;

   overriding
   function memberfunctionHandler (Self : access Item;   n : in     doh_Node'Class) return Integer
   is
      the_Node : doh_Node'Class renames n;

   begin
      indent_Log;
      log (+"");
      log (+"memberfunctionHandler");

      Self.current_c_Node := doh_Node (the_Node);
      do_base_memberfunctionHandler (Self.all, the_Node);

      if Self.proxy_Flag
      then
         declare
            the_new_Function : c_Function.view;
         begin
            the_new_Function := Self.new_c_Function (the_Node,
                                                     +get_Attribute (the_Node,  -"sym:name"),
                                                     Self.current_c_Class.nameSpace.all'Access);

            Self.prior_c_Declaration := the_new_Function.all'Access;
         end;
      end if;


      --  new ...
      --
      unindent_Log;
      return SWIG_OK;
   end memberfunctionHandler;



   overriding
   function staticmemberfunctionHandler_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end staticmemberfunctionHandler_is_overridden;

   overriding
   function staticmemberfunctionHandler (Self : access Item;   n : in     doh_Node'Class) return Integer
   is
      the_Node   : doh_Node'Class      renames n;

   begin
      indent_Log;
      log (+"");
      log (+"'staticmemberfunctionHandler'");

      Self.current_c_Node := doh_Node (the_Node);
      Self.static_Flag    := True;
      do_base_staticmemberfunctionHandler (Self.all, the_Node);

      Self.static_flag := False;


      --  new ...
      --
      unindent_Log;
      return SWIG_OK;
   end staticmemberfunctionHandler;



   overriding
   function constructorHandler_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end constructorHandler_is_overridden;

   overriding
   function constructorHandler (Self : access Item;   n : in     doh_Node'Class) return Integer
   is
      the_Node : doh_Node'Class renames n;

   begin
      if not Self.in_cpp_Mode
      then
         return SWIG_OK;
      end if;

      indent_Log;
      log (+"");
      log (+"'constructorHandler'");


      if check_Attribute (the_Node,  -"access",  -"private")
      then
         unindent_Log;
         return SWIG_OK;
      end if;

      Self.current_c_Node := doh_Node (the_Node);

      if not (   check_Attribute (the_node,  -"access",  -"protected")
              or check_Attribute (the_Node,  -"access",  -"private"))
      then
         do_base_constructorHandler (Self.all, the_Node);
      end if;

      if exists (get_Attribute (the_Node,  -"overload:ignore"))
      then     -- Wrappers not wanted for some methods where the parameters cannot be overloaded in Ada.
         unindent_Log;
         return SWIG_OK;
      end if;

      if Self.proxy_Flag
      then
         declare
            overloaded_name     : constant String             := Self.get_overloaded_Name (the_Node);

            constructor_Symbol  :          unbounded_String;    -- we need to build our own 'c' construction call   (tbd: move all this to functionWrapper)
            construct_Call      :          unbounded_String;    -- since the default swig constructor returns a pointer to class
            construct_call_Args :          unbounded_String;    -- instead of an actual solid class object.

            parameter_List      : constant doh_parmList'Class := get_Attribute (the_Node, -"parms");
            the_Parameter       :          doh_Parm'Class     := parameter_list;
            Index               :          Natural            := 0;
            gencomma            :          Boolean            := False;

         begin
            append (constructor_Symbol,  String'("gnat_" & (+Swig_name_construct (-overloaded_name))));
            append (construct_Call,      "extern "  & Self.current_lStr & "    " & constructor_Symbol & "(");

            Swig_typemap_attach_parms (-"ctype",   parameter_List, null_Wrapper);    -- attach the non-standard typemaps to the parameter list
            Swig_typemap_attach_parms (-"in",      parameter_List, null_Wrapper);    --

            emit_mark_varargs (parameter_List);

            while exists (the_Parameter)
            loop
               if check_Attribute (the_Parameter,  -"varargs:ignore",  -"1")
               then   -- Ignored varargs.
                  the_Parameter := next_Sibling (the_Parameter);

               elsif check_Attribute (the_Parameter,  -"tmap:in:numinputs",  -"0")
               then   -- Ignored parameters.
                  the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");

               else
                  declare
                     pt         : constant doh_swigType'Class :=  get_Attribute          (the_Parameter, -"type");   -- tbd: rename
                     the_c_Type :          unbounded_String   := +get_Attribute          (the_Parameter, -"tmap:ctype");
                     arg        : constant String             :=  Self.makeParameterName (the_Node,       the_Parameter, Index);
                  begin
                     if gencomma
                     then
                        append (construct_Call,        ",   ");
                        append (construct_call_Args,   ",   ");
                     end if;

                     if the_c_Type /= ""
                     then
                        replace_All (the_c_Type,  "$c_classname",  +pt);

                        append (construct_Call,       String'(+SwigType_lstr (pt, null_DOH)  &   "   "  &  arg));
                        append (construct_call_Args,  String'(+SwigType_rcaststr (pt, -arg)));
                     else
                        log (+"no ctype typemap defined for "  &  String'(+pt));
                     end if;

                     gencomma      := True;
                     the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");
                     Index         := Index + 1;
                  end;
               end if;
            end loop;

            append (construct_Call,  ")" & NL & "{");
            append (construct_Call,  NL  &  "  return "  &  Self.current_lStr  &  "("  &  construct_call_Args  &  ");"  & NL);
            append (construct_Call,  "}" & NL);


            if not gencomma
            then
               Self.have_default_constructor_flag := True;
            end if;


            --  new
            --
            declare
               the_Constructor : constant c_Function.view := Self.new_c_Function (the_Node,
                                                                                  to_unbounded_String ("construct"),
                                                                                  Self.current_c_Class.Namespace.all'Access,
                                                                                  is_constructor => True);
            begin
               the_Constructor.is_Constructor     := True;
               the_Constructor.is_Static          := True;
               the_Constructor.constructor_Symbol := constructor_Symbol;
            end;

            if not (    check_Attribute (the_Node,  -"access",  -"protected")
                    or  check_Attribute (the_Node,  -"access",  -"private"))
            then
               print_to (Self.f_gnat,  construct_Call & NL);
            end if;
         end;
      end if;


      --  new ...
      --
      unindent_Log;
      return SWIG_OK;
   end constructorHandler;



   overriding
   function destructorHandler_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end destructorHandler_is_overridden;

   overriding
   function destructorHandler (Self : access Item;   n : in     doh_Node'Class) return Integer
   is
      the_Node : doh_Node'Class renames n;

   begin
      if not Self.in_cpp_Mode
      then
         return SWIG_OK;
      end if;

      indent_Log;

      Self.current_c_Node := doh_Node (the_Node);

      if not (   check_Attribute (the_Node,  -"access",  -"protected")
              or check_Attribute (the_Node,  -"access",  -"private"))
      then
         do_base_destructorHandler (Self.all,  the_node);
      end if;

      unindent_Log;
      return SWIG_OK;
   end destructorHandler;



   overriding
   function membervariableHandler_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end membervariableHandler_is_overridden;

   overriding
   function membervariableHandler (Self : access Item;   n : in     doh_Node'Class) return Integer
   is
      use swigg.Utility;

      the_Node           :          doh_Node'Class     renames n;

      swig_Type          :          doh_swigType'Class :=      doh_Copy           (get_Attribute (the_Node,  -"type"));
      swig_Type_is_array : constant Boolean            :=      SwigType_isarray   (swig_Type) /= 0;
      is_Pointer         : constant Boolean            :=      SwigType_ispointer (swig_Type) /= 0;
      variable_Name      : constant unbounded_String   :=     +get_Attribute      (the_Node,  -"sym:name");
   begin
      indent_Log;
      log ("'memberVariableHandler':    Name => " & variable_Name & "     swig_Type: '" & String'(+swig_Type));

      strip_all_qualifiers (swig_Type);
      Self.current_c_Node := doh_Node (the_Node);

      if Self.is_smart_pointer = 0
      then    -- don't add a new member variable during smart pointer resolution.
         declare
            use c_Variable;
            new_Variable :          c_Variable.view;
            bit_Field    : constant String         := +get_Attribute (the_Node,  -"bitfield");
         begin
            if swig_Type_is_array
            then
               declare
                  unconstrained_array_swigType : constant unbounded_String := strip_array_Bounds (doh_Copy (swig_Type));
               begin
                  new_Variable := new_c_Variable (variable_Name,
                                                  Self.swig_type_Map_of_c_type.Element (unconstrained_array_swigType));
               end;
            else
               new_Variable := new_c_Variable (variable_Name,
                                               Self.demand_c_Type_for (swig_Type));
            end if;

            new_Variable.is_Static        := False;
            new_Variable.is_class_Pointer := is_Pointer;

            if bit_Field /= ""
            then
               new_Variable.bit_Field := Integer (Value (resolved_c_integer_Expression (Self,
                                                                        +bit_Field,
                                                                        Self.symbol_value_Map,
                                                                        Self.current_class_namespace_Prefix)));
            end if;


            if swig_Type_is_array
            then
               Self.add_array_Bounds_to (new_Variable, swig_Type);
            end if;

            Self.current_c_Class.add_Component (new_Variable);
         end;
      end if;

      unindent_Log;
      return SWIG_OK;
   end membervariableHandler;



   overriding
   function staticmembervariableHandler_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end staticmembervariableHandler_is_overridden;

   overriding
   function staticmembervariableHandler (Self : access Item;   n : in     doh_Node'Class) return Integer
   is
      the_Node      :          doh_Node    'Class renames n;
      the_swigType  : constant doh_SwigType'Class :=      get_Attribute      (the_Node, -"type");
      variable_Name : constant unbounded_String   :=     +get_Attribute      (the_Node,  -"sym:name");

   begin
      indent_Log;
      log (+"");
      log (+"'staticmemberVariableHandler':    Name => " & variable_Name & "   swig_type: " & to_String (the_swigType));

      Self.current_c_Node := doh_Node (the_Node);

      unindent_Log;
      return SWIG_OK;
   end staticmembervariableHandler;



   overriding
   function memberconstantHandler_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end memberconstantHandler_is_overridden;

   overriding
   function memberconstantHandler (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      the_Node : doh_Node'Class renames n;

   begin
      indent_Log;

      Self.current_c_Node := doh_Node (the_Node);

      Self.wrapping_member_flag := True;
      do_base_memberconstantHandler (Self.all, the_node);
      Self.wrapping_member_flag := False;

      --  new ...
      --
      unindent_Log;
      return SWIG_OK;
   end memberconstantHandler;



   overriding
   function insertDirective_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end insertDirective_is_overridden;

   overriding
   function insertDirective (Self : access Item;   n : in     doh_Node'Class) return Integer
   is
      the_Node :          doh_Node    'Class renames n;
      the_Code : constant doh_swigType'Class :=      get_Attribute (the_Node, -"code");
   begin
      indent_Log;
      doh_replace_all (the_Code,  -"$module",   -Self.Module_core.Name);

      unindent_Log;
      return do_base_insertDirective (Self.all, the_Node);
   end insertDirective;



   overriding
   function usingDeclaration_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end usingDeclaration_is_overridden;

   overriding
   function usingDeclaration (Self : access Item;   n : in     doh_Node'Class)
         return Integer
   is
      pragma Unreferenced (Self, n);
   begin
      return SWIG_OK;     -- Do nothing, since public/protected/private is ignored in Ada,
                          -- so 'using::' clauses are irrelevant (ie the 'used' members are already available).
   end usingDeclaration;



   overriding
   function typedefHandler_is_overridden (Self : in Item) return Boolean is pragma Unreferenced (Self); begin   return True;   end typedefHandler_is_overridden;

   overriding
   function typedefHandler (Self : access Item;   n : in doh_Node'Class) return Integer
   is
      the_Node          :          doh_Node  'Class renames n;
      the_doh_type_Name : constant doh_String'Class :=      get_Attribute (the_Node, -"name");

   begin
      indent_Log;
--        log ("");
      log (+"'typedefHandler'   the_doh_type_Name: '" & String'(+the_doh_type_Name) & "'");

      Self.current_c_Node := doh_Node (the_Node);

      if        (         Self.prior_c_Declaration     /= null
                 and then Self.prior_c_Declaration.Name = String'(+the_doh_type_Name))

        or else Self.swig_type_Map_of_c_type.contains (+the_doh_type_Name)
      then
         log (+"Skipping typedef.");
      else
         declare
            Name             : constant unbounded_String   := +get_Attribute (the_Node, -"name");
            the_type_Name    : constant unbounded_String   := Name;

            the_doh_swigType : constant doh_SwigType'Class :=  get_Attribute (the_Node, -"type");
            the_swig_Type    : constant swig_Type          := +the_doh_swigType;

            Pad              :          doh_swigType'Class := null_Doh;
            pragma Unreferenced (Pad);
         begin
            log ("'typedefHandler' - name: '" & Name & "'     swig_Type: '" & to_String (the_swig_Type) & "'");

            if SwigType_isarray (the_doh_swigType) /= 0
            then
               log (+"typedef array detected");
               declare
                  swig_Type_copy       : constant doh_swigType'Class := doh_Copy (the_doh_swigType);
                  the_Array            : constant doh_SwigType'Class := SwigType_pop_arrays (swig_Type_copy);
                  dimension_Count      : constant Natural            := SwigType_array_ndim (the_Array);
                  element_Type         : constant doh_SwigType'Class := SwigType_array_type (swig_Type_copy);
                  array_dimension_Text :          unbounded_String;
                  new_c_Array          :          c_Type.view;
               begin
                  new_c_Array := c_type.new_array_Type (namespace    => Self.current_c_Namespace,
                                                        name         => the_type_Name,
                                                        element_Type => Self.swig_type_Map_of_c_type.Element (+element_Type));
                  for Each in 1 .. dimension_Count
                  loop
                     array_dimension_Text := +SwigType_array_getdim (the_Array,  Each - 1);

                     c_type.add_array_Dimension (new_c_Array,
                                                 upper_Bound => Integer (Value (resolved_c_integer_Expression (Self,
                                                                                                               array_dimension_Text,
                                                                                                               Self.symbol_value_Map,
                                                                                                               Self.current_class_namespace_Prefix))) - 1);
                  end loop;

                  Self.register              (new_c_Array,  the_doh_type_Name);
                  Self.prior_c_Declaration := new_c_Array.all'Access;
               end;

            elsif is_a_function_Pointer (the_doh_swigType)
            then
               log (+"function pointer found");

               Pad := SwigType_del_pointer (the_doh_swigType);

               declare
                  raw_swigType         : constant doh_SwigType'Class := doh_Copy                (the_doh_swigType);
                  the_Function         : constant doh_SwigType'Class := SwigType_pop_function   (raw_swigType);
                  function_return_Type : constant doh_SwigType'Class := doh_Copy                (raw_swigType);
                  function_Parameters  : constant doh_ParmList'Class := SwigType_function_parms (the_Function);

                  new_c_Function         : c_Function.view;
                  new_c_function_Pointer : c_Type.view;
               begin
                  new_c_Function            := c_function.new_c_Function   (to_unbounded_String ("anonymous"),
                                                                            Self.swig_type_Map_of_c_type.Element (+function_return_Type));
                  new_c_function_Pointer    := c_type.new_function_Pointer (namespace         => Self.current_c_Namespace,
                                                                            name              => the_type_Name,
                                                                            accessed_function => new_c_Function);
                  new_c_Function.Parameters := Self.to_c_Parameters (function_Parameters);

                  Self.register (new_c_function_Pointer, the_doh_type_Name);
                  Self.prior_c_Declaration  := new_c_function_Pointer.all'Access;
               end;

            elsif Swigtype_isfunction (the_doh_swigType) /= 0
            then
               log (+"typedef function detected");

               declare
                  the_Function          : constant doh_SwigType'Class := SwigType_pop_function   (the_doh_swigType);
                  function_return_Type  : constant doh_SwigType'Class := doh_Copy (the_doh_swigType);
                  function_Parameters   : constant doh_ParmList'Class := SwigType_function_parms (the_Function);

                  new_c_Function        : constant c_Function.view    := c_function.new_c_Function (to_unbounded_String ("anonymous"),
                                                                                                    Self.swig_type_Map_of_c_type.Element (+function_return_Type));
                  new_c_Typdef_function :          c_Type.view;
               begin
                  log ("function_return_Type: '" & (+function_return_Type) & "'");

                  new_c_Function.Parameters := Self.to_c_Parameters (function_Parameters);
                  new_c_Typdef_function     := c_type.new_typedef_Function (namespace        => Self.current_c_Namespace,
                                                                            name             => the_type_Name,
                                                                            typed_Function   => new_c_Function);
                  Self.register (new_c_Typdef_function,
                                 the_doh_type_Name,
                                 create_array_type => False);

                  Self.prior_c_Declaration := new_c_Typdef_function.all'Access;
               end;

            else
               if Self.swig_type_Map_of_c_type.contains (the_swig_Type)
               then
                  log ("swig_type_Map_of_c_type.contains " & the_swig_Type);

                  declare
                     the_base_Type : constant c_Type.view := Self.swig_type_Map_of_c_type.Element (the_swig_Type);
                  begin
                     if "_" & the_type_Name = the_swig_Type
                     then
                        register_Mirror (Self,
                                         the_Type_Name,
                                         the_base_Type,
                                         to_Doh (to_String (the_type_Name)));
                        the_base_Type.Name_is (the_type_Name);
                        Self.name_Map_of_c_type.Element (the_base_Type.Name & "[]").Name_is (the_type_Name & "_array");
                     else
                        declare
                           new_c_typeDef : constant c_Type.view := c_Type.new_Typedef (namespace => Self.current_c_Namespace,
                                                                                       Name      => the_type_Name,
                                                                                       base_Type => the_base_Type);
                        begin
                           if Self.c_class_Stack.is_Empty
                           then   Self.register (new_c_typeDef,  the_doh_type_Name);
                           else   Self.register (new_c_typeDef,  to_Doh (to_String (Self.current_c_Class.Name & "::" & to_String (the_doh_type_Name))));
                           end if;

                           Self.prior_c_Declaration := new_c_typeDef.all'Access;
                        end;
                     end if;
                  end;

               else
                  if the_type_Name = the_swig_Type
                  then   -- Handle case:  'typedef struct  foo foo;'
                     declare
                        new_c_Class : c_Type.view;
                     begin
                        new_c_Class := c_Type.new_opaque_Struct (namespace => Self.current_c_nameSpace,
                                                                 name      => the_type_Name);
                        Self.register (new_c_Class, the_doh_type_Name);
                        Self.prior_c_Declaration := new_c_Class.all'Access;
                     end;

                  else   -- Handle case:  'typedef struct foo foo_t;'
                     declare
                        use swigg.Utility;
                        new_c_Class : c_Type.view;
                        class_Name  : doh_swigType'Class := doh_Copy (to_Doh (to_String (Name)));
                     begin
                        log (+class_Name);
                        strip_all_qualifiers (class_Name);
                        log (+class_Name);

                        if Self.swig_type_Map_of_c_type.Contains (+class_Name)
                        then
                           new_c_Class := Self.swig_type_Map_of_c_type.Element (+class_Name);
                        else
                           new_c_Class := c_Type.new_opaque_Struct (namespace => Self.current_c_nameSpace,
                                                                    name      => +class_Name); -- the_swig_Type           );
                           Self.register (new_c_Class, the_doh_swigType);
                        end if;


                        if "_" & the_type_Name = the_swig_Type
                        then
                           register_Mirror (Self,
                                            the_Type_Name,
                                            new_c_Class,
                                            to_Doh (to_String (the_type_Name)));
                           new_c_Class.Name_is (the_type_Name);

                           Self.name_Map_of_c_type.Element (new_c_Class.Name & "[]").Name_is (new_c_Class.Name & "_array");
                        else
                           if the_type_Name /= new_c_Class.Name     -- Ignore such as "typedef struct Animal Animal;".
                           then
                              declare
                                 new_c_typeDef : constant c_Type.view := c_Type.new_Typedef (namespace => Self.current_c_Namespace,
                                                                                             Name      => the_type_Name,
                                                                                             base_Type => new_c_Class);
                              begin
                                 Self.register (new_c_typeDef, the_doh_type_Name);
                                 Self.prior_c_Declaration := new_c_typeDef.all'Access;
                              end;
                           end if;
                        end if;
                     end;
                  end if;

               end if;

            end if;
         end;
      end if;

      unindent_Log;

      return SWIG_OK;
   end typedefHandler;


   -----------
   --  Utility
   -----------

   function is_a_function_Pointer (Self : in doh_swigType'Class) return Boolean
   is
      swig_Type : constant doh_swigType'Class := doh_Copy (Self);
   begin
      return     SwigType_ispointer  (swig_Type)                         /= 0
        and then SwigType_isfunction (SwigType_del_pointer (swig_Type))  /= 0;
   end is_a_function_Pointer;



   procedure log (the_Map : symbol_value_Maps.Map)
   is
      Cursor : symbol_value_Maps.Cursor := First (the_Map);
   begin
      while has_Element (Cursor)
      loop
         next (Cursor);
      end loop;
   end log;
   pragma Unreferenced (log);



   procedure add_new_c_Type (Self : access Item'Class;   the_new_Type : c_Type.view)
   is
      the_current_Module : constant swig_Module.swig_Module_view := Self.current_Module;
   begin
      the_current_Module.C.new_c_Types       .append (the_new_Type);
      the_current_Module.C.new_c_Declarations.append (the_new_Type.all'Access);
   end add_new_c_Type;



   procedure register (Self : access Item;   the_c_Type              : in     c_Type.view;
                                             to_swig_Type            : in     doh_swigType'Class;
                                             is_core_C_type          : in     Boolean           := False;
                                             create_array_Type       : in     Boolean           := True;
                                             add_level_3_Indirection : in     Boolean           := False)
   is
      use swigg.Utility;
      is_a_new_Type              : constant Boolean            :=    (not is_core_C_type);

      the_c_type_Pointer         :          c_Type.view;
      the_c_type_pointer_Pointer :          c_Type.view;

      the_swig_Type              :          doh_swigType'Class := doh_Copy (to_swig_Type);

   begin
      strip_all_qualifiers (the_swig_Type);

      if Self.swig_type_Map_of_c_type.Contains (+the_swig_Type)
      then
         log (+"Attempting to re-register the C type named '" & the_c_Type.Name & "' for swig type '" & to_String (the_swig_Type) & "'    is a new Type: " & Boolean'Image (is_a_new_Type));
         raise Aborted;
      end if;

      log (+"Registering new C type named '" & the_c_Type.Name & "' for swig type '" & to_String (the_swig_Type) & "'    is a new Type: " & Boolean'Image (is_a_new_Type));

      do_c_Type :
      begin
         Self.swig_type_Map_of_c_type.insert (+the_swig_Type,   the_c_Type);

         if Unbounded_String'(+the_swig_Type) /= the_c_Type.Name
         then
            Self.swig_type_Map_of_c_type.insert (the_c_Type.Name,   the_c_Type);
         end if;

         Self.name_Map_of_c_type.insert (the_c_Type.Name,  the_c_Type);

         if is_a_new_Type
         then
            Self.add_new_c_Type (the_c_Type);
         end if;
      end do_c_Type;


      do_level_1_indirection :
      declare
      begin
         if create_array_Type
         then   -- add associated array
            declare
               array_swigType   : constant doh_swigType'Class := to_DOH ("a." & (+the_swig_Type));
               the_c_type_Array :          c_Type.view;
            begin
               the_c_type_Array := c_type.new_array_Type (the_c_Type.nameSpace,
                                                          the_c_Type.Name & "[]",
                                                          element_type => the_c_Type);
               the_c_type_Array.add_array_Dimension;

               Self.swig_type_Map_of_c_type.insert (+array_swigType,        the_c_type_Array);

               if Unbounded_String'(+the_swig_Type) /= the_c_Type.Name
               then
                  Self.swig_type_Map_of_c_type.insert ("a." & the_c_Type.Name,   the_c_Type_Array);
               end if;


               Self.     name_Map_of_c_type.insert (the_c_type_Array.Name,  the_c_type_Array);

               if is_a_new_Type
               then
                  Self.add_new_c_Type (the_c_type_Array);
               end if;
            end;
         end if;


         declare   -- add associated pointer
            pointer_swigType : constant doh_swigType'Class := swigtype_add_Pointer (doh_copy (the_swig_Type));
         begin
            the_c_type_Pointer := c_type.new_type_Pointer (the_c_Type.nameSpace,
                                                           the_c_Type.Name & "*",
                                                           accessed_type => the_c_Type);

            log ("Adding C pointer type for swig type '" &  (+pointer_swigType) & "'    C pointer name is '" & (+the_c_type_Pointer.qualified_Name) & "'");

            Self.swig_type_Map_of_c_type.insert (+pointer_swigType,        the_c_type_Pointer);

            if Unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               Self.swig_type_Map_of_c_type.insert ("p." & the_c_Type.Name,   the_c_Type_Pointer);
            end if;

            Self.name_Map_of_c_type.insert (the_c_type_Pointer.Name,  the_c_type_Pointer);

            declare   -- Register pointer to 'const'.
               the_pointer_to_const_swigType : constant doh_swigType'Class := swigtype_add_Pointer (swigtype_add_Qualifier (doh_copy (the_swig_Type),
                                                                                                                            to_Doh ("const")));
               the_c_pointer_to_const_Name   : constant unbounded_String   := "const " & the_c_Type.Name & "*";
            begin
               Self.swig_type_Map_of_c_type.insert (+the_pointer_to_const_swigType, the_c_type_Pointer);

               if Unbounded_String'(+the_swig_Type) /= the_c_Type.Name
               then
                  Self.swig_type_Map_of_c_type.insert ("p.q(const)." & the_c_Type.Name,   the_c_Type_Pointer);
               end if;

               Self.name_Map_of_c_type.insert (the_c_pointer_to_const_Name,    the_c_type_Pointer);
            end;

            if is_a_new_Type
            then
               Self.add_new_c_Type (the_c_type_Pointer);
            end if;
         end;


         declare   -- Add associated reference.
            reference_swigType   : constant doh_swigType'Class := SwigType_add_reference (doh_copy (the_swig_Type));
         begin
            Self.swig_type_Map_of_c_type.insert (+reference_swigType,      the_c_type_Pointer);

            if Unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               Self.swig_type_Map_of_c_type.insert ("r." & the_c_Type.Name,   the_c_Type_Pointer);
            end if;

            Self.name_Map_of_c_type     .insert (the_c_type.Name & "&",    the_c_type_Pointer);

            declare   -- register reference to 'const'
               the_reference_to_const_swigType : constant doh_swigType'Class := SwigType_add_reference (swigtype_add_Qualifier (doh_copy (the_swig_Type),
                                                                                                                                to_Doh ("const")));
               the_c_reference_to_const_Name   : constant unbounded_String   := "const " & the_c_Type.Name & "&";
            begin
               Self.swig_type_Map_of_c_type.insert (+the_reference_to_const_swigType, the_c_type_Pointer);

               if Unbounded_String'(+the_swig_Type) /= the_c_Type.Name
               then
                  Self.swig_type_Map_of_c_type.insert ("r.q(const)." & the_c_Type.Name & "&",   the_c_type_Pointer);
               end if;

               Self.name_Map_of_c_type.insert (the_c_reference_to_const_Name, the_c_type_Pointer);
            end;
         end;
      end do_level_1_indirection;


      do_level_2_indirection :
      begin
         declare
            array_of_pointers_swigType : constant doh_swigType'Class := to_DOH ("a." & (+swigtype_add_Pointer (doh_copy (the_swig_Type))));
            the_c_type_pointer_Array   :          c_Type.view;
         begin
            the_c_type_pointer_Array := c_type.new_array_Type (the_c_Type.nameSpace,
                                                               the_c_Type.Name & "*[]",
                                                               element_type => the_c_type_Pointer);
            the_c_type_pointer_Array.add_array_Dimension;

            Self.swig_type_Map_of_c_type.insert (+array_of_pointers_swigType,   the_c_type_pointer_Array);

            if Unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               Self.swig_type_Map_of_c_type.insert ("a.p." & the_c_Type.Name,   the_c_type_pointer_Array);
            end if;

            Self.name_Map_of_c_type.insert (the_c_type_pointer_Array.Name, the_c_type_pointer_Array);

            if is_a_new_Type
            then
               Self.add_new_c_Type (the_c_type_pointer_Array);
            end if;
         end;

         the_c_type_pointer_Pointer := c_type.new_type_Pointer (the_c_Type.nameSpace,
                                                                the_c_Type.Name & "**",
                                                                accessed_type => the_c_type_Pointer);

         declare   -- Add pointer pointer.
            pointer_to_pointer_swigType : constant doh_swigType'Class := swigtype_add_Pointer (swigtype_add_Pointer (doh_copy (the_swig_Type)));
         begin
            Self.swig_type_Map_of_c_type.insert (+pointer_to_pointer_swigType,    the_c_type_pointer_Pointer);

            if Unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               Self.swig_type_Map_of_c_type.insert ("p.p." & the_c_Type.Name,   the_c_type_pointer_Pointer);
            end if;

            Self.name_Map_of_c_type.insert (the_c_type_pointer_Pointer.Name, the_c_type_pointer_Pointer);
         end;


         declare   -- Register pointer pointer to 'const'.
            the_pointer_to_pointer_to_const_swigType : constant doh_swigType'Class := swigtype_add_Pointer (swigtype_add_Pointer (swigtype_add_Qualifier (doh_copy (the_swig_Type),
                                                                                                                                                          to_Doh ("const"))));
            the_c_pointer_to_pointer_to_const_Name   : constant unbounded_String   := "const " & the_c_Type.Name & "**";
         begin
            Self.swig_type_Map_of_c_type.insert (+the_pointer_to_pointer_to_const_swigType, the_c_type_pointer_Pointer);

            if Unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               Self.swig_type_Map_of_c_type.insert ("p.p.q(const)." & the_c_Type.Name,   the_c_type_pointer_Pointer);
            end if;

            Self.name_Map_of_c_type.insert (the_c_pointer_to_pointer_to_const_Name,    the_c_type_pointer_Pointer);
         end;

         if is_a_new_Type
         then
            Self.add_new_c_Type (the_c_type_pointer_Pointer);
         end if;
      end do_level_2_indirection;


      if add_level_3_Indirection
      then
         do_level_3_indirection :
         declare
            the_c_type_pointer_pointer_Pointer : constant c_Type.view :=  c_type.new_type_Pointer    (the_c_Type.nameSpace,
                                                                                                      the_c_Type.Name & "***",
                                                                                                      accessed_type => the_c_type_pointer_Pointer);
         begin
            declare
               array_of_pointer_pointers_swigType : constant doh_swigType'Class := to_DOH ("a." & (+swigtype_add_Pointer (swigtype_add_Pointer (doh_copy (the_swig_Type)))));
               the_c_type_pointer_pointer_Array   :          c_Type.view;
            begin
               log (+"array_of_pointer_pointers_swigType: '" & String'(+array_of_pointer_pointers_swigType) & "'");

               the_c_type_pointer_pointer_Array := c_type.new_array_Type (the_c_Type.nameSpace,  the_c_Type.Name & "**[]",
                                                                          element_type => the_c_type_pointer_Pointer);
               the_c_type_pointer_pointer_Array.add_array_Dimension;

               Self.swig_type_Map_of_c_type.insert (+array_of_pointer_pointers_swigType,   the_c_type_pointer_pointer_Array);

               if Unbounded_String'(+the_swig_Type) /= the_c_Type.Name
               then
                  Self.swig_type_Map_of_c_type.insert ("a.p.p" & the_c_Type.Name,   the_c_type_pointer_pointer_Array);
               end if;

               Self.name_Map_of_c_type.insert (the_c_type_pointer_pointer_Array.Name, the_c_type_pointer_pointer_Array);

               if is_a_new_Type
               then
                  Self.add_new_c_Type (the_c_type_pointer_pointer_Array);
               end if;
            end;

            declare   -- Add pointer pointer.
               pointer_to_pointer_pointer_swigType : constant doh_swigType'Class := swigtype_add_Pointer (swigtype_add_Pointer (swigtype_add_Pointer (doh_copy (the_swig_Type))));
            begin
               Self.swig_type_Map_of_c_type.insert (+pointer_to_pointer_pointer_swigType,    the_c_type_pointer_pointer_Pointer);

               if Unbounded_String'(+the_swig_Type) /= the_c_Type.Name
               then
                  Self.swig_type_Map_of_c_type.insert ("p.p.p" & the_c_Type.Name,   the_c_type_pointer_pointer_Pointer);
               end if;

               Self.name_Map_of_c_type.insert (the_c_type_pointer_pointer_Pointer.Name, the_c_type_pointer_pointer_Pointer);
            end;

            if is_a_new_Type
            then
               Self.add_new_c_Type (the_c_type_pointer_pointer_Pointer);
            end if;
         end do_level_3_indirection;
      end if;

   end register;



   procedure register_Mirror (Self : access Item'Class;   proxy_Name              : in     unbounded_String;
                                                          the_c_Type              : in     c_Type.view;
                                                          the_swig_Type           : in     doh_swigType'Class;
                                                          create_array_Type       : in     Boolean           := True;
                                                          add_level_3_Indirection : in     Boolean           := False)
   is
      pragma Unreferenced (add_level_3_Indirection);
   begin
      do_c_Type :
      begin
         Self.swig_type_Map_of_c_type.insert (+the_swig_Type,  the_c_Type);
         Self.     name_Map_of_c_type.insert (proxy_Name,      the_c_Type);
      end do_c_Type;


      do_level_1_indirection :
      declare
      begin
         if create_array_Type
         then      -- Add associated array.
            declare
               array_swigType : constant doh_swigType'Class := to_DOH ("a." & (+the_swig_Type));
               my_array_Type  : constant c_Type.view        := Self.name_Map_of_c_type.Element (the_c_Type.Name & "[]");
            begin
               Self.swig_type_Map_of_c_type.insert (+array_swigType,    my_array_Type);
               Self.     name_Map_of_c_type.insert (proxy_Name & "[]",  my_array_Type);
            end;
         end if;

         declare         -- Add associated pointer.
            pointer_swigType : constant doh_swigType'Class := swigtype_add_Pointer (doh_copy (the_swig_Type));
            my_view_Type     : constant c_Type.view        := Self.name_Map_of_c_type.Element (the_c_Type.Name & "*");
         begin
            Self.swig_type_Map_of_c_type.insert (+pointer_swigType,  my_view_Type);
            Self.     name_Map_of_c_type.insert (proxy_Name & "*",   my_view_Type);

            declare      -- Register pointer to 'const'.
               the_pointer_to_const_swigType : constant doh_swigType'Class := swigtype_add_Pointer (swigtype_add_Qualifier (doh_copy (the_swig_Type),
                                                                                                                            to_Doh ("const")));
            begin
               Self.swig_type_Map_of_c_type.insert (+the_pointer_to_const_swigType,  my_view_Type);
               Self.     name_Map_of_c_type.insert ("const " & proxy_Name & "*",     my_view_Type);
            end;

            declare      -- Add associated reference.
               reference_swigType   : constant doh_swigType'Class := SwigType_add_reference (doh_copy (the_swig_Type));
            begin
               Self.swig_type_Map_of_c_type.insert (+reference_swigType, my_view_Type);
               Self.     name_Map_of_c_type.insert (proxy_Name & "&",    my_view_Type);

               declare   -- Register reference to 'const'.
                  the_reference_to_const_swigType : constant doh_swigType'Class := SwigType_add_reference (swigtype_add_Qualifier (doh_copy (the_swig_Type),
                                                                                                                                   to_Doh ("const")));
               begin
                  Self.swig_type_Map_of_c_type.insert (+the_reference_to_const_swigType,  my_view_Type);
                  Self.name_Map_of_c_type     .insert ("const " & proxy_Name & "&",       my_view_Type);
               end;
            end;
         end;
      end do_level_1_indirection;


      do_level_2_indirection :
      begin
         if create_array_Type
         then      -- Add associated array.
            declare
               array_of_pointers_swigType : constant doh_swigType'Class := to_DOH ("a." & (+swigtype_add_Pointer (doh_copy (the_swig_Type))));
               my_view_array_Type         : constant c_Type.view        := Self.name_Map_of_c_type.Element (the_c_Type.Name & "*[]");
            begin
               Self.swig_type_Map_of_c_type.insert (+array_of_pointers_swigType,
                                                    my_view_array_Type);
            end;
         end if;

         declare   -- Add pointer pointer.
            pointer_to_pointer_swigType : constant doh_swigType'Class := swigtype_add_Pointer (swigtype_add_Pointer (doh_copy (the_swig_Type)));
            my_view_view_Type           : constant c_Type.view        := Self.name_Map_of_c_type.Element (the_c_Type.Name & "**");
         begin
            Self.swig_type_Map_of_c_type.insert (+pointer_to_pointer_swigType,
                                                 my_view_view_Type);
         end;

      end do_level_2_indirection;

   end register_mirror;




   procedure associate (Self : access Item;   the_ada_Type : in ada_Type.view;
                                              with_c_Type  : in c_Type  .view)
   is
   begin
      Self.c_type_Map_of_ada_type.insert (with_c_Type, the_ada_Type);
   end associate;



   function current_Module (Self : access Item) return swig_Module.swig_Module_view
   is
      the_Module : swig_Module.swig_Module_view;

   begin
      if exists (Self.current_c_Node)
      then
         declare
            the_Node         : doh_Node'Class  renames doh_Node'Class (Self.current_c_Node);
            the_Parent       : doh_Node'Class  :=      parent_Node (the_Node);
            parent_node_Type : unbounded_String;

         begin
            while exists (the_Parent)
            loop
               parent_node_Type := +node_Type (the_Parent);

               if parent_node_Type = "import"
               then
                  declare
                     parent_module_Name : constant String := +get_Attribute (the_Parent, -"module");
                  begin
                     the_Module := Self.demand_Module (+parent_module_Name);
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



   function demand_c_Type_for (Self : access Item;   the_doh_swig_Type : in doh_swigType'Class) return c_Type.view
   is
      the_Type : c_Type.view;

   begin
      the_Type := Self.swig_type_Map_of_c_type.Element (+the_doh_swig_Type);
      return the_Type;

   exception
      when Constraint_Error =>   -- no element in map
         if the_Type = null
         then   -- c type has not yet been declared, so create it as an 'unknown' c type.
            the_Type := c_type.new_unknown_Type;        -- 'Unknown' type is a mutable variant record, so it can be morphed.

            the_Type.nameSpace_is (Self.current_c_Namespace);
            the_Type.Name_is      (+the_doh_swig_Type);

            Self.register (the_Type, the_doh_swig_Type);
         end if;

         return the_Type;
   end demand_c_Type_for;



   function demand_Module (Self : access Item;   Named : in unbounded_String) return swig_Module.swig_Module_view
   is
      the_Module : swig_Module.swig_Module_view;
   begin
      log ("demand_Module - named: '" & Named & "'");

      the_Module := Self.name_Map_of_module.Element (Named);
      return the_Module;

   exception
      when Constraint_Error =>   -- no element in map
         declare
            the_Descriptor : constant unbounded_String := Self.to_Descriptor (to_Doh (to_String (Named)));
         begin
            log ("descriptor: '" & the_Descriptor & "'");

            the_Module := new swig_Module.item;
            the_Module.define (Named, Self.Package_standard);

            Self.name_Map_of_module.insert (Named, the_Module);
            Self.new_Modules       .append (the_Module);
         end;

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



   function to_Descriptor (Self : access Item;   swig_Type : in doh_swigType'Class) return unbounded_String
   is
      the_Name       : constant unbounded_String := Self.my_stripped (swig_Type);
      the_Descriptor :          unbounded_String := class_Prefix_in (the_Name);
   begin
      if the_Descriptor = "" then
         the_Descriptor := the_Name;
      end if;

      replace_all (the_Descriptor,   ").",  "_ret_");
      replace_all (the_Descriptor,   "f(",  "f_");
      replace_all (the_Descriptor,   "p.",  "p_");
      replace_all (the_Descriptor,   "r.",  "r_");
      replace_all (the_Descriptor,   ",",  "_");

      replace_all (the_Descriptor,   ".",  "_");

      replace_all (the_Descriptor,   "<",  "_");
      replace_all (the_Descriptor,   ">",  "");
      replace_all (the_Descriptor,   "(",  "");
      replace_all (the_Descriptor,   ")",  "");
      replace_all (the_Descriptor,   " ",  "");

      return the_Descriptor;
   end to_Descriptor;



   function my_stripped (Self : access Item;   swig_Type : in doh_swigType'Class) return unbounded_String
   is
      use swigg.Utility;
      stripped_swig_Type : unbounded_String := +SwigType_strip_qualifiers (swig_Type);
   begin
      strip_enum_Prefix                     (stripped_swig_Type);
      strip_leading_global_namespace_Prefix (stripped_swig_Type); -- tbd: add this below in demand_Type also ?!

      --  Strip namespace Prefix, if any.
      --
      declare
         Cursor : namespace_Sets.Cursor := First (Self.a_Namespaces);
      begin
         while has_Element (Cursor)   -- Loop til there are no more namespaces left.
         loop
            declare
               the_Namespace   : constant String  := to_String (Element (Cursor)) & "::";
               namespace_Index : constant Natural := Index     (stripped_swig_Type,  the_Namespace);
            begin
               if namespace_Index /= 0
               then
                  delete (stripped_swig_Type,  namespace_Index,  namespace_Index + the_Namespace'Length - 1);
                  Cursor := First (Self.a_Namespaces);  -- restart
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
            bounds_Start := Index (stripped_swig_Type,  "a(");
            exit when bounds_Start = 0;                              -- Loop repeatedly til there are no more array bounds left.
            bounds_End   := Index (stripped_swig_Type,  ")", from => bounds_Start);

            delete (stripped_swig_Type,  bounds_Start + 1,  bounds_End);
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
      when Constraint_Error => log ("attempt to add namespace '" & Named & "' twice ... ignoring !"); --
   end add_Namespace;



   function get_overloaded_Name (Self : access Item;   for_Node : in doh_Node'Class) return String
   is
      pragma Unreferenced (Self);
      the_Name : constant String := +get_Attribute (for_Node,  -"sym:name");

   begin
      if exists (get_Attribute (for_Node,  -"sym:overloaded"))
      then
         return  the_Name & (+get_Attribute (for_Node,  -"sym:overname"));       -- Add overload suffix.
      else
         return  the_Name;
      end if;
   end get_overloaded_Name;



   function to_ada_subProgram (Self : access Item;   the_c_Function : in c_Function.view) return ada_subProgram.View
   is
      the_ada_subProgram : ada_subProgram.view;
   begin
      the_ada_subProgram := new_ada_subProgram (ada_Utility.to_ada_Identifier (the_c_Function.Name),
                                                Self.c_type_Map_of_ada_type.Element (the_c_Function.return_Type));
      the_ada_subProgram.link_Symbol    := the_c_Function.link_Symbol;
      the_ada_subProgram.is_Virtual     := the_c_Function.is_Virtual;
      the_ada_subProgram.is_Constructor := the_c_Function.is_Constructor;

      return the_ada_subProgram;
   end to_ada_subProgram;



   function to_ada_Variable (Self : access Item;   the_c_Variable : in c_Variable.view) return ada_Variable.view
   is
      the_ada_variable : ada_Variable.view;
   begin
      the_ada_variable := new_ada_Variable (ada_Utility.to_ada_Identifier       (the_c_Variable.Name),
                                            Self.c_type_Map_of_ada_type.Element (the_c_Variable.my_Type),
                                            the_c_Variable.Value);

      for Each in 1 .. Integer (the_c_Variable.array_Bounds.Length)
      loop
         the_ada_Variable.array_Bounds.append (the_c_Variable.array_Bounds.Element (Each));
      end loop;

      return the_ada_Variable;
   end to_ada_Variable;



   function makeParameterName (Self : access Item;   parameter_List : in doh_parmList'Class;
                                                     the_Parameter  : in doh_Parm    'Class;
                                                     arg_num        : in Integer) return String
   is
      pragma Unreferenced (Self, arg_num);

      the_Name : constant String             := +get_Attribute (the_Parameter,  -"name");
      Count    :          Natural            := 0;
      plist    :          doh_parmList'Class := parameter_List;            -- tbd: better name

   begin
      --  Use C parameter name unless it is a duplicate or an empty parameter name.
      --
      while exists (plist)
      loop
         if the_Name = String'(+get_Attribute (plist, -"name"))
         then
            Count := Count + 1;
         end if;

         plist := next_Sibling (plist);
      end loop;

      if the_Name = ""  or  Count > 1
      then
         return  the_Name  &  "arg_"  &  Trim (Natural'Image (Count), ada.strings.Left);
      else
         return  the_Name;
      end if;
   end makeParameterName;



   procedure freshen_current_module_Package (Self : access Item;   for_Node : in doh_Node'Class)
   is
      pragma Unreferenced (Self);
   begin
      null; -- tbd: Self.current_module_Package := Self.old_fetch_Package (named => current_module_Name);
   end freshen_current_module_Package;



   function to_c_Parameters (Self : access Item;   swig_Parameters : in doh_ParmList'Class) return c_parameter.Vector
   is
      the_C_Parameters : c_parameter.Vector;
   begin
      Swig_typemap_attach_parms (-"in",               swig_Parameters, null_Wrapper);    -- Attach the non-standard typemaps to the parameter list.
      Swig_typemap_attach_parms (-"adatype",          swig_Parameters, null_Wrapper);    --
      Swig_typemap_attach_parms (-"adain",            swig_Parameters, null_Wrapper);    --
      Swig_typemap_attach_parms (-"imtype",           swig_Parameters, null_Wrapper);    --
      Swig_typemap_attach_parms (-"link_symbol_code", swig_Parameters, null_Wrapper);    --

      declare
         the_Parameter :          doh_Parm'Class := swig_Parameters;
         Index         :          Integer        := 0;
      begin
         emit_mark_varargs (swig_Parameters);

         while exists (the_Parameter)
         loop
            if check_Attribute (the_Parameter,  -"varargs:ignore",  -"1")
            then
               the_Parameter := next_Sibling (the_parameter);                            -- Ignored varargs.

            elsif check_Attribute (the_Parameter,  -"tmap:in:numinputs",  -"0")
            then
               the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");         -- Ignored parameters.

            else
               if not (Self.variable_wrapper_flag  and  Index = 0)
               then   -- Ignore the 'this' argument for variable wrappers.
                  declare
                     use c_Parameter.Vectors,
                         swigg.Utility;

                     param_swigType : doh_SwigType'Class  := doh_Copy (get_Attribute (the_parameter,  -"type"));
                  begin
                     strip_all_qualifiers (param_swigType);

                     if not (String'(+param_swigType) = "")     -- Guard against an empty parameter list.
                     then
                        log ("to_c_Parameters ~ param_swigType: '" & (+param_swigType) & "'");

                        strip_all_qualifiers (doh_swigType (param_swigType));

                        if SwigType_isarray (param_swigType) /= 0
                        then   -- transform the c array to its equivalent c pointer
                           param_swigType := SwigType_del_array   (param_swigType);
                           param_swigType := SwigType_add_pointer (param_swigType);
                        end if;

                        declare
                           arg            : constant unbounded_String := to_unbounded_String (Self.makeParameterName (swig_Parameters, the_Parameter, Index));
                           new_Parameter  :          c_Parameter.view;
                        begin
                           begin
                              new_Parameter := new_c_Parameter (arg,  Self.swig_type_Map_of_c_type.Element (+param_swigType));
                           exception
                              when Constraint_Error =>
                                 log (+"Type '" & String'(+param_swigType) & " is unknown for C parameter '" & to_String (arg) & "'.");
                                 raise Aborted;
                           end;

                           new_Parameter.link_symbol_Code := +get_Attribute  (the_Parameter,  -"tmap:link_symbol_code");
                           new_Parameter.is_Pointer       :=         SwigType_isreference (param_swigType) /= 0
                                                             or else SwigType_ispointer   (param_swigType) /= 0;

                           log ("adding new parameter: " & new_Parameter.Name
                                & " type: " & new_parameter.my_type.name
                                & "  is pointer : " & Boolean'Image (new_parameter.is_Pointer));

                           append (the_C_Parameters,  new_Parameter);
                        end;
                     end if;
                  end;
               end if;

               the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");
            end if;

            Index := Index + 1;
         end loop;
      end;

      return the_C_Parameters;
   end to_c_Parameters;



   function to_ada_Parameters (Self : access Item;   the_c_Parameters : in c_parameter.Vector) return ada_Parameter.vector
   is
      use c_parameter.Vectors;

      the_ada_Parameters : ada_Parameter.vector;

      Cursor             : c_Parameter.Cursor := the_C_Parameters.First;
      the_c_Parameter    : c_Parameter.view;

   begin
      while has_Element (Cursor)
      loop
         the_c_Parameter := Element (Cursor);

         declare
            the_ada_Parameter : constant ada_Parameter.view
              := new_ada_Parameter (the_c_Parameter.Name,
                                    Self.c_type_Map_of_ada_type.Element (the_c_Parameter.my_Type));
         begin
            the_ada_Parameters.append (the_ada_Parameter);
         end;

         next (Cursor);
      end loop;

      return the_ada_Parameters;
   end to_ada_Parameters;



   function new_c_Function (Self : access Item;   the_Node       : in     doh_Node'Class;
                                                  function_name  : in     unbounded_String;
                                                  nameSpace      : in     c_nameSpace.view;
                                                  is_Constructor : in     Boolean         := False) return c_function.view
   is
      use c_parameter.Vectors;

      the_swigType          :          doh_swigType'Class   := doh_Copy (get_Attribute (the_Node,  -"type"));
      parameter_list        :          doh_ParmList'Class   := get_Attribute (the_Node,  -"parms");
      the_Parameters        :          c_parameter.Vector;

      the_return_type       :          c_Type.view;

      return_by_Reference   : constant Boolean              := SwigType_isreference (the_swigType) /= 0;
      return_by_Pointer     : constant Boolean              := SwigType_ispointer   (the_swigType) /= 0;

   begin
      Self.current_c_Node := doh_Node (the_Node);

      freshen_current_module_Package (Self, the_Node);

      if String'(+get_Attribute (the_Node, -"overload:ignore")) /= ""
      then
         return null;   -- Wrappers not wanted for some methods where the parameters cannot be overloaded in Ada.
      end if;

      --  The parameters
      --

      if exists (parameter_list)
      then
         if SwigType_type (get_Attribute (parameter_list, -"type")) = T_VOID
         then
            parameter_list := next_Sibling (parameter_list);
         end if;
      end if;

      if         not Self.c_class_Stack.is_Empty
        and then     Self.c_class_Stack.Last_Element.Name /= "std"
        and then not Self.static_flag
        and then not is_Constructor
      then    -- add the class 'Self' controlling parameter.
         declare
            self_Parameter : constant c_Parameter.view := new_c_Parameter (the_name => to_unbounded_String ("Self"),
                                                                           the_type => Self.current_c_Class.all'Access);
         begin
            append (the_Parameters,  self_Parameter);
         end;
      end if;

      append (the_Parameters,  Self.to_c_Parameters (parameter_List));


      --  The return type.
      --
      if is_Constructor
      then
         the_return_Type := Self.current_c_Class.all'Access;

      else
         declare
            use swigg.Utility;
            virtualtype : constant doh_swigType'Class := get_Attribute (the_Node,  -"virtual:type");
         begin
            if exists (virtualType)
            then                             -- note that in the case of polymorphic (covariant) return types, the method's
               the_return_Type := Self.swig_type_Map_of_c_type.Element (+virtualType);
               log (+"covariant return types not supported in Ada ... proxy method will return " & String'(+SwigType_str (virtualtype, null_Doh)));  -- tbd: ??
            else
               strip_all_Qualifiers (the_swigType);
               the_return_Type := Self.swig_type_Map_of_c_type.Element (+the_swigType);
            end if;
         end;
      end if;


      if not (Self.wrapping_member_flag  and  not Self.enum_constant_flag)
      then     -- There is no need for setter/getter functions, since the actual object is available.
         declare
            use c_nameSpace, c_Function;
            new_Function : constant c_Function.view := new_c_Function (function_name,
                                                                       the_return_type);
         begin
            new_Function.Parameters        := the_Parameters;
            new_Function.link_Symbol       := Self.current_linkage_Symbol;
            new_Function.returns_an_Access := return_by_Reference  or  return_by_Pointer;

            if    checkAttribute (the_Node, -"access",  -"public")    /= 0 then    new_Function.access_Mode := public_access;
            elsif checkAttribute (the_Node, -"access",  -"protected") /= 0 then    new_Function.access_Mode := protected_access;
            elsif checkAttribute (the_Node, -"access",  -"private")   /= 0 then    new_Function.access_Mode := private_access;
            else                                                                   new_Function.access_Mode := unknown;
            end if;

            if nameSpace = Self.nameSpace_std
            then
               new_Function.is_Static   := True;
            else
               new_Function.is_Static   := Self.static_flag;
               new_Function.is_Virtual  := checkAttribute (the_Node,  -"storage",  -"virtual") /= 0;
               new_Function.is_Abstract := checkAttribute (the_Node,  -"abstract", -"1")       /= 0;
            end if;

            nameSpace.add (new_Function.all'Access);

            return new_Function;
         end;
      else
         return null;
      end if;

   end new_c_Function;



   procedure add_array_Bounds_to (Self : access Item;   the_Variable   : in c_Variable.view;
                                                        from_swig_Type : in doh_swigType'Class)
   is
      use c_Variable.array_bounds_Vectors;

      swig_Type_copy             : constant doh_swigType'Class := doh_Copy (from_swig_Type);
      the_Array                  : constant doh_SwigType'Class := SwigType_pop_arrays (swig_Type_copy);
      dimension_Count            : constant Natural            := SwigType_array_ndim (the_Array);

      array_dimension_Expression : aliased  unbounded_String;
      resolved_array_Dimension   :          Integer;

   begin
      for Each in 1 .. dimension_Count
      loop
         array_dimension_Expression := +SwigType_array_getdim (the_Array, Each - 1);

         if array_dimension_Expression = ""
         then
            resolved_array_Dimension := 0;
         else
            resolved_array_Dimension := Integer (Value (resolved_c_integer_Expression (Self,  array_dimension_Expression,
                                                                                              Self.symbol_value_Map,
                                                                                              Self.current_class_namespace_Prefix)));
         end if;

         append (the_Variable.array_Bounds,  resolved_array_Dimension - 1);
      end loop;
   end add_array_Bounds_to;


end gnat_Language;
