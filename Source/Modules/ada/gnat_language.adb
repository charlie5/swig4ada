with
     Transformer,

     gnat_Language.c_expression_Resolver,
     gnat_Language.source_Generator,
     gnat_Language.Forge,

     ada_Utility,

     swigg_Module.Binding,
     swigMod.Binding,
     swigMod.Dispatcher,
     swigg_module.Wrapper,

     swigg.Utility,
--       swig_p_Doh,

     DOHs.Binding,
     DOHs.Pointers,
     DOHs.const_String_or_char_ptr,

     ada.Strings.fixed,
     ada.text_IO,

     interfaces.c.Strings;


package body gnat_Language
is
   use gnat_Language.c_expression_Resolver,

       c_Parameter,

       ada_Variable,
       ada_Utility,

       swigg_Module,
       swigg_Module.Binding,
       swigg_Module.Pointers,
       swigMod.Binding,
       swigMod.Dispatcher,

       DOHs,
       DOHs.Pointers,
       DOHs.Binding,

       Interfaces,
       interfaces.c.Strings,

       ada.Strings,
       ada.Strings.Fixed,
       ada.Containers,
       ada.text_IO;

--     use type swig_p_Doh.item;

   -----------
   --  Globals
   --

   usage_help_Text : constant array (1 .. 3) of access String
     := (new String'("Gnat/Ada Options (available with -gnat)"),
         new String'("       -namespace <nm> - Generate wrappers into Ada namespace <nm>"),
         new String'("       -noproxy        - Generate the low-level functional interface instead of proxy classes"));

   NL : constant String := new_line_Token;


   --  This provides the gnat_Language object to the (c-side) swig 'main' function.
   --
   function swig_gnat return system.Address
   is
      the_gnat_Language : gnat_Language.view;
   begin
      the_gnat_Language := Forge.construct;

--        the_gnat_Language.initialize;
--        swig_director_connect (the_gnat_Language.all);

--        return getCPtr (the_gnat_Language.all);
      return the_gnat_Language.all'Address;
   end swig_gnat;


   -----------
   --  Utility
   --

   function is_a_function_Pointer (Self : in doh_swigType) return Boolean;

   procedure register_Mirror (Self : access Item'Class;   proxy_Name              : in     unbounded_String;
                                                          the_c_Type              : in     c_Type.view;
                                                          the_swig_Type           : in     doh_swigType;
--                                                            is_core_C_type          : in     Boolean           := False;
                                                          create_array_Type       : in     Boolean           := True;
                                                          add_level_3_Indirection : in     Boolean           := False);

   procedure freshen_current_module_Package (Self : access Item;   for_Node : in doh_Node);



   --------------
   --  Operations
   --

   overriding
   procedure main (Self : in out Item;
                   argc : in     interfaces.c.int;
                   argv : in     swig.pointers.chars_ptr_Pointer)
   is
      use type C.int;
      Each : C.int := 0;
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
         Unused : Hash_Pointer := Preprocessor_define (const_String_or_char_ptr.item (-"SWIGGNAT 1"),  0);   -- Add a symbol to the parser for conditional compilation.
         pragma Unreferenced (Unused);
      begin
         SWIG_typemap_lang (new_String ("gnat"));                             -- Add typemap definitions.
         SWIG_config_file    (DOHs.const_String_or_char_ptr.item (-"gnat.swg"));
      end;

      Self.allow_Overloading;
      Self.allow_protected_and_private_Members;

      unindent_Log;
   end main;



   overriding
   function top (Self : access Item;
                 n    : in     swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node     :          Node_Pointer renames n;
--        options_Node : doh_Node'Class   := get_Attribute (get_Attribute (the_Node, -"module"),    -- get any options set in the module directive
--                                                          -"options");
      module_Name  : constant unbounded_String := +doh_Item (get_Attribute (the_Node, -"name"));

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
      Self.f_runtime := new_File (name => String_Pointer (get_Attribute (the_Node,
                                                                         -"outfile")),
                                  mode => new_String ("w"));
      if not exists (DOH_Pointer (Self.f_Runtime))
      then
         log (+"unable to open " & to_String (DOH_Pointer (get_Attribute (the_Node,
                                                                          -"outfile"))));
         exit_with_Fail;
      end if;

      Self.f_init     := File_Pointer (-(""));
      Self.f_header   := File_Pointer (-(""));
      Self.f_wrappers := File_Pointer (-(""));
      Self.f_gnat     := File_Pointer (-(""));

      Swig_register_filebyname (const_String_or_char_ptr.item (-"header"),        Self.f_header);              -- Register file targets with the SWIG file handler.
      Swig_register_filebyname (const_String_or_char_ptr.item (-"wrapper"),       Self.f_wrappers);
      Swig_register_filebyname (const_String_or_char_ptr.item (-"runtime"),       Self.f_runtime);
      Swig_register_filebyname (const_String_or_char_ptr.item (-"init"),          Self.f_init);
      Swig_register_filebyname (const_String_or_char_ptr.item (-"gnat_support"),  Self.f_gnat);

      --  Setup the principal namespace and module package names.
      --
      Self.Module_top.define (module_Name, Self.Package_standard);

      --  Print the SWIG banner message.
      --
      Swig_banner (Self.f_runtime);

      --   Convert 'protected' and 'private' member access to public access, within the generated C runtime.
      --   This is to allow access to protected or private copy constructor and is subject to review (tbd).
      --
      print_to (Doh_Pointer (Self.f_header),    "#define protected public");
      print_to (Doh_Pointer (Self.f_header),    "#define private   public");

      --  and destructor, needed by the replacement 'gnat_' constructor.
      print_to (Doh_Pointer (Self.f_wrappers),  "#undef protected");
      print_to (Doh_Pointer (Self.f_wrappers),  "#undef private");

      --  Register names with swig core.
      --
      declare
         wrapper_Name : constant String := "Ada_%f"; -- & to_String (Self.imclass_Name);
      begin
         Swig_name_register (const_String_or_char_ptr.item (-"wrapper"), const_String_or_char_ptr.item (-wrapper_Name));
         Swig_name_register (const_String_or_char_ptr.item (-"set"),     const_String_or_char_ptr.item (-"set_%v"));
         Swig_name_register (const_String_or_char_ptr.item (-"get"),     const_String_or_char_ptr.item (-"get_%v"));
         Swig_name_register (const_String_or_char_ptr.item (-"member"),  const_String_or_char_ptr.item (-"%c_%m"));
      end;

      print_to (Doh_Pointer (Self.f_wrappers), "#ifdef __cplusplus ");
      print_to (Doh_Pointer (Self.f_wrappers), "extern ""C"" {");
      print_to (Doh_Pointer (Self.f_wrappers), "#endif");

      print_to (Doh_Pointer (Self.f_gnat),     "#ifdef __cplusplus");
      print_to (Doh_Pointer (Self.f_gnat),     "extern ""C"" {");
      print_to (Doh_Pointer (Self.f_gnat),     "#endif");


      --   Do the base Language 'top' to recursively process all nodes.
      --   As each node is processed, the base 'top' will call the relevant
      --   specialised operation in our 'gnat_Language' package.
      --
      do_base_Top (swigMod.Language.Pointer (Self), the_Node);
--          do_base_Top (Self.all'Access, the_Node);
--      the_Status := swigMod.Language.item (Self.all).top (the_Node);
--        the_Status := swigMod.Dispatcher.item (Self.all).top (the_Node);


      print_to (Doh_Pointer (Self.f_wrappers), "#ifdef __cplusplus");
      print_to (Doh_Pointer (Self.f_wrappers), "}");
      print_to (Doh_Pointer (Self.f_wrappers), "#endif");

      print_to (Doh_Pointer (Self.f_gnat),     "#ifdef __cplusplus");
      print_to (Doh_Pointer (Self.f_gnat),     "}");
      print_to (Doh_Pointer (Self.f_gnat),     "#endif");

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
                     use c_Type;

                     the_c_Type       : constant c_Type.view      := Element (Cursor);
                     the_doh_swigType : constant doh_Swigtype     := doh_Swigtype (-to_String (the_c_Type.Name));
                     Pad              :          SwigType_Pointer := SwigType_Pointer (doh_Copy (the_doh_swigType));
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
                              raw_swigType           : constant doh_SwigType := doh_Copy (Doh_Pointer (Pad));
                              the_Function           : constant doh_SwigType := doh_SwigType (SwigType_pop_function   (SwigType_Pointer (raw_swigType)));
                              function_return_Type   : constant doh_SwigType := doh_Copy (raw_swigType);
                              function_Parameters    : constant doh_ParmList := doh_ParmList (SwigType_function_parms (SwigType_Pointer (the_Function),
                                                                                                                       null));

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
               log ("Transforming module: '" & Element (Cursor).Name & "'", Status);

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
         log (+"Transforming the main module.", Status);

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
      Wrapper_pretty_print (String_Pointer (Self.f_init), Self.f_runtime);
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

   overriding
   function typemapDirective (Self : access Item;
                              n    : in     swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node     : Node_Pointer          renames n;
      --        options_Node : doh_Node'Class   := get_Attribute (get_Attribute (the_Node, -"module"),    -- get any options set in the module directive
      --                                                          -"options");

      the_Method : constant unbounded_String := +DOH_Pointer (get_Attribute (the_Node,
                                                                             -"method"));
      the_Code   : constant unbounded_String := +DOH_Pointer (get_Attribute (the_Node,
                                                                             -"code"));
--        the_kwargs : constant unbounded_String := +get_Attribute (the_Node, -"kwargs");

   begin
      indent_Log;

      if the_method = "adatype_new"
      then
         declare
            Pattern      : Node_Pointer    := Node_Pointer (doh_ParmList (first_Child (the_Node)));
            pattern_Type : unbounded_String;
            pattern_Name : unbounded_String;
            new_Key      : unbounded_String;

         begin
            while exists (doh_Item (Pattern))
            loop
               pattern_Type := +doh_Item (get_Attribute (get_Attribute (Pattern, -"pattern"), -"type"));
               pattern_Name := +doh_Item (get_Attribute (get_Attribute (Pattern, -"pattern"), -"name"));

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
--        return do_base_typemapDirective (Self.all, the_Node);
      return swigMod.Language.item (Self.all).typemapDirective (the_Node);
   end typemapDirective;



   overriding
   function moduleDirective (Self : access Item;
                             n    : in     swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      pragma Unreferenced (Self);
      the_Node :          Node_Pointer renames n;
      the_Name : constant unbounded_String  := +doh_Item (get_Attribute (the_Node, -"name"));
   begin
      indent_Log;
      log (+"");
      log (+"moduleDirective: '" & to_String (the_Name) & "'",  Debug);

      unindent_Log;

      return SWIG_OK;
   end moduleDirective;



   overriding
   function includeDirective (Self : access Item;
                              n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      Status : C.int with Unreferenced;
   begin
      indent_Log;

--        do_base_includeDirective (Self.all, n);
      Status := swigMod.Language.item (Self.all).includeDirective (n);
      unindent_Log;

      return SWIG_OK;
   end includeDirective;



   overriding
   function namespaceDeclaration (Self : access Item;
                                  n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node :          Node_Pointer renames n;
      the_Name : constant unbounded_String  := +doh_Item (get_Attribute (the_Node, -"name"));
      Status   :          C.int with Unreferenced;
   begin
      indent_Log;
      log (+"");
      log (+"namespaceDeclaration: '" & to_String (the_Name) & "'", Debug);

      if the_Name /= ""
      then
         Self.add_Namespace (named => the_Name);
      end if;

--        do_base_namespaceDeclaration (Self.all, n);
      Status := swigMod.Language.item (Self.all).namespaceDeclaration (the_Node);

      unindent_Log;

      return SWIG_OK;
   end namespaceDeclaration;



   overriding
   function classforwardDeclaration (Self : access Item;
                                     n    : in     swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node       :          Node_Pointer renames n;

      node_Type      : constant doh_swigType := doh_swigType (get_Attribute (the_Node, -"name"));   -- Swig 'forward declaration' nodes do not have a 'type' attribute,
      the_class_Name : constant String       := +doh_Item    (get_Attribute (the_Node, -"name"));   -- so we are using 'name' instead.
      Kind           : constant String       := +doh_Item    (get_Attribute (the_Node,  -"kind"));
      is_a_Struct    : constant Boolean      := Kind = "struct";

      new_c_Class    :          c_Type.view;

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
   function nativeDirective (Self : access Item;
                             n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node       :          Node_Pointer renames n;
      wrap_Name      : constant String_Pointer    := String_Pointer (get_Attribute (the_Node, -"wrap:name"));
      Status         :          C.int;
      pragma Unreferenced (Status);

      use type C.int;
   begin
      indent_Log;
      log (+"");
      log (+"'nativeDirective'");

      if Self.addSymbol (wrap_Name, the_Node) = 0
      then
         return SWIG_ERROR;
      end if;


      if get_Attribute (the_Node, -"type") /= null
      then
         Swig_save_1   (new_String ("nativeWrapper"),  the_Node,  new_String ("name"));
         set_Attribute (the_Node,                     -"name",    wrap_Name);

         Self.native_function_Flag := True;
         Status                    := functionWrapper (Self, the_Node);     -- Delegate to functionWrapper.
         Swig_restore (the_Node);
         Self.native_function_Flag := False;
      else
         log (+"No return type for node: '" & String'(+doh_Item (wrap_Name)));
      end if;

      unindent_Log;

      return SWIG_OK;
   end nativeDirective;



   overriding
   function functionWrapper (Self : access Item;
                             n    : in     swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node : Node_Pointer renames n;
      use type C.int;
   begin
      indent_Log;
      log (+"functionWrapper: '" & String' (+doh_Item (get_Attribute (the_Node,  -"sym:name"))) & "'");

      Self.current_c_Node := doh_Node (the_Node);

      freshen_current_module_Package (Self, the_Node);

      if check_Attribute (the_Node,  -"access", -"private") /= 0
      then     -- Skip private functions (tbd: still needed ?).
         log (+"Skipping private function.");
         unindent_Log;
         return SWIG_OK;
      end if;

      declare
         sym_Name   : constant doh_String   := doh_String   (get_Attribute (the_Node,  -"sym:name"));
         swig_Type  : constant doh_swigType := doh_swigType (get_Attribute (the_Node,  -"type"));
      begin
         if get_Attribute (the_Node, -"sym:overloaded") = null
         then
            if Self.addSymbol (String_Pointer (get_Attribute (the_Node, -"sym:name")),
                               the_Node) = 0
            then
               return SWIG_ERROR;
            end if;
         end if;

         --  The rest of this function deals with generating the intermediary package wrapper function (which wraps
         --  a c/c++ function) and generating the c code. Each Ada wrapper function has a matching c function call.
         --
         declare
            the_function_Wrapper : constant Wrapper.Pointer := newWrapper;
            wrapper_Def          : constant doh_String      := the_function_Wrapper.Def;
            wrapper_Code         : constant doh_String      := the_function_Wrapper.Code;

            overloaded_Name      : constant unbounded_String := to_unbounded_String (Self.get_overloaded_Name (the_Node));
            wrapper_Name         : constant String           := +(doh_Item (Swig_name_wrapper (const_String_or_char_ptr.item (-overloaded_name))));

            the_Parameters       : constant ParmList_Pointer := ParmList_Pointer (get_Attribute (the_Node, -"parms"));

            c_return_Type        :          unbounded_String := +doh_Item (Swig_typemap_lookup (const_String_or_char_ptr.item (-"ctype"),
                                                                                                the_Node,
                                                                                                const_String_or_char_ptr.item (-""),
                                                                                                null));

            is_void_return       : constant Boolean          := (c_return_Type = "void");

            Num_arguments        :          Natural          := 0;
            Num_required         :          Natural          := 0;
            pragma Unreferenced (Num_required);

            argout_Code          :          unbounded_String;
            cleanup_Code         :          unbounded_String;

         begin
            Swig_typemap_attach_parms (const_String_or_char_ptr.item (-"ctype"),  the_Parameters, the_function_Wrapper);  -- Attach the non-standard typemaps to the parameter list.
            Swig_typemap_attach_parms (const_String_or_char_ptr.item (-"imtype"), the_Parameters, the_function_Wrapper);  --

            if c_return_Type /= ""
            then
               replace_All (c_return_Type,  "$c_classname", +swig_type);
            else
               log (+"No ctype typemap defined for " & String'(+swig_Type));
            end if;

            if not is_void_return
            then
               Wrapper_add_local_2 (the_function_Wrapper,  String_or_char_Pointer (-"jresult"),
                                                           new_String (to_String (c_return_type)),
                                                           new_String ("jresult"));                     -- Was formerly "jresult = 0".
            end if;

            Print_to (wrapper_Def,  to_String (" DllExport " & c_return_type & " SWIGSTDCALL " & wrapper_Name & " ("));

            Self.current_linkage_Symbol := to_unbounded_String (wrapper_Name);

            emit_parameter_variables (the_Parameters,
                                      the_function_Wrapper);                   -- Emit all local variables for holding arguments.
            emit_return_variable     (the_Node,
                                      SwigType_Pointer (swig_Type),
                                      the_function_Wrapper);
            emit_attach_parmMaps     (the_Parameters,
                                      the_function_Wrapper);                   -- Attach the standard typemaps.

            --  Parameter overloading.
            --
            set_Attribute (the_Node,  -"wrap:parms",  String_Pointer (the_Parameters));
            set_Attribute (the_Node,  -"wrap:name",  -wrapper_Name);

            if get_Attribute (the_Node,  -"sym:overloaded") /= null
            then     -- Wrappers not wanted for some methods where the parameters cannot be overloaded in Ada.
               Swig_overload_check (the_Node);     -- Emit warnings for the few cases that can't be overloaded in Ada and give up on generating wrapper.

               if get_Attribute (the_Node, -"overload:ignore") /= null
               then
                  unindent_Log;
                  return SWIG_OK;
               end if;
            end if;


            --  Get number of required and total arguments.
            --
            num_arguments := Natural (emit_num_arguments (the_Parameters));
            num_required  := Natural (emit_num_required  (the_Parameters));

            --  Now walk the function parameter list and generate code to get arguments.
            --
            do_Parameters :
            declare
               the_Parameter : Node_Pointer := Node_Pointer (the_Parameters);
               gen_Comma     : Boolean  := False;
            begin

               for Each in 0 .. Num_arguments - 1
               loop
                  while check_Attribute (the_Parameter,
                                         -"tmap:in:numinputs",
                                         -"0") /= 0
                  loop   -- tbd: What is this for ?
                     the_Parameter := get_Attribute (the_Parameter,
                                                     -"tmap:in:next");
                  end loop;

                  declare
                     param_swigType : constant doh_swigType     :=  doh_swigType (get_Attribute (the_Parameter,
                                                                                                 -"type"));
                     l_Name         : constant doh_String       :=  doh_String   (get_Attribute (the_Parameter,
                                                                                                 -"lname"));
                     arg            : constant String           :=  "j" & (+l_Name);
                     param_c_Type   :          unbounded_String := +doh_Item     (get_Attribute (the_Parameter,
                                                                                                 -"tmap:ctype"));
                  begin
                     if param_c_Type /= ""
                     then
                        replace_All (param_c_Type,  "$c_classname", +param_swigType);
                        replace_All (param_c_Type,  "(", " ");        -- tbd: Hack to remove parentheses from template arguments.
                        replace_All (param_c_Type,  ")", " ");
                     else
                        log (+"No ctype typemap defined for " & String'(+param_swigType));
                     end if;

                     if gen_Comma
                     then
                        Print_to (wrapper_Def,  "," & NL);
                     end if;

                     Print_to (wrapper_Def,  to_String (param_c_Type & " " & arg));     -- Add parameter to C function.
                     gen_Comma := True;

                     --  Get typemap for this argument.
                     --
                     declare
                        the_typeMap : unbounded_String := +doh_Item (get_Attribute (the_Parameter,
                                                                                    -"tmap:in"));
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
               the_Parameter : Node_Pointer := Node_Pointer (the_Parameters);
            begin
               while the_Parameter /= null
               loop
                  declare
                     the_typeMap : unbounded_String := +doh_Item (get_Attribute (the_Parameter,  -"tmap:freearg"));
                  begin
                     if the_typeMap /= ""
                     then
                        replace_All (the_typeMap,
                                     "$input",
                                     +doh_Item (get_Attribute (the_Parameter, -"emit:input")));
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
               the_Parameter : Node_Pointer := Node_Pointer (the_Parameters);
            begin
               while the_Parameter /= null
               loop
                  declare
                     the_typeMap : unbounded_String := +doh_Item (get_Attribute (the_Parameter,  -"tmap:argout"));
                  begin
                     if the_typeMap /= ""
                     then
                        replace_All (the_typeMap, "$arg",    +doh_Item (get_Attribute (the_Parameter, -"emit:input")));    -- deprecated ?
                        replace_All (the_typeMap, "$input",  +doh_Item (get_Attribute (the_Parameter, -"emit:input")));
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
                  use swigmod.Language;
                  the_Type : constant SwigType_Pointer := SwigType_Pointer (Swig_wrapped_var_type (SwigType_Pointer (get_Attribute (the_Node, -"type")),
                                                                                                   Self.use_naturalvar_mode (the_Node)));
               begin
                  set_Attribute (the_Node,   -"wrap:action",
                                             -String' (  "result = ("
                                                       & (+doh_Item (SwigType_lstr (the_Type, null)))
                                                       & ") "
                                                       & (+doh_Item (get_Attribute (the_Node, -"value")))
                                                       & ";"
                                                       & NL));
               end;
            end if;


            --  Determine C type (for contructors)  (tbd: fix/remove this hack).
            --
            declare
               the_Type : constant SwigType_Pointer := SwigType_Pointer (doh_copy (DOH_Pointer (get_Attribute (the_Node,
                                                                                                               -"type"))));
               void     :          doh_Item;
               pragma Unreferenced (void);
            begin
               if SwigType_ispointer (the_Type) /= 0
               then
                  void := doh_Item (SwigType_del_pointer (the_Type));
               end if;

               Self.current_lStr := +doh_copy (DOH_Pointer (SwigType_lstr (the_Type, null)));
            end;


            if not Self.native_function_flag
            then
               --  Now write code to make the function call
               --
--               Swig_director_emit_dynamic_cast (n, the_function_Wrapper);   -- tbd: Probably obsolete.

               declare
                  actioncode : constant String_Pointer := emit_action (n);
                  tm         :          doh_String with Unreferenced;
                  Status     :          C.int      with Unreferenced;
               begin
                  tm := doh_String (Swig_typemap_lookup_out (const_String_or_char_ptr.item (-"out"),
                                                             n,
                                                             const_String_or_char_ptr.item (-"result"),
                                                             the_function_Wrapper,
                                                             actioncode));
                  --  Return value, if necessary.
                  --
--                    if Doh_item (tm) /= null_Doh
--                    then
--                       null;
--                    else
--                       Swig_warning (WARN_TYPEMAP_OUT_UNDEF,
--                                     String_or_char_Pointer (-Value (input_file)),
--                                     line_number,
--                                     new_String (  "Unable to use return type" & (+doh_Item (SwigType_str (SwigType_Pointer (node_Type (the_Node)),  null)))
--                                                 & " in function "             & (+doh_Item (Get_attribute (n, -"name")))
--                                                 & ".\n"));
--                    end if;
               end;
            end if;

            if String'(+node_Type (the_Node)) = "constant"
            then
               Swig_restore (the_Node);
            end if;

            if not Self.native_function_flag
            then     -- Return 'result' value, if necessary.
               declare
                  the_typeMap : unbounded_String := +doh_Item (Swig_typemap_lookup (const_String_or_char_ptr.item (-"out"),
                                                                                    the_Node,
                                                                                    const_String_or_char_ptr.item (-"result"),
                                                                                    null));
               begin
                  log (+"TYPEMAP");
                  log (the_typeMap);

                  if the_typeMap /= ""
                  then
                     replace_All (the_typeMap, "$result", "jresult");
                     print_to (wrapper_Code,  the_typeMap & NL);

                  elsif not is_void_return
                  then
                     log (+ "Unable to use return type "
                          & String'(+swig_Type)
                          & " in function "
                          & String'(+doh_Item (get_Attribute (the_Node, -"name")))
                          & NL);
                  end if;
               end;
            end if;

            print_to (wrapper_Code,  argOut_Code);       -- Output argument output code.
            print_to (wrapper_Code,  cleanup_Code);      -- Output cleanup         code.

            if get_Attribute (the_Node, -"feature:new") /= null
            then   -- Look to see if there is any newfree cleanup code.
               declare
                  the_typeMap : constant unbounded_String := +doh_Item (Swig_typemap_lookup (const_String_or_char_ptr.item (-"newfree"),
                                                                                             the_Node,
                                                                                             const_String_or_char_ptr.item (-"result"),
                                                                                             null));
               begin
                  if the_typeMap /= ""
                  then
                     print_to (wrapper_Code,  "CCC" & the_typeMap & NL);
                  end if;
               end;
            end if;


            if not Self.native_function_flag
            then   -- See if there is any return cleanup code.
               declare
                  the_typeMap : constant unbounded_String := +doh_Item (Swig_typemap_lookup (const_String_or_char_ptr.item (-"ret"),
                                                                                             the_Node,
                                                                                             const_String_or_char_ptr.item (-"result"),
                                                                                             null));
               begin
                  if the_typeMap /= ""
                  then
                     --  replace_All (the_typeMap, "$source", "result");   -- deprecated
                     put_Line ("CLEANUPO '" & (+the_typeMap) &  "'");
                  end if;
               end;
            end if;


            --  Finish C function definitions.
            --

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

            if    not (Self.is_wrapping_class /= 0)   -- Ignore class member functions.
              and not Self.enum_constant_flag
            then
               declare
                  the_new_Function : c_Function.view; -- := Self.new_c_Function (the_Node,
                                                      --                     +sym_Name,
                                                      --                   current_nameSpace);  -- Self.nameSpace_std);
               begin
                  the_new_Function := Self.new_c_Function (the_Node,
                                                           +sym_Name,
                                                           Self.nameSpace_std,
                                                           is_Destructor => False);

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
   function globalvariableHandler (Self : access Item;
                                   n    : in     swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      use swigg.Utility;
      use type C.int;

      the_Node           :          Node_Pointer     renames n;

      the_Name           :          unbounded_String := +doh_Item (get_Attribute (the_Node,  -"sym:name"));
      the_swig_Type      :          SwigType_Pointer :=  SwigType_Pointer (doh_Copy (DOH_Pointer (get_Attribute (the_Node,  -"type"))));
      is_Pointer         : constant Boolean          :=  SwigType_ispointer (the_swig_Type) /= 0;

   begin
      indent_Log;
      log (+"");
      log (+"'globalvariableHandler'");

      Self.current_c_Node := doh_Node (the_Node);
      freshen_current_module_Package (Self, the_Node);

      strip_Namespaces    (the_Name);
      strip_all_qualifiers (DOH_Pointer (the_swig_Type));

      declare
         use c_Variable;
         new_Variable : constant c_Variable.view  := new_c_Variable (name    => the_Name,
                                                                     of_type => null);   -- Self.demand_Type (the_swig_Type));
      begin
         new_Variable.is_Static        := True;
         new_Variable.is_class_Pointer := is_Pointer;                                         -- tbd: simplify these 'is_pointer' variables
         new_Variable.is_Pointer       := SwigType_isreference (the_swig_type) /= 0;

         if swigtype_isArray (the_swig_type) /= 0
         then
            Self.add_array_Bounds_to (new_Variable, DOH_Pointer (the_swig_Type));
         end if;

         declare
            Pad                : constant doh_swigType     := doh_Copy (DOH_Pointer (the_Swig_type));
            the_swig_type_Name : constant unbounded_String := strip_array_Bounds (Pad);
         begin
            log (+"the_swig_type: '"
                 & String' (+doh_Item (the_swig_type))
                 & "'   type name: '"
                 & to_String (the_swig_type_Name)
                 & "'");
            new_Variable.my_Type := Self.swig_type_Map_of_c_type.Element (the_swig_type_Name);
         end;

         Self.Module_top.C.new_c_Variables.append (new_Variable);

         --  tbd: Self.prior_c_Declaration := new_Variable.all'access;

         unindent_Log;

         return SWIG_OK;
      end;
   end globalvariableHandler;



   overriding
   function enumDeclaration (Self : access Item;
                             n    : in     swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
--        use dispatcher.AccessMode;

      the_Node      : Node_Pointer renames  n;
      doh_swig_Type : SwigType_Pointer :=   SwigType_Pointer (get_Attribute (the_Node,  -"enumtype"));

      --  new ...
      --
      new_c_Enum    : c_Type.view;
      Status        : C.int with Unreferenced;

   begin
      indent_Log;
      log (+"");
      log (+"enumDeclaration - '" & String' (+DOH_Pointer (doh_swig_Type)) & "'");

      if    Self.getCurrentClass /= null
        and Self.cplus_mode      /= swigMod.Dispatcher.PUBLIC
      then
         return SWIG_NOWRAP;
      end if;

      Self.current_c_Node := doh_Node (the_Node);

      declare
         the_Name          : unbounded_String := +DOH_Pointer (get_Attribute (the_Node,  -"sym:name"));   -- nb: Will be null string for an anonymous enum.
         the_doh_swig_Type : SwigType_Pointer := SwigType_Pointer (doh_Copy (DOH_Pointer (doh_swig_Type)));

      begin
         log ("the_Name: '" & the_Name & "'");

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

         log (  "the_Name: '"
              & the_Name
              & "'   the_doh_swig_Type: '"
              & String' (+DOH_Pointer (the_doh_swig_Type))
              & "'");

         new_c_Enum := c_type.new_Enum (namespace => Self.current_c_Namespace,
                                        name      => the_Name);
         Self.register (new_c_Enum,
                        doh_SwigType (the_doh_swig_Type));

         Self.current_c_Enum        := new_c_Enum;
         Self.last_c_enum_rep_value := -1;
      end;


      --  old ...
      --

      Self.enum_rep_clause_required := False;

      freshen_current_module_Package (Self, doh_Node (the_Node));


      if String' (+DOH_Pointer (doh_swig_Type)) = "enum "
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

            doh_swig_Type := SwigType_Pointer (get_Attribute (the_Node,  -"enumtype"));
         end;

      else
         Self.is_anonymous_Enum := False;
      end if;


--        do_base_enumDeclaration (Self.all, the_Node);     -- Process each enum element (ie the enum literals).
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
                                  n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
--        use dispatcher.AccessMode;

      the_Node      :          Node_Pointer renames n;
      symname       : constant unbounded_String  := +DOH_Pointer (get_Attribute (the_Node,  -"sym:name"));

      --  old ...
      --
      value_Text    : aliased  unbounded_String  := +DOH_Pointer (get_Attribute (the_Node,  -"feature:ada:constvalue"));   -- Check for the %adaconstvalue feature.

   begin
      indent_Log;
      log (+"enumvalueDeclaration - '"
           & String' (+DOH_Pointer (get_Attribute (the_Node, -"name")))
           & "'");


      --  new ...
      --
      declare
         enum_value_Text : constant unbounded_String := +(DOH_Pointer (get_Attribute (the_Node,  -"enumvalue")));
      begin
         if enum_value_Text = ""
         then
            Self.last_c_enum_rep_value := Self.last_c_enum_rep_value + 1;

         else
            Self.last_c_enum_rep_value := Value (resolved_c_integer_Expression (Self,  enum_value_Text,
                                                                                       Self.integer_symbol_value_Map,
                                                                                       Self.current_class_namespace_Prefix));
         end if;

         insert (Self.integer_symbol_value_Map,  symName,
                                         to_Integer (Self.last_c_enum_rep_value));

         Self.current_c_Enum.add_Literal (name  => symName,
                                          value => to_Integer (Self.last_c_enum_rep_value));
      end;


      --  old ...
      --
      if    Self.getCurrentClass /= null
        and Self.cplus_mode      /= swigMod.Dispatcher.PUBLIC
      then
         return SWIG_NOWRAP;
      end if;  -- tbd: redundant (ie check is done in parent node) ?


      if value_Text = "" then
         value_Text := +DOH_Pointer (get_Attribute (the_Node,  -"enumvalue"));
      end if;


      if get_Attribute (parent_Node (the_Node),  -"enumvalues") = null
      then
         set_Attribute (parent_Node (the_Node),  -"enumvalues",  -symname);
      end if;


      --  new ...
      --
      unindent_Log;

      return SWIG_OK;
   end enumvalueDeclaration;



   overriding
   function constantWrapper (Self : access Item;
                             n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node       :          Node_Pointer  renames n;

      the_Name       : constant unbounded_String := +DOH_Pointer     (get_Attribute (the_Node,  -"sym:name"));
      the_swigType   : constant SwigType_Pointer := SwigType_Pointer (get_Attribute (the_Node,  -"type"));

      the_Type       :          c_Type.view;
      new_c_Constant :          c_Variable.view;

   begin
      indent_Log;
      log ("'constantWrapper' -   Name: '"
           & the_Name
           & "'    swigType: '"
           & String'(+DOH_Pointer (the_swigType))
           & "'");

      Self.current_c_Node := doh_Node (the_Node);
      the_Type            := Self.swig_type_Map_of_c_type.Element (+DOH_Pointer (the_swigType));

      log ("the_Type.Name => '" & the_Type.Name & "'");

      new_c_Constant      := c_variable.new_c_Variable (name    => the_Name,
                                                        of_type => the_Type);
      declare
         value_Text : unbounded_String := +DOH_Pointer (get_Attribute (the_Node,  -"value"));
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
                                                           Self.integer_symbol_value_Map,
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
               insert (Self.integer_symbol_value_Map,  the_Name, the_Value);

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
         the_swigType :          SwigType_Pointer := SwigType_Pointer (get_Attribute (the_Node,  -"type"));
         is_enum_item : constant Boolean          := String' (+node_Type (the_Node)) = "enumitem";

      begin
         if is_enum_item
         then -- Adjust the enum type for the Swig_typemap_lookup.
            the_swigType := SwigType_Pointer (get_Attribute (parent_Node (the_Node),
                                                             -"enumtype"));           -- We want the same adatype typemap for all the enum items so we use the enum type (parent node).
            set_Attribute (the_Node, -"type", String_Pointer (the_swigType));
         end if;
      end;

      --  new ...
      --
      Self.prior_c_Declaration := new_c_Constant.all'Access;

      unindent_Log;
      return SWIG_OK;
   end constantWrapper;



   overriding
   function classHandler (Self : access Item;
                          n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node       :          Node_Pointer     renames  n;
      node_Type      : constant SwigType_Pointer := SwigType_Pointer (get_Attribute (the_Node, -"name"));   -- use sym:name ???
      class_Name_Doh : constant SwigType_Pointer := SwigType_Pointer (get_Attribute (the_Node, -"sym:name"));
      class_Name     : constant String           := +DOH_Pointer (class_Name_Doh);
      new_c_Class    :          c_Type.view;
      Status         :          C.int with Unreferenced;
      use type C.int;
   begin
      indent_Log;
      log (+"");
      log (+ "classHandler - '"
           & class_Name
           & "'    node_Type '"
           & String' (+DOH_Pointer (node_Type))
           & "'");

      Self.current_c_Node := doh_Node (the_Node);

      if Self.swig_type_Map_of_c_type.contains (+DOH_Pointer (node_Type))
      then   -- the class has been 'forward' declared
         new_c_Class     := Self.swig_type_Map_of_c_type.Element (+DOH_Pointer (node_Type));      -- Get the 'opaque' c type.
         new_c_Class.all := c_Type.c_Class_construct (namespace => Self.current_c_Namespace,      -- Morph it to a c class.
                                                      name      => new_c_Class.Name);
      else
         new_c_Class := c_Type.new_c_Class (namespace => Self.current_c_Namespace,
                                            name      => +class_Name);
         Self.register (new_c_Class,
                        doh_SwigType (node_Type));
      end if;

      if String' (+DOH_Pointer (get_Attribute (the_Node, -"kind"))) = "union"
      then
         new_c_Class.is_Union;
      end if;

      Self.c_class_Stack    .append (new_C_Class);
      Self.c_namespace_Stack.append (new_C_Class.nameSpace.all'Access);

      new_c_Class.nameSpace.models_cpp_class_Type (new_c_Class);


      --  old ...
      --

      freshen_current_module_Package (Self, the_Node);

      if Self.addSymbol (-class_Name, the_Node) = 0
      then
         return SWIG_ERROR;
      end if;

      Self.have_default_constructor_flag := False;

--        do_base_classHandler (Self.all, the_node);           -- Process all class members.
      Status := swigMod.Language.item (Self.all).classHandler (the_node);           -- Process all class members.


      -- Handle base classes.
      --
      declare
         base_List    : constant doh_List   := doh_List  (get_Attribute (the_Node, -"allbases")); -- -"bases");
         the_Item     :          DOH_Pointer;
         Length       : constant C.int      := DohLen (base_List);
      begin
--           put_Line ("BASE_LIST: '" & (+base_List) & "'      Len: " & C.int'Image (Length));

         for i in 1 .. Length
         loop
            the_Item := DohGetitem (base_List, i-1);
            declare
               base_Name : constant String := +DOH_Pointer (get_Attribute (Node_Pointer (the_Item),
                                                                          -"sym:name"));  -- formerly ... getProxyName (c_baseclassname));
            begin
--                 put_Line ("Base name: '" & base_Name & "'");
               Self.current_c_Class.add_Base (Self.name_Map_of_c_type.Element (+base_Name));
            end;
         end loop;
      end;

      --  new ...
      --
      Self.c_class_Stack    .delete_Last;
      Self.c_namespace_Stack.delete_Last;

      Self.prior_c_Declaration := new_c_Class.all'Access;

      unindent_Log;
      return SWIG_OK;
   end classHandler;



   overriding
   function memberfunctionHandler (Self : access Item;
                                   n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node        :          Node_Pointer renames n;
      Status          :          C.int with Unreferenced;
      function_Name   : constant String  := +DohGetattr (DOH_Pointer (the_Node), DOH_Pointer (-"name"));
      Storage         : constant String  := +DohGetattr (DOH_Pointer (the_Node), DOH_Pointer (-"storage"));
      Value           : constant String  := +DohGetattr (DOH_Pointer (the_Node), DOH_Pointer (-"value"));
      is_Virtual      : constant Boolean := Storage = "virtual";
      is_Pure         : constant Boolean := Value   = "0";
      is_pure_Virtual : constant Boolean := is_Pure and is_Virtual;

      function get_Namespace return String
      is
      begin
         if is_pure_Virtual
         then
            return "";
         else
            return to_String (Self.current_c_Class.Name) & "::";
         end if;
      end get_Namespace;

      Namespace : constant String := get_Namespace;
   begin
      indent_Log;
      log (+"");
      log (+"memberfunctionHandler");

      Self.current_c_Node := doh_Node (the_Node);

      Status := DohSetattr (obj   => DOH_Pointer (the_Node),
                            name  => DOH_Pointer (-"name"),
                            value => DOH_Pointer (-(Namespace & function_Name)));
--                              value => DOH_Pointer (-(to_String (Self.current_c_Class.Name) & "::" & function_Name)));

--        do_base_memberfunctionHandler (Self.all, the_Node);
      Status := swigMod.Language.item (Self.all).memberfunctionHandler (the_Node);

      declare
         the_new_Function : c_Function.view;
      begin
         the_new_Function := Self.new_c_Function (doh_Node (the_Node),
                                                  +(DOH_Pointer (get_Attribute (the_Node,  -"sym:name"))),
                                                  Self.current_c_Class.nameSpace.all'Access,
                                                  is_Destructor => False);

         Self.prior_c_Declaration := the_new_Function.all'Access;
      end;


      --  new ...
      --
      unindent_Log;
      return SWIG_OK;
   end memberfunctionHandler;



   overriding
   function staticmemberfunctionHandler (Self : access Item;
                                         n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node : Node_Pointer renames n;
      Status   : C.int with Unreferenced;
   begin
      indent_Log;
      log (+"");
      log (+"'staticmemberfunctionHandler'");

      Self.current_c_Node := doh_Node (the_Node);
      Self.static_Flag    := True;

--        do_base_staticmemberfunctionHandler (Self.all, the_Node);
      Status := swigMod.Language.item (Self.all).staticmemberfunctionHandler (the_Node);

      Self.static_flag := False;


      --  new ...
      --
      unindent_Log;
      return SWIG_OK;
   end staticmemberfunctionHandler;



   overriding
   function constructorHandler (Self : access Item;
                                n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node : Node_Pointer renames n;
      Status   : C.int with Unreferenced;
      use type C.int;
   begin
      if not Self.in_cpp_Mode
      then
         return SWIG_OK;
      end if;

      indent_Log;
      log (+"");
      log (+"'constructorHandler'");


      if check_Attribute (the_Node,  -"access",  -"private") /= 0
      then
         unindent_Log;
         return SWIG_OK;
      end if;

      Self.current_c_Node := doh_Node (the_Node);

      if not (   check_Attribute (the_node,  -"access",  -"protected") /= 0
              or check_Attribute (the_Node,  -"access",  -"private")   /= 0)
      then
--           do_base_constructorHandler (Self.all, the_Node);
         Status := swigMod.Language.item (Self.all).constructorHandler (the_Node);
      end if;

      if get_Attribute (the_Node,  -"overload:ignore") /= null
      then     -- Wrappers not wanted for some methods where the parameters cannot be overloaded in Ada.
         unindent_Log;
         return SWIG_OK;
      end if;

      declare
         overloaded_name     : constant String := Self.get_overloaded_Name (doh_Node (the_Node));

         constructor_Symbol  :          unbounded_String;    -- we need to build our own 'c' construction call   (tbd: move all this to functionWrapper)
         construct_Call      :          unbounded_String;    -- since the default swig constructor returns a pointer to class
         construct_call_Args :          unbounded_String;    -- instead of an actual solid class object.

         parameter_List      : constant ParmList_Pointer := ParmList_Pointer (get_Attribute (the_Node, -"parms"));
         the_Parameter       :          Node_Pointer     := Node_Pointer (parameter_list);
         Index               :          Natural          := 0;
         gencomma            :          Boolean          := False;

      begin
         append (constructor_Symbol,  String'("gnat_" & (+doh_Item (Swig_name_construct (const_String_or_char_ptr.item (-Self.current_c_Namespace.qualified_Name),
                                                                                         const_String_or_char_ptr.item (-overloaded_name))))));
         append (construct_Call,      "extern "  & Self.current_lStr & "    " & constructor_Symbol & "(");

         Swig_typemap_attach_parms (const_String_or_char_ptr.item (-"ctype"), parameter_List, null);    -- attach the non-standard typemaps to the parameter list
         Swig_typemap_attach_parms (const_String_or_char_ptr.item (-"in"),    parameter_List, null);    --

         emit_mark_varargs (parameter_List);

         while the_Parameter /= null
         loop
            if check_Attribute (the_Parameter,  -"varargs:ignore",  -"1") /= 0
            then   -- Ignored varargs.
               the_Parameter := next_Sibling (the_Parameter);

            elsif check_Attribute (the_Parameter,  -"tmap:in:numinputs",  -"0") /= 0
            then   -- Ignored parameters.
               the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");

            else
               declare
                  pt         : constant SwigType_Pointer := SwigType_Pointer (get_Attribute (the_Parameter, -"type"));   -- tbd: rename
                  the_c_Type :          unbounded_String := +doh_Item        (get_Attribute (the_Parameter, -"tmap:ctype"));
                  arg        : constant String           :=  Self.makeParameterName (doh_parmList (the_Node),
                                                                                     doh_Parm (the_Parameter),
                                                                                     Index);
               begin
                  if gencomma
                  then
                     append (construct_Call,        ",   ");
                     append (construct_call_Args,   ",   ");
                  end if;

                  if the_c_Type /= ""
                  then
                     replace_All (the_c_Type,  "$c_classname",  +doh_Item (pt));

                     append (construct_Call,       String' (+doh_Item (SwigType_lstr     (pt, null))  &   "   "  &  arg));
                     append (construct_call_Args,  String' (+doh_Item (SwigType_rcaststr (pt, const_String_or_char_ptr.item (-arg)))));
                  else
                     log (+"no ctype typemap defined for "  &  String'(+doh_Item (pt)));
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
            the_Constructor : constant c_Function.view := Self.new_c_Function (doh_Node (the_Node),
                                                                               to_unbounded_String ("construct"),
                                                                               Self.current_c_Class.Namespace.all'Access,
                                                                               is_destructor  => False,
                                                                               is_constructor => True);
         begin
            the_Constructor.is_Constructor     := True;
            the_Constructor.is_Static          := True;
            the_Constructor.constructor_Symbol := constructor_Symbol;
         end;

         if not (    check_Attribute (the_Node,  -"access",  -"protected") /= 0
                 or  check_Attribute (the_Node,  -"access",  -"private")   /= 0)
         then
            print_to (DOH_Pointer (Self.f_gnat),  construct_Call & NL);
         end if;
      end;


      --  new ...
      --
      unindent_Log;
      return SWIG_OK;
   end constructorHandler;



   overriding
   function destructorHandler (Self : access Item;
                               n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node : doh_Node renames n;
      Status   : C.int with Unreferenced;
      use type C.int;
   begin
      if not Self.in_cpp_Mode
      then
         return SWIG_OK;
      end if;

      indent_Log;
      log (+"'destructorHandler':");

      Self.current_c_Node := doh_Node (the_Node);

      if not (   check_Attribute (the_Node,  -"access",  -"protected") /= 0
              or check_Attribute (the_Node,  -"access",  -"private")   /= 0)
      then
--           do_base_destructorHandler (Self.all,  the_node);
         Status := swigMod.Language.item (Self.all).destructorHandler (the_node);
      end if;

      -- Dummy hack destructor.
      --
      declare
         the_Destructor : constant c_Function.view := Self.new_c_Function (the_Node,
                                                                           to_unbounded_String ("destruct_0"),
                                                                           Self.current_c_Class.Namespace.all'Access,
                                                                           is_destructor => True);
      begin
         the_Destructor.is_Constructor     := False;
         the_Destructor.is_Destructor      := True;
         the_Destructor.is_Static          := False;
--         the_Destructor.constructor_Symbol := constructor_Symbol;
      end;

      declare
         the_Destructor : constant c_Function.view := Self.new_c_Function (the_Node,
                                                                           to_unbounded_String ("destruct"),
                                                                           Self.current_c_Class.Namespace.all'Access,
                                                                           is_destructor => True);
      begin
         the_Destructor.is_Constructor     := False;
         the_Destructor.is_Destructor      := True;
         the_Destructor.is_Static          := False;
--         the_Destructor.constructor_Symbol := constructor_Symbol;
      end;

      unindent_Log;
      return SWIG_OK;
   end destructorHandler;



   overriding
   function membervariableHandler (Self : access Item;
                                   n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      use swigg.Utility;
      use type C.int;
      the_Node           :          doh_Node     renames n;

      swig_Type          :          SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (get_Attribute (the_Node,  -"type"))));
      swig_Type_is_array : constant Boolean          := SwigType_isarray   (swig_Type) /= 0;
      is_Pointer         : constant Boolean          := SwigType_ispointer (swig_Type) /= 0;
      variable_Name      : constant unbounded_String := +doh_Item (get_Attribute (the_Node,  -"sym:name"));
   begin
      indent_Log;
      log ("'memberVariableHandler':    Name => " & variable_Name & "     swig_Type: '" & String' (+doh_Item (swig_Type)));

      strip_all_qualifiers (doh_Item (swig_Type));
      Self.current_c_Node := doh_Node (the_Node);

      if Self.is_smart_pointer = 0
      then    -- don't add a new member variable during smart pointer resolution.
         declare
            use c_Variable;
            new_Variable :          c_Variable.view;
            bit_Field    : constant String         := +doh_Item (get_Attribute (the_Node,  -"bitfield"));
         begin
            if swig_Type_is_array
            then
               declare
                  unconstrained_array_swigType : constant unbounded_String := strip_array_Bounds (doh_Copy (doh_Item (swig_Type)));
               begin
                  new_Variable := new_c_Variable (variable_Name,
                                                  Self.swig_type_Map_of_c_type.Element (unconstrained_array_swigType));
               end;
            else
               new_Variable := new_c_Variable (variable_Name,
                                               Self.demand_c_Type_for (doh_SwigType (swig_Type)));
            end if;

            new_Variable.is_Static        := False;
            new_Variable.is_class_Pointer := is_Pointer;

            if bit_Field /= ""
            then
               new_Variable.bit_Field := Integer (Value (resolved_c_integer_Expression (Self,
                                                                        +bit_Field,
                                                                        Self.integer_symbol_value_Map,
                                                                        Self.current_class_namespace_Prefix)));
            end if;


            if swig_Type_is_array
            then
               Self.add_array_Bounds_to (new_Variable, doh_SwigType (swig_Type));
            end if;

            Self.current_c_Class.add_Component (new_Variable);
         end;
      end if;

      unindent_Log;
      return SWIG_OK;
   end membervariableHandler;



   overriding
   function staticmembervariableHandler (Self : access Item;
                                         n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node      :          doh_Node    renames  n;
      the_swigType  : constant doh_SwigType     :=  doh_SwigType (get_Attribute (the_Node, -"type"));
      variable_Name : constant unbounded_String := +doh_Item     (get_Attribute (the_Node, -"sym:name"));
   begin
      indent_Log;
      log (+"");
      log (+"'staticmemberVariableHandler':    Name => " & variable_Name & "   swig_type: " & to_String (the_swigType));

      Self.current_c_Node := doh_Node (the_Node);

      unindent_Log;
      return SWIG_OK;
   end staticmembervariableHandler;



   overriding
   function memberconstantHandler (Self : access Item;
                                   n    : in     swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node : doh_Node renames n;
      Status   : C.int    with Unreferenced;
   begin
      indent_Log;

      Self.current_c_Node := doh_Node (the_Node);

      Self.wrapping_member_flag := True;
--        do_base_memberconstantHandler (Self.all, the_node);
      Status := swigMod.Language.item (Self.all).memberconstantHandler (the_node);
      Self.wrapping_member_flag := False;

      --  new ...
      --
      unindent_Log;
      return SWIG_OK;
   end memberconstantHandler;



   overriding
   function insertDirective (Self : access Item;
                             n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node :          doh_Node renames n;
      the_Code : constant doh_swigType  := doh_swigType (get_Attribute (the_Node, -"code"));
   begin
      indent_Log;
      doh_replace_all (the_Code,  -"$module",   -Self.Module_core.Name);

      unindent_Log;
--        return do_base_insertDirective (Self.all, the_Node);
      return swigMod.Language.item (Self.all).insertDirective (the_Node);
   end insertDirective;



   overriding
   function usingDeclaration (Self : access Item;
                              n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      pragma Unreferenced (Self, n);
   begin
      return SWIG_OK;     -- Do nothing, since public/protected/private is ignored in Ada,
                          -- so 'using::' clauses are irrelevant (ie the 'used' members are already available).
   end usingDeclaration;



   overriding
   function typedefHandler (Self : access Item;
                            n    : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int
   is
      the_Node          :          doh_Node renames n;
      the_doh_type_Name : constant doh_String    := doh_String (get_Attribute (the_Node, -"name"));

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
            Name             : constant unbounded_String   := +doh_Item (get_Attribute (the_Node, -"name"));
            the_type_Name    : constant unbounded_String   := Name;

            the_doh_swigType : constant SwigType_Pointer   := SwigType_Pointer (get_Attribute (the_Node, -"type"));
            the_swig_Type    : constant swig_Type          := +doh_Item (the_doh_swigType);

            Pad              :          SwigType_Pointer;
            pragma Unreferenced (Pad);
            use type C.int;
         begin
            log ("'typedefHandler' - name: '" & Name & "'     swig_Type: '" & to_String (the_swig_Type) & "'");

            if SwigType_isarray (the_doh_swigType) /= 0
            then
               log (+"typedef array detected");
               declare
                  swig_Type_copy       : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (the_doh_swigType)));
                  the_Array            : constant SwigType_Pointer := SwigType_pop_arrays (swig_Type_copy);
                  dimension_Count      : constant C.int            := SwigType_array_ndim (the_Array);
                  element_Type         : constant SwigType_Pointer := SwigType_array_type (swig_Type_copy);
                  array_dimension_Text :          unbounded_String;
                  new_c_Array          :          c_Type.view;
               begin
                  new_c_Array := c_type.new_array_Type (namespace    => Self.current_c_Namespace,
                                                        name         => the_type_Name,
                                                        element_Type => Self.swig_type_Map_of_c_type.Element (+doh_Item (element_Type)));
                  for Each in 1 .. dimension_Count
                  loop
                     array_dimension_Text := +doh_Item (SwigType_array_getdim (the_Array,  Each - 1));

                     c_type.add_array_Dimension (new_c_Array,
                                                 upper_Bound => Integer (Value (resolved_c_integer_Expression (Self,
                                                                                                               array_dimension_Text,
                                                                                                               Self.integer_symbol_value_Map,
                                                                                                               Self.current_class_namespace_Prefix))) - 1);
                  end loop;

                  Self.register              (new_c_Array,  the_doh_type_Name);
                  Self.prior_c_Declaration := new_c_Array.all'Access;
               end;

            elsif is_a_function_Pointer (doh_Item (the_doh_swigType))
            then
               log (+"function pointer found");

               Pad := SwigType_del_pointer (the_doh_swigType);

               declare
                  raw_swigType         : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (the_doh_swigType)));
                  the_Function         : constant SwigType_Pointer := SwigType_pop_function (raw_swigType);
                  function_return_Type : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (raw_swigType)));
                  function_Parameters  : constant doh_ParmList     := doh_ParmList (SwigType_function_parms (the_Function, the_Node));

                  new_c_Function         : c_Function.view;
                  new_c_function_Pointer : c_Type.view;
               begin
                  new_c_Function            := c_function.new_c_Function   (to_unbounded_String ("anonymous"),
                                                                            Self.swig_type_Map_of_c_type.Element (+doh_Item (function_return_Type)));
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
                  the_Function          : constant SwigType_Pointer := SwigType_pop_function   (the_doh_swigType);
                  function_return_Type  : constant unbounded_String := +doh_Copy (doh_Item (the_doh_swigType));
                  function_Parameters   : constant doh_ParmList     := doh_ParmList (SwigType_function_parms (the_Function, the_Node));

                  new_c_Function        : constant c_Function.view  := c_function.new_c_Function (to_unbounded_String ("anonymous"),
                                                                                                  Self.swig_type_Map_of_c_type.Element (function_return_Type));
                  new_c_Typdef_function :          c_Type.view;
               begin
                  log ("function_return_Type: '" & function_return_Type & "'");

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
                                         doh_SwigType (-the_type_Name));
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
                           else   Self.register (new_c_typeDef,  doh_SwigType (to_Doh (to_String (Self.current_c_Class.Name & "::" & to_String (the_doh_type_Name)))));
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
                        class_Name  : doh_swigType := doh_swigType (doh_Copy (doh_Item (-Name)));
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
                           Self.register (new_c_Class, doh_SwigType (the_doh_swigType));
                        end if;


                        if "_" & the_type_Name = the_swig_Type
                        then
                           register_Mirror (Self,
                                            the_Type_Name,
                                            new_c_Class,
                                            doh_Item (-the_type_Name));
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

   function is_a_function_Pointer (Self : in doh_swigType) return Boolean
   is
      swig_Type : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (Self));
      use type C.int;
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
                                             to_swig_Type            : in     doh_swigType;
                                             is_core_C_type          : in     Boolean           := False;
                                             create_array_Type       : in     Boolean           := True;
                                             add_level_3_Indirection : in     Boolean           := False)
   is
      use swigg.Utility;
      is_a_new_Type              : constant Boolean            :=    (not is_core_C_type);

      the_c_type_Pointer         :          c_Type.view;
      the_c_type_pointer_Pointer :          c_Type.view;

      the_swig_Type              :          doh_swigType := doh_Copy (to_swig_Type);

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
               array_swigType   : constant doh_swigType := doh_swigType (to_DOH ("a." & (+the_swig_Type)));
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
            pointer_swigType : constant doh_swigType := doh_swigType (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type))));
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
               the_pointer_to_const_swigType : constant doh_swigType
                 := doh_swigType (swigtype_add_Pointer (swigtype_add_Qualifier (SwigType_Pointer (doh_copy (the_swig_Type)),
                                                                               const_String_or_char_ptr.item (to_Doh ("const")))));
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
            reference_swigType   : constant doh_swigType := doh_swigType (SwigType_add_reference (SwigType_Pointer (doh_copy (the_swig_Type))));
         begin
            Self.swig_type_Map_of_c_type.insert (+reference_swigType,      the_c_type_Pointer);

            if Unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               Self.swig_type_Map_of_c_type.insert ("r." & the_c_Type.Name,   the_c_Type_Pointer);
            end if;

            Self.name_Map_of_c_type     .insert (the_c_type.Name & "&",    the_c_type_Pointer);

            declare   -- register reference to 'const'
               the_reference_to_const_swigType : constant doh_swigType
                 := doh_swigType (SwigType_add_reference (swigtype_add_Qualifier (SwigType_Pointer (doh_copy (the_swig_Type)),
                                                                                 const_String_or_char_ptr.item (to_Doh ("const")))));
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
            array_of_pointers_swigType : constant doh_swigType
              := doh_SwigType (to_DOH ("a." & (+doh_Item (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type)))))));
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
            pointer_to_pointer_swigType : constant doh_swigType
              := doh_SwigType (swigtype_add_Pointer (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type)))));
         begin
            Self.swig_type_Map_of_c_type.insert (+pointer_to_pointer_swigType,    the_c_type_pointer_Pointer);

            if Unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               Self.swig_type_Map_of_c_type.insert ("p.p." & the_c_Type.Name,   the_c_type_pointer_Pointer);
            end if;

            Self.name_Map_of_c_type.insert (the_c_type_pointer_Pointer.Name, the_c_type_pointer_Pointer);
         end;


         declare   -- Register pointer pointer to 'const'.
            the_pointer_to_pointer_to_const_swigType : constant doh_swigType
              := doh_SwigType (swigtype_add_Pointer (swigtype_add_Pointer (swigtype_add_Qualifier (SwigType_Pointer (doh_copy (the_swig_Type)),
                                                                                                  const_String_or_char_ptr.item (to_Doh ("const"))))));
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
               array_of_pointer_pointers_swigType : constant doh_swigType
                 := doh_SwigType (to_DOH ("a." & (+doh_Item (swigtype_add_Pointer (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type))))))));
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
               pointer_to_pointer_pointer_swigType : constant doh_swigType
                 := doh_SwigType (swigtype_add_Pointer (swigtype_add_Pointer (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type))))));
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
                                                          the_swig_Type           : in     doh_swigType;
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
               array_swigType : constant doh_swigType := doh_swigType (to_DOH ("a." & (+the_swig_Type)));
               my_array_Type  : constant c_Type.view  := Self.name_Map_of_c_type.Element (the_c_Type.Name & "[]");
            begin
               Self.swig_type_Map_of_c_type.insert (+array_swigType,    my_array_Type);
               Self.     name_Map_of_c_type.insert (proxy_Name & "[]",  my_array_Type);
            end;
         end if;

         declare         -- Add associated pointer.
            pointer_swigType : constant doh_swigType := doh_SwigType (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type))));
            my_view_Type     : constant c_Type.view  := Self.name_Map_of_c_type.Element (the_c_Type.Name & "*");
         begin
            Self.swig_type_Map_of_c_type.insert (+pointer_swigType,  my_view_Type);
            Self.     name_Map_of_c_type.insert (proxy_Name & "*",   my_view_Type);

            declare      -- Register pointer to 'const'.
               the_pointer_to_const_swigType : constant doh_swigType
                 := doh_SwigType (swigtype_add_Pointer (swigtype_add_Qualifier (SwigType_Pointer (doh_copy (the_swig_Type)),
                                                                               const_String_or_char_ptr.item (to_Doh ("const")))));
            begin
               Self.swig_type_Map_of_c_type.insert (+the_pointer_to_const_swigType,  my_view_Type);
               Self.     name_Map_of_c_type.insert ("const " & proxy_Name & "*",     my_view_Type);
            end;

            declare      -- Add associated reference.
               reference_swigType : constant doh_swigType := doh_SwigType (SwigType_add_reference (SwigType_Pointer (doh_copy (the_swig_Type))));
            begin
               Self.swig_type_Map_of_c_type.insert (+reference_swigType, my_view_Type);
               Self.     name_Map_of_c_type.insert (proxy_Name & "&",    my_view_Type);

               declare   -- Register reference to 'const'.
                  the_reference_to_const_swigType : constant doh_swigType
                    := doh_SwigType (SwigType_add_reference (swigtype_add_Qualifier (SwigType_Pointer (doh_copy (the_swig_Type)),
                                                                                    const_String_or_char_ptr.item (to_Doh ("const")))));
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
               array_of_pointers_swigType : constant doh_swigType
                 := doh_SwigType (to_DOH ("a." & (+doh_Item (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type)))))));
               my_view_array_Type         : constant c_Type.view        := Self.name_Map_of_c_type.Element (the_c_Type.Name & "*[]");
            begin
               Self.swig_type_Map_of_c_type.insert (+array_of_pointers_swigType,
                                                    my_view_array_Type);
            end;
         end if;

         declare   -- Add pointer pointer.
            pointer_to_pointer_swigType : constant doh_swigType
              := doh_SwigType (swigtype_add_Pointer (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type)))));
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
                     parent_module_Name : constant String := +doh_Item (get_Attribute (the_Parent, -"module"));
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



   function demand_c_Type_for (Self : access Item;   the_doh_swig_Type : in doh_swigType) return c_Type.view
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
            the_Descriptor : constant unbounded_String := Self.to_Descriptor (doh_SwigType (to_Doh (to_String (Named))));
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



   function to_Descriptor (Self : access Item;   swig_Type : in doh_swigType) return unbounded_String
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



   function my_stripped (Self : access Item;   swig_Type : in doh_swigType) return unbounded_String
   is
      use swigg.Utility;
      stripped_swig_Type : unbounded_String := +doh_Item (SwigType_strip_qualifiers (SwigType_Pointer (swig_Type)));
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



   function get_overloaded_Name (Self : access Item;   for_Node : in doh_Node) return String
   is
      pragma Unreferenced (Self);
      the_Name : constant String := +doh_Item (get_Attribute (for_Node,  -"sym:name"));

   begin
      if get_Attribute (for_Node,  -"sym:overloaded") /= null
      then
         return  the_Name & (+doh_Item (get_Attribute (for_Node,  -"sym:overname")));       -- Add overload suffix.
      else
         return  the_Name;
      end if;
   end get_overloaded_Name;



   function to_ada_subProgram (Self : access Item;   the_c_Function : in c_Function.view) return ada_subProgram.View
   is
      the_ada_subProgram : ada_subProgram.view;
   begin
--        put_Line ("*********** the_c_Function.Name): '" & (+the_c_Function.Name) & "'");
--      put_Line ("*********** the_c_Function.return_Type ): '" & (+the_c_Function.return_Type.Name) & "'");

      the_ada_subProgram := new_ada_subProgram (ada_Utility.to_ada_Identifier (the_c_Function.Name),
                                                Self.c_type_Map_of_ada_type.Element (the_c_Function.return_Type));
      the_ada_subProgram.link_Symbol    := the_c_Function.link_Symbol;
      the_ada_subProgram.is_Virtual     := the_c_Function.is_Virtual;
      the_ada_subProgram.is_Abstract    := the_c_Function.is_Abstract;
      the_ada_subProgram.is_Constructor := the_c_Function.is_Constructor;
      the_ada_subProgram.is_Destructor  := the_c_Function.is_Destructor;

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



   function makeParameterName (Self : access Item;   parameter_List : in doh_parmList;
                                                     the_Parameter  : in doh_Parm    ;
                                                     arg_num        : in Integer) return String
   is
      pragma Unreferenced (Self, arg_num);

      the_Name : constant String       := +doh_Item (get_Attribute (Node_Pointer (the_Parameter),
                                                                    -"name"));
      Count    :          Natural      := 0;
      plist    :          doh_parmList := parameter_List;            -- tbd: better name

   begin
      --  Use C parameter name unless it is a duplicate or an empty parameter name.
      --
      while exists (plist)
      loop
         if the_Name = String' (+doh_Item (get_Attribute (Node_Pointer (plist),
                                                          -"name")))
         then
            Count := Count + 1;
         end if;

         plist := doh_parmList (next_Sibling (Node_Pointer (plist)));
      end loop;

      if the_Name = ""  or  Count > 1
      then
         return  the_Name  &  "arg_"  &  Trim (Natural'Image (Count), ada.strings.Left);
      else
         return  the_Name;
      end if;
   end makeParameterName;



   procedure freshen_current_module_Package (Self : access Item;   for_Node : in doh_Node)
   is
      pragma Unreferenced (Self);
   begin
      null; -- tbd: Self.current_module_Package := Self.old_fetch_Package (named => current_module_Name);
   end freshen_current_module_Package;



   function to_c_Parameters (Self : access Item;   swig_Parameters : in doh_ParmList) return c_parameter.Vector
   is
      the_C_Parameters : c_parameter.Vector;
   begin
      -- Attach the non-standard typemaps to the parameter list.
      --
      Swig_typemap_attach_parms (const_String_or_char_ptr.item (-"in"),               ParmList_Pointer (swig_Parameters), null);
      Swig_typemap_attach_parms (const_String_or_char_ptr.item (-"adatype"),          ParmList_Pointer (swig_Parameters), null);
      Swig_typemap_attach_parms (const_String_or_char_ptr.item (-"adain"),            ParmList_Pointer (swig_Parameters), null);
      Swig_typemap_attach_parms (const_String_or_char_ptr.item (-"imtype"),           ParmList_Pointer (swig_Parameters), null);
      Swig_typemap_attach_parms (const_String_or_char_ptr.item (-"link_symbol_code"), ParmList_Pointer (swig_Parameters), null);

      declare
         the_Parameter : Node_Pointer := Node_Pointer (swig_Parameters);
         Index         : Integer      := 0;
         use type C.int;
      begin
         emit_mark_varargs (ParmList_Pointer (swig_Parameters));

         while the_Parameter /= null
         loop
            if check_Attribute (the_Parameter,  -"varargs:ignore",  -"1") /= 0
            then
               the_Parameter := next_Sibling (the_parameter);                            -- Ignored varargs.

            elsif check_Attribute (the_Parameter,  -"tmap:in:numinputs",  -"0") /= 0
            then
               the_Parameter := get_Attribute (the_Parameter,  -"tmap:in:next");         -- Ignored parameters.

            else
               if not (Self.variable_wrapper_flag  and  Index = 0)
               then   -- Ignore the 'this' argument for variable wrappers.
                  declare
                     use c_Parameter.Vectors,
                         swigg.Utility;

                     param_swigType : SwigType_Pointer  :=SwigType_Pointer (doh_Copy (doh_Item (get_Attribute (the_parameter,  -"type"))));
                  begin
                     strip_all_qualifiers (doh_Item (param_swigType));

                     if not (String'(+doh_Item (param_swigType)) = "")     -- Guard against an empty parameter list.
                     then
                        log ("to_c_Parameters ~ param_swigType: '" & (+doh_Item (param_swigType)) & "'");

                        strip_all_qualifiers (doh_swigType (param_swigType));

                        if SwigType_isarray (param_swigType) /= 0
                        then   -- transform the c array to its equivalent c pointer
                           param_swigType := SwigType_del_array   (param_swigType);
                           param_swigType := SwigType_add_pointer (param_swigType);
                        end if;

                        declare
                           arg : constant unbounded_String
                             := to_unbounded_String (Self.makeParameterName (swig_Parameters,
                                                                             doh_Parm (the_Parameter),
                                                                             Index));
                           new_Parameter : c_Parameter.view;
                        begin
                           begin
                              new_Parameter := new_c_Parameter (arg,
                                                                Self.swig_type_Map_of_c_type.Element (+doh_Item (param_swigType)));
                           exception
                              when Constraint_Error =>
                                 log (+"Type '"
                                      & String'(+doh_Item (param_swigType))
                                      & " is unknown for C parameter '"
                                      & to_String (arg)
                                      & "'.");
                                 raise Aborted;
                           end;

                           new_Parameter.link_symbol_Code := +doh_Item (get_Attribute  (the_Parameter,  -"tmap:link_symbol_code"));
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



   function new_c_Function (Self : access Item;   the_Node       : in     doh_Node;
                                                  function_name  : in     unbounded_String;
                                                  nameSpace      : in     c_nameSpace.view;
                                                  is_Destructor  : in     Boolean;
                                                  is_Constructor : in     Boolean         := False) return c_function.view
   is
      use c_parameter.Vectors;

      the_swigType          :          SwigType_Pointer  := SwigType_Pointer (doh_Copy (doh_Item (get_Attribute (the_Node,  -"type"))));
      parameter_list        :          doh_ParmList      := doh_parmList (get_Attribute (the_Node,  -"parms"));
      the_Parameters        :          c_parameter.Vector;

      the_return_type       :          c_Type.view;

      use type C.int;
      return_by_Reference   : constant Boolean := SwigType_isreference (the_swigType) /= 0;
      return_by_Pointer     : constant Boolean := SwigType_ispointer   (the_swigType) /= 0;

   begin
      Self.current_c_Node := the_Node;

      freshen_current_module_Package (Self, the_Node);

      if String'(+doh_Item (get_Attribute (the_Node, -"overload:ignore"))) /= ""
      then
         return null;   -- Wrappers not wanted for some methods where the parameters cannot be overloaded in Ada.
      end if;

      --  The parameters.
      --

      if exists (parameter_list)
      then
         if SwigType_type (SwigType_Pointer (get_Attribute (Node_Pointer (parameter_list), -"type"))) = T_VOID
         then
            parameter_list := doh_parmList (next_Sibling (Node_Pointer (parameter_list)));
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

      elsif is_Destructor
      then
         the_return_Type := Self.swig_type_Map_of_c_type.Element (+"void");

      else
         declare
            use Swigg.Utility;
            virtualtype : constant doh_swigType := doh_swigType (get_Attribute (the_Node,  -"virtual:type"));
         begin
            if exists (virtualType)
            then                             -- note that in the case of polymorphic (covariant) return types, the method's
               the_return_Type := Self.swig_type_Map_of_c_type.Element (+virtualType);
               log (+"covariant return types not supported in Ada ... proxy method will return "
                    & String'(+doh_Item (SwigType_str (SwigType_Pointer (virtualtype), null))));  -- tbd: ??
            else
               strip_all_Qualifiers (doh_Item (the_swigType));
               the_return_Type := Self.swig_type_Map_of_c_type.Element (+doh_Item (the_swigType));
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
            new_Function.Parameters     := the_Parameters;

            if is_Constructor
            then
               new_Function.link_Symbol := Self.current_linkage_Symbol;
            else
               new_Function.link_Symbol := Self.current_linkage_Symbol;
            end if;

            new_Function.returns_an_Access := return_by_Reference  or  return_by_Pointer;

            if    checkAttribute (the_Node,
                                  const_String_or_char_ptr.item (-"access"),
                                  const_String_or_char_ptr.item (-"public"))    /= 0
            then
               new_Function.access_Mode := public_access;

            elsif checkAttribute (the_Node,
                                  const_String_or_char_ptr.item (-"access"),
                                  const_String_or_char_ptr.item (-"protected")) /= 0
            then
               new_Function.access_Mode := protected_access;

            elsif checkAttribute (the_Node,
                                  const_String_or_char_ptr.item (-"access"),
                                  const_String_or_char_ptr.item (-"private"))   /= 0
            then
               new_Function.access_Mode := private_access;

            else
               new_Function.access_Mode := unknown;
            end if;

            if nameSpace = Self.nameSpace_std
            then
               new_Function.is_Static   := True;
            else
               new_Function.is_Static   := Self.static_flag;
               new_Function.is_Virtual  := checkAttribute (the_Node,
                                                           const_String_or_char_ptr.item (-"storage"),
                                                           const_String_or_char_ptr.item (-"virtual")) /= 0;
               new_Function.is_Abstract := checkAttribute (the_Node,
                                                           const_String_or_char_ptr.item (-"abstract"),
                                                           const_String_or_char_ptr.item (-"1"))       /= 0;
            end if;

            if is_Destructor
            then
               new_Function.is_Virtual := True;
            end if;

            nameSpace.add (new_Function.all'Access);

            return new_Function;
         end;
      else
         return null;
      end if;

   end new_c_Function;



   procedure add_array_Bounds_to (Self : access Item;   the_Variable   : in c_Variable.view;
                                                        from_swig_Type : in doh_swigType)
   is
      use c_Variable.array_bounds_Vectors;

      swig_Type_copy             : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (from_swig_Type));
      the_Array                  : constant SwigType_Pointer := SwigType_pop_arrays (swig_Type_copy);
      dimension_Count            : constant C.int            := SwigType_array_ndim (the_Array);

      array_dimension_Expression : aliased  unbounded_String;
      resolved_array_Dimension   :          Integer;
      use type C.int;
   begin
      for Each in 1 .. dimension_Count
      loop
         array_dimension_Expression := +doh_Item (SwigType_array_getdim (the_Array, Each - 1));

         if array_dimension_Expression = ""
         then
            resolved_array_Dimension := 0;
         else
            resolved_array_Dimension := Integer (Value (resolved_c_integer_Expression (Self,  array_dimension_Expression,
                                                                                              Self.integer_symbol_value_Map,
                                                                                              Self.current_class_namespace_Prefix)));
         end if;

         append (the_Variable.array_Bounds,  resolved_array_Dimension - 1);
      end loop;
   end add_array_Bounds_to;


end gnat_Language;
