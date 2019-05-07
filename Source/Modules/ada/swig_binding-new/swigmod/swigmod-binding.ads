-- This file is generated by SWIG. Please do *not* modify by hand.
--
with DOHs.Pointers;
with DOHs.const_String_or_char_ptr;
with interfaces.c;
with interfaces.c.strings;
with swig;
with swig.pointers;
with swigg_module.Pointers;
with swigg_module.Wrapper;
with swigmod.Language;
with interfaces.C;

package swigmod.Binding is

   procedure SWIG_typemap_lang (arg_1 : in interfaces.c.strings.chars_ptr);

   procedure emit_parameter_variables
     (l : in swigg_module.Pointers.ParmList_Pointer;
      f : in swigg_module.Wrapper.Pointer);

   procedure emit_return_variable (n : in swigg_module.Pointers.Node_Pointer;
      rt : in swigg_module.Pointers.SwigType_Pointer;
      f                              : in swigg_module.Wrapper.Pointer);

   procedure SWIG_exit (arg_1 : in interfaces.c.int);

   procedure SWIG_config_file (arg_1 : in DOHs.const_String_or_char_ptr.Item);

   function SWIG_output_directory return swigg_module.Pointers.String_Pointer;

   procedure SWIG_config_cppext (ext : in interfaces.c.strings.chars_ptr);

   procedure Swig_print_xml (obj : in swigg_module.Pointers.Node_Pointer;
      filename                   : in swigg_module.Pointers.String_Pointer);

   function SWIG_output_files return swigg_module.Pointers.List_Pointer;

   procedure SWIG_library_directory
     (arg_1 : in interfaces.c.strings.chars_ptr);

   function emit_num_arguments
     (arg_1 : in swigg_module.Pointers.ParmList_Pointer) return interfaces.c
     .int;

   function emit_num_required
     (arg_1 : in swigg_module.Pointers.ParmList_Pointer) return interfaces.c
     .int;

   function emit_isvarargs
     (p : in swigg_module.Pointers.ParmList_Pointer) return interfaces.c.int;

   function emit_isvarargs_function
     (n : in swigg_module.Pointers.Node_Pointer) return swig.bool;

   procedure emit_attach_parmmaps
     (arg_1 : in swigg_module.Pointers.ParmList_Pointer;
      f     : in swigg_module.Wrapper.Pointer);

   procedure emit_mark_varargs (l : in swigg_module.Pointers.ParmList_Pointer);

   function emit_action
     (n : in swigg_module.Pointers.Node_Pointer) return swigg_module.Pointers
     .String_Pointer;

   function emit_action_code (n : in swigg_module.Pointers.Node_Pointer;
      wrappercode               : in swigg_module.Pointers.String_Pointer;
      action : in swigg_module.Pointers.String_Pointer) return interfaces.c
     .int;

   procedure Swig_overload_check (n : in swigg_module.Pointers.Node_Pointer);

   function Swig_overload_dispatch (n : in swigg_module.Pointers.Node_Pointer;
      fmt                             : in DOHs.const_String_or_char_ptr.Item;
      arg_1                           : in swig.pointers.int_Pointer;
      fmt_fastdispatch                : in DOHs.const_String_or_char_ptr.Item)
      return swigg_module.Pointers.String_Pointer;

   function Swig_overload_dispatch (n : in swigg_module.Pointers.Node_Pointer;
      fmt                             : in DOHs.const_String_or_char_ptr.Item;
      arg_1 : in swig.pointers.int_Pointer) return swigg_module.Pointers
     .String_Pointer;

   function Swig_overload_dispatch_cast
     (n     : in swigg_module.Pointers.Node_Pointer;
      fmt   : in DOHs.const_String_or_char_ptr.Item;
      arg_1 : in swig.pointers.int_Pointer) return swigg_module.Pointers
     .String_Pointer;

   function Swig_overload_rank (n : in swigg_module.Pointers.Node_Pointer;
      script_lang_wrapping        : in swig.bool) return swigg_module.Pointers
     .List_Pointer;

   function cplus_value_type
     (t : in swigg_module.Pointers.SwigType_Pointer)
      return swigg_module.Pointers.SwigType_Pointer;

   function Swig_csuperclass_call
     (base   : in swigg_module.Pointers.String_Pointer;
      method : in swigg_module.Pointers.String_Pointer;
      l      : in swigg_module.Pointers.ParmList_Pointer)
      return swigg_module.Pointers.String_Pointer;

   function Swig_class_declaration (n : in swigg_module.Pointers.Node_Pointer;
      name : in swigg_module.Pointers.String_Pointer)
      return swigg_module.Pointers.String_Pointer;

   function Swig_class_name
     (n : in swigg_module.Pointers.Node_Pointer) return swigg_module.Pointers
     .String_Pointer;

   function Swig_method_call (name : in DOHs.const_String_or_char_ptr.Item;
      parms                        : in swigg_module.Pointers.ParmList_Pointer)
      return swigg_module.Pointers.String_Pointer;

   function Swig_method_decl
     (return_base_type : in swigg_module.Pointers.SwigType_Pointer;
      decl             : in swigg_module.Pointers.SwigType_Pointer;
      id               : in DOHs.const_String_or_char_ptr.Item;
      args             : in swigg_module.Pointers.List_Pointer;
      default_args     : in interfaces.c.int) return swigg_module.Pointers
     .String_Pointer;

   function Swig_director_declaration
     (n : in swigg_module.Pointers.Node_Pointer) return swigg_module.Pointers
     .String_Pointer;

   procedure Swig_director_emit_dynamic_cast
     (n : in swigg_module.Pointers.Node_Pointer;
      f : in swigg_module.Wrapper.Pointer);

   procedure Swig_director_parms_fixup
     (parms : in swigg_module.Pointers.ParmList_Pointer);

   function is_public
     (n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function is_private
     (n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function is_protected
     (n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function is_member_director
     (parentnode : in swigg_module.Pointers.Node_Pointer;
      member : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function is_member_director
     (member : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function is_non_virtual_protected_access
     (n : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   procedure Wrapper_virtual_elimination_mode_set
     (arg_1 : in interfaces.c.int);

   procedure Wrapper_fast_dispatch_mode_set (arg_1 : in interfaces.c.int);

   procedure Wrapper_cast_dispatch_mode_set (arg_1 : in interfaces.c.int);

   procedure Wrapper_naturalvar_mode_set (arg_1 : in interfaces.c.int);

   procedure clean_overloaded (n : in swigg_module.Pointers.Node_Pointer);

   function Swig_to_string (object : in DOHs.Pointers.DOH_Pointer;
      count : in interfaces.c.int) return interfaces.c.strings.chars_ptr;

   function Swig_to_string_with_location
     (object : in DOHs.Pointers.DOH_Pointer;
      count  : in interfaces.c.int) return interfaces.c.strings.chars_ptr;

   procedure Swig_contracts (n : in swigg_module.Pointers.Node_Pointer);

   procedure Swig_contract_mode_set (flag : in interfaces.c.int);

   function Swig_contract_mode_get return interfaces.c.int;

   procedure Swig_browser (n : in swigg_module.Pointers.Node_Pointer;
      arg_1                  : in interfaces.c.int);

   procedure Swig_default_allocators
     (n : in swigg_module.Pointers.Node_Pointer);

   procedure Swig_process_types (n : in swigg_module.Pointers.Node_Pointer);

   procedure Swig_nested_process_classes
     (n : in swigg_module.Pointers.Node_Pointer);

   procedure Swig_nested_name_unnamed_c_structs
     (n : in swigg_module.Pointers.Node_Pointer);

   procedure Swig_interface_feature_enable;

   procedure Swig_interface_propagate_methods
     (n : in swigg_module.Pointers.Node_Pointer);

   procedure exit_with_Fail;

   procedure do_base_top (Self : in swigmod.Language.Pointer;
      node                     : in swigg_module.Pointers.Node_Pointer);

private

   pragma Import (C, SWIG_typemap_lang, "Ada_SWIG_typemap_lang");
   pragma Import (C, emit_parameter_variables, "Ada_emit_parameter_variables");
   pragma Import (C, emit_return_variable, "Ada_emit_return_variable");
   pragma Import (C, SWIG_exit, "Ada_SWIG_exit");
   pragma Import (C, SWIG_config_file, "Ada_SWIG_config_file");
   pragma Import (C, SWIG_output_directory, "Ada_SWIG_output_directory");
   pragma Import (C, SWIG_config_cppext, "Ada_SWIG_config_cppext");
   pragma Import (C, Swig_print_xml, "Ada_Swig_print_xml");
   pragma Import (C, SWIG_output_files, "Ada_SWIG_output_files");
   pragma Import (C, SWIG_library_directory, "Ada_SWIG_library_directory");
   pragma Import (C, emit_num_arguments, "Ada_emit_num_arguments");
   pragma Import (C, emit_num_required, "Ada_emit_num_required");
   pragma Import (C, emit_isvarargs, "Ada_emit_isvarargs");
   pragma Import (C, emit_isvarargs_function, "Ada_emit_isvarargs_function");
   pragma Import (C, emit_attach_parmmaps, "Ada_emit_attach_parmmaps");
   pragma Import (C, emit_mark_varargs, "Ada_emit_mark_varargs");
   pragma Import (C, emit_action, "Ada_emit_action");
   pragma Import (C, emit_action_code, "Ada_emit_action_code");
   pragma Import (C, Swig_overload_check, "Ada_Swig_overload_check");

   function Swig_overload_dispatch_v1
     (n                : in swigg_module.Pointers.Node_Pointer;
      fmt              : in DOHs.const_String_or_char_ptr.Item;
      arg_1            : in swig.pointers.int_Pointer;
      fmt_fastdispatch : in DOHs.const_String_or_char_ptr.Item)
      return swigg_module.Pointers.String_Pointer;

   function Swig_overload_dispatch (n : in swigg_module.Pointers.Node_Pointer;
      fmt                             : in DOHs.const_String_or_char_ptr.Item;
      arg_1                           : in swig.pointers.int_Pointer;
      fmt_fastdispatch                : in DOHs.const_String_or_char_ptr.Item)
      return swigg_module.Pointers.String_Pointer renames
     Swig_overload_dispatch_v1;

   pragma Import (C, Swig_overload_dispatch_v1,
      "Ada_Swig_overload_dispatch__SWIG_0");

   function Swig_overload_dispatch_v2
     (n     : in swigg_module.Pointers.Node_Pointer;
      fmt   : in DOHs.const_String_or_char_ptr.Item;
      arg_1 : in swig.pointers.int_Pointer) return swigg_module.Pointers
     .String_Pointer;

   function Swig_overload_dispatch (n : in swigg_module.Pointers.Node_Pointer;
      fmt                             : in DOHs.const_String_or_char_ptr.Item;
      arg_1 : in swig.pointers.int_Pointer) return swigg_module.Pointers
     .String_Pointer renames
     Swig_overload_dispatch_v2;

   pragma Import (C, Swig_overload_dispatch_v2,
      "Ada_Swig_overload_dispatch__SWIG_1");
   pragma Import (C, Swig_overload_dispatch_cast,
      "Ada_Swig_overload_dispatch_cast");
   pragma Import (C, Swig_overload_rank, "Ada_Swig_overload_rank");
   pragma Import (C, cplus_value_type, "Ada_cplus_value_type");
   pragma Import (C, Swig_csuperclass_call, "Ada_Swig_csuperclass_call");
   pragma Import (C, Swig_class_declaration, "Ada_Swig_class_declaration");
   pragma Import (C, Swig_class_name, "Ada_Swig_class_name");
   pragma Import (C, Swig_method_call, "Ada_Swig_method_call");
   pragma Import (C, Swig_method_decl, "Ada_Swig_method_decl");
   pragma Import (C, Swig_director_declaration,
      "Ada_Swig_director_declaration");
   pragma Import (C, Swig_director_emit_dynamic_cast,
      "Ada_Swig_director_emit_dynamic_cast");
   pragma Import (C, Swig_director_parms_fixup,
      "Ada_Swig_director_parms_fixup");
   pragma Import (C, is_public, "Ada_is_public");
   pragma Import (C, is_private, "Ada_is_private");
   pragma Import (C, is_protected, "Ada_is_protected");

   function is_member_director_v1
     (parentnode : in swigg_module.Pointers.Node_Pointer;
      member : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function is_member_director
     (parentnode : in swigg_module.Pointers.Node_Pointer;
      member     : in swigg_module.Pointers.Node_Pointer) return interfaces.c
     .int renames
     is_member_director_v1;

   pragma Import (C, is_member_director_v1, "Ada_is_member_director__SWIG_0");

   function is_member_director_v2
     (member : in swigg_module.Pointers.Node_Pointer) return interfaces.c.int;

   function is_member_director
     (member : in swigg_module.Pointers.Node_Pointer) return interfaces.c
     .int renames
     is_member_director_v2;

   pragma Import (C, is_member_director_v2, "Ada_is_member_director__SWIG_1");
   pragma Import (C, is_non_virtual_protected_access,
      "Ada_is_non_virtual_protected_access");
   pragma Import (C, Wrapper_virtual_elimination_mode_set,
      "Ada_Wrapper_virtual_elimination_mode_set");
   pragma Import (C, Wrapper_fast_dispatch_mode_set,
      "Ada_Wrapper_fast_dispatch_mode_set");
   pragma Import (C, Wrapper_cast_dispatch_mode_set,
      "Ada_Wrapper_cast_dispatch_mode_set");
   pragma Import (C, Wrapper_naturalvar_mode_set,
      "Ada_Wrapper_naturalvar_mode_set");
   pragma Import (C, clean_overloaded, "Ada_clean_overloaded");
   pragma Import (C, Swig_to_string, "Ada_Swig_to_string");
   pragma Import (C, Swig_to_string_with_location,
      "Ada_Swig_to_string_with_location");
   pragma Import (C, Swig_contracts, "Ada_Swig_contracts");
   pragma Import (C, Swig_contract_mode_set, "Ada_Swig_contract_mode_set");
   pragma Import (C, Swig_contract_mode_get, "Ada_Swig_contract_mode_get");
   pragma Import (C, Swig_browser, "Ada_Swig_browser");
   pragma Import (C, Swig_default_allocators, "Ada_Swig_default_allocators");
   pragma Import (C, Swig_process_types, "Ada_Swig_process_types");
   pragma Import (C, Swig_nested_process_classes,
      "Ada_Swig_nested_process_classes");
   pragma Import (C, Swig_nested_name_unnamed_c_structs,
      "Ada_Swig_nested_name_unnamed_c_structs");
   pragma Import (C, Swig_interface_feature_enable,
      "Ada_Swig_interface_feature_enable");
   pragma Import (C, Swig_interface_propagate_methods,
      "Ada_Swig_interface_propagate_methods");
   pragma Import (C, exit_with_Fail, "Ada_exit_with_Fail");
   pragma Import (C, do_base_top, "Ada_do_base_top");

end swigmod.Binding;
