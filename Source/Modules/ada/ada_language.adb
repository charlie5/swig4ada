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

   usage_help_Text : constant array (1 .. 3) of access String
     := [new String'("Ada Options (available with -ada)"),
         new String'("       -namespace <ns> - Generate wrappers into Ada namespace <ns>"),
         new String'("       -check-layout   - Check the layout of every class when the wrapper is compiled")];

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


   -----------
   --- Utility
   --

   function  is_a_function_Pointer (swig_Type : in doh_swigType) return Boolean;
   function  returns_a_cpp_constructed_Type (Self : access Item;   the_Node : in doh_Node) return Boolean;
   function  cpp_Symbol (qualified_Name : in String;   Suffix : in String) return String;
   procedure bind_constructors_of_abstract_Class (Self : access Item;   the_Class : in Node_Pointer);
   procedure bind_other_base_Classes             (Self : access Item;   the_Class : in Node_Pointer);
   procedure add_hidden_Members                  (Self : access Item;   Before    : in Node_Pointer;   of_Class : in Node_Pointer := null);
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

            elsif the_Command = "-check-layout"
            then
               Self.all_layout_Checks := True;
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
         swig_typemap_Lang (new_String   ( "ada"));         -- Add typemap definitions.
         swig_config_File  (const_String (-"ada.swg"));
      end;

      Self.allow_Overloading;
      Self.allow_protected_and_private_Members;

      unindent_Log;
   end main;



   overriding
   function top (Self : access Item;
                 N    : in     Node_Pointer) return C.int
   is
      the_Node     :          Node_Pointer renames N;
      module_Name  : constant unbounded_String := +Attribute (the_Node, "name");

   begin
      indent_Log;
      log  ("");
      log  (+"Processing module: '" & module_Name & "'");
      dlog (+"Top");

      --  Initialize all of the output files.
      --
      Self.f_Runtime := new_File (Name => -Attribute (the_Node, "outfile"),
                                  Mode =>  new_String ("w"));

      if not exists (DOH_Pointer (Self.f_Runtime))
      then
         dlog (+"Unable to open " & Attribute (the_Node, "outfile") & ".");
         exit_with_Fail;
      end if;

      Self.f_Init     := File_Pointer (-(""));
      Self.f_Header   := File_Pointer (-(""));
      Self.f_Wrappers := File_Pointer (-(""));
      Self.f_Ada      := File_Pointer (-(""));

      swig_register_FileByName (const_String (-"header"),      Self.f_Header);     -- Register file targets with the SWIG file handler.
      swig_register_FileByName (const_String (-"wrapper"),     Self.f_Wrappers);
      swig_register_FileByName (const_String (-"runtime"),     Self.f_Runtime);
      swig_register_FileByName (const_String (-"init"),        Self.f_Init);
      swig_register_FileByName (const_String (-"begin"),       Self.f_Runtime);    -- There is no separate 'begin' section, the runtime section being the first one written.
      swig_register_FileByName (const_String (-"ada_support"), Self.f_Ada);

      --  Setup the principal namespace and module package names.
      --
      Self.Module_top.define (module_Name, Self.Package_standard);

      --  Print the SWIG banner message.
      --
      swig_Banner (Self.f_Runtime);

      --   Convert 'protected' and 'private' member access to public access, within the generated C runtime.
      --   This is to allow access to protected or private copy constructor and is subject to review (TODO).
      --
--        print_to (Doh_Pointer (Self.f_header),    "#define protected public");
--        print_to (Doh_Pointer (Self.f_header),    "#define private   public");
--
--        print_to (Doh_Pointer (Self.f_wrappers),  "#undef protected");
--        print_to (Doh_Pointer (Self.f_wrappers),  "#undef private");

      --  Register names with swig core.
      --
      declare
         wrapper_Name : constant String := "Ada_%f";
      begin
         swig_Name_register (const_String (-"wrapper"), const_String (-wrapper_Name));
         swig_Name_register (const_String (-"set"),     const_String (-"set_%v"));
         swig_Name_register (const_String (-"get"),     const_String (-"get_%v"));
         swig_Name_register (const_String (-"member"),  const_String (-"%c_%m"));
      end;

      print_to (Doh_Pointer (Self.f_Wrappers), "#ifdef __cplusplus ");
      print_to (Doh_Pointer (Self.f_Wrappers), "extern ""C"" {");
      print_to (Doh_Pointer (Self.f_Wrappers), "#endif");

      print_to (Doh_Pointer (Self.f_Ada),     "#ifdef __cplusplus");
      print_to (Doh_Pointer (Self.f_Ada),     "extern ""C"" {");
      print_to (Doh_Pointer (Self.f_Ada),     "#endif");

      --   Do the base Language 'top' to recursively process all nodes.
      --   As each node is processed, the base 'top' will call the relevant
      --   specialised operation in our 'ada_Language' package.
      --
      do_base_Top (swigMod.Language.Pointer (Self), the_Node);

      print_to (Doh_Pointer (Self.f_Wrappers), "#ifdef __cplusplus");
      print_to (Doh_Pointer (Self.f_Wrappers), "}");
      print_to (Doh_Pointer (Self.f_Wrappers), "#endif");

      print_to (Doh_Pointer (Self.f_Ada),     "#ifdef __cplusplus");
      print_to (Doh_Pointer (Self.f_Ada),     "}");
      print_to (Doh_Pointer (Self.f_Ada),     "#endif");

      Self.process_all_Modules;

      --  Generate the Ada source files.
      --
      log (+"");
      log (+"Creating source for the main module.");
      ada_Language.source_Generator.generate (Self);

      declare
         the_Checks : constant String := ada_Language.source_Generator.layout_Checks (Self);
      begin
         if the_Checks /= ""
         then
            print_to (DOH_Pointer (Self.f_Ada), the_Checks);     -- Which is outside the 'extern "C"' of that section.
         end if;
      end;

      --  Generate the C runtime.
      --
      dump                 (Self.f_Header,                Self.f_Runtime);
      dump                 (Self.f_Wrappers,              Self.f_Runtime);
      dump                 (Self.f_Ada,                   Self.f_Runtime);
      Wrapper_pretty_print (String_Pointer (Self.f_Init), Self.f_Runtime);
      close_File           (Self.f_Runtime);

      log (+"");
      log (+"Ada binding generated.");
      unindent_Log;

      return SWIG_OK;

   exception
      when Aborted =>
         dlog (+"Aborting !");
         raise;
   end top;




   procedure process_all_Modules (Self : in out ada_Language.item)
   is

      procedure resolve_function_Pointers (the_Module : in swig_Module.swig_Module_view)
      --
      --  Makes a function pointer type of each unknown type which is a pointer to a function (such as
      --  the type of the parameter in 'int do_op (int (*op)(int, int))', which has no typedef).
      --
      is
         use c_Type.Vectors;
         Cursor : c_Type.Cursor := the_Module.C.new_c_Types.First;

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
                     Pad := SwigType_del_Pointer (Pad);
                     declare
                        raw_swigType           : constant doh_SwigType := doh_Copy     (Doh_Pointer (Pad));
                        the_Function           : constant doh_SwigType := doh_SwigType (SwigType_pop_function (SwigType_Pointer (raw_swigType)));
                        function_return_Type   : constant doh_SwigType := doh_Copy     (raw_swigType);
                        function_Parameters    : constant doh_ParmList := doh_ParmList (SwigType_function_parms (SwigType_Pointer (the_Function),
                                                                                        null));
                        new_c_Function         : c_Function.view;
                        new_c_function_Pointer : c_Type.view;
                     begin
                        new_c_Function            := c_function.new_c_Function   (to_unbounded_String ("anonymous"),
                                                                                  Self.swig_type_Map_of_c_type.Element (+function_return_Type));
                        new_c_Function.Parameters := Self.to_c_Parameters        (function_Parameters);
                        new_c_function_Pointer    := c_type.new_function_Pointer (Namespace         =>  Self.current_c_Namespace,
                                                                                  Name              => +the_doh_swigType,
                                                                                  accessed_Function =>  new_c_Function);
                        the_c_Type.all            := new_c_function_Pointer.all;
                     end;
                  else
                     dlog ("Unable to transform unknown C type: " & the_c_Type.Name);
                  end if;
               end if;
            end;

            next (Cursor);
         end loop;
      end resolve_function_Pointers;



      procedure process (the_Module : in swig_Module.swig_Module_view)
      is
         new_ada_subPrograms                  : ada_subProgram.vector;
         the_ada_subprogram_Map_of_c_function : swig_Module.ada_subprogram_Maps_of_c_function.Map;
      begin
         resolve_function_Pointers (the_Module);

         Transformer.transform (From                                       => the_Module.C,
                                Self                                       => Self,
                                name_Map_of_c_type                         => Self.name_Map_of_c_type,
                                name_Map_of_ada_type                       => Self.name_Map_of_ada_type,
                                c_type_Map_of_ada_type                     => Self.c_type_Map_of_ada_type,
                                incomplete_access_to_Type_i_c_pointer_List => Self.incomplete_access_to_Type_i_c_pointer_List,
                                c_type_Map_of_ada_subprogram               => Self.c_type_Map_of_ada_subprogram,
                                new_ada_subPrograms                        => new_ada_subPrograms,
                                the_ada_subprogram_Map_of_c_function       => the_ada_subprogram_Map_of_c_function,
                                c_namespace_Map_of_ada_Package             => Self.c_namespace_Map_of_ada_Package,

                                Result => the_Module.Ada);
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
            dlog ("Transforming module: '" & Element (Cursor).Name & "'");

            -- Set the 'std' C namespace mapping to this modules top level Ada package.
            --
            Self.c_namespace_Map_of_ada_Package.include (Self.nameSpace_std,
                                                         Element (Cursor).Ada.Package_top);
            process (Element (Cursor));
            next             (Cursor);
         end loop;
      end;

      --  The function pointers of the main module are resolved ahead of the pruning, which would otherwise
      --  remove them and the functions which use them.
      --
      resolve_function_Pointers (Self.Module_top'unchecked_Access);

      -- Prune out unknown C types and declarations which depend on such.
      --
      Self.prune_unknown_C_Types;

      --  Process the main module.
      --
      log (+"");
      log (+"");
      log (+"Transforming the main module.");

      -- Set the 'std' C namespace mapping to our top level module top Ada package.
      --
      Self.c_namespace_Map_of_ada_Package.include (Self.nameSpace_std,
                                                   Self.Module_top.Ada.Package_top);
      process (Self.Module_top'unchecked_Access);
   end process_all_Modules;




   procedure prune_unknown_C_Types (Self : in out Item)
   is
      use c_Type;
      not_fully_known_Types : c_Type.Vector;
      Count                 : Natural := 0;


      procedure find_the_not_fully_known_Types
      is
      begin
         -- Build a list of all types which are unknown or which depend on types that are not fully known.
         --
         for Each of Self.name_Map_of_c_type
         loop
            if Each.c_type_Kind = Unknown
            then
               Count := Count + 1;
               not_fully_known_Types.append (Each);
            end if;
         end loop;

         while Count /= 0
         loop
            Count := 0;

            for Each of Self.name_Map_of_c_type
            loop
               if not not_fully_known_Types.contains (Each)
               then
                  for i in 1 .. Integer (not_fully_known_Types.Length)
                  loop
                     if Each.depends_directly_on (not_fully_known_Types.Element (i).all'Access)
                     then
                        Count := Count + 1;
                        not_fully_known_Types.append (Each);
                     end if;
                  end loop;
               end if;
            end loop;
         end loop;
      end find_the_not_fully_known_Types;

   begin
      find_the_not_fully_known_Types;

      --  A member which the interface file ignores only reserves its storage. Where its type is not known, the
      --  storage is given up, so that the class itself is still bound (the member may well have been ignored
      --  because its type cannot be bound).
      --
      declare
         Dropped : Boolean := False;
      begin
         for Each of Self.name_Map_of_c_type
         loop
            if Each.c_type_Kind = c_Class
            then
               for i in reverse 1 .. Each.component_Count
               loop
                  if         Each.Components (i).is_ignored_Member
                    and then not_fully_known_Types.contains (Each.Components (i).my_Type)
                  then
                     log (  "Warning: the ignored member '" & Each.Components (i).Name & "' of class '" & Each.Name
                          & "' has a type which is not known, so its storage is left out. The layout of the record does not match that of the class.");
                     Each.lose_Layout;
                     Each.remove_Component (i);
                     Dropped := True;
                  end if;
               end loop;
            end if;
         end loop;

         if Dropped
         then
            not_fully_known_Types.clear;
            find_the_not_fully_known_Types;
         end if;
      end;

      -- Rid not fully known C types from top module.
      --
      log (+"");
      log (+"Pruning out unknown C types.");

      for Each of not_fully_known_Types
      loop
         declare
            use c_Type.Vectors;
            i : constant Natural := Self.Module_top.C.new_c_Types.find_Index (Each);
         begin
            if i /= no_Index
            then
               log ("Unable to bind unknown C type: " & Each.Name);
               Self.Module_top.C.new_c_Types.delete (i);
            end if;
         end;
      end loop;

      -- Rid variables from top module with not fully known C types.
      --
      log (+"");
      log (+"Pruning out C variables.");

      for i in reverse 1 .. Self.Module_top.C.new_c_Variables.last_Index
      loop
         declare
            Variable      : constant c_Variable.view := Self.Module_top.C.new_c_Variables.Element (i);
            variable_Type : constant c_Type    .view := Variable.my_Type;
         begin
            if not_fully_known_Types.contains (variable_Type)
            then
               log ("Unable to bind variable '" & Variable.Name & "' due to unknown C type: " & variable_Type.Name);
               Self.Module_top.C.new_c_Variables.delete (i);
            end if;
         end;
      end loop;

      -- Rid functions from top module whose parameters or return type are not fully known C types.
      --
      log (+"");
      log (+"Pruning out C functions.");

      for i in reverse 1 .. Self.Module_top.C.new_c_Functions.last_Index
      loop
         declare
            the_Function  : constant c_Function.view := Self.Module_top.C.new_c_Functions.Element (i);
            return_Type   : constant c_Type    .view := the_Function.return_Type;
         begin
            if not_fully_known_Types.contains (return_Type)
            then
               log ("Unable to bind function '" & the_Function.Name & "' due to unknown C return type: " & return_Type.Name);
               Self.Module_top.C.new_c_Functions.delete (i);
            end if;

            for Each of the_Function.Parameters
            loop
               if not_fully_known_Types.contains (Each.my_Type)
               then
                  log ("Unable to bind function '" & the_Function.Name & "' due to parameter '" & Each.Name & "' of unknown C type: " & Each.my_Type.Name);
                  Self.Module_top.C.new_c_Functions.delete (i);
               end if;
            end loop;
         end;
      end loop;
   end prune_unknown_C_Types;



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

      node_Type      : constant doh_swigType := doh_swigType (get_Attribute (the_Node, "name"));   -- Swig 'forward declaration' nodes do not have a 'type' attribute,
      the_class_Name : constant String       := Attribute    (the_Node, "name");                   -- so we are using 'name' instead.
      Kind           : constant String       := Attribute    (the_Node, "kind");
      is_a_Struct    : constant Boolean      := Kind = "struct";

      new_c_Class    :          c_Type.view;

   begin
      indent_Log;
      dlog (+"");
      dlog (+"'ClassforwardDeclaration'   node_Type: '" & String'(+node_Type) & "'");

      Self.current_c_Node := doh_Node (the_Node);

      if Self.swig_type_Map_of_c_type.contains (+node_Type)
      then
         unindent_Log;
         return SWIG_OK;     -- The class has already been partially or fully declared, so do nothing.

      else
         if is_a_Struct
         then   new_c_Class := c_Type.new_opaque_Struct    (Namespace => Self.current_c_nameSpace, Name => +the_class_Name);
         else   new_c_Class := c_Type.new_incomplete_Class (Namespace => Self.current_c_nameSpace, Name => +the_class_Name);
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
   is
      the_Node : Node_Pointer renames N;
      use type C.int;
   begin
      indent_Log;
      log  ("");
      log  (+"Binding function: '" & Attribute (the_Node, "sym:name") & "'");
      dlog (+"functionWrapper:  '" & Attribute (the_Node, "sym:name") & "'");

      Self.current_c_Node := doh_Node (the_Node);

      freshen_current_module_Package (Self, the_Node);

      if check_Attribute (the_Node, "access", "private")
      then     -- Skip private functions (tbd: still needed ?).
         dlog (+"Skipping private function.");
         unindent_Log;
         return SWIG_OK;
      end if;

      declare
         sym_Name   : constant String       := Attribute (the_Node, "sym:name");
         swig_Type  : constant doh_swigType := doh_swigType (get_Attribute (the_Node, "type"));
      begin
         if get_Attribute (the_Node, "sym:overloaded") = null
         then
            if Self.addSymbol (String_Pointer (get_Attribute (the_Node, "sym:name")),
                               the_Node) = 0
            then
               unindent_Log;
               return SWIG_ERROR;
            end if;
         end if;

         --  The rest of this function deals with generating the intermediary package wrapper function (which wraps
         --  a C/C++ function) and generating the C code. Each Ada wrapper function has a matching C function call.
         --
         declare
            the_function_Wrapper : constant Wrapper.Pointer  := newWrapper;
            wrapper_Def          : constant doh_String       := doh_String (the_function_Wrapper.Def);
            wrapper_Code         : constant doh_String       := doh_String (the_function_Wrapper.Code);

            overloaded_Name      : constant unbounded_String := to_unbounded_String (get_overloaded_Name (the_Node));
            wrapper_Name         : constant String           := +(doh_Item (Swig_name_wrapper (const_String (-overloaded_name))));

            the_Parameters       : constant ParmList_Pointer := ParmList_Pointer (get_Attribute (the_Node, "parms"));

            c_return_Type        :          unbounded_String := +doh_Item (Swig_typemap_lookup (const_String (-"ctype"),
                                                                                                the_Node,
                                                                                                const_String (-""),
                                                                                                null));
            --  A type which C++ constructs (a class which is virtual or not trivial, or a 'std::string') cannot be the result
            --  of an Ada function, as Ada takes the result of such a function to be a reference to an existing object, where
            --  C++ builds a new one in storage given by the caller. The wrapper therefore takes a pointer to an object of the
            --  caller as its last parameter, and replaces that object by the result.
            --
            result_by_Parameter : constant Boolean :=          Self.in_cpp_Mode
                                                      and then not Self.doing_constructorDeclaration
                                                      and then returns_a_cpp_constructed_Type (Self, the_Node);

            is_void_return  : constant Boolean := (c_return_Type = "void") or result_by_Parameter;
            returns_a_Class : constant Boolean := (c_return_Type = "$c_classname") and not result_by_Parameter;     -- A class, returned by value.
            has_Parameters  :          Boolean := False;
            built_in_Place  :          Boolean := False;     -- The result is constructed from the call itself, with no result variable.
            has_exception_Code : constant Boolean := get_Attribute (the_Node, "feature:except") /= null;

            Num_arguments   : Natural          := 0;
            Num_required    : Natural with Unreferenced;

            argout_Code     : unbounded_String;
            cleanup_Code    : unbounded_String;

         begin
            Swig_typemap_attach_parms (const_String (-"ctype"),  the_Parameters, the_function_Wrapper);  -- Attach the non-standard typemaps to the parameter list.
            Swig_typemap_attach_parms (const_String (-"imtype"), the_Parameters, the_function_Wrapper);

            if c_return_Type /= ""
            then
               replace_All (c_return_Type, "$c_classname", +doh_Item (SwigType_str (SwigType_Pointer (swig_Type), null)));     -- As C++ source, not as swig holds it.
            else
               dlog (+"No ctype typemap defined for " & String'(+swig_Type));
            end if;

            if         returns_a_Class
              and then Self.in_cpp_Mode
            then   -- The class may have no default constructor or no assignment, so the result is held as the swig runtime holds such a value.
               Wrapper_add_local_2 (the_function_Wrapper,  String_or_char_Pointer (-"jresult"),
                                                           new_String ("SwigValueWrapper< " & to_String (c_return_Type) & " >"),
                                                           new_String ("jresult"));
            elsif not is_void_return
            then
               Wrapper_add_local_2 (the_function_Wrapper,  String_or_char_Pointer (-"jresult"),
                                                           new_String (to_String (c_return_Type)),
                                                           new_String ("jresult"));                     -- Was formerly "jresult = 0".
            end if;

            Print_to (wrapper_Def, to_String (" DllExport " & (if result_by_Parameter then +"void" else c_return_Type) & " SWIGSTDCALL " & wrapper_Name & " ("));

            Self.current_linkage_Symbol := to_unbounded_String (wrapper_Name);

            emit_parameter_variables (the_Parameters,
                                      the_function_Wrapper);        -- Emit all local variables for holding arguments.

            --  The core's action for a function is 'result = <call>;', which assigns to a variable of the result type. A
            --  class which C++ constructs is instead constructed from the call, and then moved (or copied) into the object
            --  of the caller. Its assignment is not used: one which the compiler generates is wrong for a class which
            --  manages a resource through its copy constructor and destructor alone.
            --
            if result_by_Parameter
            then
               declare
                  the_Action : constant String  := Attribute (the_Node, "wrap:action");
                  Prefix     : constant String  := "result = ";
                  First      : constant Natural := ada.Strings.fixed.Index (the_Action, Prefix);
                  Last       : constant Natural := ada.Strings.fixed.Index (the_Action, ";", going => ada.Strings.Backward);
               begin
                  if         First /= 0
                    and then Last   > First
                    and then ada.Strings.fixed.Trim (the_Action (the_Action'First .. First - 1), ada.Strings.Both) = ""
                    and then ada.Strings.fixed.Trim (the_Action (Last + 1 .. the_Action'Last),   ada.Strings.Both) = ""
                  then
                     --  The action is kept to one line, as an '%exception' may place it within other text.
                     --
                     set_Attribute (the_Node, "wrap:action",
                                    String'(  "{ typedef " & to_String (c_return_Type) & " swig_ada_result_type;"
                                            & "  swig_ada_result_type swig_ada_result = " & the_Action (First + Prefix'Length .. Last - 1) & ";"
                                            & "  swig_ada_replace (a_result, swig_ada_result);"
                                            & (if has_exception_Code then "  swig_ada_built = true; }" else " }")));
                     built_in_Place := True;

                     --  The code of an '%exception' need not hold the action, and may assign to the 'result' variable
                     --  itself. The wrapper therefore notes whether the action has run, and uses 'result' if it has not.
                     --
                     if has_exception_Code
                     then
                        Wrapper_add_local_2 (the_function_Wrapper,  String_or_char_Pointer (-"swig_ada_built"),
                                                                    new_String ("bool"),
                                                                    new_String ("swig_ada_built = false"));
                     end if;
                  end if;
               end;
            end if;

            if        not built_in_Place
              or else has_exception_Code
            then
               emit_return_variable  (the_Node,
                                      SwigType_Pointer (swig_Type),
                                      the_function_Wrapper);
            end if;
            emit_attach_parmMaps     (the_Parameters,
                                      the_function_Wrapper);        -- Attach the standard typemaps.

            --  Parameter overloading.
            --
            set_Attribute (the_Node, "wrap:parms", String_Pointer (the_Parameters));
            set_Attribute (the_Node, "wrap:name",  wrapper_Name);

            if get_Attribute (the_Node, "sym:overloaded") /= null
            then     -- Wrappers not wanted for some methods where the parameters cannot be overloaded in Ada.
               Swig_overload_check (the_Node);                      -- Emit warnings for the few cases that can't be overloaded in Ada and give up on generating wrapper.

               if get_Attribute (the_Node, "overload:ignore") /= null
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
            do_Parameters:
            declare
               the_Parameter : Node_Pointer := Node_Pointer (the_Parameters);
               gen_Comma     : Boolean      := False;
            begin
               for Each in 0 .. Num_arguments - 1
               loop
                  while check_Attribute (the_Parameter, "tmap:in:numinputs", "0")
                  loop   -- TODO: What is this for ?
                     the_Parameter := get_Attribute (the_Parameter, "tmap:in:next");
                  end loop;

                  declare
                     param_swigType : constant doh_swigType     :=  doh_swigType (get_Attribute (the_Parameter, "type"));
                     l_Name         : constant doh_String       :=  doh_String   (get_Attribute (the_Parameter, "lname"));
                     arg            : constant String           :=  "a_" & (+l_Name);
                     param_c_Type   :          unbounded_String := +Attribute (the_Parameter, "tmap:ctype");
                     declares_Name  :          Boolean          := False;     -- 'param_c_Type' holds the name of the parameter too.
                  begin
                     if param_c_Type = "$c_classname"
                     then   -- A class or structure passed by value. Ada passes a record to an imported subprogram by reference.
                        declare
                           pointer_Type : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (param_swigType)));
                        begin
                           --  The type is written with the name of the parameter, which
                           --  does not simply follow it (as in 'int (*const *a_arg1)[10]').
                           --
                           param_c_Type  := +doh_Item (SwigType_str (SwigType_add_Pointer (pointer_Type), const_String (-arg)));
                           declares_Name := True;
                        end;

                     elsif param_c_Type /= ""
                     then
                        replace_All (param_c_Type,  "$c_classname", +doh_Item (SwigType_str (SwigType_Pointer (param_swigType), null)));
                        replace_All (param_c_Type,  "(", " ");        -- TODO: Hack to remove parentheses from template arguments.
                        replace_All (param_c_Type,  ")", " ");
                     else
                        dlog (+"No ctype typemap defined for " & String'(+param_swigType));
                     end if;

                     if gen_Comma
                     then
                        print_to (wrapper_Def, "," & NL);
                     end if;

                     print_to (wrapper_Def, to_String (if declares_Name then param_c_Type else param_c_Type & " " & arg));     -- Add parameter to C function.
                     gen_Comma      := True;
                     has_Parameters := True;

                     --  Get typemap for this argument.
                     --
                     declare
                        the_typeMap : unbounded_String := +Attribute (the_Parameter, "tmap:in");
                     begin
                        if the_typeMap /= ""
                        then
                           replace_All (the_typeMap,  "$source",  Arg);          -- Deprecated.
                           replace_All (the_typeMap,  "$target", +l_Name);       -- Deprecated.
                           replace_All (the_typeMap,  "$arg",     Arg);          -- Deprecated ?
                           replace_All (the_typeMap,  "$input",   Arg);          -- Deprecated.

                           set_Attribute (the_Parameter, "emit:input", Arg);

                           print_to (wrapper_Code, the_typeMap & NL);

                           the_Parameter := get_Attribute (the_Parameter, "tmap:in:next");
                        else
                           dlog (+"Unable to use type " & String'(+param_swigType) & " as a function argument.");
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
                     the_typeMap : unbounded_String := +Attribute (the_Parameter, "tmap:freearg");
                  begin
                     if the_typeMap /= ""
                     then
                        replace_All (the_typeMap,
                                     "$input",
                                     Attribute (the_Parameter, "emit:input"));
                        append (cleanup_Code,  the_typeMap & NL);
                        the_Parameter := get_Attribute (the_Parameter,  "tmap:freearg:next");
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
                     the_typeMap : unbounded_String := +Attribute (the_Parameter, "tmap:argout");
                  begin
                     if the_typeMap /= ""
                     then
                        replace_All (the_typeMap, "$arg",    Attribute (the_Parameter, "emit:input"));     -- Deprecated ?
                        replace_All (the_typeMap, "$input",  Attribute (the_Parameter, "emit:input"));
                        replace_All (the_typeMap, "$result", "jresult");

                        append (argout_Code,  the_typeMap & NL);

                        the_Parameter := get_Attribute (the_Parameter, "tmap:argout:next");
                     else
                        the_Parameter := next_Sibling (the_Parameter);
                     end if;
                  end;
               end loop;
            end;


            if String'(+node_Type (the_Node)) = "constant"
            then
               Swig_save_1 (to_C ("functionWrapper"), the_Node, to_C ("wrap:action"));      -- Wrapping a constant hack. (TODO: This is usual swig hack)

               declare      -- Below based on Swig_VargetToFunction().
                  use swigMod.Language;
                  the_Type : constant SwigType_Pointer := SwigType_Pointer (Swig_wrapped_var_type (SwigType_Pointer (get_Attribute (the_Node, "type")),
                                                                                                   Self.use_naturalVar_Mode (the_Node)));
               begin
                  set_Attribute (the_Node, "wrap:action",
                                           String' (  "result = ("
                                                    & (+doh_Item (SwigType_lstr (the_Type, null)))
                                                    & ") "
                                                    & Attribute (the_Node, "value")
                                                    & ";"
                                                    & NL));
               end;
            end if;


            --  Determine C type (for contructors).  (TODO: Fix/remove this hack.)
            --
            declare
               void     : doh_Item with Unreferenced;
               the_Type : constant SwigType_Pointer := SwigType_Pointer (doh_copy (DOH_Pointer (get_Attribute (the_Node,
                                                                                                               "type"))));
            begin
               if SwigType_isPointer (the_Type) /= 0
               then
                  void := doh_Item (SwigType_del_Pointer (the_Type));
               end if;

               Self.current_lStr := +doh_copy (DOH_Pointer (SwigType_lStr (the_Type, null)));
            end;


            if not Self.native_function_Flag
            then
               --  Now write code to make the function call.
               --
               declare
                  actionCode : constant String_Pointer := emit_action (N);
                  tm         :          doh_String   with Unreferenced;
                  Status     :          C.int        with Unreferenced;
               begin
                  tm := doh_String (Swig_typemap_lookup_out (const_String (-"out"),
                                                             N,
                                                             const_String (-"result"),
                                                             the_function_Wrapper,
                                                             actionCode));
               end;
            end if;

            if String'(+node_Type (the_Node)) = "constant"
            then
               Swig_restore (the_Node);
            end if;

            if not Self.native_function_Flag
            then     -- Return 'result' value, if necessary.
               declare
                  the_typeMap : unbounded_String := +doh_Item (Swig_typemap_lookup (const_String (-"out"),
                                                                                    the_Node,
                                                                                    const_String (-"result"),
                                                                                    null));
               begin
                  if         built_in_Place
                    and then has_exception_Code
                  then
                     print_to (wrapper_Code,   "  if (!swig_ada_built)"                                                                 & NL
                                             & "  {"                                                                                   & NL
                                             & "    typedef " & to_String (c_return_Type) & " swig_ada_result_type;"                   & NL
                                             & "    swig_ada_replace (a_result, (swig_ada_result_type &) result);"                     & NL
                                             & "  }"                                                                                   & NL);
                  elsif built_in_Place
                  then
                     null;     -- The action has done so.

                  elsif result_by_Parameter
                  then   -- Replace the object of the caller by the result.
                     print_to (wrapper_Code,   "  {"                                                                                     & NL
                                             & "    typedef " & to_String (c_return_Type) & " swig_ada_result_type;"                    & NL
                                             & "    a_result->~swig_ada_result_type ();"                                                 & NL
                                             & "    new (a_result) swig_ada_result_type ((swig_ada_result_type &) result);"              & NL
                                             & "  }"                                                                                     & NL);
                  elsif the_typeMap /= ""
                  then
                     replace_All (the_typeMap, "$result", "jresult");

                     --  A pointer result is cast to the type which the wrapper returns, as the two differ where a typemap
                     --  has been applied to another type ('%apply char * { unsigned char * }'), or in their qualifiers.
                     --
                     if         Length (c_return_Type) > 0
                       and then Element (Trim (c_return_Type, ada.Strings.Both), Length (Trim (c_return_Type, ada.Strings.Both))) = '*'
                     then
                        declare
                           White    : constant ada.Strings.Maps.Character_Set := ada.Strings.Maps.to_Set (' ' & ASCII.LF & ASCII.CR & ASCII.HT);
                           the_Code : constant String := ada.Strings.fixed.Trim (to_String (the_typeMap), Left => White, Right => White);
                           Head     : constant String := "jresult = ";
                           Tail     : constant String := "result;";
                        begin
                           if         the_Code'Length >= Head'Length + Tail'Length
                             and then the_Code (the_Code'First .. the_Code'First + Head'Length - 1) = Head
                             and then the_Code (the_Code'Last - Tail'Length + 1 .. the_Code'Last)   = Tail
                           then
                              declare
                                 its_Cast : constant String := ada.Strings.fixed.Trim (the_Code (the_Code'First + Head'Length .. the_Code'Last - Tail'Length),
                                                                                       ada.Strings.Both);
                              begin
                                 if        its_Cast = ""
                                   or else (         its_Cast (its_Cast'First) = '('
                                            and then its_Cast (its_Cast'Last)  = ')'
                                            and then ada.Strings.fixed.Index (its_Cast, ";") = 0)
                                 then
                                    the_typeMap := +("  jresult = (" & to_String (c_return_Type) & ") result;");
                                 end if;
                              end;
                           end if;
                        end;
                     end if;

                     print_to (wrapper_Code, the_typeMap & NL);

                  elsif not is_Void_return
                  then
                     dlog (+ "Unable to use return type "
                          & String'(+swig_Type)
                          & " in function "
                          & Attribute (the_Node, "name")
                          & NL);
                  end if;
               end;
            end if;

            print_to (wrapper_Code, argOut_Code);       -- Output argument output code.
            print_to (wrapper_Code, cleanup_Code);      -- Output cleanup         code.

            if get_Attribute (the_Node, "feature:new") /= null
            then   -- Look to see if there is any newfree cleanup code.
               declare
                  the_typeMap : constant unbounded_String := +doh_Item (Swig_typemap_lookup (const_String (-"newfree"),
                                                                                             the_Node,
                                                                                             const_String (-"result"),
                                                                                             null));
               begin
                  if the_typeMap /= ""
                  then
                     print_to (wrapper_Code, the_typeMap & NL);
                  end if;
               end;
            end if;


            if not Self.native_function_Flag
            then   -- See if there is any return cleanup code.
               declare
                  the_typeMap : constant unbounded_String := +doh_Item (Swig_typemap_lookup (const_String (-"ret"),
                                                                                             the_Node,
                                                                                             const_String (-"result"),
                                                                                             null));
               begin
                  if the_typeMap /= ""
                  then
                     dlog ("CLEANUP '" & (+the_typeMap) &  "'");
                  end if;
               end;
            end if;

            --  Finish C function definitions.
            --
            if result_by_Parameter
            then
               print_to (wrapper_Def, to_String ((if has_Parameters then +("," & NL) else +"") & c_return_Type & " * a_result"));
            end if;

            print_to (wrapper_Def, ")" & NL & "{" & NL);

            if not is_Void_return
            then
               print_to (wrapper_Code, "    return jresult;" & NL);     -- TODO: Change 'jresult' to 'ada_result'.
            end if;

            print_to        (wrapper_Code, "}" & NL);
            doh_replace_All (wrapper_Code, -"$cleanup",               -cleanup_Code);                      -- Substitute the cleanup code.
            doh_replace_All (wrapper_Code, -"$symname",               -sym_Name);                          -- And the name which the function is bound by.
            doh_replace_All (wrapper_Code, -"SWIG_contract_assert(",  -"SWIG_contract_assert($null, ");    -- Contract macro modification.

            if not is_Void_return
            then   doh_replace_All (wrapper_Code, -"$null", -"0");
            else   doh_replace_All (wrapper_Code, -"$null", -"");
            end if;

            --  A protected member is given a wrapper too (the bindings to swig itself call some). Such a wrapper compiles
            --  only where access is opened to it: by '#define protected public' ahead of the class, as 'swigmod.i' does,
            --  or by the '-fno-access-control' switch of g++.
            --
            if    not Self.native_function_Flag
              and not Self.doing_constructorDeclaration
            then
               Wrapper_print (the_function_Wrapper, Self.f_Wrappers);      -- Dump the function out.
            end if;

            if    not (Self.is_wrapping_Class /= 0)   -- Ignore class member functions.
              and not Self.enum_constant_Flag
            then
               declare
                  the_new_Function : c_Function.view;
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

            --  The 'get' or the 'set' function of a member variable (see 'memberVariableHandler').
            --
            if Self.accessor_member_Name /= ""
            then
               declare
                  the_Name     : constant String  := sym_Name;
                  is_Setter    : constant Boolean := the_Name'Length > 4 and then the_Name (the_Name'First .. the_Name'First + 3) = "set_";     -- The core names them 'set_<class>_<member>' and 'get_...'.
                  the_Accessor : c_Function.view;
               begin
                  the_Accessor := Self.new_c_Function (the_Node,
                                                       (if is_Setter then "set_" & Self.accessor_member_Name
                                                                     else Self.accessor_member_Name),
                                                       Self.current_c_Class.nameSpace.all'Access,
                                                       is_Destructor => False);
                  pragma Unreferenced (the_Accessor);
               end;
            end if;

            delWrapper (the_function_Wrapper);
         end;
      end;

      dlog (+"end functionWrapper.");
      unindent_Log;
      return SWIG_OK;
   end functionWrapper;



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
         new_Variable.is_Pointer       := SwigType_isReference (the_swig_Type) /= 0;

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
              and then to_String (new_Variable.my_Type.Name) in "int" | "unsigned int" | "long" | "unsigned long" | "short" | "unsigned short" | "long long" | "unsigned long long"
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
              and then to_String (new_Variable.my_Type.Name) in "double" | "float"
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
         if get_Attribute (the_Node, "inherit") /= null
         then
            declare
               the_Base : constant String := +doh_Item (SwigType_typedef_resolve_all (SwigType_Pointer (get_Attribute (the_Node, "inherit"))));
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

      Self.enum_rep_clause_Required := False;

      freshen_current_module_Package (Self, doh_Node (the_Node));


      if String' (+DOH_Pointer (doh_swig_Type)) = "enum "
      then   -- Handle anonymous enums.
         Self.is_anonymous_Enum    := True;
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

      else
         Self.is_anonymous_Enum := False;
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

                  log (  "Warning: unable to evaluate the value '" & enum_value_Text & "' of the enumeration literal '" & symName
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
      the_Type            := Self.demand_c_Type_for (doh_swigType (the_swigType));     -- An unknown type is pruned later.
      new_c_Constant      := c_variable.new_c_Variable (Name    => the_Name,
                                                        of_Type => the_Type);
      dlog ("the_Type.Name => '" & the_Type.Name & "'");

      declare
         value_Text : unbounded_String := +Attribute (the_Node, "value");
      begin
         dlog ("value_Text => '" & value_Text & "'");

         if        (         Index (value_Text, "&")  = 1
                    and then Index (value_Text, "::") > 0)
           or else Index (String'(+DOH_Pointer (the_swigType)), "m(") = 1
         then   -- A pointer to a member of a class, for which Ada has no counterpart.
            log ("Warning: unable to bind the constant '" & the_Name & "', as its value is a pointer to a class member.");
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
                  begin
                     strip_c_integer_literal_qualifiers_in (value_Text);

                     if        the_Type.Name = "float"
                       or else the_Type.Name = "double"
                     then
                        replace_Integer_with_Float (value_Text);

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
                              log (  "Warning: unable to bind the constant '" & the_Name & "', as its value (" & the_Text
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



   overriding
   function classHandler (Self : access Item;
                          N    : in Node_Pointer) return C.int
   is
      the_Node       :          Node_Pointer renames N;
      node_Type      : constant SwigType_Pointer :=  SwigType_Pointer (get_Attribute (the_Node, "name"));   -- TODO: Use sym:name ?
      class_Name_Doh : constant SwigType_Pointer :=  SwigType_Pointer (get_Attribute (the_Node, "sym:name"));
      class_Name     : constant String           := +DOH_Pointer (class_Name_Doh);
      new_c_Class    :          c_Type.view;
      Status         :          C.int with Unreferenced;
      use type C.int;
   begin
      indent_Log;
      dlog (+"");
      dlog (+ "classHandler - '"
           & class_Name
           & "'    node_Type '"
           & String' (+DOH_Pointer (node_Type))
           & "'");

      Self.current_c_Node := doh_Node (the_Node);

      if Self.swig_type_Map_of_c_type.contains (+DOH_Pointer (node_Type))
      then   -- The class has been 'forward' declared.
         new_c_Class     := Self.swig_type_Map_of_c_type.Element (+DOH_Pointer (node_Type));      -- Get the 'opaque' c type.
         new_c_Class.all := c_Type.c_Class_construct (Namespace => Self.current_c_Namespace,      -- Morph it to a c class.
                                                      Name      => new_c_Class.Name);

         --  A class may be declared in an imported module and defined in the module which imports it. It remains
         --  a class of the module which declared it, whose own binding knows it only as an incomplete class, so
         --  the specification of its package is generated along with those of the module which defines it.
         --
         declare
            use type swig_Module.swig_Module_view;
         begin
            if         Self.current_Module = Self.Module_top'Access
              and then not Self.Module_top.C.new_c_Types.contains (new_c_Class)
            then
               Self.imported_Classes_defined_here.append (new_c_Class);
               new_c_Class.is_defined_in_main_Module;
            end if;
         end;
      else
         new_c_Class := c_Type.new_c_Class (Namespace => Self.current_c_Namespace,
                                            Name      => +class_Name);
         Self.register (new_c_Class,
                        doh_SwigType (node_Type));
      end if;

      if String' (+DOH_Pointer (get_Attribute (the_Node, "kind"))) = "union"
      then
         new_c_Class.is_Union;
      end if;

      --  Note whether the class declares a virtual member, as the member functions
      --  of a class in an imported module are not collected.
      --
      declare
         the_Child : Node_Pointer := first_Child (the_Node);
      begin
         while the_Child /= null
         loop
            if check_Attribute (the_Child, "storage", "virtual")
            then
               new_c_Class.has_virtual_Members;
               exit;
            end if;

            the_Child := next_Sibling (the_Child);
         end loop;
      end;

      --  Likewise whether its destructor is virtual, which a class derived from it in another module needs to know.
      --
      declare
         the_Child : Node_Pointer := first_Child (the_Node);
      begin
         while the_Child /= null
         loop
            if         Attribute (the_Child, "nodeType") = "destructor"
              and then check_Attribute (the_Child, "storage", "virtual")
            then
               new_c_Class.has_virtual_Destructor;
               exit;
            end if;

            the_Child := next_Sibling (the_Child);
         end loop;
      end;

      --  Note the form which the name of a template instance takes when the default arguments of its template are given.
      --
      declare
         full_Form : constant String := +doh_Item (Swig_symbol_template_deftype (node_Type, null));
         its_Form  : constant String := +DOH_Pointer (node_Type);
      begin
         if         full_Form /= its_Form
           and then not Self.template_full_Forms.contains (full_Form)
         then
            Self.template_full_Forms .append (full_Form);
            Self.template_plain_Forms.append (its_Form);
         end if;
      end;

      --  Note whether the class declares a destructor or a copy constructor. C++ passes and returns such a
      --  class by reference, so it cannot be bound as a plain record. (The core notes both on the class, and
      --  later adds a destructor node to every class, declared or not.)
      --
      if         Self.in_cpp_Mode     -- In C, a destructor can only be one which the interface file adds.
        and then (        get_Attribute (the_Node, "allocate:has_destructor")       /= null
                  or else get_Attribute (the_Node, "allocate:has_copy_constructor") /= null)
      then
         new_c_Class.has_nontrivial_Members;
      end if;

      --  A base class which is inherited virtually, or a member whose type is a nested class with no name (which the
      --  core leaves out), changes the layout of the class in a way which is not followed here. The parser notes both.
      --
      if Attribute (the_Node, "has_virtual_base") /= ""
      then
         log (  "Warning: the class '" & class_Name & "' inherits a base class virtually, which is not supported."
              & " The layout of its record does not match that of the class.");
         new_c_Class.lose_Layout;
      end if;

      if         Attribute (the_Node, "has_unnamed_member") /= ""
        and then (        get_Attribute (the_Node, "unnamed_nested") = null
                  or else not Self.in_cpp_Mode)
      then
         log (  "Warning: the class '" & class_Name & "' has a nested class or union with no name, whose members are left out."
              & " The layout of its record does not match that of the class.");
         new_c_Class.lose_Layout;
      end if;

      --  Note the name by which the wrapper file knows the class, for a check of its layout.
      --
      declare
         the_Name : constant String := Attribute (the_Node, "name");
      begin
         if        the_Name = ""
           or else ada.Strings.fixed.Index (the_Name, "$unnamed") /= 0
           or else Attribute (the_Node, "access") in "private" | "protected"
         then
            null;     -- It cannot be named there.

         elsif Self.in_cpp_Mode
         then
            new_c_Class.layout_Name_is (+String'(+doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (the_Node, "name"))))));

         elsif Attribute (the_Node, "tdname") /= ""
         then
            new_c_Class.layout_Name_is (+Attribute (the_Node, "tdname"));
         else
            new_c_Class.layout_Name_is (+(Attribute (the_Node, "kind") & " " & the_Name));
         end if;
      end;

      --  Note whether the class is more than a plain structure, as C++ lays one out. A class derived from one which
      --  is may have members in its unused tail, where one derived from a plain structure begins after the whole of it.
      --  (These are the cases in which GCC does so.)
      --
      if Self.in_cpp_Mode
      then
         declare
            the_Child : Node_Pointer := first_Child (the_Node);
         begin
            if         get_Attribute (the_Node, "allbases") /= null
              and then DohLen (doh_List (get_Attribute (the_Node, "allbases"))) > 0
            then
               new_c_Class.is_not_layout_Pod;     -- It has a base class.
            end if;

            if get_Attribute (the_Node, "allocate:has_copy_constructor") /= null
            then
               new_c_Class.is_not_layout_Pod;     -- It declares a copy constructor.
            end if;

            while the_Child /= null
            loop
               declare
                  the_Kind    : constant String  := Attribute (the_Child, "nodeType");
                  is_Extended : constant Boolean := Attribute (the_Child, "feature:extend") /= "";
                  is_Given    : constant Boolean := Attribute (the_Child, "value") not in "default" | "delete";     -- Not left to the compiler.
               begin
                  if    (         the_Kind = "constructor"                                -- One which the class declares: the core
                         and then is_Given                                                -- adds those which the compiler provides.
                         and then not is_Extended
                         and then Attribute (the_Child, "default_constructor") = ""
                         and then Attribute (the_Child, "copy_constructor")    = "")

                     or (         the_Kind = "destructor"                                 -- Likewise.
                         and then is_Given
                         and then not is_Extended
                         and then get_Attribute (the_Node, "allocate:has_destructor") /= null)

                     or (         the_Kind = "cdecl"                                      -- An assignment operator.
                         and then Attribute (the_Child, "name") = "operator ="
                         and then is_Given
                         and then not is_Extended)

                     or (         the_Kind = "cdecl"                                      -- A member variable which is not public,
                         and then Attribute (the_Child, "kind") = "variable"              -- or has an initial value.
                         and then Attribute (the_Child, "storage") not in "static" | "typedef" | "friend" | "extern"
                         and then not is_Extended
                         and then (        Attribute (the_Child, "access") in "private" | "protected"
                                   or else Attribute (the_Child, "hasvalue") /= ""))

                     or (         the_Kind = "cdecl"                                      -- A virtual function.
                         and then Attribute (the_Child, "storage") = "virtual")
                  then
                     new_c_Class.is_not_layout_Pod;
                  end if;
               end;

               the_Child := next_Sibling (the_Child);
            end loop;
         end;
      end if;

      if Self.in_cpp_Mode
      then
         bind_unnamed_nested_Classes (Self, the_Node,
                                      outer_Name => class_Name,
                                      cpp_Name   => +doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (the_Node, "name")))));
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

      Self.have_default_constructor_Flag := False;

      -- Handle base classes.
      --
      declare
         base_List : constant doh_List   := doh_List (get_Attribute (the_Node, "allbases"));
         Length    : constant C.int      := DohLen (base_List);
         the_Item  :          DOH_Pointer;
      begin
         for i in 1 .. Length
         loop
            the_Item := DohGetitem (base_List, i - 1);

            declare
               base_Name : constant String := Attribute (Node_Pointer (the_Item), "sym:name");
            begin
               --  The base class is sought by its full name first, as its plain name may be that of a class
               --  of another namespace ('A::C::Foo', where 'A::B::Foo' is also declared).
               --
               if         Self.swig_type_Map_of_c_type.contains (+Attribute (Node_Pointer (the_Item), "name"))
                 and then Self.swig_type_Map_of_c_type.Element  (+Attribute (Node_Pointer (the_Item), "name")).c_type_Kind in c_Type.c_Class
               then
                  Self.current_c_Class.add_Base (Self.swig_type_Map_of_c_type.Element (+Attribute (Node_Pointer (the_Item), "name")));

               elsif Self.name_Map_of_c_type.contains (+base_Name)
               then
                  Self.current_c_Class.add_Base (Self.name_Map_of_c_type.Element (+base_Name));
               else   -- Such as a base class which is ignored, or is a template which has not been instantiated.
                  log ("Warning: the base class '" & base_Name & "' of class '" & class_Name & "' is not known, and is ignored.");
                  new_c_Class.lose_Layout;
               end if;
            end;
         end loop;
      end;

      Status := swigMod.Language.item (Self.all).classHandler (the_Node);     -- Process all class members.

      add_hidden_Members (Self, before => null);                              -- Those which follow the last member.

      bind_constructors_of_abstract_Class (Self, the_Node);
      bind_other_base_Classes             (Self, the_Node);

      --  new ...
      --
      Self.c_class_Stack    .delete_Last;
      Self.c_namespace_Stack.delete_Last;

      Self.prior_c_Declaration := new_c_Class.all'Access;

      unindent_Log;
      return SWIG_OK;
   end classHandler;



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
   is
      the_Node : Node_Pointer renames N;
      Status   : C.int with Unreferenced;

      for_abstract_Class : constant Boolean := Self.abstract_shim_Name /= "";
      extend_Function    : unbounded_String;     -- The function of the wrapper which is a constructor added by '%extend'.
   begin
      if not Self.in_cpp_Mode
      then
         --  C has no constructors, but the interface file may add one with '%extend' (as '%array_class' does).
         --  It is bound as an ordinary function, 'new_<type>', which returns a pointer to a new object.
         --
         if         Attribute (the_Node, "feature:extend") /= ""
           and then not Self.c_class_Stack.is_Empty
           and then Self.name_Map_of_c_type.contains (Self.current_c_Class.Name & "*")
         then
            Self.current_c_Node := doh_Node (the_Node);
            Status              := swigMod.Language.item (Self.all).constructorHandler (the_Node);

            declare
               use type C.int;

               the_Name       : constant String       := "new_" & to_String (Self.current_c_Class.Name);
               parameter_List :          doh_ParmList := doh_parmList (get_Attribute (the_Node, "parms"));
               the_Function   : constant c_Function.view
                 := c_Function.new_c_Function (+the_Name,
                                               Self.name_Map_of_c_type.Element (Self.current_c_Class.Name & "*"));
            begin
               if         exists (parameter_List)
                 and then SwigType_type (SwigType_Pointer (get_Attribute (Node_Pointer (parameter_List), "type"))) = T_VOID
               then
                  parameter_List := doh_parmList (next_Sibling (Node_Pointer (parameter_List)));
               end if;

               the_Function.Parameters.append (Self.to_c_Parameters (parameter_List));
               the_Function.link_Symbol       := +("Ada_" & the_Name);
               the_Function.returns_an_Access := True;

               Self.current_Module.C.new_c_Functions   .append (the_Function);
               Self.current_Module.C.new_c_Declarations.append (the_Function.all'Access);
            end;
         end if;

         return SWIG_OK;
      end if;

      indent_Log;
      dlog (+"");
      dlog (+"'constructorHandler'");

      if check_Attribute (the_Node, "access", "private")
      then
         unindent_Log;
         return SWIG_OK;
      end if;

      Self.current_c_Node := doh_Node (the_Node);

      if not (   check_Attribute (the_Node, "access", "protected")
              or check_Attribute (the_Node, "access", "private")
              or for_abstract_Class)     -- The core's wrapper makes a new object of the class, which an abstract class cannot have.
      then
         Self.doing_constructorDeclaration := True;
         Status := swigMod.Language.item (Self.all).constructorHandler (the_Node);
         Self.doing_constructorDeclaration := False;

         --  A constructor which was added by '%extend' is a function of the wrapper, which returns a new object.
         --  Its name is taken from the call which the core has made of it ('result = (Vec *)new_Vec(arg1,arg2);').
         --
         if Attribute (the_Node, "feature:extend") /= ""
         then
            declare
               the_Action : constant String  := Attribute (the_Node, "wrap:action");
               Last       : constant Natural := ada.Strings.fixed.Index (the_Action, "(", going => ada.Strings.Backward);
               First      :          Natural := Last;
            begin
               while      First > the_Action'First
                 and then the_Action (First - 1) in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_'
               loop
                  First := First - 1;
               end loop;

               if         Last /= 0
                 and then First < Last
               then
                  extend_Function := +the_Action (First .. Last - 1);
               end if;
            end;
         end if;
      end if;

      if get_Attribute (the_Node, "overload:ignore") /= null
      then   -- Wrappers not wanted for some methods where the parameters cannot be overloaded in Ada.
         unindent_Log;
         return SWIG_OK;
      end if;

      declare
         overloaded_name     : constant String := get_overloaded_Name (doh_Node (the_Node));

         constructor_Symbol  : unbounded_String;     -- We need to build our own 'c' construction call   (TODO: Move all this to functionWrapper.)
         construct_Call      : unbounded_String;     -- since the default swig constructor returns a pointer to class
         construct_call_Args : unbounded_String;     -- instead of an actual solid class object.

         parameter_List : constant ParmList_Pointer := ParmList_Pointer (get_Attribute (the_Node, "parms"));

         the_Parameter  : Node_Pointer := Node_Pointer (parameter_list);
         Index          : Natural      := 0;
         genComma       : Boolean      := False;

         parameters_First : Positive;     -- Where the parameters begin in 'construct_Call'.

         ignored_Code     : unbounded_String;   -- The code which gives a value to each parameter which the caller does not give.
         any_Argument     : Boolean := False;   -- The call of the constructor has an argument so far.

         function has_hidden_Destructor return Boolean
         --
         --  The construction function returns its object by value, which C++
         --  allows only for a class whose destructor is public.
         --
         is
            the_Child : Node_Pointer := first_Child (Self.getCurrentClass);
         begin
            while the_Child /= null
            loop
               if         Attribute (the_Child, "nodeType") = "destructor"
                 and then (        check_Attribute (the_Child, "access", "protected")
                           or else check_Attribute (the_Child, "access", "private"))
               then
                  return True;
               end if;

               the_Child := next_Sibling (the_Child);
            end loop;

            return False;
         end has_hidden_Destructor;

      begin
         append (constructor_Symbol, String'("ada_" & (+doh_Item (Swig_name_construct (const_String (-Self.current_c_Namespace.qualified_Name),
                                                                                       const_String (-overloaded_name))))));
         --  The name of a class in a namespace, or of a template instance, holds characters which a C identifier may not.
         --
         for Each in 1 .. Length (constructor_Symbol)
         loop
            if Element (constructor_Symbol, Each) not in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_'
            then
               replace_Element (constructor_Symbol, Each, '_');
            end if;
         end loop;

         append (construct_Call, "extern "  & Self.current_lStr & "    " & constructor_Symbol & "(");
         parameters_First := Length (construct_Call) + 1;

         --  Each parameter is given the name of a local variable, which its 'in' typemap then assigns
         --  to. It is only used for a parameter which the caller does not give (see below).
         --
         declare
            Each  : Node_Pointer := Node_Pointer (parameter_List);
            Count : Natural      := 0;
         begin
            while Each /= null
            loop
               Count := Count + 1;
               set_Attribute (Each, "lname", "swig_ada_ignored_" & ada.Strings.fixed.Trim (Count'Image, ada.Strings.Left));
               Each  := next_Sibling (Each);
            end loop;
         end;

         Swig_typemap_attach_parms (const_String (-"ctype"), parameter_List, null);    -- Attach the non-standard typemaps to the parameter list.
         Swig_typemap_attach_parms (const_String (-"in"),    parameter_List, null);

         emit_mark_varArgs (parameter_List);

         while the_Parameter /= null
         loop
            if check_Attribute (the_Parameter, "varargs:ignore", "1")
            then   -- Ignored varargs.
               the_Parameter := next_Sibling (the_Parameter);

            elsif check_Attribute (the_Parameter, "tmap:in:numinputs", "0")
            then   -- A parameter which the caller does not give: its 'in' typemap gives it a value, held in a local variable.
               declare
                  swig_Type : constant SwigType_Pointer := SwigType_Pointer (get_Attribute (the_Parameter, "type"));
                  the_Local : constant String           := Attribute (the_Parameter, "lname");
                  the_Code  : constant unbounded_String := +Attribute (the_Parameter, "tmap:in");
               begin

                  append (ignored_Code,   "  " & String'(+doh_Item (SwigType_lstr (swig_Type, const_String (-the_Local)))) & ";" & NL
                                        & "  " & to_String (the_Code) & NL);

                  if any_Argument
                  then
                     append (construct_call_Args,  ",   ");
                  end if;

                  append (construct_call_Args, the_Local);
                  any_Argument  := True;
                  the_Parameter := get_Attribute (the_Parameter, "tmap:in:next");
               end;

            else
               declare
                  swig_Type  : constant SwigType_Pointer :=  SwigType_Pointer  (get_Attribute (the_Parameter, "type"));   -- TODO: Rename.
                  the_c_Type :          unbounded_String := +Attribute         (the_Parameter, "tmap:ctype");
                  Arg        : constant String           :=  makeParameterName (doh_parmList (the_Node),
                                                                                doh_Parm (the_Parameter),
                                                                                Index);
               begin
                  if genComma
                  then
                     append (construct_Call,       ",   ");
                  end if;

                  if any_Argument
                  then
                     append (construct_call_Args,  ",   ");
                  end if;

                  any_Argument := True;

                  if the_c_Type = "$c_classname"
                  then   -- A class or structure passed by value, which Ada passes by reference.
                     append (construct_Call,      String' (+doh_Item (SwigType_lstr (SwigType_add_Pointer (SwigType_Pointer (doh_Copy (doh_Item (swig_Type)))),
                                                                                    const_String (-Arg)))));
                     append (construct_call_Args, "*" & Arg);

                  elsif the_c_Type /= ""
                  then
                     replace_All (the_c_Type, "$c_classname", +doh_Item (SwigType_str (swig_Type, null)));

                     append (construct_Call,      String' (+doh_Item (SwigType_lstr     (swig_Type, null))  &   "   "  &  Arg));
                     append (construct_call_Args, String' (+doh_Item (SwigType_rcaststr (swig_Type, const_String (-Arg)))));
                  else
                     dlog (+"no ctype typemap defined for "  &  String' (+doh_Item (swig_Type)));
                  end if;

                  genComma      := True;
                  the_Parameter := get_Attribute (the_Parameter, "tmap:in:next");
                  Index         := Index + 1;
               end;
            end if;
         end loop;

         if for_abstract_Class
         then
            --  The function has the profile of a constructor: it is given the address of the storage, in which it
            --  constructs an object of the concrete class. Ada then makes the object one of its own derived type.
            --
            declare
               the_Class      : constant String := +doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (Self.getCurrentClass, "name"))));
               the_Parameters : constant String := Slice (construct_Call, parameters_First, Length (construct_Call));
            begin
               append (Self.abstract_shim_Constructors,
                         "  " & Self.abstract_shim_Name & " (" & the_Parameters & ") : " & the_Class & " (" & construct_call_Args & ") {}" & NL);

               construct_Call := +(  "extern void " & to_String (constructor_Symbol) & " (" & the_Class & " * self"
                                   & (if the_Parameters = "" then "" else ",   " & the_Parameters) & ")"                   & NL
                                   & "{"                                                                                   & NL
                                   & to_String (ignored_Code)
                                   & "  new (self) " & to_String (Self.abstract_shim_Name) & " (" & to_String (construct_call_Args) & ");" & NL
                                   & "}"                                                                                   & NL);
            end;
         else
            append (construct_Call,  ")" & NL & "{" & NL);
            append (construct_Call,  ignored_Code);

            if extend_Function /= ""
            then   -- The function makes its object with 'new'. The object is copied, and then deleted.
               append (construct_Call,    "  " & Self.current_lStr & " * made = " & extend_Function & " (" & construct_call_Args & ");" & NL
                                        & "  " & Self.current_lStr & "   the_object (*made);"                                           & NL
                                        & "  delete made;"                                                                             & NL
                                        & "  return the_object;"                                                                       & NL);
            else
               append (construct_Call,  "  return "  &  Self.current_lStr  &  "("  &  construct_call_Args  &  ");"  & NL);
            end if;
            append (construct_Call,  "}" & NL);
         end if;

         if not genComma
         then
            Self.have_default_constructor_Flag := True;
         end if;

         --  new
         --
         declare
            the_Constructor : constant c_Function.view := Self.new_c_Function (doh_Node (the_Node),
                                                                               to_unbounded_String ("construct"),
                                                                               Self.current_c_Class.Namespace.all'Access,
                                                                               is_Destructor  => False,
                                                                               is_Constructor => True);
         begin
            the_Constructor.is_Static          := True;
            the_Constructor.constructor_Symbol := constructor_Symbol;
         end;

         if for_abstract_Class
         then   -- Written once the concrete class is complete (see 'classHandler').
            append (Self.abstract_shim_Functions, construct_Call & NL);

         elsif not (    check_Attribute (the_Node, "access", "protected")
                    or  check_Attribute (the_Node, "access", "private")
                    or  has_hidden_Destructor
                    or  (         Attribute (the_Node, "feature:extend") /= ""     -- A constructor added by '%extend' is not one which
                         and then extend_Function = ""))                           -- C++ can call, so the function of the wrapper is.
         then
            print_to (DOH_Pointer (Self.f_Ada), construct_Call & NL);
         end if;
      end;

      unindent_Log;
      return SWIG_OK;
   end constructorHandler;



   overriding
   function destructorHandler (Self : access Item;
                               N    : in     Node_Pointer) return C.int
   is
      the_Node : doh_Node renames N;

      Status        :          C.int with Unreferenced;
      Storage       : constant String  := Attribute (the_Node, "storage");
      is_Virtual    : constant Boolean := Storage = "virtual";
      is_Overriding :          Boolean := False;

      destruct_Symbol : unbounded_String;     -- The function of the wrapper which destructs an object, where there is one.
      class_cpp_Name  : constant String := (if Self.in_cpp_Mode then +DOH_Pointer (get_Attribute (Self.getCurrentClass, "name")) else "");
   begin
      if not Self.in_cpp_Mode
      then
         --  Likewise a destructor which the interface file adds is the function 'delete_<type>'.
         --
         if         Attribute (the_Node, "feature:extend") /= ""
           and then not Self.c_class_Stack.is_Empty
           and then Self.name_Map_of_c_type.contains (Self.current_c_Class.Name & "*")
           and then Self.name_Map_of_c_type.contains (+"void")
         then
            Self.current_c_Node := doh_Node (the_Node);
            Status              := swigMod.Language.item (Self.all).destructorHandler (the_Node);

            declare
               the_Name     : constant String := "delete_" & to_String (Self.current_c_Class.Name);
               the_Function : constant c_Function.view
                 := c_Function.new_c_Function (+the_Name,
                                               Self.name_Map_of_c_type.Element (+"void"));
            begin
               the_Function.Parameters.append (c_Parameter.new_c_Parameter (the_Name => +"Self",
                                                                            the_Type => Self.name_Map_of_c_type.Element (Self.current_c_Class.Name & "*")));
               the_Function.link_Symbol := +("Ada_" & the_Name);

               Self.current_Module.C.new_c_Functions   .append (the_Function);
               Self.current_Module.C.new_c_Declarations.append (the_Function.all'Access);
            end;
         end if;

         return SWIG_OK;
      end if;

      indent_Log;
      dlog (+"");
      dlog (+"'destructorHandler':");

      if is_Virtual
      then
         Self.current_c_Class.has_virtual_Destructor;
      end if;

      declare
         Bases : constant c_Type.Vector := Self.current_c_Class.base_Classes;
      begin
         for Each of Bases
         loop
            if Each.is_Virtual     -- Only the first virtual base class is the parent.
            then
               is_Overriding := Each.has_virtual_Destructor;
               exit;
            end if;
         end loop;
      end;

      Self.current_c_Node := doh_Node (the_Node);

      if not (   check_Attribute (the_Node, "access", "protected")
              or check_Attribute (the_Node, "access", "private"))
      then
         Status := swigMod.Language.item (Self.all).destructorHandler (the_node);
      end if;

      --  The destructor of a class which is not virtual is called through a function of the wrapper, as its C++
      --  symbol cannot be told from the name of the class alone (that of a template instance or of a class in a
      --  namespace, say). A virtual destructor is imported by its symbol, as it is a primitive of the tagged type.
      --
      if         not Self.current_c_Class.is_Virtual
        and then not is_Virtual
        and then not is_Overriding
        and then not (   check_Attribute (the_Node, "access", "protected")
                      or check_Attribute (the_Node, "access", "private"))
      then
         declare
            the_Class : constant String := +doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (Self.getCurrentClass, "name"))));
         begin
            destruct_Symbol := +("ada_destruct_" & String'(+DOH_Pointer (get_Attribute (Self.getCurrentClass, "name"))));

            for Each in 1 .. Length (destruct_Symbol)
            loop
               if Element (destruct_Symbol, Each) not in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_'
               then
                  replace_Element (destruct_Symbol, Each, '_');
               end if;
            end loop;

            print_to (DOH_Pointer (Self.f_Ada),   "extern ""C"" void " & to_String (destruct_Symbol) & " (" & the_Class & " * self)" & NL
                                                & "{"                                                                              & NL
                                                & "  typedef " & the_Class & " swig_ada_class;"                                    & NL
                                                & "  self->~swig_ada_class ();"                                                    & NL
                                                & "}"                                                                              & NL & NL);
         end;
      end if;

      -- Dummy hack destructor.
      --
      declare
         the_Destructor : constant c_Function.view := Self.new_c_Function (the_Node,
                                                                           to_unbounded_String ("destruct_0"),
                                                                           Self.current_c_Class.Namespace.all'Access,
                                                                           is_Destructor => True,
                                                                           is_Overriding => is_Overriding);
      begin
         the_Destructor.is_Static   := False;
         the_Destructor.is_Virtual  := the_Destructor.is_Virtual or is_Overriding;     -- An implicit destructor is virtual when a base class destructor is.
         the_Destructor.link_Symbol := (if destruct_Symbol /= "" then destruct_Symbol
                                                                 else +cpp_Symbol (class_cpp_Name, Suffix => "D1Ev"));     -- The complete object destructor.
      end;

      declare
         the_Destructor : constant c_Function.view := Self.new_c_Function (the_Node,
                                                                           to_unbounded_String ("destruct"),
                                                                           Self.current_c_Class.Namespace.all'Access,
                                                                           is_Destructor => True,
                                                                           is_Overriding => is_Overriding);
      begin
         the_Destructor.is_Static   := False;
         the_Destructor.is_Virtual  := the_Destructor.is_Virtual or is_Overriding;     -- An implicit destructor is virtual when a base class destructor is.
         the_Destructor.link_Symbol := (if destruct_Symbol /= "" then destruct_Symbol
                                        else +cpp_Symbol (class_cpp_Name, Suffix => (if the_Destructor.is_Virtual then "D0Ev"      -- The deleting destructor.
                                                                                                                  else "D1Ev")));
      end;

      unindent_Log;
      return SWIG_OK;
   end destructorHandler;



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
              and then SwigType_isReference (swig_Type) = 0
            then   -- The wrapper file can ask where the member is.
               new_Variable.member_Name := +Attribute (the_Node, "name");
            end if;

            if swig_Type_is_Array
            then
               Self.add_array_Bounds_to (new_Variable, doh_SwigType (swig_Type));
            end if;

            Self.current_c_Class.add_Component (new_Variable);
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
         new_Variable.is_Pointer       := SwigType_isReference (the_swig_Type) /= 0;
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
               if to_String (new_Variable.my_Type.Name) in "int" | "unsigned int" | "long" | "unsigned long" | "short" | "unsigned short" | "long long" | "unsigned long long"
               then
                  new_Variable.Value := +Image (resolved_c_integer_Expression (Self, +value_Text,
                                                                                     Self.integer_symbol_value_Map,
                                                                                     Self.current_class_namespace_Prefix));

               elsif to_String (new_Variable.my_Type.Name) in "double" | "float"
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
               log (  "Warning: unable to bind the static member variable '" & variable_Name & "' of class '" & class_Name
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
   is
      the_Node          :          doh_Node renames N;
      the_doh_type_Name : constant doh_String    := doh_String (get_Attribute (the_Node, "name"));
   begin
      indent_Log;
      dlog (+"");
      dlog (+"'typedefHandler'   the_doh_type_Name: '" & String'(+the_doh_type_Name) & "'");

      Self.current_c_Node := doh_Node (the_Node);

      if        (         Self.prior_c_Declaration     /= null
                 and then Self.prior_c_Declaration.Name = String'(+the_doh_type_Name))

        or else Self.swig_type_Map_of_c_type.contains (+the_doh_type_Name)
      then
         dlog (+"Skipping typedef.");
      else
         declare
            Name             : constant unbounded_String := +Attribute (the_Node, "name");
            the_type_Name    : constant unbounded_String :=  Name;

            the_doh_swigType : constant SwigType_Pointer :=  SwigType_Pointer (get_Attribute (the_Node, "type"));
            the_swig_Type    : constant swig_Type        := +doh_Item (the_doh_swigType);

            Pad              :          SwigType_Pointer with Unreferenced;
            use type C.int;
         begin
            dlog ("'typedefHandler' - name: '" & Name & "'     swig_Type: '" & to_String (the_swig_Type) & "'");

            if SwigType_isArray (the_doh_swigType) /= 0
            then
               dlog (+"typedef array detected");
               declare
                  swig_Type_copy       : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (the_doh_swigType)));
                  the_Array            : constant SwigType_Pointer := SwigType_pop_Arrays (swig_Type_copy);
                  dimension_Count      : constant C.int            := SwigType_array_nDim (the_Array);
                  element_Type         : constant SwigType_Pointer := SwigType_array_type (swig_Type_copy);
                  array_dimension_Text :          unbounded_String;
                  new_c_Array          :          c_Type.view;
               begin
                  new_c_Array := c_type.new_array_Type (Namespace    => Self.current_c_Namespace,
                                                        Name         => the_type_Name,
                                                        element_Type => Self.demand_c_Type_for (doh_Item (element_Type)));
                  for Each in 1 .. dimension_Count
                  loop
                     array_dimension_Text := +doh_Item (SwigType_array_getdim (the_Array, Each - 1));

                     declare
                        the_Dimension : Integer := 0;     -- A dimension of 0 stands for an unknown length (as in 'typedef char name[];').
                     begin
                        if array_dimension_Text /= ""
                        then
                           begin
                              the_Dimension := Integer (Value (resolved_c_integer_Expression (Self,
                                                                                              array_dimension_Text,
                                                                                              Self.integer_symbol_value_Map,
                                                                                              Self.current_class_namespace_Prefix)));
                           exception
                              when others =>
                                 log (  "Warning: unable to evaluate the array dimension '" & array_dimension_Text & "' of '" & the_type_Name
                                      & "', whose length is taken to be unknown.");
                           end;
                        end if;

                        c_type.add_array_Dimension (new_c_Array,
                                                    upper_Bound => the_Dimension - 1);
                     end;
                  end loop;

                  Self.register (new_c_Array, the_doh_type_Name);
                  Self.prior_c_Declaration := new_c_Array.all'Access;
               end;

            elsif is_a_function_Pointer (doh_Item (the_doh_swigType))
            then
               dlog (+"function pointer found");
               Pad := SwigType_del_pointer (the_doh_swigType);

               declare
                  raw_swigType         : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (the_doh_swigType)));
                  the_Function         : constant SwigType_Pointer := SwigType_pop_Function (raw_swigType);
                  function_return_Type : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (raw_swigType)));
                  function_Parameters  : constant doh_ParmList     := doh_ParmList (SwigType_function_parms (the_Function, the_Node));

                  new_c_Function         : c_Function.view;
                  new_c_function_Pointer : c_Type.view;
               begin
                  new_c_Function            := c_function.new_c_Function   (to_unbounded_String ("anonymous"),
                                                                            Self.swig_type_Map_of_c_type.Element (+doh_Item (function_return_Type)));
                  new_c_function_Pointer    := c_type.new_function_Pointer (Namespace         => Self.current_c_Namespace,
                                                                            Name              => the_type_Name,
                                                                            accessed_Function => new_c_Function);
                  new_c_Function.Parameters := Self.to_c_Parameters (function_Parameters);

                  Self.register (new_c_function_Pointer, the_doh_type_Name);
                  Self.prior_c_Declaration  := new_c_function_Pointer.all'Access;
               end;

            elsif Swigtype_isFunction (the_doh_swigType) /= 0
            then
               dlog (+"typedef function detected");
               declare
                  the_Function          : constant SwigType_Pointer := SwigType_pop_function (the_doh_swigType);
                  function_return_Type  : constant unbounded_String := +doh_Copy (doh_Item   (the_doh_swigType));
                  function_Parameters   : constant doh_ParmList     := doh_ParmList (SwigType_function_Parms (the_Function, the_Node));

                  new_c_Function        : constant c_Function.view  := c_Function.new_c_Function (to_unbounded_String ("anonymous"),
                                                                                                  Self.swig_type_Map_of_c_type.Element (function_return_Type));
                  new_c_typdef_Function :          c_Type.view;
               begin
                  dlog ("function_return_Type: '" & function_return_Type & "'");

                  new_c_Function.Parameters := Self.to_c_Parameters (function_Parameters);
                  new_c_Typdef_function     := c_type.new_typedef_Function (Namespace      => Self.current_c_Namespace,
                                                                            Name           => the_type_Name,
                                                                            typed_Function => new_c_Function);
                  Self.register (new_c_typdef_Function,
                                 the_doh_type_Name,
                                 create_array_Type => False);

                  Self.prior_c_Declaration := new_c_Typdef_function.all'Access;
               end;

            else
               if Self.swig_type_Map_of_c_type.contains (the_swig_Type)
               then
                  dlog ("swig_type_Map_of_c_type.contains " & the_swig_Type);
                  declare
                     the_base_Type : constant c_Type.view := Self.swig_type_Map_of_c_type.Element (the_swig_Type);
                  begin
                     if "_" & the_type_Name = the_swig_Type
                     then
                        Self.register_Mirror (the_Type_Name,
                                              the_base_Type,
                                              doh_SwigType (-the_type_Name));
                        the_base_Type.Name_is (the_type_Name);
                        Self.name_Map_of_c_type.Element (the_base_Type.Name & "[]").Name_is (the_type_Name & "_array");
                     else
                        declare
                           new_c_typeDef : constant c_Type.view := c_Type.new_Typedef (Namespace => Self.current_c_Namespace,
                                                                                       Name      => the_type_Name,
                                                                                       base_Type => the_base_Type);
                        begin
                           if Self.c_class_Stack.is_Empty
                           then   Self.register (new_c_typeDef, the_doh_type_Name);
                           else   Self.register (new_c_typeDef, doh_SwigType (to_Doh (to_String (Self.current_c_Class.Name & "::" & to_String (the_doh_type_Name)))));
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
                        new_c_Class := c_Type.new_opaque_Struct (Namespace => Self.current_c_nameSpace,
                                                                 Name      => the_type_Name);
                        Self.register (new_c_Class, the_doh_type_Name);
                        Self.prior_c_Declaration := new_c_Class.all'Access;
                     end;

                  else   -- Handle case:  'typedef struct foo foo_t;'
                     declare
                        use swigg.Utility;
                        new_c_Class : c_Type.view;
                        class_Name  : doh_swigType := doh_swigType (doh_Copy (doh_Item (-Name)));
                     begin
                        dlog (String' (+class_Name));
                        strip_all_qualifiers (class_Name);
                        dlog (String' (+class_Name));

                        if Self.swig_type_Map_of_c_type.Contains (+class_Name)
                        then
                           new_c_Class := Self.swig_type_Map_of_c_type.Element (+class_Name);
                        else
                           new_c_Class := c_Type.new_opaque_Struct (Namespace => Self.current_c_nameSpace,
                                                                    Name      => +class_Name);
                           Self.register (new_c_Class, doh_SwigType (the_doh_swigType));
                        end if;


                        if "_" & the_type_Name = the_swig_Type
                        then
--                             Self.register_Mirror (the_Type_Name,
--                                                   new_c_Class,
--                                                   doh_Item (-the_type_Name));
--                                                   doh_Item (-("_" & the_type_Name)));
                           new_c_Class.Name_is (the_type_Name);

                           Self.name_Map_of_c_type.Element (new_c_Class.Name & "[]").Name_is (new_c_Class.Name & "_array");
                        else
                           if the_type_Name /= new_c_Class.Name     -- Ignore such as "typedef struct Animal Animal;".
                           then
                              declare
                                 new_c_typeDef : constant c_Type.view := c_Type.new_Typedef (Namespace => Self.current_c_Namespace,
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
   --- Utility
   --

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
   --
   --  Three kinds of member take part in the layout of a class, but are not handed on by the core:
   --
   --    - A bit-field with no name ('unsigned : 2;'). The parser notes each one on the node of the class, by its line,
   --      width and type. It becomes a component with no name of its own, which is given no declaration.
   --
   --    - A member variable which the interface file ignores ('%ignore Sensor::state;'). It becomes a component
   --      named '<member>_storage', as without it every member which follows would be out of place.
   --
   --    - A member whose type is a nested class or union with no name, and the members of an anonymous union,
   --      in C++ (see 'bind_unnamed_nested_Classes'). It becomes a component of the class made for that type.
   --
   --  Those of the class which come before the given member (or all of them, when it is null), and are not yet
   --  components, are added to the current class. 'of_Class' is the node of that class, where the core does not
   --  yet know of it.
   --
   is
      use type C.int;

      type a_Kind is (Ignored, Bits, Nested);

      type hidden_Member is
         record
            Kind     : a_Kind;
            Line     : Integer;
            the_Node : Node_Pointer;         -- The declaration of an ignored member, or the nested class.
            Width    : unbounded_String;
            the_Type : unbounded_String;
            Index    : Natural := 0;
         end record;

      package hidden_Vectors is new ada.Containers.Vectors (Positive, hidden_Member);

      function "<" (Left, Right : in hidden_Member) return Boolean
      is (Left.Line < Right.Line);

      package Sorting is new hidden_Vectors.generic_Sorting;

      the_Class   : constant Node_Pointer := (if of_Class /= null then of_Class else Self.getCurrentClass);
      before_Line : constant Integer      := (if Before = null then Integer'Last else Integer (DohGetline (DOH_Pointer (Before))));
      the_Hidden  :          hidden_Vectors.Vector;
      bits_Used   :          Natural      := 0;
      the_Child   :          Node_Pointer;
   begin
      if the_Class = null
      then
         return;
      end if;

      --  The ignored members, in the order of their declaration, up to the given member.
      --
      the_Child := first_Child (the_Class);

      while the_Child /= null
        and then the_Child /= Before
      loop
         if         Attribute (the_Child, "nodeType") = "cdecl"
           and then Attribute (the_Child, "feature:ignore") /= ""
           and then Attribute (the_Child, "feature:extend")  = ""
           and then Attribute (the_Child, "ada:placed")      = ""
           and then Attribute (the_Child, "name")           /= ""
           and then Attribute (the_Child, "storage") not in "static" | "typedef" | "friend" | "extern"
           and then (        get_Attribute (the_Child, "decl") = null
                     or else SwigType_isfunction (SwigType_Pointer (get_Attribute (the_Child, "decl"))) = 0)
         then
            the_Hidden.append (hidden_Member'(Kind     => Ignored,
                                              Line     => Integer (DohGetline (DOH_Pointer (the_Child))),
                                              the_Node => the_Child,
                                              others   => <>));
         end if;

         the_Child := next_Sibling (the_Child);
      end loop;

      --  The bit-fields with no name, which are known by their lines alone.
      --
      if get_Attribute (the_Class, "anonymous_bitfields") /= null
      then
         for Each of Self.current_c_Class.Components
         loop
            if Each.is_anonymous_Bits
            then
               bits_Used := bits_Used + 1;
            end if;
         end loop;

         declare
            the_Fields : constant doh_List := doh_List (get_Attribute (the_Class, "anonymous_bitfields"));
         begin
            for i in C.int (bits_Used) + 1 .. DohLen (the_Fields)
            loop
               declare
                  the_Field : constant String  := +DohGetitem (the_Fields, i - 1);     -- '<line>|<width>|<type>'
                  Bar_1     : constant Natural := ada.Strings.fixed.Index (the_Field, "|");
                  Bar_2     : constant Natural := ada.Strings.fixed.Index (the_Field, "|", from => Bar_1 + 1);
                  the_Line  : constant Integer := Integer'Value (the_Field (the_Field'First .. Bar_1 - 1));
               begin
                  if the_Line < before_Line
                  then
                     the_Hidden.append (hidden_Member'(Kind     => Bits,
                                                       Line     => the_Line,
                                                       the_Node => null,
                                                       Width    => +the_Field (Bar_1 + 1 .. Bar_2 - 1),
                                                       the_Type => +the_Field (Bar_2 + 1 .. the_Field'Last),
                                                       Index    => Natural (i)));
                  end if;
               end;
            end loop;
         end;
      end if;

      --  The nested classes with no name.
      --
      if get_Attribute (the_Class, "unnamed_nested") /= null
      then
         declare
            the_Nested : constant doh_List := doh_List (get_Attribute (the_Class, "unnamed_nested"));
         begin
            for i in 1 .. DohLen (the_Nested)
            loop
               declare
                  the_Node : constant Node_Pointer := Node_Pointer (DohGetitem (the_Nested, i - 1));
                  the_Line : constant Integer      := Integer'Value (Attribute (the_Node, "unnamed_nested:line"));
               begin
                  if         the_Line < before_Line
                    and then Attribute (the_Node, "ada:placed") = ""
                  then
                     the_Hidden.append (hidden_Member'(Kind     => Nested,
                                                       Line     => the_Line,
                                                       the_Node => the_Node,
                                                       Index    => Natural (i),
                                                       others   => <>));
                  end if;
               end;
            end loop;
         end;
      end if;

      Sorting.sort (the_Hidden);

      for the_Member of the_Hidden
      loop
         case the_Member.Kind
         is
            when Bits =>
               declare
                  new_Variable : constant c_Variable.view
                    := c_Variable.new_c_Variable (+("anonymous_bits_" & ada.Strings.fixed.Trim (Natural'Image (the_Member.Index), ada.Strings.Left)),
                                                  Self.demand_c_Type_for (doh_swigType (to_Doh (to_String (the_Member.the_Type)))));
               begin
                  new_Variable.is_anonymous_Bits := True;
                  new_Variable.bit_Field         := Integer (Value (resolved_c_integer_Expression (Self, the_Member.Width,
                                                                                                         Self.integer_symbol_value_Map,
                                                                                                         Self.current_class_namespace_Prefix)));
                  Self.current_c_Class.add_Component (new_Variable);
               end;

            when Ignored =>
               declare
                  new_Variable : constant c_Variable.view
                    := member_Variable (Self, the_Member.the_Node, Attribute (the_Member.the_Node, "name") & "_storage");
               begin
                  new_Variable.is_ignored_Member := True;
                  set_Attribute (doh_Node (the_Member.the_Node), "ada:placed", "1");
                  Self.current_c_Class.add_Component (new_Variable);
               end;

            when Nested =>
               declare
                  the_type_Name : constant String   := Attribute (the_Member.the_Node, "ada:type_name");
                  the_Declared  : constant doh_List := doh_List (get_Attribute (the_Member.the_Node, "unnamed_nested:members"));
                  new_Variable  :          c_Variable.view;
               begin
                  set_Attribute (doh_Node (the_Member.the_Node), "ada:placed", "1");

                  if        the_type_Name = ""
                    or else not Self.name_Map_of_c_type.contains (+the_type_Name)
                  then
                     Self.current_c_Class.lose_Layout;     -- The class for it could not be made.

                  elsif DohLen (the_Declared) = 0
                  then   -- An anonymous union or structure, whose members C++ takes as members of the outer class.
                     new_Variable := c_Variable.new_c_Variable (+("anonymous_" & ada.Strings.fixed.Trim (Natural'Image (the_Member.Index), ada.Strings.Left)),
                                                                Self.name_Map_of_c_type.Element (+the_type_Name));
                     Self.current_c_Class.add_Component (new_Variable);
                  else
                     for i in 1 .. DohLen (the_Declared)
                     loop
                        declare
                           the_Entry : constant String  := +DohGetitem (the_Declared, i - 1);     -- '<name>|<declarator>'
                           the_Bar   : constant Natural := ada.Strings.fixed.Index (the_Entry, "|");
                           the_Name  : constant String  := the_Entry (the_Entry'First .. the_Bar - 1);
                           the_Decl  : constant String  := the_Entry (the_Bar + 1 .. the_Entry'Last);
                        begin
                           if the_Decl = ""
                           then
                              new_Variable := c_Variable.new_c_Variable (+the_Name, Self.name_Map_of_c_type.Element (+the_type_Name));
                              new_Variable.member_Name := +the_Name;
                              Self.current_c_Class.add_Component (new_Variable);

                           elsif      the_Decl = "p."
                             and then Self.name_Map_of_c_type.contains (+(the_type_Name & "*"))
                           then
                              new_Variable := c_Variable.new_c_Variable (+the_Name, Self.name_Map_of_c_type.Element (+(the_type_Name & "*")));
                              new_Variable.is_class_Pointer := True;
                              new_Variable.member_Name      := +the_Name;
                              Self.current_c_Class.add_Component (new_Variable);

                           elsif      the_Decl'Length > 2
                             and then the_Decl (the_Decl'First .. the_Decl'First + 1) = "a("
                             and then ada.Strings.fixed.Index (the_Decl, "p.") = 0
                             and then Self.name_Map_of_c_type.contains (+(the_type_Name & "[]"))
                           then
                              new_Variable := c_Variable.new_c_Variable (+the_Name, Self.name_Map_of_c_type.Element (+(the_type_Name & "[]")));
                              Self.add_array_Bounds_to (new_Variable, doh_SwigType (to_Doh (the_Decl & the_type_Name)));
                              new_Variable.member_Name := +the_Name;
                              Self.current_c_Class.add_Component (new_Variable);
                           else
                              log (  "Warning: unable to bind the member '" & the_Name & "' of class '" & Self.current_c_Class.Name
                                   & "', whose type is a nested class with no name. The layout of the record does not match that of the class.");
                              Self.current_c_Class.lose_Layout;
                           end if;
                        end;
                     end loop;
                  end if;
               end;
         end case;
      end loop;
   end add_hidden_Members;



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
                        the_Symbol   : unbounded_String := +("ada_base_" & the_cpp_Class & "_" & the_cpp_Base);

                        the_Function : constant c_Function.view
                          := c_Function.new_c_Function (+("as_" & base_Name),
                                                        Self.name_Map_of_c_type.Element (+base_Name & "*"));
                     begin
                        for Each in 1 .. Length (the_Symbol)
                        loop
                           if Element (the_Symbol, Each) not in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_'
                           then
                              replace_Element (the_Symbol, Each, '_');
                           end if;
                        end loop;

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
   --
   --  An abstract class cannot be constructed, and the core gives it no constructor. A class which is derived
   --  from it in Ada needs one all the same, to construct the part of its object which is the abstract class.
   --
   --  The wrapper is therefore given a concrete class which is derived from the abstract class, has each of its
   --  constructors and defines each of its pure virtual functions (which are never called, as Ada replaces the
   --  vtable of the object by that of its own type). A constructor of the abstract class is bound to a function
   --  which constructs an object of the concrete class in the storage it is given.
   --
   is
      use type C.int;
      use type DOH_Pointer;
      use type swig_Module.swig_Module_view;

      the_Abstracts : constant DOH_Pointer := DOH_Pointer (get_Attribute (the_Class, "abstracts"));
      the_Name      : unbounded_String     := +("ada_concrete_" & String'(+DOH_Pointer (get_Attribute (the_Class, "name"))));
      the_cpp_Class : constant String      := (if get_Attribute (the_Class, "name") = null then ""
                                               else +doh_Item (SwigType_namestr (SwigType_Pointer (get_Attribute (the_Class, "name")))));
      the_Functions : unbounded_String;
      has_Constructor : Boolean := False;
      the_Child       : Node_Pointer;
      Status          : C.int with Unreferenced;
   begin
      if        not Self.in_cpp_Mode
        or else the_Abstracts = null
        or else DohLen (the_Abstracts) = 0
        or else Self.current_Module /= Self.Module_top'Access                 -- The wrapper of an imported module is not written here.
        or else get_Attribute (the_Class, "allocate:private_destructor") /= null
        or else get_Attribute (the_Class, "allocate:nonew")              /= null
        or else get_Attribute (the_Class, "feature:notabstract")         /= null     -- The core has given it its constructors.
      then
         return;
      end if;

      for Each in 1 .. Length (the_Name)
      loop
         if Element (the_Name, Each) not in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_'
         then
            replace_Element (the_Name, Each, '_');
         end if;
      end loop;

      --  A definition of each pure virtual function.
      --
      for Each in 0 .. DohLen (the_Abstracts) - 1
      loop
         declare
            the_Function : constant Node_Pointer := Node_Pointer (DohGetitem (the_Abstracts, Each));
         begin
            if Attribute (the_Function, "nodeType") = "destructor"
            then
               return;     -- A pure virtual destructor cannot be defined within a class.
            end if;

            declare
               the_Type  : constant SwigType_Pointer := SwigType_Pointer (doh_Copy (doh_Item (get_Attribute (the_Function, "type"))));
               Name      :          unbounded_String := +Attribute (the_Function, "name");
               the_Decl  :          unbounded_String := +Attribute (the_Function, "decl");
               Qualifier :          unbounded_String;     -- That of the function itself, as in 'int f () const'.
            begin
               strip_Namespaces (Name);

               if Index (the_Decl, "q(") = 1
               then
                  declare
                     Last : constant Natural := Index (the_Decl, ").");
                  begin
                     Qualifier := " " & unbounded_Slice (the_Decl, 3, Last - 1);
                     the_Decl  := unbounded_Slice (the_Decl, Last + 2, Length (the_Decl));
                  end;
               end if;

               SwigType_push (the_Type, to_Doh (to_String (the_Decl)));

               append (the_Functions,   "  virtual " & String'(+doh_Item (SwigType_str (the_Type, const_String (-to_String (Name)))))
                                      & Qualifier & " { abort (); }" & NL);
            end;
         end;
      end loop;

      --  A constructor for each of those of the class.
      --
      Self.abstract_shim_Name         := the_Name;
      Self.abstract_shim_Constructors := null_unbounded_String;
      Self.abstract_shim_Functions    := null_unbounded_String;

      the_Child := first_Child (the_Class);

      while the_Child /= null
      loop
         if         Attribute (the_Child, "nodeType") = "constructor"
           and then get_Attribute (the_Child, "template") = null
         then
            has_Constructor := True;

            if not check_Attribute (the_Child, "access", "private")
            then
               Status := Self.constructorHandler (the_Child);
            end if;
         end if;

         the_Child := next_Sibling (the_Child);
      end loop;

      if not has_Constructor
      then   -- The class has the default constructor which C++ gives it.
         declare
            the_Constructor : constant Node_Pointer := Node_Pointer (DohNewHash);
         begin
            set_Attribute (the_Constructor, "nodeType", "constructor");
            set_Attribute (the_Constructor, "name",     Attribute (the_Class, "sym:name"));
            set_Attribute (the_Constructor, "sym:name", Attribute (the_Class, "sym:name"));
            set_Attribute (the_Constructor, "access",   "public");

            Status := Self.constructorHandler (the_Constructor);
         end;
      end if;

      if Self.abstract_shim_Functions /= ""
      then
         print_to (DOH_Pointer (Self.f_Ada),   "class " & to_String (the_Name) & " : public " & the_cpp_Class & NL
                                             & "{"                                                           & NL
                                             & "public:"                                                     & NL
                                             & to_String (Self.abstract_shim_Constructors)
                                             & to_String (the_Functions)
                                             & "};"                                                          & NL & NL
                                             & to_String (Self.abstract_shim_Functions));
      end if;

      Self.abstract_shim_Name := null_unbounded_String;
   end bind_constructors_of_abstract_Class;



   function cpp_Symbol (qualified_Name : in String;   Suffix : in String) return String
   --
   --  The C++ symbol of an entity with the given name, as swig holds it ('geometry::solid::Box', 'Source<(int)>'),
   --  and the suffix of its kind ('E' for a variable, 'D1Ev' for a destructor). Returns "" where the symbol
   --  cannot be made: the mangling done here covers namespaces and the simpler template arguments only (a
   --  standard type, a class, a pointer or reference to either, and an integer), and no substitutions.
   --
   is
      Unsupported : exception;


      function Image (Count : in Natural) return String
      is (ada.Strings.fixed.Trim (Count'Image, Left));


      function split (Text : in String;   Separator : in String) return String_Vectors.Vector
      --
      --  Splits the text at each separator which is not within the arguments of a template.
      --
      is
         the_Parts : String_Vectors.Vector;
         Depth     : Natural  := 0;
         First     : Positive := Text'First;
         Index     : Positive := Text'First;
      begin
         while Index <= Text'Last
         loop
            if         Index < Text'Last
              and then Text (Index .. Index + 1) = "<("
            then
               Depth := Depth + 1;
               Index := Index + 2;

            elsif      Index < Text'Last
              and then Text (Index .. Index + 1) = ")>"
            then
               Depth := Depth - 1;
               Index := Index + 2;

            elsif      Depth = 0
              and then Index + Separator'Length - 1 <= Text'Last
              and then Text (Index .. Index + Separator'Length - 1) = Separator
            then
               the_Parts.append (Text (First .. Index - 1));
               Index := Index + Separator'Length;
               First := Index;
            else
               Index := Index + 1;
            end if;
         end loop;

         the_Parts.append (Text (First .. Text'Last));
         return the_Parts;
      end split;


      function mangled_Name (Name : in String;   is_Nested : in Boolean) return String;


      function mangled_Type (the_Type : in String) return String
      --
      --  'the_Type' is a swig type, such as 'int', 'p.q(const).char' or 'ns::Thing'.
      --
      is
      begin
         if the_Type'Length > 2 and then the_Type (the_Type'First .. the_Type'First + 1) = "p."
         then
            return "P" & mangled_Type (the_Type (the_Type'First + 2 .. the_Type'Last));

         elsif the_Type'Length > 2 and then the_Type (the_Type'First .. the_Type'First + 1) = "r."
         then
            return "R" & mangled_Type (the_Type (the_Type'First + 2 .. the_Type'Last));

         elsif the_Type'Length > 9 and then the_Type (the_Type'First .. the_Type'First + 8) = "q(const)."
         then
            return "K" & mangled_Type (the_Type (the_Type'First + 9 .. the_Type'Last));

         elsif the_Type = "void"                then   return "v";
         elsif the_Type = "bool"                then   return "b";
         elsif the_Type = "char"                then   return "c";
         elsif the_Type = "signed char"         then   return "a";
         elsif the_Type = "unsigned char"       then   return "h";
         elsif the_Type = "short"               then   return "s";
         elsif the_Type = "unsigned short"      then   return "t";
         elsif the_Type = "int"                 then   return "i";
         elsif the_Type = "unsigned int"        then   return "j";
         elsif the_Type = "long"                then   return "l";
         elsif the_Type = "unsigned long"       then   return "m";
         elsif the_Type = "long long"           then   return "x";
         elsif the_Type = "unsigned long long"  then   return "y";
         elsif the_Type = "float"               then   return "f";
         elsif the_Type = "double"              then   return "d";
         elsif the_Type = "long double"         then   return "e";

         elsif (for all Each of the_Type => Each in '0' .. '9')
         then   -- An integer, which is taken to be an argument of type 'int'.
            return "Li" & the_Type & "E";

         elsif (for some Each of the_Type => Each in ' ' | '.' | '-')
         then
            raise Unsupported;
         else
            return mangled_Name (the_Type, is_Nested => False);
         end if;
      end mangled_Type;


      function mangled_Name (Name : in String;   is_Nested : in Boolean) return String
      --
      --  'is_Nested' is True where the name is already within 'N' and 'E'.
      --
      is
         the_Components : constant String_Vectors.Vector := split (Name, "::");
         the_Result     : unbounded_String;
      begin
         for Each of the_Components
         loop
            declare
               Open     : constant Natural := ada.Strings.fixed.Index (Each, "<(");
               the_Base : constant String  := (if Open = 0 then Each else Each (Each'First .. Open - 1));
            begin
               if        the_Base = ""
                 or else the_Base = "std"
                 or else (for some Char of the_Base => Char not in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_')
               then
                  raise Unsupported;
               end if;

               append (the_Result, Image (the_Base'Length) & the_Base);

               if Open /= 0
               then
                  if Each (Each'Last - 1 .. Each'Last) /= ")>"
                  then
                     raise Unsupported;
                  end if;

                  append (the_Result, "I");

                  for each_Argument of split (Each (Open + 2 .. Each'Last - 2), ",")
                  loop
                     append (the_Result, mangled_Type (each_Argument));
                  end loop;

                  append (the_Result, "E");
               end if;
            end;
         end loop;

         if        is_Nested
           or else Natural (the_Components.Length) = 1
         then
            return to_String (the_Result);
         else
            return "N" & to_String (the_Result) & "E";
         end if;
      end mangled_Name;

   begin
      if qualified_Name = ""
      then
         return "";
      end if;

      return "_ZN" & mangled_Name (qualified_Name, is_Nested => True) & Suffix;

   exception
      when Unsupported | constraint_Error =>
         return "";
   end cpp_Symbol;



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
        or else SwigType_isReference (the_swig_Type) /= 0
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
   is
      use swigg.Utility;
      is_a_new_Type : constant Boolean := not is_core_C_type;
      the_swig_Type : doh_swigType     := doh_Copy (to_swig_Type);

      the_c_type_Pointer         : c_Type.view;
      the_c_type_pointer_Pointer : c_Type.view;

      --  A type is known by its swig type and also, for convenience, by its unqualified name and the names of its
      --  array, pointer and reference types. Two types of different scopes may share such a name (an enumeration
      --  of the same name in each of two classes, say), in which case the name remains that of the first.
      --
      procedure enter_swig_Type (Key : in unbounded_String;   the_Type : in c_Type.view)
      is
      begin
         if not Self.swig_type_Map_of_c_type.contains (Key)
         then
            Self.swig_type_Map_of_c_type.insert (Key, the_Type);
         end if;
      end enter_swig_Type;

      procedure enter_Name (Key : in unbounded_String;   the_Type : in c_Type.view)
      is
      begin
         if not Self.name_Map_of_c_type.contains (Key)
         then
            Self.name_Map_of_c_type.insert (Key, the_Type);
         end if;
      end enter_Name;

   begin
      strip_all_Qualifiers (the_swig_Type);

      if Self.swig_type_Map_of_c_type.Contains (+the_swig_Type)
      then   -- The swig type is already registered (such as by 'typedef struct foo {...} foo;').
         dlog (+"The C type named '" & the_c_Type.Name & "' for swig type '" & to_String (the_swig_Type) & "' is already registered.");
         return;
      end if;

      --  dlog ("");
      --  dlog (+"Registering new C type named '" & the_c_Type.Name & "' for swig type '" & to_String (the_swig_Type) & "'    is a new Type: " & Boolean'Image (is_a_new_Type));

      do_c_Type:
      begin
         enter_swig_Type (+the_swig_Type, the_c_Type);

         if unbounded_String' (+the_swig_Type) /= the_c_Type.Name
         then
            enter_swig_Type (the_c_Type.Name, the_c_Type);
         end if;

         enter_Name (the_c_Type.Name, the_c_Type);

         if is_a_new_Type
         then
            Self.add_new_c_Type (the_c_Type);
         end if;
      end do_c_Type;


      do_level_1_indirection:
      begin
         if create_array_Type
         then   -- Add associated array.
            declare
               array_swigType   : constant doh_swigType := doh_swigType (to_DOH ("a." & (+the_swig_Type)));
               the_c_type_Array :          c_Type.view;
            begin
               the_c_type_Array := c_type.new_array_Type (the_c_Type.nameSpace,
                                                          the_c_Type.Name & "[]",
                                                          element_Type => the_c_Type);

               --  dlog ("Adding C array   type for swig type '" &  to_String (array_swigType) & "'    C array name is '" & (+the_c_type_Array.qualified_Name) & "'");

               the_c_type_Array.add_array_Dimension;

               enter_swig_Type (+array_swigType, the_c_type_Array);

               if unbounded_String'(+the_swig_Type) /= the_c_Type.Name
               then
                  enter_swig_Type ("a." & the_c_Type.Name, the_c_Type_Array);
               end if;

               enter_Name (the_c_type_Array.Name, the_c_type_Array);

               if is_a_new_Type
               then
                  Self.add_new_c_Type (the_c_type_Array);
               end if;
            end;
         end if;

         declare   -- Add associated pointer.
            pointer_swigType : constant doh_swigType := doh_swigType (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type))));
         begin
            the_c_type_Pointer := c_type.new_type_Pointer (the_c_Type.nameSpace,
                                                           the_c_Type.Name & "*",
                                                           accessed_Type => the_c_Type);

            --  dlog ("Adding C pointer type for swig type '" &  to_String (pointer_swigType) & "'    C pointer name is '" & (+the_c_type_Pointer.qualified_Name) & "'");

            enter_swig_Type (+pointer_swigType, the_c_type_Pointer);

            if unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               enter_swig_Type ("p." & the_c_Type.Name, the_c_Type_Pointer);
            end if;

            enter_Name (the_c_type_Pointer.Name, the_c_type_Pointer);

            declare   -- Register pointer to 'const'.
               the_pointer_to_const_swigType : constant doh_swigType
                 := doh_swigType (swigtype_add_Pointer (swigtype_add_Qualifier (SwigType_Pointer (doh_copy (the_swig_Type)),
                                                                               const_String (to_Doh ("const")))));
               the_c_pointer_to_const_Name   : constant unbounded_String := "const " & the_c_Type.Name & "*";
            begin
               enter_swig_Type (+the_pointer_to_const_swigType, the_c_type_Pointer);

               if unbounded_String'(+the_swig_Type) /= the_c_Type.Name
               then
                  enter_swig_Type ("p.q(const)." & the_c_Type.Name, the_c_Type_Pointer);
               end if;

               enter_Name (the_c_pointer_to_const_Name, the_c_type_Pointer);
            end;

            if is_a_new_Type
            then
               Self.add_new_c_Type (the_c_type_Pointer);
            end if;
         end;

         declare   -- Add associated reference.
            reference_swigType : constant doh_swigType := doh_swigType (SwigType_add_reference (SwigType_Pointer (doh_copy (the_swig_Type))));
         begin
            enter_swig_Type (+reference_swigType, the_c_type_Pointer);

            if unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               enter_swig_Type ("r." & the_c_Type.Name, the_c_Type_Pointer);
            end if;

            enter_Name (the_c_type.Name & "&", the_c_type_Pointer);

            declare   -- Register reference to 'const'.
               the_reference_to_const_swigType : constant doh_swigType
                 := doh_swigType (SwigType_add_reference (swigtype_add_Qualifier (SwigType_Pointer (doh_copy (the_swig_Type)),
                                                                                 const_String (to_Doh ("const")))));
               the_c_reference_to_const_Name   : constant unbounded_String := "const " & the_c_Type.Name & "&";
            begin
               enter_swig_Type (+the_reference_to_const_swigType, the_c_type_Pointer);

               if unbounded_String'(+the_swig_Type) /= the_c_Type.Name
               then
                  enter_swig_Type ("r.q(const)." & the_c_Type.Name & "&", the_c_type_Pointer);
               end if;

               enter_Name (the_c_reference_to_const_Name, the_c_type_Pointer);
            end;
         end;
      end do_level_1_indirection;


      do_level_2_indirection:
      begin
         declare
            array_of_pointers_swigType : constant doh_swigType
              := doh_SwigType (to_DOH ("a." & (+doh_Item (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type)))))));
            the_c_type_pointer_Array   : c_Type.view;
         begin
            the_c_type_pointer_Array := c_type.new_array_Type (the_c_Type.nameSpace,
                                                               the_c_Type.Name & "*[]",
                                                               element_Type => the_c_type_Pointer);
            the_c_type_pointer_Array.add_array_Dimension;

            enter_swig_Type (+array_of_pointers_swigType, the_c_type_pointer_Array);

            if unbounded_String' (+the_swig_Type) /= the_c_Type.Name
            then
               enter_swig_Type ("a.p." & the_c_Type.Name, the_c_type_pointer_Array);
            end if;

            enter_Name (the_c_type_pointer_Array.Name, the_c_type_pointer_Array);

            if is_a_new_Type
            then
               Self.add_new_c_Type (the_c_type_pointer_Array);
            end if;
         end;

         the_c_type_pointer_Pointer := c_type.new_type_Pointer (the_c_Type.nameSpace,
                                                                the_c_Type.Name & "**",
                                                                accessed_Type => the_c_type_Pointer);

         declare   -- Add pointer pointer.
            pointer_to_pointer_swigType : constant doh_swigType
              := doh_SwigType (swigtype_add_Pointer (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type)))));
         begin
            enter_swig_Type (+pointer_to_pointer_swigType, the_c_type_pointer_Pointer);

            if unbounded_String' (+the_swig_Type) /= the_c_Type.Name
            then
               enter_swig_Type ("p.p." & the_c_Type.Name, the_c_type_pointer_Pointer);
            end if;

            enter_swig_Type ("r.p." & the_c_Type.Name, the_c_type_pointer_Pointer);     -- A reference to a pointer is passed as a pointer to it.

            enter_Name (the_c_type_pointer_Pointer.Name, the_c_type_pointer_Pointer);
         end;


         declare   -- Register pointer pointer to 'const'.
            the_pointer_to_pointer_to_const_swigType : constant doh_swigType
              := doh_SwigType (swigtype_add_Pointer (swigtype_add_Pointer (swigtype_add_Qualifier (SwigType_Pointer (doh_copy (the_swig_Type)),
                                                                                                  const_String (to_Doh ("const"))))));
            the_c_pointer_to_pointer_to_const_Name   : constant unbounded_String   := "const " & the_c_Type.Name & "**";
         begin
            enter_swig_Type (+the_pointer_to_pointer_to_const_swigType, the_c_type_pointer_Pointer);

            if unbounded_String'(+the_swig_Type) /= the_c_Type.Name
            then
               enter_swig_Type ("p.p.q(const)." & the_c_Type.Name, the_c_type_pointer_Pointer);
            end if;

            enter_Name (the_c_pointer_to_pointer_to_const_Name, the_c_type_pointer_Pointer);
         end;

         if is_a_new_Type
         then
            Self.add_new_c_Type (the_c_type_pointer_Pointer);
         end if;
      end do_level_2_indirection;


      if add_level_3_Indirection
      then
         do_level_3_indirection:
         declare
            the_c_type_pointer_pointer_Pointer : constant c_Type.view := c_type.new_type_Pointer (the_c_Type.nameSpace,
                                                                                                  the_c_Type.Name & "***",
                                                                                                  accessed_Type => the_c_type_pointer_Pointer);
         begin
            declare
               array_of_pointer_pointers_swigType : constant doh_swigType
                 := doh_SwigType (to_DOH ("a." & (+doh_Item (swigtype_add_Pointer (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type))))))));
               the_c_type_pointer_pointer_Array   : c_Type.view;
            begin
               --  dlog (+"array_of_pointer_pointers_swigType: '" & String'(+array_of_pointer_pointers_swigType) & "'");

               the_c_type_pointer_pointer_Array := c_type.new_array_Type (the_c_Type.nameSpace,
                                                                          the_c_Type.Name & "**[]",
                                                                          element_Type => the_c_type_pointer_Pointer);
               the_c_type_pointer_pointer_Array.add_array_Dimension;

               enter_swig_Type (+array_of_pointer_pointers_swigType, the_c_type_pointer_pointer_Array);

               if unbounded_String' (+the_swig_Type) /= the_c_Type.Name
               then
                  enter_swig_Type ("a.p.p" & the_c_Type.Name, the_c_type_pointer_pointer_Array);
               end if;

               enter_Name (the_c_type_pointer_pointer_Array.Name, the_c_type_pointer_pointer_Array);

               if is_a_new_Type
               then
                  Self.add_new_c_Type (the_c_type_pointer_pointer_Array);
               end if;
            end;

            declare   -- Add pointer pointer.
               pointer_to_pointer_pointer_swigType : constant doh_swigType
                 := doh_SwigType (swigtype_add_Pointer (swigtype_add_Pointer (swigtype_add_Pointer (SwigType_Pointer (doh_copy (the_swig_Type))))));
            begin
               enter_swig_Type (+pointer_to_pointer_pointer_swigType, the_c_type_pointer_pointer_Pointer);

               if unbounded_String'(+the_swig_Type) /= the_c_Type.Name
               then
                  enter_swig_Type ("p.p.p" & the_c_Type.Name, the_c_type_pointer_pointer_Pointer);
               end if;

               enter_Name (the_c_type_pointer_pointer_Pointer.Name, the_c_type_pointer_pointer_Pointer);
            end;

            if is_a_new_Type
            then
               Self.add_new_c_Type (the_c_type_pointer_pointer_Pointer);
            end if;
         end do_level_3_indirection;
      end if;

   end register;



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
      pragma Unreferenced (arg_num);

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
         return the_Name & "arg_" & Trim (Count'Image, ada.strings.Left);
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
                           new_Parameter.is_Pointer       :=         SwigType_isreference (param_swigType) /= 0
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
   is
      use c_Parameter.Vectors;

      the_swigType    : SwigType_Pointer  := SwigType_Pointer (doh_Copy (doh_Item (get_Attribute (the_Node, "type"))));
      parameter_list  : doh_ParmList      := doh_parmList (get_Attribute (the_Node, "parms"));
      the_Parameters  : c_Parameter.Vector;

      the_return_Type : c_Type.view;

      use type C.int;
      return_by_Reference : constant Boolean := SwigType_isReference (the_swigType) /= 0;
      return_by_Pointer   : constant Boolean := SwigType_isPointer   (the_swigType) /= 0;

   begin
      Self.current_c_Node := the_Node;

      freshen_current_module_Package (Self, the_Node);

      if Attribute (the_Node, "overload:ignore") /= ""
      then
         return null;   -- Wrappers not wanted for some methods where the parameters cannot be overloaded in Ada.
      end if;

      --  The parameters.
      --
      if exists (parameter_list)
      then
         if SwigType_type (SwigType_Pointer (get_Attribute (Node_Pointer (parameter_list), "type"))) = T_VOID
         then
            parameter_list := doh_parmList (next_Sibling (Node_Pointer (parameter_list)));
         end if;
      end if;

      if         not Self.c_class_Stack.is_Empty
        and then     Self.c_class_Stack.last_Element.Name /= "std"
        and then not Self.static_Flag
        and then not is_Constructor
      then -- Add the class 'Self' controlling parameter.
         declare
            self_Parameter : constant c_Parameter.view := new_c_Parameter (the_name => to_unbounded_String ("Self"),
                                                                           the_type => Self.current_c_Class.all'Access);
         begin
            append (the_Parameters, self_Parameter);
         end;
      end if;

      append (the_Parameters, Self.to_c_Parameters (parameter_List));


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
            virtualType : constant doh_swigType := doh_swigType (get_Attribute (the_Node, "virtual:type"));
         begin
            if exists (virtualType)
            then
               the_return_Type := Self.swig_type_Map_of_c_type.Element (+virtualType);
               dlog (+"covariant return types not supported in Ada ... proxy method will return "
                    & String'(+doh_Item (SwigType_str (SwigType_Pointer (virtualType), null))));     -- TODO: ?
            else
               strip_all_Qualifiers (doh_Item (the_swigType));

               if         Self.accessor_member_Name /= ""
                 and then SwigType_isArray (the_swigType) /= 0
               then   -- The function which returns a member which is an array returns a pointer to its first element.
                  declare
                     element_Type : unbounded_String := +doh_Item (the_swigType);
                  begin
                     while Index (element_Type, "a(") = 1
                     loop
                        element_Type := unbounded_Slice (element_Type, Index (element_Type, ").") + 2, Length (element_Type));
                     end loop;

                     the_return_Type := Self.demand_c_Type_for (doh_swigType (to_Doh ("p." & to_String (element_Type))));
                  end;
               else
                  the_return_Type := Self.demand_c_Type_for (doh_Item (the_swigType));
               end if;
            end if;
         end;
      end if;

      --  A type which C++ constructs is not returned, but replaces an object of the caller (see 'functionWrapper').
      --
      if         Self.in_cpp_Mode
        and then not is_Constructor
        and then not is_Destructor
        and then returns_a_cpp_constructed_Type (Self, the_Node)
        and then Self.name_Map_of_c_type.contains (the_return_Type.Name & "*")
      then
         declare
            result_Parameter : constant c_Parameter.view := new_c_Parameter (the_Name => to_unbounded_String ("Result"),
                                                                             the_Type => Self.name_Map_of_c_type.Element (the_return_Type.Name & "*"));
         begin
            result_Parameter.is_Pointer := True;
            append (the_Parameters, result_Parameter);
         end;

         the_return_Type := Self.swig_type_Map_of_c_type.Element (+"void");
      end if;


      if not (        Self.wrapping_member_Flag
              and not Self.enum_constant_Flag)
      then     -- There is no need for setter/getter functions, since the actual memeber variables are available.
         declare
            use c_nameSpace,
                c_Function;
            new_Function : constant c_Function.view := new_c_Function (function_Name,
                                                                       the_return_Type);
         begin
            new_Function.Parameters     := the_Parameters;
            new_Function.is_Overriding  := is_Overriding;
            new_Function.is_Constructor := is_Constructor;
            new_Function.is_Destructor  := is_Destructor;

            if is_Constructor
            then
               new_Function.link_Symbol := Self.current_linkage_Symbol;
            else
               new_Function.link_Symbol := Self.current_linkage_Symbol;
            end if;

            new_Function.returns_an_Access := return_by_Reference or return_by_Pointer;

            if    check_Attribute (the_Node, "access", "public")
            then
               new_Function.access_Mode := public_Access;

            elsif check_Attribute (the_Node, "access", "protected")
            then
               new_Function.access_Mode := protected_Access;

            elsif check_Attribute (the_Node, "access", "private")
            then
               new_Function.access_Mode := private_Access;

            else
               new_Function.access_Mode := unknown;
            end if;

            if nameSpace = Self.nameSpace_std
            then
               new_Function.is_Static   := True;
            else
               new_Function.is_Static   := Self.static_Flag;
               new_Function.is_Virtual  :=          check_Attribute (the_Node, "storage",  "virtual")
                                           and then C."=" (Self.is_smart_Pointer, 0);     -- A function of the class which a smart pointer points to
                                                                                          -- is no virtual function of the smart pointer.
               new_Function.is_Abstract := check_Attribute (the_Node, "abstract", "1");
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

                  log (  "Warning: unable to evaluate the array dimension '" & array_dimension_Expression & "' of '" & the_Variable.Name
                       & "', whose length is taken to be unknown.");
            end;
         end if;

         append (the_Variable.array_Bounds, resolved_array_Dimension - 1);
      end loop;
   end add_array_Bounds_to;


end ada_Language;
