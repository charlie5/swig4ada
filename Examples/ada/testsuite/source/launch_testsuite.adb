with
     lace.Environ.Paths,
     ada.Command_Line,
     ada.Containers.indefinite_Vectors,
     ada.Directories,
     ada.Strings.fixed,
     ada.Text_IO,
     gnat.OS_Lib;


procedure launch_testsuite
--
--  Runs the generator over the SWIG test suite and checks, for each case, that
--
--    - the generator ends without an error,
--    - the generated specs have no syntax errors (found by 'gnatpp', which also tidies them),
--    - the generated C or C++ wrapper compiles,
--    - the generated specs compile.
--
--  The specs are compiled once every case has been generated, as a case which imports another
--  module needs the specs of that module. A failure leaves a log in the 'generated' folder,
--  named '<case>-generator.log', '-pretty_print.log', '-wrapper.log' or '-compile.log'.
--
--  It then runs the run-time cases of the 'runtime' folder. Each has a C++ header, an interface file
--  and an Ada tester, which is built with the address sanitizer and run. A failure leaves a log
--  named 'generated/<case>-runtime.log'.
--
is
   use lace.Environ,
       ada.Strings.fixed,
       ada.Text_IO;

   do_C                : constant Boolean := True;
   do_Cxx              : constant Boolean := True;
   do_uncompilable_C   : constant Boolean := True;
   do_uncompilable_Cxx : constant Boolean := True;
   do_broken_C         : constant Boolean := True;
   do_broken_Cxx       : constant Boolean := True;

   check_Wrappers      : constant Boolean := True;     -- Compile each generated wrapper.
   check_Specs         : constant Boolean := True;     -- Compile each generated spec.
   do_Runtime          : constant Boolean := True;     -- Build and run the run-time cases.
   do_Examples         : constant Boolean := True;     -- Build each example of 'Examples/ada' and run its tester.

   Root                : constant String  := "../../../..";     -- The repository root, as seen from the 'generated' folder.


   --  The specs which each case generates, kept for the compile check.
   --
   type a_Case (name_Length, specs_Length : Natural) is
      record
         Name  : String (1 .. name_Length);
         Specs : String (1 .. specs_Length);     -- The file names, separated by spaces.
      end record;

   package case_Vectors is new ada.Containers.indefinite_Vectors (Positive, a_Case);

   the_Cases          : case_Vectors.Vector;

   generator_Failures : Natural := 0;
   syntax_Failures    : Natural := 0;
   wrapper_Failures   : Natural := 0;
   compile_Failures   : Natural := 0;
   runtime_Cases      : Natural := 0;
   runtime_Failures   : Natural := 0;
   example_Count      : Natural := 0;
   example_Failures   : Natural := 0;
   unexpected_Passes  : Natural := 0;



   function run (Command : in String;   Log : in String) return Boolean
   --
   --  Runs the command in a shell, with its output sent to the 'Log' file. Returns True if the command succeeds.
   --
   is
      use gnat.OS_Lib;

      Arguments : Argument_List := [new String'("-c"),
                                    new String'(Command)];
      Success   : Boolean;
      Status    : Integer;
   begin
      Spawn (program_Name => "/bin/sh",
             Args         => Arguments,
             output_File  => Log,
             Success      => Success,
             return_Code  => Status,
             err_to_Out   => True);

      for Each of Arguments
      loop
         Free (Each);
      end loop;

      return Success and then Status = 0;
   end run;



   function Contents (of_File : in String) return String
   is
      use ada.Directories;
      the_File : File_Type;
      Result   : String (1 .. Natural (Size (of_File)));
      Last     : Natural := 0;
   begin
      open (the_File, in_File, of_File);

      while not end_of_File (the_File)
      loop
         declare
            the_Line : constant String := get_Line (the_File);
         begin
            Result (Last + 1 .. Last + the_Line'Length) := the_Line;
            Last                                        := Last + the_Line'Length + 1;
            Result (Last)                               := ' ';
         end;
      end loop;

      close (the_File);
      return Result (1 .. Natural'Min (Last, Result'Last));
   end Contents;



   procedure keep (Log : in String;   as_Log : in String)
   --
   --  Keeps the log of a failed step.
   --
   is
   begin
      ada.Directories.copy_File (Log, as_Log);
   end keep;



   procedure generate (swig_Module      : in String;
                       use_CPP          : in Boolean := False;
                       wrapper_Compiles : in Boolean := True;
                       check_Layout     : in Boolean := True)
   --
   --  'wrapper_Compiles' is False for a case whose wrapper is known not to compile. Its wrapper
   --  is still compiled, so that the launcher can say when it has begun to.
   --
   --  The wrapper checks the layout of every class, so that a record which does not match its class fails
   --  to compile. 'check_Layout' is False for a case whose input is made so that one cannot ('-no-check-layout').
   --
   is
      use lace.Environ.Paths;

      Stem      : constant String := swig_Module (swig_Module'First .. swig_Module'Last - 2);     -- Less the '.i'.
      Wrapper   : constant String := Stem & "_wrap." & (if use_CPP then "cxx" else "c");
      Step_Log  : constant String := "step.log";
      Specs_Log : constant String := "specs.log";
   begin
      put_Line ("Generating swig module '" & swig_Module & "'.");

      ensure_Folder (+"./generated");
      go_to_Folder  (+"./generated");

      --  Generate.
      --
      if not run ("touch marker", Step_Log)
      then
         raise Program_Error with "Unable to write into the 'generated' folder.";
      end if;

      if not run (  Root & "/ada-build/swig4ada -ada" & (if check_Layout then "" else " -no-check-layout")
                  & (if use_CPP then " -c++" else "")
                  & " -outdir . -o ./" & Wrapper
                  & " -I/usr/include "
                  & "../../../test-suite/" & swig_Module,
                  Step_Log)
      then
         keep (Step_Log, as_Log => swig_Module & "-generator.log");
         generator_Failures := generator_Failures + 1;
         put_Line ("   The generator failed !");
      end if;

      --  Find the specs which were generated, tidy them and check their syntax.
      --
      if not run ("find . -maxdepth 1 -name '*.ads' -newer marker | sort", Specs_Log)
      then
         raise Program_Error with "Unable to list the generated specs.";
      end if;

      declare
         Specs : constant String := Contents (of_File => Specs_Log);
      begin
         if Specs /= ""
         then
            if        not run (  "gnatpp --replace"
                               & " --layout=default"
                               & " --max-line-length=120"
                               & " --based-grouping=3"
                               & " --decimal-grouping=3"
                               & " --par-threshold=2"
                               & " --call-threshold=2"
                               & " -I" & Root & " "
                               & Specs,
                               Step_Log)
              or else Index (Contents (of_File => Step_Log), "Syntax errors in") /= 0
            then
               keep (Step_Log, as_Log => swig_Module & "-pretty_print.log");
               syntax_Failures := syntax_Failures + 1;
               put_Line ("   A spec has a syntax error !");
            end if;
         end if;

         the_Cases.append (a_Case'(name_Length  => swig_Module'Length,
                                   specs_Length => Specs'Length,
                                   Name         => swig_Module,
                                   Specs        => Specs));
      end;

      --  Compile the wrapper.
      --
      if         check_Wrappers
        and then ada.Directories.exists (Wrapper)
      then
         declare
            --  The Ada module wraps the protected members of a class, and such a wrapper needs access to them.
            --
            Compiles : constant Boolean := run (  (if use_CPP then "g++ -fno-access-control" else "gcc -std=gnu17")
                                                & " -fsyntax-only -w -I../../../test-suite -I. " & Wrapper,
                                                Step_Log);
         begin
            if         wrapper_Compiles
              and then not Compiles
            then
               keep (Step_Log, as_Log => swig_Module & "-wrapper.log");
               wrapper_Failures := wrapper_Failures + 1;
               put_Line ("   The wrapper does not compile !");

            elsif      Compiles
              and then not wrapper_Compiles
            then
               unexpected_Passes := unexpected_Passes + 1;
               put_Line ("   The wrapper now compiles, and need no longer be marked as failing to.");
            end if;
         end;
      end if;

      go_to_Folder (to_Folder (".."));
   end generate;



   procedure run (the_Case : in String;   use_CPP  : in Boolean := True;
                                          Imported : in String  := "")
   --
   --  Generates the binding of a run-time case, builds its tester and runs it. 'Imported' names an
   --  interface file of the case ('base' for 'base.i') whose module the case imports, and which is
   --  generated first.
   --
   is
      Generator : constant String := "../../../../../ada-build/swig4ada -ada" & (if use_CPP then " -c++" else "") & " -outdir .";
      Extension : constant String := (if use_CPP then "cxx" else "c");

      Build : constant String := "runtime-build/" & the_Case;
      Log   : constant String := "runtime-build/" & the_Case & ".log";
   begin
      put_Line ("Running the run-time case '" & the_Case & "'.");
      runtime_Cases := runtime_Cases + 1;

      ada.Directories.create_Path ("runtime-build");     -- The log is written there.

      if not run (  "mkdir -p " & Build
                  & " && cd " & Build
                  & " && rm -rf obj tester *.ads *_wrap.cxx *_wrap.c"
                  & " && echo 'Generating.'"
                  & (if Imported = "" then ""
                     else   " && " & Generator & " -o ./" & Imported & "_wrap." & Extension
                          & " -I../../runtime/" & the_Case & " ../../runtime/" & the_Case & "/" & Imported & ".i")
                  & " && " & Generator & " -o ./example_wrap." & Extension
                  &          " -I../../runtime/" & the_Case & " ../../runtime/" & the_Case & "/example.i"
                  & " && echo 'Building.'"
                  & " && gprbuild -q -p -P ../../runtime/runtime_test.gpr -XCASE=" & the_Case & (if use_CPP then "" else " -XBOUND_LANGUAGE=C")
                  & " && echo 'Running.'"
                  & " && ./tester",
                  Log)
      then
         ada.Directories.create_Path ("generated");
         keep (Log, as_Log => "generated/" & the_Case & "-runtime.log");
         runtime_Failures := runtime_Failures + 1;
         put_Line ("   The run-time case failed !");
      end if;
   end run;



   procedure run_Example (the_Example : in String)
   --
   --  Runs the builder of an example of 'Examples/ada', which regenerates its binding, builds its tester and runs it.
   --
   is
      Log : constant String := "runtime-build/" & the_Example & "-example.log";
   begin
      put_Line ("Running the example '" & the_Example & "'.");
      example_Count := example_Count + 1;

      ada.Directories.create_Path ("runtime-build");     -- The log is written there.

      if not run ("cd ../" & the_Example & " && ./builder", Log)
      then
         ada.Directories.create_Path ("generated");
         keep (Log, as_Log => "generated/" & the_Example & "-example.log");
         example_Failures := example_Failures + 1;
         put_Line ("   The example failed !");
      end if;
   end run_Example;



   procedure compile_all_Specs
   is
      use lace.Environ.Paths;
      Step_Log : constant String := "step.log";
   begin
      new_Line;
      put_Line ("Compiling the generated specs.");
      new_Line;

      go_to_Folder (+"./generated");

      for Each of the_Cases
      loop
         if         Each.Specs /= ""
           and then not run ("gcc -c -gnatc -gnat2022 -I" & Root & " " & Each.Specs, Step_Log)
         then
            keep (Step_Log, as_Log => Each.Name & "-compile.log");
            compile_Failures := compile_Failures + 1;
            put_Line ("A spec of '" & Each.Name & "' does not compile !");
         end if;
      end loop;

      go_to_Folder (to_Folder (".."));
   end compile_all_Specs;


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
      generate ("allowexcept.i",                    use_CPP => True);
      generate ("argout.i",                         use_CPP => True);
      generate ("array_member.i");
      --  generate ("bools.i");     -- A C++ input, which is run with the C++ tests. As C, SWIG reports a syntax error.
      generate ("char_constant.i");
      generate ("const_const.i");
      generate ("derived_byvalue.i",                use_CPP => True);
      generate ("empty.i");
      generate ("enum_plus.i");
      generate ("enums.i");
      generate ("enum_var.i",                       use_CPP => True);
      generate ("extern_declaration.i");
      generate ("fragments.i");
      generate ("ignore_parameter.i",               use_CPP => True);
      generate ("immutable_values.i");
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
      generate ("nested.i");
      generate ("null_pointer.i",                   use_CPP => True);
      generate ("ordering.i",                       use_CPP => True);
      generate ("ret_by_value.i");
      generate ("struct_rename.i");
      generate ("struct_value.i",                   use_CPP => True);
      generate ("tag_no_clash_with_variable.i");
      generate ("typedef_mptr.i");
      generate ("typedef_reference.i",              use_CPP => True);
      generate ("typedef_sizet.i");
      generate ("typemap_numinputs.i");
      generate ("typemap_subst.i",                  use_CPP => True);
      generate ("unions.i");
      generate ("wrapmacro.i",                      use_CPP => True);
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
      generate ("bools.i",                          use_CPP => True);
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
      generate ("derived_nested.i",                 use_CPP => True);
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
      generate ("minherit.i",                       use_CPP => True);
      generate ("mod_a.i",                          use_CPP => True);
      generate ("multi_import_b.i",                 use_CPP => True);
      generate ("name_cxx.i",                       use_CPP => True);
      generate ("namespace_enum.i",                 use_CPP => True);
      generate ("namespace_extend.i",               use_CPP => True);
      generate ("namespace_template.i",             use_CPP => True);
      generate ("namespace_typedef_class.i",        use_CPP => True);
      generate ("newobject2.i",                     use_CPP => True);
      generate ("operator_overload_break.i",        use_CPP => True);
      generate ("overload_copy.i",                  use_CPP => True);
      --  generate ("overload_extendc.i",               use_CPP => True);     -- There is no such test file.
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
      generate ("return_const_value.i",             use_CPP => True);
      generate ("smart_pointer_const2.i",           use_CPP => True);
      generate ("smart_pointer_const.i",            use_CPP => True);
      generate ("smart_pointer_extend.i",           use_CPP => True);
      generate ("smart_pointer_member.i",           use_CPP => True);
      generate ("smart_pointer_multi.i",            use_CPP => True);
      generate ("smart_pointer_namespace2.i",       use_CPP => True);
      generate ("smart_pointer_namespace.i",        use_CPP => True);
      generate ("smart_pointer_not.i",              use_CPP => True);
      generate ("smart_pointer_overload.i",         use_CPP => True);
      generate ("smart_pointer_rename.i",           use_CPP => True);
      generate ("smart_pointer_simple.i",           use_CPP => True);
      generate ("smart_pointer_static.i",           use_CPP => True);
      generate ("smart_pointer_typedef.i",          use_CPP => True);
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
      generate ("template_expr.i",                  use_CPP => True,   wrapper_Compiles => False);     -- Wrapper: the input holds C++ which does not compile.
      generate ("template_extend1.i",               use_CPP => True);
      generate ("template_extend2.i",               use_CPP => True);
      generate ("template_extend_overload_2.i",     use_CPP => True);
      generate ("template_inherit.i",               use_CPP => True);
      generate ("template_int_const.i",             use_CPP => True);
      generate ("template_methods.i",               use_CPP => True);
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
      generate ("typedef_class.i",                  use_CPP => True);
      generate ("typedef_inherit.i",                use_CPP => True);
      generate ("typemap_self.i",                   use_CPP => True,   wrapper_Compiles => False);     -- Wrapper: uses the swig runtime type system, which the Ada runtime does not have.
      generate ("typemap_variables.i",              use_CPP => True);
      generate ("types_directive.i",                use_CPP => True);
      generate ("union_scope.i",                    use_CPP => True);
      generate ("using_composition.i",              use_CPP => True);
      generate ("using_extend.i",                   use_CPP => True);
      generate ("using_inherit.i",                  use_CPP => True);
      generate ("using_private.i",                  use_CPP => True);
      generate ("using_protected.i",                use_CPP => True);
      generate ("valuewrapper_base.i",              use_CPP => True);
      generate ("valuewrapper_const.i",             use_CPP => True);
      generate ("valuewrapper.i",                   use_CPP => True);
      generate ("varargs.i",                        use_CPP => True);
      generate ("virtual_derivation.i",             use_CPP => True);
      generate ("virtual_destructor.i",             use_CPP => True);
      generate ("voidtest.i",                       use_CPP => True);
   end if;


   ----------------------
   --- Uncompilable tests
   --

   -- C Tests
   --
   if do_uncompilable_C
   then
      new_Line;
      new_Line;
      put_Line ("Generating uncompilable C tests.");
      new_Line;

      generate ("li_carrays.i");
      generate ("li_cmalloc.i");

      generate ("preproc.i");            -- Fails due to #define MASK(shift, size) (((1 << (size)) - 1) <<(shift))
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
      generate ("dynamic_cast.i",                   use_CPP => True,   wrapper_Compiles => False);     -- Wrapper: uses the swig runtime type system, which the Ada runtime does not have.
      generate ("features.i",                       use_CPP => True);
      generate ("fvirtual.i",                       use_CPP => True);
      generate ("import_nomodule.i",                use_CPP => True);
      generate ("imports_b.i",                      use_CPP => True);
      generate ("inherit_same_name.i",              use_CPP => True);
      generate ("li_attribute.i",                   use_CPP => True);
      generate ("minherit2.i",                      use_CPP => True);
      generate ("mod_b.i",                          use_CPP => True);
      generate ("multi_import_a.i",                 use_CPP => True);
      generate ("namespace_virtual_method.i",       use_CPP => True);
      generate ("name_warnings.i",                  use_CPP => True);
      generate ("newobject1.i",                     use_CPP => True);
      generate ("operator_overload.i",              use_CPP => True);
      generate ("private_assign.i",                 use_CPP => True);
      generate ("pure_virtual.i",                   use_CPP => True);
      generate ("rname.i",                          use_CPP => True);
      generate ("samename.i",                       use_CPP => True);
      generate ("smart_pointer_multi_typedef.i",    use_CPP => True);
      generate ("smart_pointer_protected.i",        use_CPP => True);
      generate ("template_inherit_abstract.i",      use_CPP => True);
      generate ("template_specialization_enum.i",   use_CPP => True);
      generate ("template_typedef_import.i",        use_CPP => True);
      generate ("using_pointers.i",                 use_CPP => True);
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

      generate ("anonymous_bitfield.i");
      generate ("apply_signed_char.i",              use_CPP => True);
      generate ("apply_strings.i",                  use_CPP => True);
      generate ("arrayref.i",                       use_CPP => True);
      generate ("arrays_dimensionless.i",           use_CPP => True);
      generate ("arrays_global.i",                  use_CPP => True);
      generate ("arrays_global_twodim.i");
      generate ("arrays.i");
      generate ("arrays_scope.i",                   use_CPP => True);
      generate ("array_typedef_memberin.i",         use_CPP => True);
      generate ("bloody_hell.i");
      generate ("char_strings.i",                   use_CPP => True);
      generate ("class_scope_weird.i",              use_CPP => True);
      generate ("default_args.i",                   use_CPP => True);
      generate ("enum_thorough_typeunsafe.i",       use_CPP => True);
      generate ("file_test.i");
      generate ("funcptr.i");
      generate ("function_typedef.i");
      generate ("global_vars.i",                    use_CPP => True);
      generate ("grouping.i");
      generate ("inctest.i");
      generate ("li_std_map.i",                     use_CPP => True);
      generate ("li_std_pair.i",                    use_CPP => True);
      generate ("li_std_set.i",                     use_CPP => True);
      generate ("li_std_vector.i",                  use_CPP => True);
      generate ("li_std_wstring.i",                 use_CPP => True);
      --  generate ("list_vector.i");     -- Not applicable: uses a library of Guile typemaps.
      generate ("li_typemaps.i",                    use_CPP => True);
      generate ("li_windows.i",                     use_CPP => True);
      generate ("long_long_apply.i",                use_CPP => True);
      generate ("nested_comment.i");
      --  generate ("pointer_in_out.i");     -- Not applicable: uses a library of Guile typemaps.
      generate ("pointer_reference.i",              use_CPP => True);
      generate ("register_par.i");
      generate ("sizeof_pointer.i");
      generate ("sizet.i",                          use_CPP => True);
      generate ("sneaky1.i");
      generate ("special_variables.i",              use_CPP => True);
      generate ("threads.i",                        use_CPP => True);
      generate ("typedef_array_member.i");
      generate ("typedef_funcptr.i",                use_CPP => True);
      generate ("typedef_struct.i",                 check_Layout => False);     -- A structure hides a member from SWIG ('#ifndef SWIG').
   end if;


   -- C++ Tests
   --
   if do_broken_Cxx
   then
      new_Line;
      new_Line;
      put_Line ("Generating broken C++ tests.");
      new_Line;

      generate ("add_link.i",                       use_CPP => True);
      generate ("allprotected.i",                   use_CPP => True);

      generate ("abstract_typedef2.i",              use_CPP => True);
      generate ("class_ignore.i",                   use_CPP => True);
      generate ("constant_pointers.i",              use_CPP => True);
      --  generate ("constants.i",                       use_CPP => True);     -- Error: Syntax error in input(1).
      generate ("cpp_basic.i",                      use_CPP => True);
      --  generate ("cpp_broken.i",                      use_CPP => True);     -- There is no such test file.
      generate ("cpp_enum.i",                       use_CPP => True);
      generate ("cpp_namespace.i",                  use_CPP => True);
      generate ("cpp_typedef.i",                    use_CPP => True);
      generate ("enum_scope_template.i",            use_CPP => True);
      generate ("enum_thorough.i",                  use_CPP => True);
      generate ("enum_thorough_proper.i",           use_CPP => True);
      generate ("enum_thorough_simple.i",           use_CPP => True);
      generate ("enum_thorough_typesafe.i",         use_CPP => True);
      generate ("global_ns_arg.i",                  use_CPP => True);
      generate ("ignore_template_constructor.i",    use_CPP => True);
      generate ("inherit_target_language.i",        use_CPP => True);
      generate ("intermediary_classname.i",         use_CPP => True);
      generate ("kind.i",                           use_CPP => True);
      generate ("li_boost_shared_ptr_bits.i",       use_CPP => True);
      generate ("li_boost_shared_ptr.i",            use_CPP => True);
      generate ("li_cdata_carrays.i",               use_CPP => True);
      generate ("li_cdata.i",                       use_CPP => True);
      generate ("li_factory.i",                     use_CPP => True);
      generate ("li_implicit.i",                    use_CPP => True);
      generate ("li_std_deque.i",                   use_CPP => True);
      generate ("li_std_except.i",                  use_CPP => True);
      generate ("li_std_stream.i",                  use_CPP => True);
      generate ("li_std_string.i",                  use_CPP => True);
      generate ("memberin1.i",                      use_CPP => True);
      generate ("member_pointer.i",                 use_CPP => True);
      generate ("mixed_types.i",                    use_CPP => True);
      --  generate ("multi_import_c.i",                  use_CPP => True);     -- No module name specified using %module or -module.
      generate ("multiple_inheritance.i",           use_CPP => True);
      generate ("namespace_class.i",                use_CPP => True);
      generate ("namespace_nested.i",               use_CPP => True);
      generate ("namespace_spaces.i",               use_CPP => True);
      generate ("namespace_typemap.i",              use_CPP => True);
      generate ("namespace_union.i",                use_CPP => True);
      generate ("overload_complicated.i",           use_CPP => True);
      generate ("primitive_ref.i",                  use_CPP => True);
      generate ("primitive_types.i",                use_CPP => True);
      generate ("refcount.i",                       use_CPP => True);
      generate ("reference_global_vars.i",          use_CPP => True);
      generate ("rename1.i",                        use_CPP => True);
      generate ("rename2.i",                        use_CPP => True);
      generate ("rename3.i",                        use_CPP => True);
      generate ("rename4.i",                        use_CPP => True);
      generate ("return_value_scope.i",             use_CPP => True);
      generate ("smart_pointer_inherit.i",          use_CPP => True);
      generate ("smart_pointer_templatemethods.i",  use_CPP => True);
      generate ("smart_pointer_templatevariables.i", use_CPP => True);
      generate ("std_containers.i",                 use_CPP => True,   wrapper_Compiles => False);     -- Wrapper: a container of a class with no default constructor has a constructor which takes a size (the input would '%ignore' it).
      generate ("template_arg_scope.i",             use_CPP => True);
      generate ("template_arg_typename.i",          use_CPP => True);
      generate ("template_classes.i",               use_CPP => True);
      generate ("template_const_ref.i",             use_CPP => True);
      generate ("template_default_arg.i",           use_CPP => True);
      generate ("template_default.i",               use_CPP => True);
      generate ("template_default_inherit.i",       use_CPP => True);
      --  generate ("template_default_pointer.i",        use_CPP => True);     -- Error: Syntax error in input(1).
      generate ("template_enum.i",                  use_CPP => True);
      generate ("template_enum_typedef.i",          use_CPP => True);
      generate ("template_explicit.i",              use_CPP => True);
      generate ("template_extend_overload.i",       use_CPP => True);
      generate ("template_forward.i",               use_CPP => True);
      --  generate ("template.i",                        use_CPP => True);     -- There is no such test file.
      generate ("template_ns2.i",                   use_CPP => True);
      generate ("template_ns4.i",                   use_CPP => True);
      generate ("template_ns_enum2.i",              use_CPP => True);
      generate ("template_ns_enum.i",               use_CPP => True);
      generate ("template_opaque.i",                use_CPP => True);
      generate ("template_retvalue.i",              use_CPP => True);
      generate ("template_tbase_template.i",        use_CPP => True);
      generate ("template_typedef_cplx2.i",         use_CPP => True);
      generate ("template_typedef_cplx3.i",         use_CPP => True);
      generate ("template_typedef_cplx4.i",         use_CPP => True);
      generate ("template_typedef_cplx5.i",         use_CPP => True);
      generate ("template_typedef_cplx.i",          use_CPP => True);
      generate ("template_typedef_fnc.i",           use_CPP => True);
      generate ("template_typedef_funcptr.i",       use_CPP => True);
      generate ("template_typedef.i",               use_CPP => True);
      generate ("template_typemaps.i",              use_CPP => True);
      generate ("template_type_namespace.i",        use_CPP => True);
      generate ("template_whitespace.i",            use_CPP => True);
      generate ("typedef_scope.i",                  use_CPP => True);
      --  generate ("typemap_namespace.i",               use_CPP => True);     -- Error: Can't copy typemap (freearg) char * = Foo::Str1 *.
      generate ("typemap_ns_using.i",               use_CPP => True);
      generate ("typemap_various.i",                use_CPP => True);
      generate ("typename.i",                       use_CPP => True);
      generate ("using1.i",                         use_CPP => True);
      generate ("using2.i",                         use_CPP => True);
      generate ("using_namespace.i",                use_CPP => True);
      generate ("valuewrapper_opaque.i",            use_CPP => True);
      generate ("virtual_poly.i",                   use_CPP => True);
   end if;


   -----------------
   --- Compile check
   --
   if check_Specs
   then
      compile_all_Specs;
   end if;


   -----------------
   --- Run-time cases
   --
   if do_Runtime
   then
      new_Line;
      put_Line ("Running the run-time cases.");
      new_Line;

      run ("values");              -- References, pointers, enumerations, plain structures and callbacks.
      run ("class_values");        -- A class which is not trivial, constructed, returned and passed by value.
      run ("virtual_classes");     -- Dispatching in both directions, a class derived in Ada, and guards.
      run ("mutual_classes");      -- Two classes, each of which uses the other.
      run ("containers");          -- The containers of the C++ standard library.
      run ("exceptions");          -- The record of a C++ exception which a wrapper has caught.
      run ("namespaces");          -- Declarations in namespaces, one of them nested.
      run ("overloads");           -- Overloading, default arguments, operators and a static member function.
      run ("c_library",   use_CPP => False);     -- A binding to C: structures, a union, arrays, strings, callbacks and variables.
      run ("smart_pointers");      -- A class which is used through a smart pointer.
      run ("imports",     Imported => "base");   -- A module which imports another, and derives from one of its classes.
      run ("extensions");          -- Members added with '%extend', and a function with an '%exception'.
      run ("templates");           -- Templates which a library defines, one of them with virtual functions.
      run ("multiple_inheritance");   -- Classes with more than one base class.
      run ("nested");              -- Declarations which are nested in a class.
      run ("callbacks");           -- Functions of Ada which C++ calls.
      run ("arrays");              -- Arrays and pointers, the other standard types, and variables.
      run ("constants");           -- Constants and enumerations of every kind.
      run ("static_members");      -- Static member variables of classes.
      run ("layouts");             -- Unions, bit-fields and structures within structures.
      run ("strings");             -- Strings of the C++ standard library.
      run ("directives");          -- Directives which change a binding.
      run ("derived_layouts");     -- Classes whose members lie in the unused tail of a base class.
   end if;


   -------------
   --- Examples
   --
   if do_Examples
   then
      new_Line;
      put_Line ("Running the examples.");
      new_Line;

      run_Example ("addlink");
      run_Example ("anonymous_bitfield");
      run_Example ("char_constants");
      run_Example ("class");
      run_Example ("enum");
      run_Example ("funcptr");
      run_Example ("import_tree");
      run_Example ("li_carrays");
      run_Example ("preproc");
      run_Example ("reference");
      run_Example ("simple");
      run_Example ("std_string");
      run_Example ("std_vector");
      run_Example ("template");
      run_Example ("typedef");
      run_Example ("variables");
   end if;


   --------
   --- Done
   --
   new_Line;
   put_Line ("Cases:                        " & the_Cases.Length'Image);
   put_Line ("Generator failures:           " & generator_Failures'Image);
   put_Line ("Specs with a syntax error:    " & syntax_Failures   'Image);
   put_Line ("Wrappers which do not compile:" & wrapper_Failures  'Image);
   put_Line ("Specs which do not compile:   " & compile_Failures  'Image);

   if unexpected_Passes > 0
   then
      put_Line ("Wrappers which now compile:   " & unexpected_Passes'Image);
   end if;

   put_Line ("Run-time cases:               " & runtime_Cases   'Image);
   put_Line ("Run-time cases which fail:    " & runtime_Failures'Image);
   put_Line ("Examples:                     " & example_Count   'Image);
   put_Line ("Examples which fail:          " & example_Failures'Image);

   new_Line;

   if generator_Failures + syntax_Failures + wrapper_Failures + compile_Failures + runtime_Failures + example_Failures = 0
   then
      put_Line ("Complete.");
   else
      put_Line ("Testsuite failed !");
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
end launch_testsuite;
