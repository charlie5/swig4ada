with
     ada.Containers.indefinite_hashed_Maps,
     ada.Strings.Hash,
     ada.Characters.handling;

separate (ada_Language)


overriding
function top (Self : access Item;
              N    : in     Node_Pointer) return C.int
is
   the_Node     :          Node_Pointer renames N;
   module_Name  : constant unbounded_String := +Attribute (the_Node, "name");


   procedure name_the_nested_Classes
   --
   --  A class which is nested in another is moved out beside it by the core, under its own name. Two classes may
   --  each have a nested class of one name ('Outer::Inner' and 'Other::Inner'), which cannot both be the package
   --  'Inner'. So a nested class whose name is taken is named after the class which holds it as well ('Other_Inner').
   --  This is done before the tree is walked, so that the functions of its wrapper are named after it too.
   --
   is
      package name_Maps is new ada.Containers.indefinite_hashed_Maps (String, String, ada.Strings.Hash, "=");

      bound_Names : name_Maps.Map;     -- The name which each class is bound by, by its name in C++.
      taken_Names : name_Maps.Map;     -- The names which are taken, in lower case, as two packages may not differ in case alone.

      function is_a_Class (the_Node : in Node_Pointer) return Boolean
      is (Attribute (the_Node, "nodeType") = "class" and then Attribute (the_Node, "sym:name") /= "");

      function is_Nested (the_Node : in Node_Pointer) return Boolean
      is (Attribute (the_Node, "nested") /= "");

      procedure note_the_Classes (Parent : in Node_Pointer)
      is
         the_Child : Node_Pointer := first_Child (Parent);
      begin
         while the_Child /= null
         loop
            if is_a_Class (the_Child)
            then
               bound_Names.include (Attribute (the_Child, "name"), Attribute (the_Child, "sym:name"));

               if not is_Nested (the_Child)
               then
                  taken_Names.include (ada.Characters.handling.to_Lower (Attribute (the_Child, "sym:name")), "");
               end if;
            end if;

            if Attribute (the_Child, "nodeType") /= "template"     -- A class within a template is seen again in each instance of it.
            then
               note_the_Classes (the_Child);
            end if;

            the_Child := next_Sibling (the_Child);
         end loop;
      end note_the_Classes;

      procedure name_the_nested_Ones (Parent : in Node_Pointer)
      is
         the_Child : Node_Pointer := first_Child (Parent);
      begin
         while the_Child /= null
         loop
            if         is_a_Class (the_Child)
              and then is_Nested  (the_Child)
            then
               declare
                  its_Name : constant String  := Attribute (the_Child, "sym:name");
                  cpp_Name : constant String  := Attribute (the_Child, "name");
                  Colons   : constant Natural := ada.Strings.fixed.Index (cpp_Name, "::", Going => ada.Strings.Backward);
               begin
                  if taken_Names.contains (ada.Characters.handling.to_Lower (its_Name))
                  then
                     if         Colons > cpp_Name'First
                       and then bound_Names.contains (cpp_Name (cpp_Name'First .. Colons - 1))
                     then
                        declare
                           new_Name : constant String := bound_Names.Element (cpp_Name (cpp_Name'First .. Colons - 1)) & "_" & its_Name;
                        begin
                           set_Attribute (doh_Node (the_Child), "sym:name", new_Name);
                           bound_Names.include (cpp_Name, new_Name);
                           taken_Names.include (ada.Characters.handling.to_Lower (new_Name), "");
                        end;
                     end if;
                  else
                     taken_Names.include (ada.Characters.handling.to_Lower (its_Name), "");
                  end if;
               end;
            end if;

            if Attribute (the_Child, "nodeType") /= "template"
            then
               name_the_nested_Ones (the_Child);
            end if;

            the_Child := next_Sibling (the_Child);
         end loop;
      end name_the_nested_Ones;

   begin
      note_the_Classes     (the_Node);
      name_the_nested_Ones (the_Node);
   end name_the_nested_Classes;

   procedure keep_the_Shape (of_Class : in Node_Pointer)
   --
   --  Binds a class which the core does not hand on for its shape alone: it is no longer ignored, and each of its
   --  members is, but for its virtual functions. A member variable which is ignored is storage ('<member>_storage',
   --  see 'add_hidden_Members'), a virtual function has its place and may be overridden, and nothing else of the class
   --  is bound.
   --
   is
      the_Child : Node_Pointer := first_Child (of_Class);
      Unused    : C.int with Unreferenced;
   begin
      Unused := DohDelattr (DOH_Pointer (of_Class), DOH_Pointer (to_Doh ("feature:ignore")));
      set_Attribute (doh_Node (of_Class), "ada:shape_only", "1");

      while the_Child /= null
      loop
         declare
            Kind       : constant String  := Attribute (the_Child, "nodeType");
            is_Virtual : constant Boolean := ada.Strings.fixed.Index (Attribute (the_Child, "storage"), "virtual") /= 0;
         begin
            if        (Kind in "cdecl" | "destructor" and then not is_Virtual)
              or else  Kind in "constructor" | "using" | "template"
            then
               set_Attribute (doh_Node (the_Child), "feature:ignore", "1");
            end if;
         end;

         the_Child := next_Sibling (the_Child);
      end loop;
   end keep_the_Shape;



   procedure keep_the_shape_of_hidden_nested_Classes
   --
   --  A class which is nested in another, and is not public, is ignored by the core when it moves it out of the class
   --  (nested classes being flattened for Ada). A member of the outer class whose type it is was then of a type which
   --  is not known, and was left out: the record of the outer class was smaller than its class (jsoncpp's 'Value',
   --  with a member of its private 'Comments'), so that its constructor wrote beyond an object which Ada declared. Such
   --  a class is bound for its shape alone, as an ignored base class is. This is done before the tree is walked.
   --
   is
      procedure walk (Parent : in Node_Pointer)
      is
         the_Child : Node_Pointer := first_Child (Parent);
      begin
         while the_Child /= null
         loop
            if         Attribute (the_Child, "nodeType") = "class"
              and then Attribute (the_Child, "nested") /= ""
              and then Attribute (the_Child, "feature:ignore") /= ""
              and then Attribute (the_Child, "access") in "private" | "protected"
              and then Attribute (the_Child, "templatetype") = ""
            then
               if Attribute (the_Child, "sym:name") = ""
               then   -- A class which is ignored is given no name to be bound by: it takes its own, less its scope.
                  declare
                     its_Name : constant String  := Attribute (the_Child, "name");
                     Colons   : constant Natural := ada.Strings.fixed.Index (its_Name, "::", Going => ada.Strings.Backward);
                  begin
                     set_Attribute (doh_Node (the_Child), "sym:name", (if Colons = 0 then its_Name else its_Name (Colons + 2 .. its_Name'Last)));
                  end;
               end if;

               keep_the_Shape (the_Child);
            end if;

            if Attribute (the_Child, "nodeType") /= "template"
            then
               walk (the_Child);
            end if;

            the_Child := next_Sibling (the_Child);
         end loop;
      end walk;

   begin
      if Self.in_cpp_Mode
      then
         walk (the_Node);
      end if;
   end keep_the_shape_of_hidden_nested_Classes;



   procedure keep_the_shape_of_ignored_Bases
   --
   --  A class which the interface file ignores ('%ignore Base;') is not handed on by the core. Where a class which is
   --  bound is derived from it, that class would lose the members and the virtual functions of its base: its record
   --  would be too small, and its virtual functions out of their places. So such a base class is bound for its shape
   --  alone. It is no longer ignored, and each of its members is, but for its virtual functions: a member variable
   --  which is ignored is storage ('<member>_storage', see 'add_hidden_Members'), a virtual function has its place
   --  and may be overridden, and nothing else of the class is bound. This is done before the tree is walked.
   --
   is
      use type C.int;

      function is_Ignored (the_Node : in Node_Pointer) return Boolean
      is (Attribute (the_Node, "feature:ignore") /= "");


      procedure look_at (the_Class : in Node_Pointer)
      --
      --  Keeps the shape of each ignored base class of a class which is bound, and of the bases of those in turn.
      --
      is
         base_List : constant doh_List := doh_List (get_Attribute (the_Class, "allbases"));
      begin
         if get_Attribute (the_Class, "allbases") = null
         then
            return;
         end if;

         for Each in 1 .. DohLen (base_List)
         loop
            declare
               the_Base : constant Node_Pointer := Node_Pointer (DohGetitem (base_List, Each - 1));
            begin
               if         the_Base /= null
                 and then Attribute (the_Base, "nodeType") = "class"
                 and then is_Ignored (the_Base)
                 and then ada.Strings.fixed.Index (Attribute (the_Base, "name"), "std::") /= 1     -- A class of the standard library is declared
               then                                                                                -- by a library file, which does not show its members.
                  if Attribute (the_Base, "sym:name") = ""
                  then   -- A class which is ignored is given no name to be bound by: it takes its own, less its scope.
                     declare
                        its_Name : constant String  := Attribute (the_Base, "name");
                        Colons   : constant Natural := ada.Strings.fixed.Index (its_Name, "::", Going => ada.Strings.Backward);
                     begin
                        set_Attribute (doh_Node (the_Base), "sym:name", (if Colons = 0 then its_Name else its_Name (Colons + 2 .. its_Name'Last)));
                     end;
                  end if;

                  keep_the_Shape (the_Base);
                  look_at        (the_Base);
               end if;
            end;
         end loop;
      end look_at;

      procedure walk (Parent : in Node_Pointer)
      is
         the_Child : Node_Pointer := first_Child (Parent);
      begin
         while the_Child /= null
         loop
            if         Attribute (the_Child, "nodeType") = "class"
              and then not is_Ignored (the_Child)
            then
               look_at (the_Child);
            end if;

            if Attribute (the_Child, "nodeType") /= "template"
            then
               walk (the_Child);
            end if;

            the_Child := next_Sibling (the_Child);
         end loop;
      end walk;

   begin
      if Self.in_cpp_Mode
      then
         walk (the_Node);
      end if;
   end keep_the_shape_of_ignored_Bases;



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

   keep_the_shape_of_ignored_Bases;
   keep_the_shape_of_hidden_nested_Classes;
   name_the_nested_Classes;

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
