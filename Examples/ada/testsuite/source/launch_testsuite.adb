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
   do_Newer            : constant Boolean := True;     -- The cases which were added with SWIG 4.5.1.
   do_Older            : constant Boolean := True;     -- The cases of SWIG 4.0.0 which had not been added until 2026-11-22.

   check_Wrappers      : constant Boolean := True;     -- Compile each generated wrapper.
   check_Specs         : constant Boolean := True;     -- Compile each generated spec.
   check_Baseline      : constant Boolean := True;     -- Say which of the generated specs and wrappers differ from those of the baseline.
   do_Runtime          : constant Boolean := True;     -- Build and run the run-time cases.
   do_Examples         : constant Boolean := True;     -- Build each example of 'Examples/ada' and run its tester.
   do_cBound           : constant Boolean := True;     -- Try the tool on a copy of cBound, the bindings which are made with it, where it is present.
   do_Units            : constant Boolean := True;     -- Build and run the tests of single units of the Ada module.

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
   unit_Count         : Natural := 0;
   unit_Failures      : Natural := 0;
   unexpected_Passes  : Natural := 0;
   baseline_Changes   : Natural := 0;
   has_Baseline       : Boolean := False;



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



   function Contents (of_File : in String) return String;


   --  What the tool is made of when a run is made: a checksum of the tool and of each file of its library.
   --
   Tool_checksum : constant String :=   "{ sha256sum ../../../ada-build/swig4ada;"
                                      & " find ""$(../../../ada-build/swig4ada -swiglib)"" -type f | sort | xargs sha256sum; }"
                                      & " | sha256sum | cut -d' ' -f1";


   procedure note_the_Run (Failures : in Natural;   is_Whole : in Boolean)
   --
   --  Notes how a run ended, and with which tool, so that its specs and wrappers may be accepted as the baseline.
   --
   is
      the_Note : File_Type;
   begin
      create   (the_Note, out_File, "generated/last-run");
      put_Line (the_Note, (if not is_Whole then "partial" elsif Failures = 0 then "passed" else "failed"));
      close    (the_Note);

      if not run (Tool_checksum & " > generated/last-run.tool", "/dev/null")
      then
         raise Program_Error with "Unable to take the checksum of the tool.";
      end if;
   end note_the_Run;



   procedure accept_the_Baseline
   --
   --  Makes the specs and wrappers of the last run the baseline ('./launch_testsuite accept'), without running the suite
   --  again. The run must have been of the whole suite, must have failed in nothing but its differences from the
   --  baseline, and must have been made with the tool and library as they are now.
   --
   is
      procedure refuse (Reason : in String)
      is
      begin
         put_Line ("The baseline is not changed: " & Reason);
         ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
      end refuse;

   begin
      if        not ada.Directories.exists ("generated/last-run")
        or else not ada.Directories.exists ("generated/last-run.tool")
        or else not ada.Directories.exists ("generated/specs.sha")
      then
         refuse ("there is no run of the suite to accept. Run './launch_testsuite' first.");

      elsif Index (Contents ("generated/last-run"), "partial") /= 0
      then
         refuse ("the last run was of a part of the suite.");

      elsif Index (Contents ("generated/last-run"), "passed") = 0
      then
         refuse ("the last run failed in more than its differences from the baseline.");

      elsif not run ("[ ""$(" & Tool_checksum & ")"" = ""$(cat generated/last-run.tool)"" ]", "/dev/null")
      then
         refuse ("the tool or its library has changed since the last run (or 'SWIG_LIB' names another library). Run './launch_testsuite' again.");

      elsif not run (  "cp generated/specs.sha baseline.sha"
                     & " && rm -rf baseline && mkdir baseline && cp generated/*.ads generated/*_wrap.c generated/*_wrap.cxx baseline/",
                     "/dev/null")
      then
         refuse ("the generated specs could not be copied.");

      else
         put_Line ("The specs and wrappers of the last run are now the baseline.");
      end if;
   end accept_the_Baseline;



   procedure check_against_Baseline
   --
   --  A spec or a wrapper may change and still compile, so each is compared with the one which was last accepted as right.
   --
   --  'baseline.sha' holds a checksum of each spec of the baseline, and is kept with the sources. The specs themselves
   --  are kept in the 'baseline' folder, which is not: where it is present, 'generated/baseline-changes.log' shows how
   --  each changed spec differs. Both are made anew by './launch_testsuite accept' ('accept_the_Baseline'), once the
   --  changes have been looked at and are as they should be. (The specs are pretty printed, so another version of
   --  'gnatpp' may change them all.)
   --
   is
      Step_Log : constant String := "generated/baseline-step.log";
   begin
      if not run ("cd generated && sha256sum *.ads *_wrap.c *_wrap.cxx > specs.sha", Step_Log)
      then
         raise Program_Error with "Unable to take the checksums of the generated specs.";
      end if;

      if not ada.Directories.exists ("baseline.sha")
      then
         new_Line;
         put_Line ("There is no baseline of the specs to compare with ('./launch_testsuite accept' makes one).");
         return;
      end if;

      has_Baseline := True;

      --  The names of the specs which are changed, added or gone.
      --
      if not run (  "diff baseline.sha generated/specs.sha | grep '^[<>]' | awk '{print $3}' | sort -u > generated/baseline-changes.lst;"
                  & " : > generated/baseline-changes.log;"
                  & " for Each in $(cat generated/baseline-changes.lst); do"
                  & "   if   [ ! -f generated/$Each ];  then echo ""=== $Each is no longer generated."";"
                  & "   elif ! grep -q ""  $Each$"" baseline.sha;  then echo ""=== $Each is new."";"
                  & "   elif [ -f baseline/$Each ];  then echo ""=== $Each differs:"";  diff baseline/$Each generated/$Each;"
                  & "   else echo ""=== $Each differs (there is no 'baseline' folder to show how)."";"
                  & "   fi;"
                  & " done >> generated/baseline-changes.log;"
                  & " true",
                  Step_Log)
      then
         raise Program_Error with "Unable to compare the generated specs with the baseline.";
      end if;

      declare
         the_Changes : File_Type;
      begin
         open (the_Changes, in_File, "generated/baseline-changes.lst");

         while not end_of_File (the_Changes)
         loop
            skip_Line (the_Changes);
            baseline_Changes := baseline_Changes + 1;
         end loop;

         close (the_Changes);
      end;

      if baseline_Changes > 0
      then
         new_Line;
         put_Line (baseline_Changes'Image & " specs or wrappers differ from the baseline: see 'generated/baseline-changes.log'.");
         put_Line ("If they are as they should be, './launch_testsuite accept' makes them the baseline.");

         --  Most of the differences of a run break nothing. Those which may break a program that uses
         --  a binding are picked out, as they are the ones to read before the baseline is accepted.
         --
         if         ada.Directories.exists ("baseline")
           and then run ("./baseline_report > generated/baseline-report.txt 2>&1", Step_Log)
         then
            new_Line;
            put_Line ("Of these, the changes which may break a program that uses a binding:");
            put      (Contents ("generated/baseline-report.txt"));
         end if;
      end if;
   end check_against_Baseline;



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
                       check_Layout     : in Boolean := True;
                       Options          : in String  := "")
   --
   --  'Options' are further options of the generator, which the input of a few cases requires ('-DFOO', '-std=c23').
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
                  & (if Options = "" then "" else " " & Options)
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
                                          Imported : in String  := "";
                                          Options  : in String  := "";
                                          Input    : in String  := "")
   --
   --  Generates the binding of a run-time case, builds its tester and runs it. 'Imported' names an
   --  interface file of the case ('base' for 'base.i') whose module the case imports, and which is
   --  generated first. 'Options' are further options of the generator. 'Input' is the interface file, as it is
   --  named from the folder in which the case is built, where it is not the 'example.i' of the case.
   --
   --  The warnings which the Ada module gives (those numbered from 861) must be those of the file
   --  'expected-warnings' of the case, each less the folder of its file. A case with no such file must give none.
   --
   is
      Generator : constant String :=   "../../../../../ada-build/swig4ada -ada" & (if use_CPP then " -c++" else "")
                                     & (if Options = "" then "" else " " & Options) & " -outdir .";
      Expected  : constant String := "../../runtime/" & the_Case & "/expected-warnings";
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
                  & " && { true"
                  & (if Imported = "" then ""
                     else   " && " & Generator & " -o ./" & Imported & "_wrap." & Extension
                          & " -I../../runtime/" & the_Case & " ../../runtime/" & the_Case & "/" & Imported & ".i")
                  & " && " & Generator & " -o ./example_wrap." & Extension
                  &          " -I../../runtime/" & the_Case & " " & (if Input = "" then "../../runtime/" & the_Case & "/example.i" else Input)
                  & "; } > generate.log 2>&1 || { cat generate.log; false; }"
                  & " && cat generate.log"
                  & " && echo 'Checking the warnings.'"
                  & " && { grep 'Warning 86' generate.log || true; } | sed 's|^[^ ]*/||' > warnings.txt"
                  & " && if [ -f " & Expected & " ]; then diff " & Expected & " warnings.txt;"
                  &    " elif [ -s warnings.txt ]; then echo 'These warnings are not expected:'; cat warnings.txt; false; fi"
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



   procedure run_Upstream (the_Case : in String;   use_CPP : in Boolean := True)
   --
   --  Runs a case of upstream's suite as a run-time case. Its input is 'Examples/test-suite/<case>.i', and its
   --  tester, which is written after the test which upstream has for another language, is in 'runtime/up_<case>'.
   --
   is
   begin
      run ("up_" & the_Case,
           use_CPP => use_CPP,
           Options => "-I../../../../test-suite",
           Input   => "../../../../test-suite/" & the_Case & ".i");
   end run_Upstream;



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



   procedure run_Unit (the_Unit : in String)
   --
   --  Builds and runs the test of one unit of the Ada module, which is tested apart from the tool: 'unit/<unit>'
   --  holds '<unit>_test.gpr' and its main program, which makes its checks through the 'Checks' package.
   --
   is
      Log : constant String := "unit-build/" & the_Unit & ".log";
   begin
      put_Line ("Running the unit test '" & the_Unit & "'.");
      unit_Count := unit_Count + 1;

      ada.Directories.create_Path ("unit-build");     -- The log is written there.

      if not run (  "gprbuild -q -p -P unit/" & the_Unit & "/" & the_Unit & "_test.gpr"
                  & " && unit-build/" & the_Unit & "/" & the_Unit & "_test",
                  Log)
      then
         ada.Directories.create_Path ("generated");
         keep (Log, as_Log => "generated/" & the_Unit & "-unit.log");
         unit_Failures := unit_Failures + 1;
         put_Line ("   The unit test failed !");
      end if;
   end run_Unit;



   procedure run_Step (Name : in String;   Command : in String)
   --
   --  Runs a check which is a command of its own, counted with the unit tests.
   --
   is
      Log : constant String := "unit-build/" & Name & ".log";
   begin
      put_Line ("Checking " & Name & ".");
      unit_Count := unit_Count + 1;

      ada.Directories.create_Path ("unit-build");

      if not run (Command, Log)
      then
         ada.Directories.create_Path ("generated");
         keep (Log, as_Log => "generated/" & Name & "-check.log");
         unit_Failures := unit_Failures + 1;
         put_Line ("   The check failed !");
      end if;
   end run_Step;



   procedure check_the_layout_Assertions
   --
   --  Every other case shows that the layout checks of a wrapper pass. This shows that they can fail: 'runtime/wrong_layout'
   --  hides a member of a structure from SWIG, so the record does not match, and its wrapper must not compile. It must
   --  compile once the checks are turned off.
   --
   is
      Tool   : constant String := "../../../../../ada-build/swig4ada -ada -c++ -outdir . -o ./example_wrap.cxx";
      Source : constant String := "../../runtime/wrong_layout";
   begin
      run_Step ("that a layout check can fail",
                  "mkdir -p unit-build/wrong_layout && cd unit-build/wrong_layout"
                & " && " & Tool & " -I" & Source & " " & Source & "/example.i"
                & " && if g++ -fsyntax-only -I" & Source & " example_wrap.cxx > compile.log 2>&1;"
                &    " then echo 'The wrapper of a record which does not match its structure compiles.'; false; fi"
                & " && grep 'swig4ada: the Ada record' compile.log"
                & " && grep ""swig4ada: the member 'last'"" compile.log"
                & " && g++ -fsyntax-only -DSWIG_ADA_NO_LAYOUT_CHECKS -I" & Source & " example_wrap.cxx");
   end check_the_layout_Assertions;



   procedure check_the_Bootstrap
   --
   --  The tool is built with bindings to the swig core which it generated itself. This generates the
   --  three of them again, apart, and requires each file to be as it is in the sources.
   --
   is
      Source : constant String := "../../../../../../Source";     -- As seen from the folder of a binding which is generated again.
      Paths  : constant String :=   " -I" & Source & "/Include -I" & Source & "/Swig -I" & Source & "/Modules"
                                  & " -I" & Source & "/Preprocessor -I" & Source & "/DOH";

      function Regenerated (the_Binding : in String;   use_CPP : in Boolean) return String
      is
         Wrapper : constant String := the_Binding & "_wrap." & (if use_CPP then "cxx" else "c");
         Tracked : constant String := Source & "/Modules/ada/swig_binding/" & the_Binding;
      begin
         return   "mkdir -p unit-build/bootstrap/" & the_Binding & " && cd unit-build/bootstrap/" & the_Binding
                & " && rm -f *.ads *_wrap.*"
                & " && ../" & "../../../../../ada-build/swig4ada -ada" & (if use_CPP then " -c++" else "")
                &    Paths & " -outdir . -o ./" & Wrapper & " " & Tracked & "/" & the_Binding & ".i > generate.log 2>&1"
                & " && rm -f *-guards.ads"
                & " && gnatpp -rnb -I" & Source & " *.ads > pretty_print.log 2>&1"
                & " && for Each in " & Tracked & "/*.ads " & Tracked & "/*_wrap.*; do cmp $Each $(basename $Each) || exit 1; done"
                & " && cd ../../..";
      end Regenerated;
   begin
      run_Step ("that the tool regenerates its own bindings",
                  Regenerated ("doh",       use_CPP => False)
                & " && " & Regenerated ("swig_core", use_CPP => False)
                & " && " & Regenerated ("swigmod",   use_CPP => True));
   end check_the_Bootstrap;



   procedure check_the_imported_Symbols
   --
   --  A spec imports each entity by a symbol: a function of the wrapper file, a variable of the library, or the C++
   --  symbol of a virtual destructor, a static member variable or a variable in a namespace, which the tool makes
   --  itself. A symbol which is wrong is found only when a program is linked, and the cases are not. So each wrapper
   --  is compiled to an object (a C++ one with every inline function kept), and each symbol which a spec imports
   --  must be one which some object defines or refers to.
   --
   --  Those which are in none are compared with the file 'expected-missing-symbols': they are entities which the
   --  test inputs declare and do not define, or whose symbol cannot be told from what swig knows (see CLAUDE.md).
   --
   is
      Build    : constant String := "../unit-build/symbols";
      Includes : constant String := " -w -I../../../test-suite -I. {} -o " & Build & "/{}.o 2> /dev/null || true'";
      Imports  : constant String :=   "while (/pragma\s+(?:Import|CPP_Constructor)\s*\([^;]*?""([A-Za-z_]\w*)""\s*\)\s*;/gsi) { print ""$1\n"" }"
                                    & " while (/External_Name\s*=>\s*""([A-Za-z_]\w*)""/gs) { print ""$1\n"" }";
   begin
      run_Step ("that the symbols which the specs import exist",
                  "cd generated && rm -rf " & Build & " && mkdir -p " & Build
                & " && export LC_ALL=C"
                & " && ls *_wrap.cxx | xargs -P $(nproc) -I{} sh -c 'g++ -c -fno-access-control -fkeep-inline-functions" & Includes
                & " && ls *_wrap.c   | xargs -P $(nproc) -I{} sh -c 'gcc -c -std=gnu17" & Includes
                & " && for Each in " & Build & "/*.o; do nm $Each; done | awk '{print $NF}' | sort -u > " & Build & "/emitted.txt"
                & " && perl -0ne '" & Imports & "' *.ads | sort -u > " & Build & "/imported.txt"
                & " && comm -23 " & Build & "/imported.txt " & Build & "/emitted.txt > " & Build & "/missing.txt"
                & " && echo ""Imported: $(wc -l < " & Build & "/imported.txt), of which missing: $(wc -l < " & Build & "/missing.txt)."""
                & " && echo 'Differences from the symbols which are expected to be missing (<), if any:'"
                & " && diff ../expected-missing-symbols " & Build & "/missing.txt");
   end check_the_imported_Symbols;



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
   if ada.Command_Line.Argument_Count = 1 and then ada.Command_Line.Argument (1) = "accept"
   then
      accept_the_Baseline;
      return;
   end if;

   --  The specs and wrappers of an earlier run are removed, so that one which is no longer generated is seen
   --  to be gone, and is neither compiled nor counted. A run of a part of the suite leaves them.
   --
   if do_C and do_Cxx and do_Newer and do_Older
   then
      ada.Directories.create_Path ("generated");

      if not run ("rm -f generated/*.ads generated/*_wrap.c generated/*_wrap.cxx", "/dev/null")
      then
         put_Line ("Unable to clear the 'generated' folder.");
      end if;
   end if;

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
      generate ("multi_import_d.i",                 use_CPP => True);
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
      generate ("template_expr.i",                  use_CPP => True);
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
      generate ("dynamic_cast.i",                   use_CPP => True,   wrapper_Compiles => False);     -- Wrapper: the input sets a member of a type descriptor of the swig runtime, at file scope where Ada has no initialisation function.
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
      generate ("std_containers.i",                 use_CPP => True);
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


   ---------------------------------
   --- Cases added with SWIG 4.5.1
   --
   --  The cases which upstream added between SWIG 4.0.0 and 4.5.1, for C and for C++ up to C++20.
   --
   if do_Newer
   then
      new_Line;
      new_Line;
      put_Line ("Generating the C tests which were added with SWIG 4.5.1.");
      new_Line;

      generate ("charptr_fragment.i");
      generate ("command_line_define.i",                      Options => "-DFOO -DBAR=123 -DBAZ -UBAZ -UNOTSET");
      generate ("constant_expr_c.i");
      generate ("contract_c.i");
      generate ("final_c.i");
      generate ("global_immutable_vars.i");
      generate ("li_cdata_bytes.i");
      generate ("multichar_constant.i");
      generate ("not_c_keywords.i");
      generate ("preproc_expr.i");
      generate ("preproc_predefined.i");
      generate ("preproc_predefined_stdc.i",                  Options => "-std=c23");

      new_Line;
      new_Line;
      put_Line ("Generating the C++ tests which were added with SWIG 4.5.1.");
      new_Line;

      generate ("abstract_basecast.i",                        use_CPP => True);
      generate ("abstract_inherit_using.i",                   use_CPP => True);
      generate ("apply_typemap_typedefs.i",                   use_CPP => True);
      generate ("assign_const.i",                             use_CPP => True);
      generate ("assign_reference.i",                         use_CPP => True);
      generate ("begin_code.i",                               use_CPP => True);
      generate ("catches_strings.i",                          use_CPP => True);
      generate ("char_binary_rev_len.i",                      use_CPP => True);
      generate ("class_case.i",                               use_CPP => True);
      generate ("constructor_copy_non_const.i",               use_CPP => True);
      generate ("copyctor.i",                                 use_CPP => True);
      generate ("cpp11_alias_template_inheritance.i",         use_CPP => True);
      generate ("cpp11_alias_templates.i",                    use_CPP => True);
      generate ("cpp11_assign_delete.i",                      use_CPP => True);
      generate ("cpp11_assign_rvalue_reference.i",            use_CPP => True);
      generate ("cpp11_attribute_specifiers.i",               use_CPP => True);
      generate ("cpp11_auto_variable.i",                      use_CPP => True);
      generate ("cpp11_brackets_expression.i",                use_CPP => True);
      generate ("cpp11_constexpr_friend.i",                   use_CPP => True);
      generate ("cpp11_copyctor_delete.i",                    use_CPP => True);
      generate ("cpp11_director_using_constructor.i",         use_CPP => True);
      generate ("cpp11_final_class.i",                        use_CPP => True);
      generate ("cpp11_inheriting_constructors_typedef.i",    use_CPP => True);
      generate ("cpp11_move_only.i",                          use_CPP => True);
      generate ("cpp11_move_only_valuewrapper.i",             use_CPP => True);
      generate ("cpp11_move_typemaps.i",                      use_CPP => True);
      generate ("cpp11_rvalue_reference_move.i",              use_CPP => True);
      generate ("cpp11_shared_ptr_crtp_upcast.i",             use_CPP => True);
      generate ("cpp11_shared_ptr_template_upcast.i",         use_CPP => True);
      generate ("cpp11_std_function.i",                       use_CPP => True);
      generate ("cpp11_std_unique_ptr.i",                     use_CPP => True);
      generate ("cpp11_template_pack.i",                      use_CPP => True);
      generate ("cpp11_template_pack_specialization.i",       use_CPP => True);
      generate ("cpp11_template_parameters_decltype.i",       use_CPP => True);
      generate ("cpp11_template_templated_methods.i",         use_CPP => True);
      generate ("cpp11_template_using_base.i",                use_CPP => True);
      generate ("cpp11_using_constructor.i",                  use_CPP => True);
      generate ("cpp11_using_functor.i",                      use_CPP => True);
      generate ("cpp11_using_member_template.i",              use_CPP => True);
      generate ("cpp11_using_typedef_struct.i",               use_CPP => True);
      generate ("cpp11_using_typedef_template_member.i",      use_CPP => True);
      generate ("cpp11_variadic_function_templates.i",        use_CPP => True);
      generate ("cpp14_auto_return_type.i",                   use_CPP => True);
      generate ("cpp14_generic_lambda.i",                     use_CPP => True);
      generate ("cpp14_variable_templates.i",                 use_CPP => True);
      generate ("cpp17_class_template_argument_deduction.i",  use_CPP => True);
      generate ("cpp17_director_string_view.i",               use_CPP => True);
      generate ("cpp17_enable_if_t.i",                        use_CPP => True);
      generate ("cpp17_inheriting_constructors_pack.i",       use_CPP => True);
      generate ("cpp17_map_no_default_ctor.i",                use_CPP => True);
      generate ("cpp17_string_view.i",                        use_CPP => True);
      generate ("cpp17_using_pack_alias_template.i",          use_CPP => True);
      generate ("cpp17_using_pack_expansion.i",               use_CPP => True);
      generate ("cpp17_using_typename_pack.i",                use_CPP => True);
      generate ("cpp20_abbreviated_template.i",               use_CPP => True);
      generate ("cpp20_abbreviated_template_decorated.i",     use_CPP => True);
      generate ("cpp20_abbreviated_template_mixed.i",         use_CPP => True);
      generate ("cpp20_alias_template.i",                     use_CPP => True);
      generate ("cpp20_concepts.i",                           use_CPP => True);
      generate ("cpp20_concepts_class_methods.i",             use_CPP => True);
      generate ("cpp20_concepts_classes.i",                   use_CPP => True);
      generate ("cpp20_concepts_constrained_param.i",         use_CPP => True);
      generate ("cpp20_concepts_extra.i",                     use_CPP => True);
      generate ("cpp20_concepts_lambda.i",                    use_CPP => True);
      generate ("cpp20_concepts_overloads.i",                 use_CPP => True);
      generate ("cpp20_constexpr_destructor.i",               use_CPP => True);
      generate ("cpp20_lambda_template.i",                    use_CPP => True);
      generate ("cpp20_spaceship_operator.i",                 use_CPP => True);
      generate ("cpp20_variable_templates.i",                 use_CPP => True);
      generate ("cpp_parameters.i",                           use_CPP => True);
      generate ("director_binary_string_rev_len.i",           use_CPP => True);
      generate ("director_comparison_operators.i",            use_CPP => True);
      generate ("director_conversion_operators.i",            use_CPP => True);
      generate ("director_langobj.i",                         use_CPP => True);
      generate ("director_minimal.i",                         use_CPP => True);
      generate ("director_multiple_inheritance.i",            use_CPP => True);
      generate ("director_shared_ptr.i",                      use_CPP => True);
      generate ("director_simple.i",                          use_CPP => True);
      generate ("director_template.i",                        use_CPP => True);
      generate ("director_unwrap_result.i",                   use_CPP => True);
      generate ("director_using_member_scopes.i",             use_CPP => True);
      generate ("doxygen_autodoc_docstring.i",                use_CPP => True);
      generate ("doxygen_basic_translate_style2.i",           use_CPP => True);
      generate ("doxygen_basic_translate_style3.i",           use_CPP => True);
      generate ("doxygen_code_blocks.i",                      use_CPP => True);
      generate ("doxygen_constructors.i",                     use_CPP => True);
      generate ("doxygen_interface.i",                        use_CPP => True);
      generate ("doxygen_overloads.i",                        use_CPP => True);
      generate ("duplicate_class_name_in_ns.i",               use_CPP => True);
      generate ("duplicate_parm_names.i",                     use_CPP => True);
      generate ("exception_memory_leak.i",                    use_CPP => True);
      generate ("friends_nested.i",                           use_CPP => True);
      generate ("friends_operator_overloading.i",             use_CPP => True);
      generate ("global_immutable_vars_cpp.i",                use_CPP => True);
      generate ("injecting_base_class.i",                     use_CPP => True);
      generate ("inout_typemaps.i",                           use_CPP => True);
      generate ("li_cdata_bytes_cpp.i",                       use_CPP => True);
      generate ("li_std_containers_overload.i",               use_CPP => True);
      generate ("li_std_vector_vector.i",                     use_CPP => True);
      generate ("multiple_inheritance_overload.i",            use_CPP => True);
      generate ("namespace_struct.i",                         use_CPP => True);
      generate ("nested_inheritance_interface.i",             use_CPP => True);
      generate ("nested_scope_flat.i",                        use_CPP => True);
      generate ("nspace_interface.i",                         use_CPP => True);
      generate ("nspacemove.i",                               use_CPP => True);
      generate ("nspacemove_nested.i",                        use_CPP => True);
      generate ("nspacemove_stl.i",                           use_CPP => True);
      generate ("numeric_bounds_checking.i",                  use_CPP => True);
      generate ("preproc_cpp.i",                              use_CPP => True);
      generate ("preproc_predefined_stdcpp.i",                use_CPP => True,   Options => "-std=c++23");
      generate ("template_advanced_rename.i",                 use_CPP => True);
      generate ("template_duplicate.i",                       use_CPP => True);
      generate ("template_function_parm.i",                   use_CPP => True);
      generate ("template_nested_flat.i",                     use_CPP => True);
      generate ("template_partial_specialization_more.i",     use_CPP => True);
      generate ("template_specialization_using_declaration.i",use_CPP => True);
      generate ("template_template_template_parameters.i",    use_CPP => True);
      generate ("template_type_collapse.i",                   use_CPP => True);
      generate ("template_using_member_default_arg.i",        use_CPP => True);
      generate ("typedef_inherit_using.i",                    use_CPP => True);
      generate ("typemap_isvoid.i",                           use_CPP => True);
      generate ("typemap_string_alloc.i",                     use_CPP => True);
      generate ("using_duplicates.i",                         use_CPP => True);
      generate ("using_extend_flatten.i",                     use_CPP => True);
      generate ("using_member.i",                             use_CPP => True);
      generate ("using_member_multiple_inherit.i",            use_CPP => True);
      generate ("using_member_scopes.i",                      use_CPP => True);
      generate ("using_member_typedef.i",                     use_CPP => True);
      generate ("using_member_typedef_overload.i",            use_CPP => True);
      generate ("using_member_typedef_template.i",            use_CPP => True);
      generate ("using_method_typedefs.i",                    use_CPP => True);
      generate ("using_nested_member_typedef.i",              use_CPP => True);
   end if;


   ---------------------------------------------
   --- Older cases, which were not run until now
   --
   --  The cases of upstream's lists which were in SWIG 4.0.0, and had not been added to this launcher.
   --  One which is commented out fails, for the reason which is given with it.
   --
   if do_Older
   then
      new_Line;
      new_Line;
      put_Line ("Generating the older C tests.");
      new_Line;

      generate ("bom_utf8.i");
      generate ("c_delete.i");
      generate ("c_delete_function.i");
      generate ("default_args_c.i");
      generate ("empty_c.i");
      generate ("enum_forward.i");
      generate ("enum_macro.i");
      generate ("enum_missing.i");
      generate ("global_functions.i");
      generate ("infinity.i");
      generate ("keyword_rename_c.i");
      generate ("memberin_extend_c.i");
      generate ("nested_extend_c.i");
      generate ("nested_structs.i");
      generate ("overload_extend2.i");
      generate ("overload_extend_c.i");
      generate ("preproc_constants_c.i");
      generate ("preproc_defined.i");
      generate ("preproc_gcc_output.i");
      generate ("preproc_include.i");
      generate ("preproc_line_file.i");
      generate ("simple_array.i");
      generate ("string_simple.i");
      generate ("struct_initialization.i");
      generate ("typedef_classforward_same_name.i");
      generate ("union_parameter.i");

      new_Line;
      new_Line;
      put_Line ("Generating the older C++ tests.");
      new_Line;

      generate ("allprotected_not.i",                         use_CPP => True);
      generate ("argcargvtest.i",                             use_CPP => True);
      generate ("autodoc.i",                                  use_CPP => True);
      generate ("catches.i",                                  use_CPP => True);
      generate ("char_binary.i",                              use_CPP => True);
      generate ("chartest.i",                                 use_CPP => True);
      generate ("class_forward.i",                            use_CPP => True);
      --  generate ("class_scope_namespace.i",                use_CPP => True);     -- Spec: a class has the name of an opaque type of the top package.
      generate ("constant_directive.i",                       use_CPP => True);
      generate ("constant_expr.i",                            use_CPP => True);
      generate ("constructor_rename.i",                       use_CPP => True);
      generate ("conversion_operators.i",                     use_CPP => True);
      generate ("cpp11_alias_nested_template_scoping.i",      use_CPP => True);
      generate ("cpp11_alignment.i",                          use_CPP => True);
      generate ("cpp11_alternate_function_syntax.i",          use_CPP => True);
      generate ("cpp11_constexpr.i",                          use_CPP => True);
      generate ("cpp11_decltype.i",                           use_CPP => True);
      generate ("cpp11_default_delete.i",                     use_CPP => True);
      generate ("cpp11_delegating_constructors.i",            use_CPP => True);
      generate ("cpp11_director_enums.i",                     use_CPP => True);
      generate ("cpp11_directors.i",                          use_CPP => True);
      generate ("cpp11_explicit_conversion_operators.i",      use_CPP => True);
      generate ("cpp11_final_directors.i",                    use_CPP => True);
      generate ("cpp11_final_override.i",                     use_CPP => True);
      generate ("cpp11_function_objects.i",                   use_CPP => True);
      generate ("cpp11_inheriting_constructors.i",            use_CPP => True);
      generate ("cpp11_initializer_list.i",                   use_CPP => True);
      generate ("cpp11_initializer_list_extend.i",            use_CPP => True);
      generate ("cpp11_lambda_functions.i",                   use_CPP => True);
      generate ("cpp11_noexcept.i",                           use_CPP => True);
      generate ("cpp11_null_pointer_constant.i",              use_CPP => True);
      generate ("cpp11_raw_string_literals.i",                use_CPP => True);
      generate ("cpp11_ref_qualifiers.i",                     use_CPP => True);
      generate ("cpp11_ref_qualifiers_rvalue_unignore.i",     use_CPP => True);
      generate ("cpp11_ref_qualifiers_typemaps.i",            use_CPP => True);
      generate ("cpp11_result_of.i",                          use_CPP => True);
      generate ("cpp11_rvalue_reference.i",                   use_CPP => True);
      generate ("cpp11_rvalue_reference2.i",                  use_CPP => True);
      generate ("cpp11_rvalue_reference3.i",                  use_CPP => True);
      generate ("cpp11_shared_ptr_const.i",                   use_CPP => True);
      generate ("cpp11_shared_ptr_nullptr_in_containers.i",   use_CPP => True);
      generate ("cpp11_shared_ptr_overload.i",                use_CPP => True);
      generate ("cpp11_shared_ptr_upcast.i",                  use_CPP => True);
      generate ("cpp11_sizeof_object.i",                      use_CPP => True);
      generate ("cpp11_static_assert.i",                      use_CPP => True);
      generate ("cpp11_std_array.i",                          use_CPP => True);
      generate ("cpp11_strongly_typed_enumerations.i",        use_CPP => True);
      generate ("cpp11_template_double_brackets.i",           use_CPP => True);
      generate ("cpp11_template_explicit.i",                  use_CPP => True);
      generate ("cpp11_template_typedefs.i",                  use_CPP => True);
      generate ("cpp11_thread_local.i",                       use_CPP => True);
      generate ("cpp11_type_aliasing.i",                      use_CPP => True);
      generate ("cpp11_type_traits.i",                        use_CPP => True);
      --  generate ("cpp11_uniform_initialization.i",         use_CPP => True);     -- Spec: an array variable of two dimensions, the first unknown.
      generate ("cpp11_unrestricted_unions.i",                use_CPP => True);
      generate ("cpp11_userdefined_literals.i",               use_CPP => True);
      generate ("cpp11_variadic_templates.i",                 use_CPP => True);
      generate ("cpp14_binary_integer_literals.i",            use_CPP => True);
      generate ("cpp17_hex_floating_literals.i",              use_CPP => True);
      generate ("cpp17_nested_namespaces.i",                  use_CPP => True);
      generate ("cpp17_nspace_nested_namespaces.i",           use_CPP => True);
      generate ("cpp17_u8_char_literals.i",                   use_CPP => True);
      generate ("curiously_recurring_template_pattern.i",     use_CPP => True);
      generate ("default_arg_expressions.i",                  use_CPP => True);
      generate ("default_arg_values.i",                       use_CPP => True);
      generate ("destructor_methodmodifiers.i",               use_CPP => True);
      generate ("director_abstract.i",                        use_CPP => True);
      generate ("director_alternating.i",                     use_CPP => True);
      generate ("director_basic.i",                           use_CPP => True);
      generate ("director_binary_string.i",                   use_CPP => True);
      generate ("director_classes.i",                         use_CPP => True);
      generate ("director_classic.i",                         use_CPP => True);
      generate ("director_constructor.i",                     use_CPP => True);
      generate ("director_default.i",                         use_CPP => True);
      generate ("director_detect.i",                          use_CPP => True);
      generate ("director_enum.i",                            use_CPP => True);
      generate ("director_exception.i",                       use_CPP => True);
      generate ("director_exception_catches.i",               use_CPP => True);
      generate ("director_exception_nothrow.i",               use_CPP => True);
      generate ("director_extend.i",                          use_CPP => True);
      generate ("director_finalizer.i",                       use_CPP => True);
      generate ("director_frob.i",                            use_CPP => True);
      generate ("director_ignore.i",                          use_CPP => True);
      generate ("director_namespace_clash.i",                 use_CPP => True);
      generate ("director_nested.i",                          use_CPP => True);
      generate ("director_nspace.i",                          use_CPP => True);
      generate ("director_nspace_director_name_collision.i",  use_CPP => True);
      generate ("director_overload.i",                        use_CPP => True);
      generate ("director_overload2.i",                       use_CPP => True);
      generate ("director_ownership.i",                       use_CPP => True);
      generate ("director_pass_by_value.i",                   use_CPP => True);
      generate ("director_primitives.i",                      use_CPP => True);
      generate ("director_property.i",                        use_CPP => True,   check_Layout => False);     -- A class hides a member from SWIG.
      --  generate ("director_protected.i",                   use_CPP => True);     -- Generator: a name is defined twice ('Foo_s').
      generate ("director_protected_overloaded.i",            use_CPP => True);
      --  generate ("director_redefined.i",                   use_CPP => True);     -- Spec: a function is marked as overriding, and does not.
      generate ("director_ref.i",                             use_CPP => True);
      generate ("director_string.i",                          use_CPP => True);
      generate ("director_thread.i",                          use_CPP => True);
      generate ("director_unroll.i",                          use_CPP => True);
      --  generate ("director_using.i",                       use_CPP => True);     -- Wrapper: the concrete class of an abstract template instance is still abstract.
      generate ("director_void.i",                            use_CPP => True);
      generate ("director_wombat.i",                          use_CPP => True);
      generate ("doxygen_alias.i",                            use_CPP => True);
      generate ("doxygen_basic_notranslate.i",                use_CPP => True);
      generate ("doxygen_basic_translate.i",                  use_CPP => True);
      generate ("doxygen_ignore.i",                           use_CPP => True);
      generate ("doxygen_misc_constructs.i",                  use_CPP => True);
      generate ("doxygen_nested_class.i",                     use_CPP => True);
      generate ("doxygen_parsing.i",                          use_CPP => True);
      generate ("doxygen_parsing_enums.i",                    use_CPP => True);
      generate ("doxygen_translate.i",                        use_CPP => True);
      generate ("doxygen_translate_all_tags.i",               use_CPP => True);
      generate ("doxygen_translate_links.i",                  use_CPP => True);
      generate ("enum_ignore.i",                              use_CPP => True);
      generate ("enum_rename.i",                              use_CPP => True);
      generate ("equality.i",                                 use_CPP => True);
      generate ("exception_classname.i",                      use_CPP => True);
      generate ("expressions.i",                              use_CPP => True);
      generate ("extend_constructor_destructor.i",            use_CPP => True);
      generate ("extend_special_variables.i",                 use_CPP => True);
      generate ("extend_template_method.i",                   use_CPP => True);
      generate ("extend_typedef_class.i",                     use_CPP => True);
      generate ("extern_c.i",                                 use_CPP => True);
      generate ("friends_template.i",                         use_CPP => True);
      generate ("funcptr_cpp.i",                              use_CPP => True);
      generate ("functors.i",                                 use_CPP => True);
      generate ("global_namespace.i",                         use_CPP => True);
      generate ("global_scope_types.i",                       use_CPP => True);
      generate ("import_fragments.i",                         use_CPP => True);
      generate ("inherit_member.i",                           use_CPP => True);
      --  generate ("insert_directive.i",                     use_CPP => True);     -- The input includes a header which the test suite makes when it is run.
      generate ("kwargs_feature.i",                           use_CPP => True);
      generate ("li_attribute_template.i",                    use_CPP => True);
      generate ("li_boost_shared_ptr_attribute.i",            use_CPP => True);
      generate ("li_boost_shared_ptr_director.i",             use_CPP => True);
      generate ("li_boost_shared_ptr_template.i",             use_CPP => True);
      generate ("li_carrays_cpp.i",                           use_CPP => True);
      generate ("li_cdata_cpp.i",                             use_CPP => True);
      generate ("li_cpointer_cpp.i",                          use_CPP => True);
      --  generate ("li_std_auto_ptr.i",                      use_CPP => True);     -- 'std::auto_ptr', which C++17 removed, is not bound: it has neither a move constructor nor a copy constructor of a constant.
      generate ("li_std_combinations.i",                      use_CPP => True);
      generate ("li_std_except_as_class.i",                   use_CPP => True);
      --  generate ("li_std_pair_using.i",                    use_CPP => True);     -- Generator: the template 'pair' is not found through a using declaration.
      generate ("li_std_vector_back_reference.i",             use_CPP => True);
      --  generate ("li_std_vector_enum.i",                   use_CPP => True);     -- Spec: the packages of a vector and of its enumeration depend on each other.
      generate ("li_std_vector_member_var.i",                 use_CPP => True);
      --  generate ("li_std_vector_ptr.i",                    use_CPP => True);     -- Wrapper: a pointer to a reference, for a vector of pointers.
      generate ("li_swigtype_inout.i",                        use_CPP => True);
      --  generate ("li_typemaps_apply.i",                    use_CPP => True);     -- Wrapper: the typemaps of 'typemaps.i' are applied to a reference to a bool.
      generate ("member_funcptr_galore.i",                    use_CPP => True);
      generate ("member_pointer_const.i",                     use_CPP => True);
      generate ("memberin_extend.i",                          use_CPP => True);
      generate ("multiple_inheritance_abstract.i",            use_CPP => True);
      generate ("multiple_inheritance_interfaces.i",          use_CPP => True);
      generate ("multiple_inheritance_nspace.i",              use_CPP => True);
      generate ("multiple_inheritance_shared_ptr.i",          use_CPP => True);
      generate ("namespace_chase.i",                          use_CPP => True);
      generate ("namespace_forward_declaration.i",            use_CPP => True);
      generate ("native_directive.i",                         use_CPP => True);
      generate ("naturalvar_more.i",                          use_CPP => True);
      generate ("naturalvar_onoff.i",                         use_CPP => True);
      generate ("nested_class.i",                             use_CPP => True);
      generate ("nested_directors.i",                         use_CPP => True);
      generate ("nested_ignore.i",                            use_CPP => True);
      generate ("nested_in_template.i",                       use_CPP => True);
      --  generate ("nested_scope.i",                         use_CPP => True);     -- Generator: an array type is added twice to the map of Ada types.
      generate ("nested_template_base.i",                     use_CPP => True);
      generate ("nested_workaround.i",                        use_CPP => True);
      generate ("newobject3.i",                               use_CPP => True);
      generate ("nspace.i",                                   use_CPP => True);
      generate ("nspace_extend.i",                            use_CPP => True);
      generate ("operator_pointer_ref.i",                     use_CPP => True);
      generate ("operbool.i",                                 use_CPP => True);
      generate ("overload_arrays.i",                          use_CPP => True);
      generate ("overload_bool.i",                            use_CPP => True);
      generate ("overload_method.i",                          use_CPP => True);
      generate ("overload_null.i",                            use_CPP => True);
      generate ("overload_numeric.i",                         use_CPP => True);
      generate ("overload_polymorphic.i",                     use_CPP => True);
      generate ("overload_return_type.i",                     use_CPP => True);
      generate ("preproc_constants.i",                        use_CPP => True);
      generate ("proxycode.i",                                use_CPP => True);
      generate ("redefined_not.i",                            use_CPP => True);
      generate ("rename_pcre_encoder.i",                      use_CPP => True);
      generate ("rename_pcre_enum.i",                         use_CPP => True);
      generate ("rename_predicates.i",                        use_CPP => True);
      generate ("rename_rstrip_encoder.i",                    use_CPP => True);
      generate ("rename_simple.i",                            use_CPP => True);
      generate ("rename_strip_encoder.i",                     use_CPP => True);
      generate ("rename_wildcard.i",                          use_CPP => True);
      generate ("smart_pointer_const_overload.i",             use_CPP => True);
      generate ("smart_pointer_ignore.i",                     use_CPP => True);
      generate ("smart_pointer_template_const_overload.i",    use_CPP => True);
      generate ("smart_pointer_template_defaults_overload.i", use_CPP => True);
      generate ("special_variable_attributes.i",              use_CPP => True);
      --  generate ("special_variable_macros.i",              use_CPP => True);     -- Wrapper: a typemap of the input assigns a string to a class result.
      generate ("stl_no_default_constructor.i",               use_CPP => True);
      generate ("string_constants.i",                         use_CPP => True);
      generate ("struct_initialization_cpp.i",                use_CPP => True);
      generate ("swig_exception.i",                           use_CPP => True);
      generate ("symbol_clash.i",                             use_CPP => True);
      generate ("template_basic.i",                           use_CPP => True);
      generate ("template_class_reuse_name.i",                use_CPP => True);
      generate ("template_default_arg_overloaded.i",          use_CPP => True);
      generate ("template_default_arg_overloaded_extend.i",   use_CPP => True);
      generate ("template_default_arg_virtual_destructor.i",  use_CPP => True);
      --  generate ("template_default_cache.i",               use_CPP => True);     -- Generator: a name is added twice to the map of Ada types.
      generate ("template_default_class_parms_typedef.i",     use_CPP => True);
      generate ("template_empty_inherit.i",                   use_CPP => True);
      generate ("template_keyword_in_type.i",                 use_CPP => True);
      generate ("template_namespace_forward_declaration.i",   use_CPP => True);
      generate ("template_nested.i",                          use_CPP => True);
      generate ("template_nested_typemaps.i",                 use_CPP => True);
      generate ("template_parameters_global_scope.i",         use_CPP => True);
      generate ("template_partial_specialization.i",          use_CPP => True);
      --  generate ("template_partial_specialization_typedef.i",use_CPP => True);     -- Spec: a pointer to a pointer to 'unsigned' is not declared.
      generate ("template_private_assignment.i",              use_CPP => True);
      generate ("template_templated_constructors.i",          use_CPP => True);
      generate ("template_typedef_class_template.i",          use_CPP => True);
      generate ("template_typedef_inherit.i",                 use_CPP => True);
      generate ("template_typedef_typedef.i",                 use_CPP => True);
      --  generate ("template_typemaps_typedef.i",            use_CPP => True);     -- Generator: an array type is added twice to the map of Ada types.
      --  generate ("template_typemaps_typedef2.i",           use_CPP => True);     -- Generator: an array type is added twice to the map of Ada types.
      generate ("template_using_directive_and_declaration_forward.i",use_CPP => True);
      generate ("template_using_directive_typedef.i",         use_CPP => True);
      generate ("threads_exception.i",                        use_CPP => True);
      generate ("typedef_struct_cpp.i",                       use_CPP => True,   check_Layout => False);     -- A structure hides a member from SWIG ('#ifndef SWIG').
      generate ("typedef_typedef.i",                          use_CPP => True);
      --  generate ("typemap_array_qualifiers.i",             use_CPP => True);     -- Generator: a type is sought which is not in the map of C types.
      generate ("typemap_arrays.i",                           use_CPP => True);
      generate ("typemap_delete.i",                           use_CPP => True);
      --  generate ("typemap_directorout.i",                  use_CPP => True);     -- Wrapper: a typemap of the input converts from 'void*'.
      generate ("typemap_documentation.i",                    use_CPP => True);
      generate ("typemap_global_scope.i",                     use_CPP => True);
      generate ("typemap_manyargs.i",                         use_CPP => True);
      generate ("typemap_out_optimal.i",                      use_CPP => True);
      generate ("typemap_qualifier_strip.i",                  use_CPP => True);
      generate ("typemap_template.i",                         use_CPP => True);
      generate ("typemap_template_parm_typedef.i",            use_CPP => True);
      generate ("typemap_template_parms.i",                   use_CPP => True);
      generate ("typemap_template_typedef.i",                 use_CPP => True);
      generate ("unicode_strings.i",                          use_CPP => True);
      generate ("using_directive_and_declaration.i",          use_CPP => True);
      generate ("using_directive_and_declaration_forward.i",  use_CPP => True);
      generate ("using_namespace_loop.i",                     use_CPP => True);
      generate ("varargs_overload.i",                         use_CPP => True);
      generate ("variable_replacement.i",                     use_CPP => True);
      generate ("virtual_vs_nonvirtual_base.i",               use_CPP => True);
      generate ("wallkw.i",                                   use_CPP => True);

      --  The modules of the cases of several modules ('MULTI_CPP_TEST_CASES' of 'common.mk') which were not run:
      --  each imports the first of its case.
      --
      generate ("import_share_a.i",                           use_CPP => True);
      generate ("import_share_b.i",                           use_CPP => True);
      generate ("import_share_c.i",                           use_CPP => True);
      generate ("import_stl_a.i",                             use_CPP => True);
      generate ("import_stl_b.i",                             use_CPP => True);
      generate ("import_stl_c.i",                             use_CPP => True);
      generate ("packageoption_c.i",                          use_CPP => True);
   end if;


   -----------------
   --- Compile check
   --
   if check_Specs
   then
      compile_all_Specs;
   end if;


   ------------
   --- Baseline
   --
   if check_Baseline
   then
      check_against_Baseline;
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
      run ("moves");               -- Objects which are moved and not copied, and a pointer which owns its object.
      run ("in_namespace",         -- The packages of a binding within another package.
           Options => "-namespace outer");
      run ("warnings");            -- The warnings of the Ada module, by number, place and filter.
      run ("library");             -- Further classes of the standard library: a multiset, a multimap, a complex number, a wide string, the streams.
      run ("library_c",            -- Further library files, in C: parameters which are input or output, the arguments of a program, a file, raw data.
           use_CPP => False);

      --  Cases of upstream's suite, each with a tester written after upstream's test of it for Python.
      --
      new_Line;
      run_Upstream ("using_inherit");             -- Overloads which a derived class redefines, and those of its base.
      run_Upstream ("ret_by_value");              -- A structure which is returned by value.
      run_Upstream ("return_const_value");        -- A smart pointer which is returned by value, and as a constant.
      run_Upstream ("typedef_scope");             -- A typedef of a class with the name of one outside it.
      run_Upstream ("struct_initialization");     -- Variables which are declared with their structure.
      run_Upstream ("constover");                 -- Functions which are overloaded on what is constant.
      run_Upstream ("global_vars");               -- Global variables: a string, a reference, a pointer.
      run_Upstream ("cpp_enum");                  -- Enumerations of no name, and values which are casts.
      run_Upstream ("smart_pointer_member");      -- The members of a class, through a smart pointer.
      run_Upstream ("cpp_static");                -- Static member functions and variables.
      run_Upstream ("primitive_ref");             -- A reference to each primitive type.
      run_Upstream ("virtual_poly");              -- Virtual functions whose result is covariant.
      run_Upstream ("template_inherit");          -- A class template which is derived from another, with virtual functions.
      run_Upstream ("typedef_inherit");           -- Classes derived from a base which a typedef names.
      run_Upstream ("unions");                    -- A union which is a member of a structure.
      run_Upstream ("varargs");                   -- Functions and constructors of a variable number of arguments.
      run_Upstream ("operator_overload");         -- The operators of C++, as members and as friends.
      run_Upstream ("cpp_namespace");             -- Namespaces, and 'using' declarations and directives.
      run_Upstream ("voidtest");                  -- Functions which return nothing, and pointers to 'void'.
   end if;


   --------------
   --- Unit tests
   --
   if do_Units
   then
      new_Line;
      run_Unit ("layout");          -- The layout engine: the place of each member of a class or structure.
      run_Unit ("expressions");     -- The value of a C expression, against the value which a C compiler gives.
      run_Unit ("mangling");        -- The symbol of a C++ entity, against the symbol which a C++ compiler gives.

      check_the_layout_Assertions;
      check_the_Bootstrap;

      if do_C and do_Cxx     -- The symbols are those of the wrappers of the cases.
      then
         check_the_imported_Symbols;

         --  The cases are compiled, and so a spec is only checked for its meaning. './check_links' builds, links and
         --  runs a program for each case which 'with's every spec of it, with the object of its wrapper (which the
         --  check above has made): whatever a spec refers to must then be there.
         --
         run_Step ("that the specs of each case build and link", "./check_links");
      end if;
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

   --  cBound is the one user of the tool which is at hand, and a change which breaks one of its bindings is best seen
   --  before the tool is installed. './check_cbound' generates each binding of a copy of it again, with the tool as it
   --  is built, and runs cBound's own checks. What is then generated differently is listed, and is no failure.
   --
   if do_cBound
   then
      new_Line;
      run_Step ("that cBound works with the tool", "./check_cbound");

      if ada.Directories.exists ("unit-build/that cBound works with the tool.log")
      then
         declare
            the_Log : constant String  := Contents ("unit-build/that cBound works with the tool.log");
            First   : constant Natural := ada.Strings.fixed.Index (the_Log, "Files of cBound which are generated differently");
         begin
            if First /= 0
            then
               put (the_Log (First .. the_Log'Last));
               new_Line;
            end if;
         end;
      end if;
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

   if has_Baseline
   then
      put_Line ("Files which differ from the baseline:" & baseline_Changes'Image);
   end if;

   put_Line ("Run-time cases:               " & runtime_Cases   'Image);
   put_Line ("Run-time cases which fail:    " & runtime_Failures'Image);
   put_Line ("Unit tests:                   " & unit_Count      'Image);
   put_Line ("Unit tests which fail:        " & unit_Failures   'Image);
   put_Line ("Examples:                     " & example_Count   'Image);
   put_Line ("Examples which fail:          " & example_Failures'Image);

   new_Line;

   note_the_Run (Failures => generator_Failures + syntax_Failures + wrapper_Failures + compile_Failures + runtime_Failures + unit_Failures + example_Failures,
                 is_Whole => do_C and do_Cxx and do_Newer and do_Older and do_Units and do_Examples and check_Baseline);

   if generator_Failures + syntax_Failures + wrapper_Failures + compile_Failures + runtime_Failures + unit_Failures + example_Failures + baseline_Changes = 0
   then
      put_Line ("Complete.");
   else
      put_Line ("Testsuite failed !");
      ada.Command_Line.set_exit_Status (ada.Command_Line.Failure);
   end if;
end launch_testsuite;
