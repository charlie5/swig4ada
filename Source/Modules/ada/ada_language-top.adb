separate (ada_Language)


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
   Self.Module_top.define (module_Name, (if ada_Package."=" (Self.Package_namespace, null) then Self.Package_standard
                                                                          else Self.Package_namespace));

   --  Print the SWIG banner message.
   --
   swig_Banner (Self.f_Runtime);

   --  The version of swig and the symbol of the target language ('SWIGADA'), which the wrapper of each language defines.
   --
   declare
      the_Language : interfaces.C.Strings.chars_ptr := interfaces.C.Strings.new_String ("ADA");
   begin
      Swig_obligatory_macros (swig_Core.Pointers.String_Pointer (Self.f_Runtime), the_Language);
      interfaces.C.Strings.free (the_Language);
   end;

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

   Logger.locate (File => Attribute (the_Node, "inputfile"),     -- A warning of the steps which follow, which is
                  Line => 1);                                    -- about no declaration, names the interface file.

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

   --  'std::string' is a type of the support package 'swig.std_Strings', which imports functions of the wrapper. They
   --  are a fragment of the library ('ada.swg'), which 'std_string.i' asks for. A spec may need the package where
   --  that file is not included (a class with a member which is a string, say), so it is asked for here too.
   --
   if Self.uses_std_Strings
   then
      Swig_fragment_emit (to_Doh ("SwigAdaStdString"));
   end if;

   declare
      the_Checks : constant String := ada_Language.source_Generator.layout_Checks (Self);
   begin
      if the_Checks /= ""
      then
         print_to (DOH_Pointer (Self.f_Ada), the_Checks);     -- Which is outside the 'extern "C"' of that section.
      end if;
   end;

   --  Declare each type descriptor of the swig runtime which the wrapper names (see 'adahead.swg').
   --
   declare
      the_Text  : constant String := String'(+DOH_Pointer (Self.f_Wrappers)) & String'(+DOH_Pointer (Self.f_Ada));
      the_Mark  : constant String := "SWIGTYPE_";
      Declared  : namespace_Sets.Set;
      First     : Natural := the_Text'First;
      Last      : Natural;
   begin
      loop
         First := ada.Strings.fixed.Index (the_Text, the_Mark, from => First);
         exit when First = 0;

         Last := First + the_Mark'Length - 1;

         while      Last < the_Text'Last
           and then the_Text (Last + 1) in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_'
         loop
            Last := Last + 1;
         end loop;

         if         Last > First + the_Mark'Length - 1
           and then (First = the_Text'First or else the_Text (First - 1) not in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_')
           and then not Declared.contains (+the_Text (First .. Last))
         then
            Declared.insert (+the_Text (First .. Last));

            declare
               the_Name : constant String := the_Text (First + the_Mark'Length .. Last);
            begin
               print_to (DOH_Pointer (Self.f_Header),   "static swig_type_info _swigt__" & the_Name & " = { """ & the_Name & """ };" & NL
                                                      & "#define SWIGTYPE_" & the_Name & " (&_swigt__" & the_Name & ")"            & NL);
            end;
         end if;

         First := Last + 1;
         exit when First > the_Text'Last;
      end loop;
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
