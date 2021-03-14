with
     lace.Environ,
     ada.Strings.fixed,
     ada.Text_IO;


procedure launch_testsuite
is
   use lace.Environ,
       ada.Strings.fixed,
       ada.Text_IO;

   Error : exception;

   do_C                : Boolean := True;
   do_Cxx              : Boolean := True;
   do_uncompilable_C   : Boolean := True;
   do_uncompilable_Cxx : Boolean := True;
   do_broken_C         : Boolean := True;
   do_broken_Cxx       : Boolean := True;

   abort_on_Error      : Boolean := False;


   procedure generate (swig_Module : in String;
                       use_CPP     : in Boolean := False)
   is
   begin
      put_Line ("Generating swig module '" & swig_Module & "'.");

--        remove_Folder ("./generated");
      verify_Folder ("./generated");
      goto_Folder   ("./generated", lock => False);

      declare
         function cpp_Mode return String
         is
         begin
            if use_CPP then return " -c++ ";
                       else return "";
            end if;
         end cpp_Mode;

         generator_Log : constant String := Output_of (  "../../../../ada-build/swig_ada -outdir .  -ada "
                                                       & cpp_Mode
                                                       & " -I/usr/include   ../../../test-suite/"
                                                       & swig_Module);
      begin
         --           put_Line (generator_Log);
         if Index (generator_Log, "unhandled exception") /= 0
         then
            save (generator_Log, swig_Module & "-generator.log");
         end if;
      end;

      declare
         pretty_Log : constant String := Output_of ("../do_pretty_print.sh");
      begin
         if Index (pretty_Log, "gnatpp: cannot compile") /= 0
         then
--              put_Line (pretty_Log);
            save (pretty_Log, "pretty_print.log");

            if abort_on_Error
            then
               raise Error;
            else
               put_line ("Compile error detected !");
            end if;
         end if;
      end;

      declare
         tidy_Log : String := Output_of ("../do_tidy.sh");
      begin
--           put_Line (tidy_Log);
         null;
      end;

      goto_Folder   ("..", lock => False);
   end generate;


begin
   --------------
   --- Compilable
   --
   if do_C
   then
      -- C Tests
      --
      put_Line ("Generating C tests.");
      new_Line;
      generate ("aggregate.i");
      generate ("allowexcept.i");
      generate ("argout.i");
      generate ("array_member.i");
      --  generate ("bools.i");            -- BoolStructure& operator=(const BoolStructure &); is broken.
      generate ("const_const.i");
      generate ("derived_byvalue.i");
      generate ("empty.i");
      generate ("enum_plus.i");
      generate ("enums.i");
      generate ("enum_var.i");
      generate ("extern_declaration.i");
      generate ("fragments.i");
      generate ("ignore_parameter.i");
      --  generate ("immutable.i");     -- '.i' file is missing.
      generate ("integers.i");
      generate ("keyword_rename.i");
      generate ("langobj.i");
      generate ("lextype.i");
      generate ("li_constraints.i");
      generate ("li_cpointer.i");
      generate ("li_cstring.i");
      generate ("li_cwstring.i");
      generate ("li_math.i");
      generate ("li_stdint.i");
      generate ("long_long.i");
      generate ("multivalue.i");
      generate ("name.i");
      generate ("naturalvar.i");
      --  generate ("nested.i");     -- Crashes swig_ada.
      generate ("null_pointer.i");
      generate ("ordering.i");
      generate ("ret_by_value.i");
      generate ("struct_rename.i");
      generate ("struct_value.i");
      generate ("tag_no_clash_with_variable.i");
      --  generate ("traits.i");     -- '.i' file is missing.
      generate ("typedef_mptr.i");
      generate ("typedef_reference.i");
      generate ("typedef_sizet.i");
      generate ("typemap_numinputs.i");
      generate ("typemap_subst.i");
      generate ("unions.i");
      generate ("wrapmacro.i");
   end if;


   -- C++ Tests
   --
   if do_Cxx
   then
      new_Line;
      new_Line;
      put_Line ("Generating C++ tests.");
      new_Line;

      generate ("abstract_access.i",                use_CPP => True);
      generate ("abstract_inherit.i",               use_CPP => True);
      generate ("abstract_inherit_ok.i",            use_CPP => True);
      generate ("abstract_signature.i",             use_CPP => True);
      generate ("abstract_typedef.i",               use_CPP => True);
      generate ("access_change.i",                  use_CPP => True);
      generate ("cast_operator.i",                  use_CPP => True);
      generate ("casts.i",                          use_CPP => True);
      generate ("clientdata_prop_a.i",              use_CPP => True);
      generate ("compactdefaultargs.i",             use_CPP => True);
      generate ("const_const_2.i",                  use_CPP => True);
      generate ("constover.i",                      use_CPP => True);
      generate ("constructor_copy.i",               use_CPP => True);
      generate ("constructor_exception.i",          use_CPP => True);
      generate ("constructor_explicit.i",           use_CPP => True);
      generate ("constructor_ignore.i",             use_CPP => True);
      generate ("constructor_value.i",              use_CPP => True);
      generate ("conversion.i",                     use_CPP => True);
      generate ("conversion_namespace.i",           use_CPP => True);
      generate ("conversion_ns_template.i",         use_CPP => True);
      generate ("cplusplus_throw.i",                use_CPP => True);
      generate ("cpp_nodefault.i",                  use_CPP => True);
      generate ("cpp_static.i",                     use_CPP => True);
      generate ("default_constructor.i",            use_CPP => True);
      generate ("defvalue_constructor.i",           use_CPP => True);
      --  generate ("derived_nested.i",                 use_CPP => True);     -- Crashes swig_ada.
      generate ("destructor_reprotected.i",         use_CPP => True);
      generate ("disown.i",                         use_CPP => True);
      generate ("enum_template.i",                  use_CPP => True);
      generate ("evil_diamond.i",                   use_CPP => True);
      generate ("evil_diamond_ns.i",                use_CPP => True);
      generate ("evil_diamond_prop.i",              use_CPP => True);
      generate ("exception_order.i",                use_CPP => True);
      generate ("exception_partial_info.i",         use_CPP => True);
      generate ("extend_default.i",                 use_CPP => True);
      generate ("extend.i",                         use_CPP => True);
      generate ("extend_placement.i",               use_CPP => True);
      generate ("extend_template.i",                use_CPP => True);
      generate ("extend_template_ns.i",             use_CPP => True);
      generate ("extend_variable.i",                use_CPP => True);
      generate ("extern_namespace.i",               use_CPP => True);
      generate ("extern_throws.i",                  use_CPP => True);
      generate ("friends.i",                        use_CPP => True);
      generate ("imports_a.i",                      use_CPP => True);
      generate ("inherit.i",                        use_CPP => True);
      generate ("inherit_missing.i",                use_CPP => True);
      generate ("inherit_void_arg.i",               use_CPP => True);
      generate ("inline_initializer.i",             use_CPP => True);
      generate ("member_template.i",                use_CPP => True);
      --  generate ("minherit.i",                       use_CPP => True);     -- Crashes swig_ada.
      generate ("mod_a.i",                          use_CPP => True);
      generate ("multi_import_b.i",                 use_CPP => True);
      generate ("name_cxx.i",                       use_CPP => True);
      generate ("namespace_enum.i",                 use_CPP => True);
      generate ("namespace_extend.i",               use_CPP => True);
      --  generate ("namespace_template.i",             use_CPP => True);     -- Crashes swig_ada.
      generate ("namespace_typedef_class.i",        use_CPP => True);
      generate ("newobject2.i",                     use_CPP => True);
      generate ("operator_overload_break.i",        use_CPP => True);
      generate ("overload_copy.i",                  use_CPP => True);
      --  generate ("overload_extendc.i",               use_CPP => True);     -- Crashes swig_ada.
      generate ("overload_extend.i",                use_CPP => True);
      generate ("overload_rename.i",                use_CPP => True);
      generate ("overload_simple.i",                use_CPP => True);
      generate ("overload_subtype.i",               use_CPP => True);
      generate ("overload_template_fast.i",         use_CPP => True);
      generate ("overload_template.i",              use_CPP => True);
      generate ("packageoption_a.i",                use_CPP => True);
      generate ("packageoption_b.i",                use_CPP => True);
      generate ("profiletest.i",                    use_CPP => True);
      generate ("protected_rename.i",               use_CPP => True);
      generate ("redefined.i",                      use_CPP => True);
      generate ("rename_camel.i",                   use_CPP => True);
      generate ("rename_scope.i",                   use_CPP => True);
      generate ("restrict_cplusplus.i",             use_CPP => True);
      --  generate ("return_const_value.i",             use_CPP => True);     -- Crashes swig_ada.
      --  generate ("smart_pointer_const2.i",           use_CPP => True);     -- Crashes swig_ada.
      --  generate ("smart_pointer_const.i",            use_CPP => True);     -- Crashes swig_ada.
      --  generate ("smart_pointer_extend.i",           use_CPP => True);     -- Crashes swig_ada.
      generate ("smart_pointer_member.i",           use_CPP => True);
      --  generate ("smart_pointer_multi.i",            use_CPP => True);     -- Crashes swig_ada.
      --  generate ("smart_pointer_namespace2.i",       use_CPP => True);     -- Crashes swig_ada.
      --  generate ("smart_pointer_namespace.i",        use_CPP => True);     -- Crashes swig_ada.
      generate ("smart_pointer_not.i",              use_CPP => True);
      --  generate ("smart_pointer_overload.i",         use_CPP => True);     -- Crashes swig_ada.
      --  generate ("smart_pointer_rename.i",           use_CPP => True);     -- Crashes swig_ada.
      --  generate ("smart_pointer_simple.i",           use_CPP => True);     -- Crashes swig_ada.
      --  generate ("smart_pointer_static.i",           use_CPP => True);     -- Crashes swig_ada.
      --  generate ("smart_pointer_typedef.i",          use_CPP => True);     -- Crashes swig_ada.
      generate ("static_array_member.i",            use_CPP => True);
      generate ("static_const_member_2.i",          use_CPP => True);
      generate ("static_const_member.i",            use_CPP => True);
      generate ("sym.i",                            use_CPP => True);
      generate ("template_arg_replace.i",           use_CPP => True);
      generate ("template_array_numeric.i",         use_CPP => True);
      generate ("template_base_template.i",         use_CPP => True);
      generate ("template_construct.i",             use_CPP => True);
      generate ("template_default2.i",              use_CPP => True);
      generate ("template_default_class_parms.i",   use_CPP => True);
      generate ("template_default_qualify.i",       use_CPP => True);
      generate ("template_default_vw.i",            use_CPP => True);
      generate ("template_enum_ns_inherit.i",       use_CPP => True);
      --   generate ("template_expr.i",                  use_CPP => True);     -- Hangs swig_ada.
      generate ("template_extend1.i",               use_CPP => True);
      generate ("template_extend2.i",               use_CPP => True);
      generate ("template_extend_overload_2.i",     use_CPP => True);
      generate ("template_inherit.i",               use_CPP => True);
      generate ("template_int_const.i",             use_CPP => True);
      --  generate ("template_methods.i",               use_CPP => True);     -- Error: Unable to find 'std_string.i'
      generate ("template_ns3.i",                   use_CPP => True);
      generate ("template_ns.i",                    use_CPP => True);
      generate ("template_ns_inherit.i",            use_CPP => True);
      generate ("template_ns_scope.i",              use_CPP => True);
      generate ("template_partial_arg.i",           use_CPP => True);
      generate ("template_qualifier.i",             use_CPP => True);
      generate ("template_ref_type.i",              use_CPP => True);
      generate ("template_rename.i",                use_CPP => True);
      generate ("template_specialization_defarg.i", use_CPP => True);
      generate ("template_specialization.i",        use_CPP => True);
      generate ("template_static.i",                use_CPP => True);
      generate ("template_template_parameters.i",   use_CPP => True);
      generate ("template_typedef_ns.i",            use_CPP => True);
      generate ("template_typedef_ptr.i",           use_CPP => True);
      generate ("template_typedef_rec.i",           use_CPP => True);
      generate ("template_using.i",                 use_CPP => True);
      generate ("template_virtual.i",               use_CPP => True);
      generate ("throw_exception.i",                use_CPP => True);
      --  generate ("typedef_class.i",                  use_CPP => True);     -- Crashes swig_ada.
      generate ("typedef_inherit.i",                use_CPP => True);
      generate ("typemap_self.i",                   use_CPP => True);
      generate ("typemap_variables.i",              use_CPP => True);
      generate ("types_directive.i",                use_CPP => True);
      generate ("union_scope.i",                    use_CPP => True);
      generate ("using_composition.i",              use_CPP => True);
      generate ("using_extend.i",                   use_CPP => True);
      generate ("using_inherit.i",                  use_CPP => True);
      generate ("using_private.i",                  use_CPP => True);
      generate ("using_protected.i",                use_CPP => True);
      generate ("valuewrapper_base.i",              use_CPP => True);
      --  generate ("valuewrapper_const.i",             use_CPP => True);     -- Crashes swig_ada.
      generate ("valuewrapper.i",                   use_CPP => True);
      generate ("varargs.i",                        use_CPP => True);
      generate ("virtual_derivation.i",             use_CPP => True);
      generate ("virtual_destructor.i",             use_CPP => True);
      generate ("voidtest.i",                       use_CPP => True);
   end if;

   ----------------
   --- Uncompilable
   --

   -- C Tests
   --
   if do_uncompilable_C
   then
      new_Line;
      new_Line;
      put_Line ("Generating uncompilable C tests.");
      new_Line;

      generate ("char_constant.i");   -- Fails due to #define SPECIALCHAR 'á'
      generate ("li_carrays.i");
      generate ("li_cmalloc.i");
      generate ("preproc.i");         -- Fails due to #define MASK(shift, size) (((1 << (size)) - 1) <<(shift))
                                      --              #define SOME_MASK_DEF (80*MASK(8, 10))
   end if;


   -- C++ Tests
   --
   if do_uncompilable_Cxx
   then
      new_Line;
      new_Line;
      put_Line ("Generating uncompilable C++ tests.");
      new_Line;

      generate ("abstract_virtual.i",               use_CPP => True);
      generate ("clientdata_prop_b.i",              use_CPP => True);
      generate ("contract.i",                       use_CPP => True);
      generate ("dynamic_cast.i",                   use_CPP => True);
      generate ("features.i",                       use_CPP => True);
      generate ("fvirtual.i",                       use_CPP => True);
      generate ("import_nomodule.i",                use_CPP => True);
      generate ("imports_b.i",                      use_CPP => True);
      generate ("inherit_same_name.i",              use_CPP => True);
      --  generate ("li_attribute.i",                   use_CPP => True);     -- Error: Unable to find 'std_string.i'
      generate ("minherit2.i",                      use_CPP => True);
      generate ("mod_b.i",                          use_CPP => True);
      generate ("multi_import_a.i",                 use_CPP => True);
      --  generate ("namespace_virtual_method.i",       use_CPP => True);     -- Crashes swig_ada.
      generate ("name_warnings.i",                  use_CPP => True);
      generate ("newobject1.i",                     use_CPP => True);
      generate ("operator_overload.i",              use_CPP => True);
      generate ("private_assign.i",                 use_CPP => True);
      generate ("pure_virtual.i",                   use_CPP => True);
      generate ("rname.i",                          use_CPP => True);
      generate ("samename.i",                       use_CPP => True);
      --  generate ("smart_pointer_multi_typedef.i",    use_CPP => True);     -- Crashes swig_ada.
      generate ("smart_pointer_protected.i",        use_CPP => True);
      generate ("template_inherit_abstract.i",      use_CPP => True);
      generate ("template_specialization_enum.i",   use_CPP => True);
      generate ("template_typedef_import.i",        use_CPP => True);
      --  generate ("using_pointers.i",                 use_CPP => True);     -- Crashes swig_ada.
   end if;


   ----------------
   --- Broken Tests
   --

   -- C Tests
   --
   if do_broken_C
   then
      new_Line;
      new_Line;
      put_Line ("Generating broken C tests.");
      new_Line;

      --  generate ("anonymous_bitfield.i");     -- Crashes swig_ada.
      --  generate ("apply_signed_char.i");      -- Error: Directors are not supported for C code and require the -c++ option.
      --  generate ("apply_strings.i");          -- Error: Directors are not supported for C code and require the -c++ option.
      --  generate ("arrayref.i");               -- Crashes swig_ada.
      --  generate ("arrays_dimensionless.i");   -- Crashes swig_ada.
      --  generate ("arrays_global.i");          -- Crashes swig_ada.
      --  generate ("arrays_global_twodim.i");   -- Crashes swig_ada.
      --  generate ("arrays.i");                 -- Crashes swig_ada.
      --  generate ("arrays_scope.i");           -- Crashes swig_ada.
      --  generate ("array_typedef_memberin.i"); -- Crashes swig_ada.
      --  generate ("bloody_hell.i");            -- Crashes swig_ada.
      --  generate ("char_strings.i");           -- Crashes swig_ada.
      --  generate ("class_scope_weird.i");      -- Crashes swig_ada.
      --  generate ("default_args.i");           -- Error: Unable to find 'std_string.i'.
      --  generate ("enum_thorough_typeunsafe.i");   -- Error: Unable to find 'enumtypeunsafe.swg'.
      --  generate ("file_test.i");                  -- Error: Unable to find 'file.i'.
      --  generate ("funcptr.i");                    -- Crashes swig_ada.
      --  generate ("function_typedef.i");           -- Crashes swig_ada.
      --  generate ("global_vars.i");                -- Error: Unable to find 'std_string.i'
      generate ("grouping.i");
      --  generate ("inctest.i");                    -- Crashes swig_ada.
      --  generate ("li_std_map.i");                 -- Error: Unable to find 'std_pair.i'
      --  generate ("li_std_pair.i");                -- Error: Unable to find 'std_pair.i'
      --  generate ("li_std_set.i");                 -- Error: Unable to find 'std_string.i'
      --  generate ("li_std_vector.i");              -- Error: Unable to find 'std_string.i'
      --  generate ("li_std_wstring.i");             -- Error: Unable to find 'std_basic_string.i'
      --  generate ("list_vector.i");                -- Error: Unable to find 'list-vector.i'
      --  generate ("li_typemaps.i");                -- Crashes swig_ada.
      --  generate ("li_windows.i");                 -- Crashes swig_ada.
      --  generate ("long_long_apply.i");            -- Crashes swig_ada.
      generate ("nested_comment.i");
      --  generate ("pointer_in_out.i");             -- Error: Unable to find 'pointer-in-out.i'
      --  generate ("pointer_reference.i");          -- Crashes swig_ada.
      --  generate ("register_par.i");               -- Crashes swig_ada.
      --  generate ("sizeof_pointer.i");             -- Crashes swig_ada.
      --  generate ("sizet.i");                      -- Crashes swig_ada.
      generate ("sneaky1.i");
      --  generate ("special_variables.i");          -- Error: Unable to find 'std_string.i'
      --  generate ("threads.i");                    -- Error: Unable to find 'std_string.i'
      --  generate ("typedef_array_member.i");       -- Crashes swig_ada.
      --  generate ("typedef_funcptr.i");            -- Crashes swig_ada.
      --  generate ("typedef_struct.i");             -- Crashes swig_ada.
   end if;


   -- C++ Tests
   --
   if do_broken_Cxx
   then
      new_Line;
      new_Line;
      put_Line ("Generating broken C++ tests.");
      new_Line;

      generate ("add_link.i",                        use_CPP => True);
      --  generate ("allprotected.i",                    use_CPP => True);     -- Error: Unable to find 'std_string.i'

      --  generate ("abstract_typedef2.i",               use_CPP => True);     -- Crashes swig_ada.
      --  generate ("class_ignore.i",                    use_CPP => True);     -- Crashes swig_ada.
      --  generate ("constant_pointers.i",               use_CPP => True);     -- Crashes swig_ada.
      --  generate ("constants.i",                       use_CPP => True);     -- Crashes swig_ada.
      --  generate ("cpp_basic.i",                       use_CPP => True);     -- Crashes swig_ada.
      --  generate ("cpp_broken.i",                      use_CPP => True);     -- Crashes swig_ada.
      --  generate ("cpp_enum.i",                        use_CPP => True);     -- Crashes swig_ada.
      --  generate ("cpp_namespace.i",                   use_CPP => True);     -- Crashes swig_ada.
      --  generate ("cpp_typedef.i",                     use_CPP => True);     -- Crashes swig_ada.
      --  generate ("enum_scope_template.i",             use_CPP => True);     -- Crashes swig_ada.
      --  generate ("enum_thorough.i",                   use_CPP => True);     -- Crashes swig_ada.
      --  generate ("enum_thorough_proper.i",            use_CPP => True);     -- Crashes swig_ada.
      --  generate ("enum_thorough_simple.i",            use_CPP => True);     -- Crashes swig_ada.
      --  generate ("enum_thorough_typesafe.i",          use_CPP => True);     -- Crashes swig_ada.
      --  generate ("global_ns_arg.i",                   use_CPP => True);     -- Crashes swig_ada.
      --  generate ("ignore_template_constructor.i",     use_CPP => True);     -- Crashes swig_ada.
      --  generate ("inherit_target_language.i",         use_CPP => True);     -- Crashes swig_ada.
      --  generate ("intermediary_classname.i",          use_CPP => True);     -- Crashes swig_ada.
      --  generate ("kind.i",                            use_CPP => True);     -- Crashes swig_ada.
      --  generate ("li_boost_shared_ptr_bits.i",        use_CPP => True);     -- Crashes swig_ada.
      --  generate ("li_boost_shared_ptr.i",             use_CPP => True);     -- Error: Unable to find 'std_string.i'
      --  generate ("li_cdata_carrays.i",                use_CPP => True);     -- Crashes swig_ada.
      --  generate ("li_cdata.i",                        use_CPP => True);     -- Crashes swig_ada.
      --  generate ("li_factory.i",                      use_CPP => True);     -- Error: Unable to find 'factory.i'
      --  generate ("li_implicit.i",                     use_CPP => True);     -- Error: Unable to find 'implicit.i'
      --  generate ("li_std_deque.i",                    use_CPP => True);     -- Error: Unable to find 'std_deque.i'
      --  generate ("li_std_except.i",                   use_CPP => True);     -- Crashes swig_ada.
      --  generate ("li_std_stream.i",                   use_CPP => True);     -- Error: Unable to find 'std_iostream.i'
      --  generate ("li_std_string.i",                   use_CPP => True);     -- Error: Unable to find 'std_string.i'
      --  generate ("memberin1.i",                       use_CPP => True);     -- Crashes swig_ada.
      --  generate ("member_pointer.i",                  use_CPP => True);     -- Crashes swig_ada.
      --  generate ("mixed_types.i",                     use_CPP => True);     -- Crashes swig_ada.
      --  generate ("multi_import_c.i",                  use_CPP => True);     -- No module name specified using %module or -module.
      --  generate ("multiple_inheritance.i",            use_CPP => True);     -- Crashes swig_ada.
      --  generate ("namespace_class.i",                 use_CPP => True);     -- Crashes swig_ada.
      --  generate ("namespace_nested.i",                use_CPP => True);     -- Crashes swig_ada.
      --  generate ("namespace_spaces.i",                use_CPP => True);     -- Crashes swig_ada.
      --  generate ("namespace_typemap.i",               use_CPP => True);     -- Crashes swig_ada.
      generate ("namespace_union.i",                 use_CPP => True);
      --  generate ("overload_complicated.i",            use_CPP => True);     -- Crashes swig_ada.
      --  generate ("primitive_ref.i",                   use_CPP => True);     -- Crashes swig_ada.
      --  generate ("primitive_types.i",                 use_CPP => True);     -- Crashes swig_ada.
      --  generate ("refcount.i",                        use_CPP => True);     -- Crashes swig_ada.
      --  generate ("reference_global_vars.i",           use_CPP => True);     -- Crashes swig_ada.
      --  generate ("rename1.i",                         use_CPP => True);     -- Crashes swig_ada.
      --  generate ("rename2.i",                         use_CPP => True);     -- Crashes swig_ada.
      --  generate ("rename3.i",                         use_CPP => True);     -- Crashes swig_ada.
      --  generate ("rename4.i",                         use_CPP => True);     -- Crashes swig_ada.
      --  generate ("return_value_scope.i",              use_CPP => True);     -- Crashes swig_ada.
      --  generate ("smart_pointer_inherit.i",           use_CPP => True);     -- Crashes swig_ada.
      --  generate ("smart_pointer_templatemethods.i",   use_CPP => True);     -- Crashes swig_ada.
      --  generate ("smart_pointer_templatevariables.i", use_CPP => True);     -- Crashes swig_ada.
      --  generate ("std_containers.i",                  use_CPP => True);     -- Error: Unable to find 'std_string.i'
      --  generate ("template_arg_scope.i",              use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_arg_typename.i",           use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_classes.i",                use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_const_ref.i",              use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_default_arg.i",            use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_default.i",                use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_default_inherit.i",        use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_default_pointer.i",        use_CPP => True);     -- Error: Syntax error in input(1).
      --  generate ("template_enum.i",                   use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_enum_typedef.i",           use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_explicit.i",               use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_extend_overload.i",        use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_forward.i",                use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template.i",                        use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_ns2.i",                    use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_ns4.i",                    use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_ns_enum2.i",               use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_ns_enum.i",                use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_opaque.i",                 use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_retvalue.i",               use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_tbase_template.i",         use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_typedef_cplx2.i",          use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_typedef_cplx3.i",          use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_typedef_cplx4.i",          use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_typedef_cplx5.i",          use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_typedef_cplx.i",           use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_typedef_fnc.i",            use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_typedef_funcptr.i",        use_CPP => True);     -- Error: Unable to find 'std_string.i'
      --  generate ("template_typedef.i",                use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_typemaps.i",               use_CPP => True);     -- Crashes swig_ada.
      --  generate ("template_type_namespace.i",         use_CPP => True);     -- Error: Unable to find 'std_string.i'
      --  generate ("template_whitespace.i",             use_CPP => True);
      --  generate ("typedef_scope.i",                   use_CPP => True);
      --  generate ("typemap_namespace.i",               use_CPP => True);
      --  generate ("typemap_ns_using.i",                use_CPP => True);
      --  generate ("typemap_various.i",                 use_CPP => True);
      --  generate ("typename.i",                        use_CPP => True);
      --  generate ("using1.i",                          use_CPP => True);
      --  generate ("using2.i",                          use_CPP => True);
      --  generate ("using_namespace.i",                 use_CPP => True);
      --  generate ("valuewrapper_opaque.i",             use_CPP => True);
      --  generate ("virtual_poly.i",                    use_CPP => True);
   end if;


   --------
   --- Done
   --
   new_Line;
   put_Line ("Complete.");

exception
   when Error =>
      new_Line;
      put_Line ("Testsuite failed !");
end launch_testsuite;
